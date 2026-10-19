/// Response of POST /api/payments/razorpay/create/<order_id>/.
/// Shape UNCONFIRMED — parsed defensively against a few likely field
/// names. Lock this down once a real filled response is available
/// (same pattern as cart/notifications elsewhere in this app).
class RazorpayOrderModel {
  final String razorpayOrderId;
  final String? keyId;
  final int amountInPaise;
  final String currency;

  RazorpayOrderModel({
    required this.razorpayOrderId,
    this.keyId,
    required this.amountInPaise,
    required this.currency,
  });

  factory RazorpayOrderModel.fromJson(
    Map<String, dynamic> json, {
    int fallbackAmountPaise = 0,
  }) {
    final dynamic orderId =
        json['razorpay_order_id'] ?? json['order_id'] ?? json['id'];
    final dynamic key = json['key'] ?? json['key_id'] ?? json['razorpay_key'];
    final dynamic amount = json['amount'] ?? json['amount_due'];

    return RazorpayOrderModel(
      razorpayOrderId: orderId?.toString() ?? '',
      keyId: key?.toString(),
      amountInPaise: amount is int
          ? amount
          : int.tryParse(amount?.toString() ?? '') ?? fallbackAmountPaise,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }
}