import 'package:ecommerce_app/core/api_client.dart';
import 'package:ecommerce_app/core/providers.dart';
import 'package:ecommerce_app/models/adress_model.dart';

/// Network calls for /api/accounts/addresses/ (list + add). The same
/// URL serves both — GET lists, POST creates.
class AddressService {
  final ApiClient _apiClient;

  AddressService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<AddressModel>> getAddresses() async {
    final data = await _apiClient.get(ApiEndpoints.addresses);
    // This endpoint returns a plain JSON array — ApiClient.get() wraps
    // a bare array as {'data': [...]}.
    final List<dynamic> resultsJson = (data['data'] as List?) ?? [];
    return resultsJson
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final data = await _apiClient.post(ApiEndpoints.addresses, address.toJson());
    return AddressModel.fromJson(data);
  }
}