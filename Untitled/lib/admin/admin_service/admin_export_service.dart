import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../admin_api_client.dart';
import '../admin_endpoints.dart';

class AdminExportService {
  final AdminApiClient _apiClient;

  AdminExportService({AdminApiClient? apiClient}) : _apiClient = apiClient ?? AdminApiClient();

  Future<void> exportOrders() => _exportAndShare(AdminEndpoints.exportOrders, 'orders_export.pdf');

  Future<void> exportPayments() => _exportAndShare(AdminEndpoints.exportPayments, 'payments_export.pdf');

  Future<void> _exportAndShare(String url, String filename) async {
    final bytes = await _apiClient.getBytes(url);
    await Share.shareXFiles(
      [XFile.fromData(Uint8List.fromList(bytes), name: filename, mimeType: 'application/pdf')],
      subject: filename,
    );
  }
}