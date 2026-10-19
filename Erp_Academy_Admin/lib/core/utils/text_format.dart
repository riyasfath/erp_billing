class TextFormat {
  TextFormat._();

  static const _upper = {'upi', 'id', 'pdf', 'emi', 'neft', 'imps'};

  /// "default_installment" → "Default Installment", "upi" → "UPI"
  static String pretty(String? v, {String empty = '—'}) {
    if (v == null || v.trim().isEmpty) return empty;
    return v
        .trim()
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .map((w) {
          final l = w.toLowerCase();
          if (_upper.contains(l)) return l.toUpperCase();
          return l[0].toUpperCase() + l.substring(1);
        })
        .join(' ');
  }

  static String orDash(String? v) =>
      (v == null || v.trim().isEmpty) ? '—' : v.trim();
}