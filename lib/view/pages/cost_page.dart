part of 'pages.dart';

class ShippingCostPage extends StatefulWidget {
  const ShippingCostPage({super.key});

  @override
  State<ShippingCostPage> createState() => _ShippingCostPageState();
}

class _ShippingCostPageState extends State<ShippingCostPage> {
  late HomeViewmodel _viewModel;
  final _weightController = TextEditingController();

  dynamic _selectedOriginProvince;
  dynamic _selectedDestinationProvince;
  dynamic _selectedOriginCity;
  dynamic _selectedDestinationCity;
  String? _selectedCourier;
  final List<String> _availableCouriers = ['jne', 'pos', 'tiki'];

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewmodel();
    _viewModel.fetchProvinceList();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shipping Cost Calculator'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildLocationSelector(
                label: 'Origin',
                selectedProvince: _selectedOriginProvince,
                selectedCity: _selectedOriginCity,
                onProvinceChanged: (newProvince) {
                  setState(() {
                    _selectedOriginProvince = newProvince;
                    _selectedOriginCity = null;
                    _viewModel.fetchOriginCityList(newProvince!.provinceId);
                  });
                },
                onCityChanged: (newCity) {
                  setState(() {
                    _selectedOriginCity = newCity;
                  });
                },
                cityList: _viewModel.originCityList,
              ),
              const SizedBox(height: 20),
              _buildLocationSelector(
                label: 'Destination',
                selectedProvince: _selectedDestinationProvince,
                selectedCity: _selectedDestinationCity,
                onProvinceChanged: (newProvince) {
                  setState(() {
                    _selectedDestinationProvince = newProvince;
                    _selectedDestinationCity = null;
                    _viewModel.fetchDestinationCityList(newProvince!.provinceId);
                  });
                },
                onCityChanged: (newCity) {
                  setState(() {
                    _selectedDestinationCity = newCity;
                  });
                },
                cityList: _viewModel.destinationCityList,
              ),
              const SizedBox(height: 20),
              _buildWeightAndCourierInputs(),
              const SizedBox(height: 20),
              _buildCalculateButton(),
              const SizedBox(height: 20),
              _buildCostResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector({
    required String label,
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
              '$label Province',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProvinceDropdown(
              selectedProvince: selectedProvince,
              provinces: viewModel.provinceList,
              onChanged: onProvinceChanged,
            ),
            const SizedBox(height: 10),
            if (selectedProvince != null) ...[
              Text(
                '$label City',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildCityDropdown(
                selectedCity: selectedCity,
                cities: cityList,
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
    required ApiResponse<List<Province>> provinces,
    required Function(dynamic) onChanged,
  }) {
    if (provinces.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provinces.status == Status.error) {
      return Center(child: Text(provinces.message ?? 'Error fetching provinces'));
    } else if (provinces.status == Status.completed) {
      return DropdownButton<dynamic>(
        isExpanded: true,
        value: selectedProvince,
        hint: const Text('Select Province'),
        items: provinces.data!.map((province) {
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
    required ApiResponse<List<City>> cities,
    required Function(dynamic) onChanged,
  }) {
    if (cities.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (cities.status == Status.error) {
      return Center(child: Text(cities.message ?? 'Error fetching cities'));
    } else if (cities.status == Status.completed) {
      return DropdownButton<dynamic>(
        isExpanded: true,
        value: selectedCity,
        hint: const Text('Select City'),
        items: cities.data!.map((city) {
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

  Widget _buildWeightAndCourierInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight (grams)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _weightController,
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
          value: _selectedCourier,
          hint: const Text('Select Courier'),
          items: _availableCouriers.map((courier) {
            return DropdownMenuItem(
              value: courier,
              child: Text(courier.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCourier = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    final isReadyToCalculate = _selectedOriginCity != null &&
        _selectedDestinationCity != null &&
        _selectedCourier != null &&
        _weightController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: isReadyToCalculate
          ? () {
              _viewModel.calculateCost(
                origin: _selectedOriginCity!.cityId,
                destination: _selectedDestinationCity!.cityId,
                weight: int.parse(_weightController.text),
                courier: _selectedCourier!,
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isReadyToCalculate ? Colors.blue : Colors.grey,
      ),
      child: const Text('Calculate Cost'),
    );
  }

  Widget _buildCostResultSection() {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, _) {
        if (viewModel.costResult.status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.costResult.status == Status.error) {
          return Center(child: Text(viewModel.costResult.message ?? 'Error fetching cost')); 
        } else if (viewModel.costResult.status == Status.completed) {
          final costDetails = viewModel.costResult.data?.costs;
          if (costDetails != null && costDetails.isNotEmpty) {
            return Column(
              children: costDetails.map((cost) {
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
