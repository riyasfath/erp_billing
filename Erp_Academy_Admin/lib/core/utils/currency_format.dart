class CurrencyFormat {
  CurrencyFormat._();

  /// ₹ with Indian grouping: 100000 → ₹1,00,000
  static String inr(double v) {
    final whole = v.round().toString();
    if (whole.length <= 3) return '₹$whole';
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }

  /// 9.0 → "9%", 2.5 → "2.5%"
  static String percent(double v) =>
      v % 1 == 0 ? '${v.toInt()}%' : '${v.toStringAsFixed(1)}%';
}