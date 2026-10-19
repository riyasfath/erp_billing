import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/country_model.dart';
import 'package:pokakbilling/models/data-models/state_model.dart';
import 'package:pokakbilling/models/services/country_state_service.dart';

class CountryStateProvider with ChangeNotifier {
  List<CountriesModel> _countryList = [];
  List<StatesModel> _stateList = [];
  bool _isLoading = false;
  bool _isLoadingStates = false;
  String? selectedCountry;
  String? selectedState;

  List<CountriesModel> get countryList => _countryList;
  List<StatesModel> get stateList => _stateList;
  bool get isLoading => _isLoading;
  bool get isLoadingStates => _isLoadingStates;
  // String? get selectedCountry => _selectedCountry;
  // String? get selectedState => _selectedState;

  CountryStateProvider() {
    fetchCountries();
  }

  // Fetch Countries
  Future<void> fetchCountries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _countryList = await CountryService.getCountries();
    } catch (e) {
      print("Error fetching countries: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch States
  Future<void> fetchStates(String country) async {
    _isLoadingStates = true;
    notifyListeners();

    try {
      _stateList = await CountryService.getStates(country);
    } catch (e) {
      print("Error fetching states: $e");
    }

    _isLoadingStates = false;
    notifyListeners();
  }

  // Select Country and Fetch States
  void selectCountry(String? country) async {
    if (selectedCountry == country) return;

    selectedCountry = country;
    selectedState = null;
    _stateList.clear();
    notifyListeners();

    if (country != null) {
      await fetchStates(country);
    }
  }

  // Select State
  void selectState(String? state) {
    if (selectedState == state) return; // Avoid unnecessary updates

    selectedState = state;
    notifyListeners();
  }
}
