import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/profile_model.dart';
import 'package:pokakbilling/models/services/profile_service.dart';

class ProfileViewmodel extends ChangeNotifier {
  bool getProfileLoader = false;
  var profileList = <ProfileModel>[];

  ProfileViewmodel() {
    getAllProfile();
  }

  /// ✅ RESET (for session expiry)
  void reset() {
    profileList = [];
    getProfileLoader = false;
    notifyListeners();
  }

  /// (optional alias)
  void clearData() => reset();

  Future<void> getAllProfile() async {
    try {
      getProfileLoader = true;
      notifyListeners();

      List<ProfileModel> profileItems = await ProfileService.getUserProfile();

      if (profileItems.isNotEmpty) {
        profileList = profileItems;
      } else {
        profileList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getProfileLoader = false;
      notifyListeners();
    }
  }
}
