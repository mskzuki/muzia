import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

void main() {
  group('MuziaTheme.light', () {
    final theme = MuziaTheme.light();
    final colors = theme.extension<MuziaColors>()!;

    test('デザイントークンのアクセント色を公開する', () {
      expect(colors.accent, const Color(0xFF3E63DD));
      expect(colors.accentHover, const Color(0xFF3358D4));
      expect(colors.accentText, const Color(0xFF3A5BC7));
      expect(colors.accentSoft, const Color(0xFFEDF2FE));
      expect(colors.onAccent, const Color(0xFFFFFFFF));
    });

    test('テキストと面の色を公開する', () {
      expect(colors.fgPrimary, const Color(0xFF202020));
      expect(colors.fgSecondary, const Color(0xFF646464));
      expect(colors.fgTertiary, const Color(0xFF838383));
      expect(colors.windowBg, const Color(0xFFFFFFFF));
      expect(colors.sidebarBg, const Color(0xFFF6F6F8));
    });

    test('行の縞・ホバー・罫線は黒のアルファで定義する', () {
      expect(colors.rowStripe.a, closeTo(0.02, 0.01));
      expect(colors.rowHover.a, closeTo(0.06, 0.01));
      expect(colors.borderSubtle.a, closeTo(0.16, 0.02));
    });

    test('警告と破壊的操作の色を公開する', () {
      expect(colors.warn, const Color(0xFFFFC53D));
      expect(colors.warnText, const Color(0xFFAD5700));
      expect(colors.destructive, const Color(0xFFCE2C31));
    });

    test('ThemeDataへトークンを反映する', () {
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, colors.accent);
      expect(theme.scaffoldBackgroundColor, colors.windowBg);
    });
  });

  group('MuziaTheme.dark', () {
    final theme = MuziaTheme.dark();
    final colors = theme.extension<MuziaColors>()!;

    test('同じRadixステップのダーク値を公開する', () {
      expect(theme.brightness, Brightness.dark);
      expect(colors.accent, const Color(0xFF3E63DD));
      expect(colors.fgPrimary, const Color(0xFFEEEEEE));
      expect(colors.windowBg, const Color(0xFF111111));
    });
  });

  test('スペーシングは4pxスケールで定義する', () {
    expect(MuziaSpacing.s1, 4);
    expect(MuziaSpacing.s2, 8);
    expect(MuziaSpacing.s3, 12);
    expect(MuziaSpacing.s4, 16);
    expect(MuziaSpacing.s5, 24);
    expect(MuziaSpacing.s6, 32);
  });

  testWidgets('アプリにライト/ダーク両方のMuziaテーマが設定される', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.extension<MuziaColors>(), MuziaColors.light);
    expect(app.darkTheme?.extension<MuziaColors>(), MuziaColors.dark);
  });

  test('角丸はデザイントークンの段階で定義する', () {
    expect(MuziaRadius.r1, 3);
    expect(MuziaRadius.r2, 4);
    expect(MuziaRadius.r3, 6);
    expect(MuziaRadius.r4, 8);
    expect(MuziaRadius.r5, 12);
    expect(MuziaRadius.r6, 16);
  });
}
