import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_page.dart';
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

    test('スクリム・バッジ・スライダー・半透明面の補助トークンを公開する', () {
      expect(colors.warnTextStrong, const Color(0xFF4F3422));
      expect(colors.alertBadge, const Color(0xFFE5484D));
      expect(colors.overlay.a, closeTo(0.30, 0.02));
      expect(colors.panelTranslucent.a, closeTo(0.70, 0.02));
      expect(colors.sliderTrack.a, closeTo(0.08, 0.01));
      expect(colors.rowDivider.a, closeTo(0.04, 0.01));
      expect(colors.accentBorder.a, closeTo(0.28, 0.02));
      expect(colors.warnBorder.a, closeTo(0.40, 0.02));
    });

    test('ThemeDataへトークンを反映する', () {
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, colors.accent);
      expect(theme.scaffoldBackgroundColor, colors.windowBg);
      expect(theme.dialogTheme.barrierColor, colors.overlay);
    });
  });

  group('MuziaShadows / MuziaMotion', () {
    test('shadow-2 / shadow-3 をデザイントークンの値で定義する', () {
      expect(MuziaShadows.card.single.blurRadius, 3);
      expect(MuziaShadows.card.single.offset, const Offset(0, 1));
      expect(MuziaShadows.card.single.color.a, closeTo(0.10, 0.01));
      expect(MuziaShadows.raised.single.blurRadius, 12);
      expect(MuziaShadows.raised.single.offset, const Offset(0, 4));
      expect(MuziaShadows.raised.single.color.a, closeTo(0.14, 0.01));
    });

    test('開閉のdurationとカーブを定義する', () {
      expect(MuziaMotion.open, const Duration(milliseconds: 160));
      expect(MuziaMotion.close, const Duration(milliseconds: 100));
      expect(MuziaMotion.curve, const Cubic(0.16, 1, 0.3, 1));
    });

    testWidgets('Reduce Motion時はdurationをゼロにする', (tester) async {
      late Duration normal;
      late Duration reduced;
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Builder(
                builder: (context) {
                  normal = MuziaMotion.resolve(context, MuziaMotion.open);
                  return const SizedBox.shrink();
                },
              ),
              MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Builder(
                  builder: (context) {
                    reduced = MuziaMotion.resolve(context, MuziaMotion.open);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );
      expect(normal, MuziaMotion.open);
      expect(reduced, Duration.zero);
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

    test('スクリムはダークでより濃く、補助トークンもダーク値を持つ', () {
      expect(colors.overlay.a, greaterThan(MuziaColors.light.overlay.a));
      expect(colors.warnTextStrong, const Color(0xFFFFE7B3));
      expect(colors.alertBadge, MuziaColors.light.alertBadge);
      expect(theme.dialogTheme.barrierColor, colors.overlay);
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

  testWidgets('アプリにライト/ダーク両方のMuziaテーマが設定され、表示はライトに固定される', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.extension<MuziaColors>(), MuziaColors.light);
    expect(app.darkTheme?.extension<MuziaColors>(), MuziaColors.dark);
    expect(app.themeMode, ThemeMode.light);
  });

  testWidgets('OSがダークモードでもライトテーマで描画される', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AppShellPage));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).extension<MuziaColors>(), MuziaColors.light);
  });

  testWidgets('ダイアログのスクリムに overlay トークンが使われる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MuziaTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(title: Text('dialog')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final barrier = tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
    expect(barrier.color, MuziaColors.light.overlay);
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
