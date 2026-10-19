
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/services.dart';
import 'package:pokakbilling/models/data-models/module_permission/permission_module.dart';
import 'package:pokakbilling/models/services/global_services.dart';

class AccessViewModel extends ChangeNotifier {
  bool checkingIsLoggedIn = false;
  bool isModuleLoading = true;
  bool _isAdmin = false;

  // Raw parsed tree from /accounts/user/modules/all/
  List<UserModuleModel> userModules = [];

  // Flattened, normalized set of every module name AND submodule name
  // the logged-in user is allowed to access. Built once per fetch so
  // UI lookups (hasAccess) are O(1) instead of re-scanning the tree.
  Set<String> _permissionKeys = {};

  final SecureStorageService secureStorage = SecureStorageService();

  // read-only computed state
  bool get isLoggedIn => checkingIsLoggedIn;
  bool get isAdmin => checkingIsLoggedIn && _isAdmin;

  AccessViewModel() {
    checkLoginStatus();
    fetchModules();
  }

  Future<void> isLogin() async {
    checkingIsLoggedIn = true;
    notifyListeners();
  }

  void markAsAdmin() {
    _isAdmin = true;
    notifyListeners();
  }

  Future<void> isLogout() async {
    await secureStorage.deleteToken();
    checkingIsLoggedIn = false;
    _isAdmin = false;
    userModules.clear();
    _permissionKeys.clear();
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    String? token = await secureStorage.getToken();
    checkingIsLoggedIn = token != null;
    notifyListeners();
  }

  Future<void> fetchModules() async {
    try {
      isModuleLoading = true;
      notifyListeners();

      userModules = await GlobalServices.getUserModulesAll();
      _permissionKeys = _buildPermissionKeys(userModules);
    } catch (e) {
      debugPrint("Module fetch error: $e");
      userModules = [];
      _permissionKeys = {};
    } finally {
      isModuleLoading = false;
      notifyListeners();
    }
  }

  Set<String> _buildPermissionKeys(List<UserModuleModel> modules) {
    final keys = <String>{};
    for (final m in modules) {
      keys.add(_normalize(m.name));
      for (final s in m.submodules) {
        keys.add(_normalize(s));
      }
    }
    return keys;
  }

  // "New Lead" and "new_lead" and "NEWLEAD" all normalize the same way,
  // so UI card titles can be matched against API module/submodule names
  // without worrying about casing/spacing/underscore differences.
  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// True if [label] (a UI card/chip title) exactly matches (after
  /// normalization) a module or submodule name returned by the
  /// permissions API for the current user.
  bool hasAccess(String label) {
    if (isModuleLoading) return false;
    return _permissionKeys.contains(_normalize(label));
  }
}
