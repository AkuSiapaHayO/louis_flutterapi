part of 'pages.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  late HomeViewmodel homeViewmodel;
  final weightController = TextEditingController();

  dynamic selectedOriginProvince;
  dynamic selectedDestinationProvince;
  dynamic selectedOriginCity;
  dynamic selectedDestinationCity;
  String? selectedCourier;
  List<String> couriers = ['jne', 'pos', 'tiki'];

  @override
  void initState() {
    super.initState();
    homeViewmodel = HomeViewmodel();
    homeViewmodel.fetchProvinceList();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => homeViewmodel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculate Shipping Cost'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDropdownSection(
                title: 'Origin',
                selectedProvince: selectedOriginProvince,
                selectedCity: selectedOriginCity,
                onProvinceChanged: (newValue) {
                  setState(() {
                    selectedOriginProvince = newValue;
                    selectedOriginCity = null;
                    homeViewmodel.fetchOriginCityList(selectedOriginProvince!.provinceId);
                  });
                },
                onCityChanged: (newValue) {
                  setState(() {
                    selectedOriginCity = newValue;
                  });
                },
                cityList: homeViewmodel.originCityList,
              ),
              const SizedBox(height: 20),
              _buildDropdownSection(
                title: 'Destination',
                selectedProvince: selectedDestinationProvince,
                selectedCity: selectedDestinationCity,
                onProvinceChanged: (newValue) {
                  setState(() {
                    selectedDestinationProvince = newValue;
                    selectedDestinationCity = null;
                    homeViewmodel.fetchDestinationCityList(selectedDestinationProvince!.provinceId);
                  });
                },
                onCityChanged: (newValue) {
                  setState(() {
                    selectedDestinationCity = newValue;
                  });
                },
                cityList: homeViewmodel.destinationCityList,
              ),
              const SizedBox(height: 20),
              _buildWeightAndCourierSection(),
              const SizedBox(height: 20),
              _buildCalculateButton(),
              const SizedBox(height: 20),
              _buildResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required dynamic selectedProvince,
    required dynamic selectedCity,
    required Function(dynamic) onProvinceChanged,
    required Function(dynamic) onCityChanged,
    required ApiResponse<List<City>> cityList,
  }) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title Province',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProvinceDropdown(
              selectedProvince: selectedProvince,
              provinceList: viewModel.provinceList,
              onChanged: onProvinceChanged,
            ),
            const SizedBox(height: 10),
            if (selectedProvince != null) ...[
              Text(
                '$title City',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildCityDropdown(
                selectedCity: selectedCity,
                cityList: cityList,
                onChanged: onCityChanged,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProvinceDropdown({
    required dynamic selectedProvince,
    required ApiResponse<List<Province>> provinceList,
    required Function(dynamic) onChanged,
  }) {
    if (provinceList.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provinceList.status == Status.error) {
      return Center(child: Text(provinceList.message ?? 'Error loading provinces'));
    } else if (provinceList.status == Status.completed) {
      return DropdownButton<dynamic>(
        isExpanded: true,
        value: selectedProvince,
        hint: const Text('Select Province'),
        items: provinceList.data!.map((province) {
          return DropdownMenuItem(
            value: province,
            child: Text(province.province ?? ''),
          );
        }).toList(),
        onChanged: onChanged,
      );
    }
    return Container();
  }

  Widget _buildCityDropdown({
    required dynamic selectedCity,
    required ApiResponse<List<City>> cityList,
    required Function(dynamic) onChanged,
  }) {
    if (cityList.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (cityList.status == Status.error) {
      return Center(child: Text(cityList.message ?? 'Error loading cities'));
    } else if (cityList.status == Status.completed) {
      return DropdownButton<dynamic>(
        isExpanded: true,
        value: selectedCity,
        hint: const Text('Select City'),
        items: cityList.data!.map((city) {
          return DropdownMenuItem(
            value: city,
            child: Text('${city.cityName} (${city.type})'),
          );
        }).toList(),
        onChanged: onChanged,
      );
    }
    return Container();
  }

  Widget _buildWeightAndCourierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight (in grams)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter weight',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Courier',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedCourier,
          hint: const Text('Select Courier'),
          items: couriers.map((courier) {
            return DropdownMenuItem(
              value: courier,
              child: Text(courier.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCourier = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    final canCalculate = selectedOriginCity != null &&
        selectedDestinationCity != null &&
        selectedCourier != null &&
        weightController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: canCalculate
          ? () {
              homeViewmodel.calculateCost(
                origin: selectedOriginCity!.cityId,
                destination: selectedDestinationCity!.cityId,
                weight: int.parse(weightController.text),
                courier: selectedCourier!,
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canCalculate ? Colors.blue : Colors.grey,
      ),
      child: const Text('Calculate Cost'),
    );
  }

  Widget _buildResultSection() {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, _) {
        if (viewModel.costResult.status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.costResult.status == Status.error) {
          return Center(child: Text(viewModel.costResult.message ?? 'Error fetching cost'));
        } else if (viewModel.costResult.status == Status.completed) {
          final costs = viewModel.costResult.data?.costs;
          if (costs != null && costs.isNotEmpty) {
            return Column(
              children: costs.map((cost) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(cost.service ?? ''),
                    subtitle: Text('Estimation: ${cost.cost?[0].etd ?? '-'} days'),
                    trailing: Text('Rp ${cost.cost?[0].value ?? 0}'),
                  ),
                );
              }).toList(),
            );
          }
          return const Center(child: Text('No cost data available.'));
        }
        return Container();
      },
    );
  }
}