import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/models/data-models/customer_type_model.dart';

class CustomerTypeService {
  static Future<List<CustomerTypeModel>> getCustomerTypes() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.customerTypesEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = response.data;
        return jsonList
            .map((e) => CustomerTypeModel.fromJson(e))
            .where((t) => t.isActive)
            .toList();
      } else {
        throw Exception("Failed to load customer types");
      }
    } catch (e) {
      throw Exception("Error fetching customer types: $e");
    }
  }
}
