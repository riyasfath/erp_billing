// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class SettingsViewmodel with ChangeNotifier {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   File? get selectedImage => _selectedImage;

//   Future<void> pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _selectedImage = File(pickedFile.path);
//       notifyListeners();
//     }
//   }
// }
