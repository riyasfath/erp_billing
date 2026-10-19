import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/student_model.dart';
import '../models/student_profile_model.dart';
import '../services/student_service.dart';

class StudentProfileViewModel extends ChangeNotifier {
  StudentProfileViewModel(this._service, this.student) {
    load();
  }

  final StudentService _service;
  final StudentListItem student;

  StudentProfile? profile;
  bool loading = true;
  String? error;

  bool savingCredentials = false;
  String? credentialsError;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _service.getProfile(student.id);
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load profile. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------- Credentials ----------
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  String? validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirm(String? v, String password) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }

  void clearCredentialsError() {
    if (credentialsError == null) return;
    credentialsError = null;
    notifyListeners();
  }

  /// True only if the API accepted the change.
  Future<bool> updateCredentials({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (savingCredentials) return false;
    savingCredentials = true;
    credentialsError = null;
    notifyListeners();
    try {
      await _service.updateCredentials(
        student.id,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return true;
    } on ApiException catch (e) {
      credentialsError = e.message;
      return false;
    } catch (_) {
      credentialsError = 'Could not update credentials. Please try again.';
      return false;
    } finally {
      savingCredentials = false;
      notifyListeners();
    }
  }
}