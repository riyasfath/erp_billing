import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/pincode_checkmodel.dart';

/// Network call for POST /api/products/check-pincode/.
class PincodeService {
  final ApiClient _apiClient;

  PincodeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PincodeCheckModel> checkPincode(String pincode) async {
    final data = await _apiClient.post(ApiEndpoints.checkPincode, {'pincode': pincode});
    return PincodeCheckModel.fromJson(data);
  }
}