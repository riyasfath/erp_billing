import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/profile_model.dart';
import 'package:pokakbilling/models/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileViewmodel extends ChangeNotifier {
  bool getProfileLoader = false;
  bool updateProfileLoader = false;

  List<ProfileModel> profileList = [];

  static const String _cachedProfileKey = 'cached_profile';

  ProfileViewmodel() {
    _init();
  }

  Future<void> _init() async {
    await _loadCachedProfile();
    await getAllProfile();
  }

  Future<void> _loadCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedJson = prefs.getString(
        _cachedProfileKey,
      );

      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);

        profileList = decoded
            .map(
              (item) => ProfileModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint(
        'Error loading cached profile: $e',
      );
    }
  }

  Future<void> _saveProfileToCache(
    List<ProfileModel> profiles,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = jsonEncode(
        profiles.map((e) => e.toJson()).toList(),
      );

      await prefs.setString(
        _cachedProfileKey,
        encoded,
      );
    } catch (e) {
      debugPrint(
        'Error saving profile cache: $e',
      );
    }
  }

  Future<void> clearCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(
        _cachedProfileKey,
      );

      profileList.clear();

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error clearing cache: $e',
      );
    }
  }

  Future<void> getAllProfile() async {
    try {
      getProfileLoader = true;
      notifyListeners();

      final profileItems = await ProfileService.getUserProfile();

      profileList = profileItems;

      await _saveProfileToCache(
        profileItems,
      );
    } catch (e) {
      debugPrint(
        'Profile Fetch Error : $e',
      );
    } finally {
      getProfileLoader = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String dob,
    required String address,
    String? imagePath,
  }) async {
    try {
      updateProfileLoader = true;
      notifyListeners();

      await ProfileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        dob: dob,
        address: address,
        imagePath: imagePath,
      );

      await getAllProfile();

      return true;
    } catch (e) {
      debugPrint(
        'Profile Update Error : $e',
      );

      return false;
    } finally {
      updateProfileLoader = false;
      notifyListeners();
    }
  }

  void reset() {
    profileList = [];
    getProfileLoader = false;
    updateProfileLoader = false;

    clearCachedProfile();

    notifyListeners();
  }
}
