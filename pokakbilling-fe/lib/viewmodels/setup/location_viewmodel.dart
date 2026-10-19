// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
// import 'package:pokakbilling/models/services/marketing_location.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class LocationViewmodel extends ChangeNotifier {
//   List<Location> _locations = [];
//   bool _isLoading = false;
//   bool _addLocationLoading = false;
//   bool _editLocationLoading = false;
//   bool _deleteLocationLoading = false;
//   String? _errorMessage;
//   bool _disposed = false;

//   List<Location> get locations => _locations;
//   bool get isLoading => _isLoading;
//   bool get addLocationLoading => _addLocationLoading;
//   bool get editLocationLoading => _editLocationLoading;
//   bool get deleteLocationLoading => _deleteLocationLoading;
//   String? get errorMessage => _errorMessage;

//   LocationViewmodel() {
//     fetchLocations();
//   }

//   Future<void> fetchLocations() async {
//     if (_disposed) return;

//     _isLoading = true;
//     _safeNotifyListeners();

//     try {
//       final fetchedLocations = await LocationServices.getLocations();

//       if (!_disposed) {
//         _locations = fetchedLocations;
//         _errorMessage = null;
//       }
//     } catch (e) {
//       if (!_disposed) {
//         _errorMessage = e.toString();
//         _locations = [];
//       }
//     }

//     if (!_disposed) {
//       _isLoading = false;
//       _safeNotifyListeners();
//     }
//   }

//   // CREATE - Add new location
//   Future<void> createLocation(String name, BuildContext context) async {
//     if (_disposed) return;

//     try {
//       _addLocationLoading = true;
//       _safeNotifyListeners();

//       String? response = await LocationServices.createLocation(name);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Location Created Successfully!",
//         );
//         await fetchLocations();
//         Navigator.pop(context, true);
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//       if (!_disposed && context.mounted) {
//         showOverlayError(context, "Failed to create location");
//       }
//     } finally {
//       if (!_disposed) {
//         _addLocationLoading = false;
//         _safeNotifyListeners();
//       }
//     }
//   }

//   // UPDATE - Edit existing location
//   Future<void> editLocation(
//       int locationId, String name, BuildContext context) async {
//     if (_disposed) return;

//     try {
//       _editLocationLoading = true;
//       _safeNotifyListeners();

//       String? response =
//           await LocationServices.updateLocation(locationId, name);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Location Updated Successfully!",
//         );
//         await fetchLocations();
//         Navigator.pop(context, true);
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//       if (!_disposed && context.mounted) {
//         showOverlayError(context, "Failed to update location");
//       }
//     } finally {
//       if (!_disposed) {
//         _editLocationLoading = false;
//         _safeNotifyListeners();
//       }
//     }
//   }

//   // DELETE - Remove location
//   Future<void> deleteLocation(int locationId, BuildContext context) async {
//     if (_disposed) return;

//     try {
//       _deleteLocationLoading = true;
//       _safeNotifyListeners();

//       String? response = await LocationServices.deleteLocation(locationId);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Location Deleted Successfully!",
//         );
//         await fetchLocations();
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//       if (!_disposed && context.mounted) {
//         showOverlayError(context, "Failed to delete location");
//       }
//     } finally {
//       if (!_disposed) {
//         _deleteLocationLoading = false;
//         _safeNotifyListeners();
//       }
//     }
//   }

//   // Clear error message
//   void clearError() {
//     if (!_disposed) {
//       _errorMessage = null;
//       _safeNotifyListeners();
//     }
//   }

//   // Safe notify listeners methodimport 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
import 'package:pokakbilling/models/services/marketing_location.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class LocationViewmodel extends ChangeNotifier {
  List<Location> _locations = [];
  bool _isLoading = false;
  bool _addLocationLoading = false;
  bool _editLocationLoading = false;
  bool _deleteLocationLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  bool get addLocationLoading => _addLocationLoading;
  bool get editLocationLoading => _editLocationLoading;
  bool get deleteLocationLoading => _deleteLocationLoading;
  String? get errorMessage => _errorMessage;

  LocationViewmodel() {
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    if (_disposed) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final fetchedLocations = await LocationServices.getLocations();

      if (!_disposed) {
        _locations = fetchedLocations;
        _errorMessage = null;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = e.toString();
        _locations = [];
      }
    }

    if (!_disposed) {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Check if location name already exists
  bool isLocationNameExists(String name, {int? excludeId}) {
    final trimmedName = name.trim().toLowerCase();
    return _locations.any((location) {
      if (excludeId != null && location.id == excludeId) {
        return false; // Exclude current location when editing
      }
      return location.name.trim().toLowerCase() == trimmedName;
    });
  }

  // CREATE - Add new location
  Future<void> createLocation(String name, BuildContext context) async {
    if (_disposed) return;

    // Check for duplicate name before making API call
    if (isLocationNameExists(name)) {
      if (context.mounted) {
        showOverlayError(
          context,
          "A location with the name '$name' already exists.",
        );
      }
      return;
    }

    try {
      _addLocationLoading = true;
      _safeNotifyListeners();

      String? response = await LocationServices.createLocation(name);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Location Created Successfully!",
        );
        await fetchLocations();
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to create location");
      }
    } finally {
      if (!_disposed) {
        _addLocationLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // UPDATE - Edit existing location
  Future<void> editLocation(
      int locationId, String name, BuildContext context) async {
    if (_disposed) return;

    // Check for duplicate name before making API call (excluding current location)
    if (isLocationNameExists(name, excludeId: locationId)) {
      if (context.mounted) {
        showOverlayError(
          context,
          "A location with the name '$name' already exists.",
        );
      }
      return;
    }

    try {
      _editLocationLoading = true;
      _safeNotifyListeners();

      String? response =
          await LocationServices.updateLocation(locationId, name);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Location Updated Successfully!",
        );
        await fetchLocations();
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to update location");
      }
    } finally {
      if (!_disposed) {
        _editLocationLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // DELETE - Remove location
  Future<void> deleteLocation(int locationId, BuildContext context) async {
    if (_disposed) return;

    try {
      _deleteLocationLoading = true;
      _safeNotifyListeners();

      String? response = await LocationServices.deleteLocation(locationId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Location Deleted Successfully!",
        );
        await fetchLocations();
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to delete location");
      }
    } finally {
      if (!_disposed) {
        _deleteLocationLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // Clear error message
  void clearError() {
    if (!_disposed) {
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }

  // Safe notify listeners method
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
//   void _safeNotifyListeners() {
//     if (!_disposed) {
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     super.dispose();
//   }
// }
