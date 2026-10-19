class AppDate {
  AppDate._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// 2026-10-12 → "12 Oct 2026"
  static String format(DateTime? d, {String empty = '—'}) {
    if (d == null) return empty;
    return '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';
  }
}