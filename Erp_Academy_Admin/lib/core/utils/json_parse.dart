/// Safe converters for API values that may come as String, int, double or null.
class JsonParse {
  JsonParse._();

  static int toInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ??
        double.tryParse(v.toString())?.toInt() ??
        fallback;
  }

  static double toDouble(dynamic v, [double fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static String toStr(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static bool toBool(dynamic v, [bool fallback = false]) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  static DateTime? toDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  static List<Map<String, dynamic>> toMapList(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];
}