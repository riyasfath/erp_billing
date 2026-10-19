import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/models/data-models/country_model.dart';
import 'package:pokakbilling/models/data-models/state_model.dart';

class CountryService {
  static Future<List<CountriesModel>> getCountries() async {
    final dio = Dio();
    try {
      final response = await dio.get(ApiConstants.countriesEndpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("Data")) {
          return (responseData["Data"] as List)
              .map((json) => CountriesModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching countries: $e");
    }
    return [];
  }

  static Future<List<StatesModel>> getStates(String country) async {
    final dio = Dio();
    try {
      final response = await dio.get(ApiConstants.statesEndpoint(country));

      print("States API Response: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("Data")) {
          return (responseData["Data"] as List)
              .map((json) => StatesModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching states: $e");
    }
    return [];
  }
}
