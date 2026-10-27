import 'package:bangla_utils/bangla_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Bn', () {
    test('digits both ways', () {
      expect(Bn.num(123), '১২৩');
      expect(Bn.num('Roll 7'), 'Roll ৭');
      expect(Bn.ascii('১২৩'), '123');
      expect(Bn.ascii('৳১,২৫১'), '৳1,251');
    });

    test('months and weekdays', () {
      expect(Bn.month(10), 'অক্টোবর');
      expect(Bn.month(10, short: true), 'অক্টো');
      expect(Bn.monthShort('2026-10'), 'অক্টো');
      expect(Bn.monthShort('bad'), 'bad');
      expect(Bn.weekday(DateTime(2026, 10, 26).weekday), 'সোমবার');
      expect(Bn.date(DateTime(2026, 10, 26)), '২৬ অক্টোবর ২০২৬');
    });

    test('taka', () {
      expect(Bn.taka(1250.5), '৳১,২৫১');
      expect(Bn.taka(-80), '-৳৮০');
      expect(Bn.taka(null), '৳০');
      expect(Bn.takaShort(271610), '৳২.৭ল');
      expect(Bn.takaShort(1500000), '৳১৫ল');
      expect(Bn.takaShort(45000), '৳৪৫হ');
      expect(Bn.takaShort(850), '৳৮৫০');
    });
  });

  group('safe parsing', () {
    test('numbers that arrive as strings', () {
      expect(numOrNull('101'), 101);
      expect(numOrNull('1,250.50'), 1250.5);
      expect(numOrNull('১২৩'), 123);
      expect(numOrNull(''), isNull);
      expect(numOrNull('abc'), isNull);
      expect(num0(null), 0);
      expect(int0('12.9'), 12);
      expect(dbl0('7'), 7.0);
    });

    test('strings, bools, maps, lists never throw', () {
      expect(strOrNull('  '), isNull);
      expect(strOrNull(42), '42');
      expect(bool0('1'), isTrue);
      expect(bool0('no'), isFalse);
      expect(mapOf(null), isEmpty);
      expect(mapOf({'a': 1})['a'], 1);
      expect(listOf('x'), isEmpty);
      expect(listOf([1, 2]).length, 2);
    });
  });
}
