import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/terms-and-condition/terms_model.dart';
import 'package:pokakbilling/models/services/terms/terms_and_condition_service.dart';

class TermsViewModel extends ChangeNotifier {
  // ================= STATE =================
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDetailsLoading = false;
  bool get isDetailsLoading => _isDetailsLoading;

  List<TermsModel> _termsList = [];
  List<TermsModel> get termsList => _termsList;

  TermsModel? _selectedTerms;
  TermsModel? get selectedTerms => _selectedTerms;

  int _selectedTermsId = 0;
  int get selectedTermsId => _selectedTermsId;

  String _selectedTermsTitle = "";
  String get selectedTermsTitle => _selectedTermsTitle;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ================= CLEAR =================
  void clearSelectedTerms() {
    _selectedTerms = null;
    _selectedTermsId = 0;
    _selectedTermsTitle = "";
    notifyListeners();
  }

  void clearSelection() {
    clearSelectedTerms();
  }

  // ================= GET ALL =================
  // Future<void> getAllTermsTitle() async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     _termsList = await TermsService.getTermsTitle();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  // }
  Future<void> getAllTermsTitle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await TermsService.getTermsTitle();

      _termsList = list;

      print("TERMS COUNT: ${_termsList.length}"); // 🔥 DEBUG
    } catch (e) {
      _errorMessage = e.toString();
      _termsList = []; // important fallback
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= GET BY ID =================
  Future<void> getTermsById(int id) async {
    _isDetailsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTerms = await TermsService.getTermsTitleById(id);
      if (_selectedTerms != null) {
        _selectedTermsId = _selectedTerms!.id ?? 0;
        _selectedTermsTitle = _selectedTerms!.name ?? "";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isDetailsLoading = false;
    notifyListeners();
  }

  // ================= LOAD FOR QUOTATION VIEW ================================
  // Accepts the integer termsTemplateId parsed from QuotationModel
  Future<void> loadTermsForQuotation(int? termsTemplateId) async {
    if (termsTemplateId == null || termsTemplateId == 0) return;
    await getTermsById(termsTemplateId);
  }

  // ================= SELECT =================
  void selectTerms(TermsModel model) {
    _selectedTerms = model;
    _selectedTermsId = model.id ?? 0;
    _selectedTermsTitle = model.name ?? "";
    notifyListeners();
  }

  // ================= HELPER =================
  List<String> get selectedTermsPoints {
    if (_selectedTerms == null || _selectedTerms!.points == null) return [];
    return _selectedTerms!.points!.map((e) => e.content ?? "").toList();
  }
}
