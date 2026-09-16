/// 件数を3桁区切りで表示する（例: 8214 → "8,214"）。
/// intl 等のパッケージを追加せず、デザインの `tabular-nums` 表記に合わせるための最小実装。
String formatCount(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}
