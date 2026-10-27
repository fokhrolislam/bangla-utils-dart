/// Bangla digits, month and weekday names, short taka amounts, and crash-safe
/// parsing of values that arrive from a PHP/MySQL backend as strings.
library bangla_utils;

// `Bn.num()` shadows the `num` type inside the class; this alias keeps it usable.
typedef _Num = num;

/// Bangla (Bengali script) digit helpers.
class Bn {
  Bn._();

  static const digits = {
    '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
    '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
  };

  static const months = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  static const monthsShort = [
    'জানু', 'ফেব', 'মার্চ', 'এপ্রি', 'মে', 'জুন',
    'জুলা', 'আগ', 'সেপ্ট', 'অক্টো', 'নভে', 'ডিসে',
  ];

  /// Monday first, matching `DateTime.weekday`.
  static const weekdays = [
    'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার',
  ];

  /// ASCII digits to Bangla digits: `123` → `১২৩`. Other characters pass through.
  static String num(Object? value) {
    if (value == null) return '';
    final b = StringBuffer();
    for (final c in value.toString().split('')) {
      b.write(digits[c] ?? c);
    }
    return b.toString();
  }

  /// Bangla digits to ASCII digits: `১২৩` → `123`.
  static String ascii(String s) {
    const bn = '০১২৩৪৫৬৭৮৯';
    final b = StringBuffer();
    for (final r in s.runes) {
      final i = bn.indexOf(String.fromCharCode(r));
      b.write(i >= 0 ? i.toString() : String.fromCharCode(r));
    }
    return b.toString();
  }

  /// Month name for a 1-based month number; empty when out of range.
  static String month(int m, {bool short = false}) =>
      (m >= 1 && m <= 12) ? (short ? monthsShort : months)[m - 1] : '';

  /// `'2026-10'` → `'অক্টো'`; anything else is returned as is.
  static String monthShort(String? ym) {
    if (ym == null || ym.length < 7) return ym ?? '';
    final mi = int.tryParse(ym.substring(5, 7));
    return (mi != null && mi >= 1 && mi <= 12) ? monthsShort[mi - 1] : ym;
  }

  /// Weekday name for `DateTime.weekday` (1 = Monday).
  static String weekday(int d) => (d >= 1 && d <= 7) ? weekdays[d - 1] : '';

  /// `DateTime` → `'২৬ অক্টোবর ২০২৬'`.
  static String date(DateTime d, {bool short = false}) =>
      '${num(d.day)} ${month(d.month, short: short)} ${num(d.year)}';

  /// Whole taka with thousands separators: `1250.5` → `৳১,২৫১`.
  static String taka(_Num? value) {
    final v = (value ?? 0).round();
    return '৳${num(_group(v.abs()))}'.replaceFirst('৳', v < 0 ? '-৳' : '৳');
  }

  /// Short taka for tight spaces: `271610` → `৳২.৭ল`, `45000` → `৳৪৫হ`, `850` → `৳৮৫০`.
  static String takaShort(_Num? v) {
    if (v == null) return '৳${num(0)}';
    final a = v.abs();
    final sign = v < 0 ? '-' : '';
    if (a >= 100000) {
      return '$sign৳${num((a / 100000).toStringAsFixed(a >= 1000000 ? 0 : 1))}ল';
    }
    if (a >= 1000) return '$sign৳${num((a / 1000).round())}হ';
    return '$sign৳${num(a.round())}';
  }

  static String _group(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

// ---------------------------------------------------------------------------
// Crash-safe parsing.
//
// Production MySQL tenants often keep numeric columns as varchar, so JSON
// carries "101" (String) where the test database gives 101 (int). A raw
// `as num` cast then throws "type 'String' is not a subtype of type 'num?'"
// on the phone and never on the developer's machine. Never cast dynamic API
// values; run them through these helpers.
// ---------------------------------------------------------------------------

/// Any value → `num`, or `null`. Accepts Bangla digits and thousands commas.
num? numOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  var s = v.toString().trim();
  if (s.isEmpty) return null;
  s = Bn.ascii(s).replaceAll(',', '');
  return num.tryParse(s);
}

/// Any value → `num`, or `0`.
num num0(dynamic v) => numOrNull(v) ?? 0;

/// Any value → `int`, or `null`.
int? intOrNull(dynamic v) => numOrNull(v)?.toInt();

/// Any value → `int`, or `0`.
int int0(dynamic v) => intOrNull(v) ?? 0;

/// Any value → `double`, or `0`.
double dbl0(dynamic v) => num0(v).toDouble();

/// Any value → non-empty trimmed `String`, or `null`.
String? strOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// `true`, `1`, `"1"`, `"true"`, `"yes"` → `true`; everything else `false`.
bool bool0(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().trim().toLowerCase();
  return s == '1' || s == 'true' || s == 'yes';
}

/// Any value → `Map<String, dynamic>`, or an empty map (never throws).
Map<String, dynamic> mapOf(dynamic v) =>
    v is Map ? v.map((k, val) => MapEntry(k.toString(), val)) : <String, dynamic>{};

/// Any value → `List`, or an empty list (never throws).
List<dynamic> listOf(dynamic v) => v is List ? v : const [];
