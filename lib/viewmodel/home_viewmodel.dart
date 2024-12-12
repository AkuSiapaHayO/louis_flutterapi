import 'package:flutter/material.dart';
import 'package:louis_flutterapi/data/response/api_response.dart';
import 'package:louis_flutterapi/model/city.dart';
import 'package:louis_flutterapi/model/model.dart';
import 'package:louis_flutterapi/model/costs/cost_response.dart';
import 'package:louis_flutterapi/repository/home_repository.dart';

class HomeViewmodel with ChangeNotifier {
  final HomeRepository _homeRepo = HomeRepository();

  // API Responses
  ApiResponse<List<Province>> provinceList = ApiResponse.loading();
  ApiResponse<List<City>> originCityList = ApiResponse.completed([]);
  ApiResponse<List<City>> destinationCityList = ApiResponse.completed([]);
  ApiResponse<CostResponse> costResult = ApiResponse.loading();

  // Province List
  void setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  Future<void> fetchProvinceList() async {
    setProvinceList(ApiResponse.loading());
    try {
      final provinces = await _homeRepo.fetchProvinceList();
      setProvinceList(ApiResponse.completed(provinces));
    } catch (e) {
      setProvinceList(ApiResponse.error(e.toString()));
    }
  }

  // Origin City List
  void setOriginCityList(ApiResponse<List<City>> response) {
    originCityList = response;
    notifyListeners();
  }

  Future<void> fetchOriginCityList(String provinceId) async {
    setOriginCityList(ApiResponse.loading());
    try {
      final cities = await _homeRepo.fetchCityList(provinceId);
      setOriginCityList(ApiResponse.completed(cities));
    } catch (e) {
      setOriginCityList(ApiResponse.error(e.toString()));
    }
  }

  // Destination City List
  void setDestinationCityList(ApiResponse<List<City>> response) {
    destinationCityList = response;
    notifyListeners();
  }

  Future<void> fetchDestinationCityList(String provinceId) async {
    setDestinationCityList(ApiResponse.loading());
    try {
      final cities = await _homeRepo.fetchCityList(provinceId);
      setDestinationCityList(ApiResponse.completed(cities));
    } catch (e) {
      setDestinationCityList(ApiResponse.error(e.toString()));
    }
  }

  // Cost Calculation
  void setCostResult(ApiResponse<CostResponse> response) {
    costResult = response;
    notifyListeners();
  }

  Future<void> calculateCost({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    setCostResult(ApiResponse.loading());
    try {
      final costResponse = await _homeRepo.calculateCost(
        citySenderId: origin,
        cityReceiverId: destination,
        weight: weight,
        courier: courier,
      );
      setCostResult(ApiResponse.completed(costResponse));
    } catch (e) {
      setCostResult(ApiResponse.error(e.toString()));
    }
  }
}