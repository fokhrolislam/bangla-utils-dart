# bangla_format

[![pub package](https://img.shields.io/pub/v/bangla_format.svg)](https://pub.dev/packages/bangla_format) [![tests](https://github.com/fokhrolislam/bangla-utils-dart/actions/workflows/test.yml/badge.svg)](https://github.com/fokhrolislam/bangla-utils-dart/actions/workflows/test.yml)

Small, dependency-free Dart helpers for apps that speak Bangla and talk to a PHP/MySQL backend.

Extracted from the [Sabaq](https://sabaaq.com) Flutter app, where they run on every screen.

## Install

```
dart pub add bangla_format
```

## Bangla digits, dates and taka

```dart
import 'package:bangla_format/bangla_format.dart';

Bn.num(123);                        // '১২৩'
Bn.ascii('১২৩');                    // '123'
Bn.month(10);                       // 'অক্টোবর'
Bn.monthShort('2026-10');           // 'অক্টো'
Bn.date(DateTime(2026, 10, 26));    // '২৬ অক্টোবর ২০২৬'
Bn.taka(1250.5);                    // '৳১,২৫১'
Bn.takaShort(271610);               // '৳২.৭ল'   (ল = lakh, হ = thousand)
```

## Crash-safe parsing of API values

Production MySQL tenants often keep numeric columns as `varchar`. The JSON then carries `"101"` where your test database gives `101`, and a raw `as num` cast crashes only on the phone. These helpers never throw and understand Bangla digits and thousands commas:

```dart
numOrNull('1,250.50');   // 1250.5
numOrNull('১২৩');        // 123
num0(null);              // 0
int0('12.9');            // 12
strOrNull('  ');         // null
bool0('1');              // true
mapOf(json['student']);  // {} when missing or not a map
listOf(json['rows']);    // [] when missing or not a list
```

Rule we enforce in CI: `as num`, `as int`, `as double`, `as Map`, `as List` on API data are banned; see [flutter-risk-scans](https://github.com/fokhrolislam/flutter-risk-scans).

## License

MIT
