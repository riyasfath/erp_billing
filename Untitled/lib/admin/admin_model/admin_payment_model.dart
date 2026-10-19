double _pAsDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
int _pAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

class AdminPaymentModel {
  final int id;
  final String formattedTransactionId;
  final String transactionId;
  final String? razorpayPaymentId;
  final String? customerName;
  final String? customerEmail;
  final String orderId;
  final String date; // already formatted by the API, e.g. "Sep 14, 2026 04:08"
  final String method;
  final double amount; // negative for refund entries
  final double refundedAmount;
  final String status; // completed | failed | refunded

  AdminPaymentModel({
    required this.id,
    required this.formattedTransactionId,
    required this.transactionId,
    this.razorpayPaymentId,
    this.customerName,
    this.customerEmail,
    required this.orderId,
    required this.date,
    required this.method,
    required this.amount,
    required this.refundedAmount,
    required this.status,
  });

  factory AdminPaymentModel.fromJson(Map<String, dynamic> json) => AdminPaymentModel(
        id: _pAsInt(json['id']),
        formattedTransactionId: json['formatted_transaction_id']?.toString() ?? '',
        transactionId: json['transaction_id']?.toString() ?? '',
        razorpayPaymentId: json['razorpay_payment_id']?.toString(),
        customerName: json['customer_name']?.toString(),
        customerEmail: json['customer_email']?.toString(),
        orderId: json['order_id']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        method: json['method']?.toString() ?? '',
        amount: _pAsDouble(json['amount']),
        refundedAmount: _pAsDouble(json['refunded_amount']),
        status: json['status']?.toString() ?? '',
      );
}