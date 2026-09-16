import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/shared/format/count_format.dart';

void main() {
  test('件数を3桁区切りで表示する', () {
    expect(formatCount(0), '0');
    expect(formatCount(7), '7');
    expect(formatCount(999), '999');
    expect(formatCount(1000), '1,000');
    expect(formatCount(8214), '8,214');
    expect(formatCount(1234567), '1,234,567');
    expect(formatCount(-1234), '-1,234');
  });
}
