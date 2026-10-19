/// Response of POST /api/products/check-pincode/. Note: the confirmed
/// sample only returns `available` + `message` — no estimated delivery
/// date field. If the real API adds one later (e.g. `estimated_days`
/// or `expected_delivery`), add it here and to fromJson.
class PincodeCheckModel {
  final String pincode;
  final bool available;
  final String message;

  PincodeCheckModel({
    required this.pincode,
    required this.available,
    required this.message,
  });

  factory PincodeCheckModel.fromJson(Map<String, dynamic> json) {
    return PincodeCheckModel(
      pincode: json['pincode']?.toString() ?? '',
      available: json['available'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}