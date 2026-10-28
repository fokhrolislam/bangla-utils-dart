import 'package:bangla_format/bangla_format.dart';

void main() {
  // A row as a PHP/MySQL API often sends it: numbers as strings.
  final json = <String, dynamic>{'roll': '7', 'due': '1,250.50', 'paid': null};

  final due = num0(json['due']);
  final paid = num0(json['paid']);

  print('রোল ${Bn.num(int0(json['roll']))}');
  print('বকেয়া ${Bn.taka(due - paid)}');
  print(Bn.date(DateTime(2026, 10, 26)));
}
