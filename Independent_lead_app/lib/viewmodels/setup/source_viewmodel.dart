import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/models/services/marketing_source.dart';

class SourceViewmodel extends ChangeNotifier {
  List<Source> _sources = [];
  bool _isLoading = false;
  bool _addSourceLoading = false;
  bool _editSourceLoading = false;
  bool _deleteSourceLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Source> get sources => _sources;
  bool get isLoading => _isLoading;
  bool get addSourceLoading => _addSourceLoading;
  bool get editSourceLoading => _editSourceLoading;
  bool get deleteSourceLoading => _deleteSourceLoading;
  String? get errorMessage => _errorMessage;

  SourceViewmodel() {
    fetchSources();
  }

  // FETCH
  Future<void> fetchSources() async {
    if (_disposed) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final fetchedSources = await SourceServices.getSources();
      if (!_disposed) {
        _sources = fetchedSources;
        _errorMessage = null;
      }
    } catch (e) {
      if (!_disposed) {
        _sources = [];
        _errorMessage = e.toString();
      }
    }

    if (!_disposed) {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // CREATE
  Future<void> createSource(String name, BuildContext context) async {
    if (_disposed) return;

    try {
      _addSourceLoading = true;
      _safeNotifyListeners();

      final response = await SourceServices.createSource(name);

      if (response == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Source created successfully!")),
        );
        await fetchSources();
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
      }
    } finally {
      if (!_disposed) {
        _addSourceLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // EDIT
  Future<void> editSource(
      int sourceId, String name, BuildContext context) async {
    if (_disposed) return;

    try {
      _editSourceLoading = true;
      _safeNotifyListeners();

      final response = await SourceServices.updateSource(sourceId, name);

      if (response == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Source updated successfully!")),
        );
        await fetchSources();
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
      }
    } finally {
      if (!_disposed) {
        _editSourceLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // DELETE
  Future<void> deleteSource(int sourceId, BuildContext context) async {
    if (_disposed) return;

    try {
      _deleteSourceLoading = true;
      _safeNotifyListeners();

      final response = await SourceServices.deleteSource(sourceId);

      if (response == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Source deleted successfully!")),
        );
        await fetchSources();
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
      }
    } finally {
      if (!_disposed) {
        _deleteSourceLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // Safe notify
  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
