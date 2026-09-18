import 'package:flutter/material.dart';

/// デザインハンドオフ（docs/design_handoff/DESIGN_TOKENS.md）のセマンティックカラー。
/// Widgetは生のhexを書かず、`Theme.of(context).extension<MuziaColors>()!` を参照する。
class MuziaColors extends ThemeExtension<MuziaColors> {
  const MuziaColors({
    required this.accent,
    required this.accentHover,
    required this.accentText,
    required this.accentSoft,
    required this.onAccent,
    required this.fgPrimary,
    required this.fgSecondary,
    required this.fgTertiary,
    required this.windowBg,
    required this.sidebarBg,
    required this.panel,
    required this.rowStripe,
    required this.rowHover,
    required this.borderSubtle,
    required this.warn,
    required this.warnText,
    required this.warnSurface,
    required this.warnTextStrong,
    required this.destructive,
    required this.alertBadge,
    required this.overlay,
    required this.panelTranslucent,
    required this.sliderTrack,
    required this.rowDivider,
    required this.accentBorder,
    required this.warnBorder,
    required this.highlight,
  });

  final Color accent;
  final Color accentHover;
  final Color accentText;
  final Color accentSoft;
  final Color onAccent;
  final Color fgPrimary;
  final Color fgSecondary;
  final Color fgTertiary;
  final Color windowBg;
  final Color sidebarBg;
  final Color panel;
  final Color rowStripe;
  final Color rowHover;
  final Color borderSubtle;
  final Color warn;
  final Color warnText;
  final Color warnSurface;

  /// 警告バナー本文（amber-12）。
  final Color warnTextStrong;
  final Color destructive;

  /// アラートの警告バッジ背景（red-9）。
  final Color alertBadge;

  /// モーダルのスクリム（black-a6 / ダークは black-a8）。
  final Color overlay;

  /// シートのフッターなど半透明の面。
  final Color panelTranslucent;

  /// スライダーのトラック背景（gray-a4）。
  final Color sliderTrack;

  /// テーブル行間のヘアライン（gray-a2）。
  final Color rowDivider;

  /// アクセント面の縁取り（indigo-a5。選択バーの下罫線など）。
  final Color accentBorder;

  /// 警告面の縁取り（amber-a5。バナーの下罫線）。
  final Color warnBorder;

  /// 検索一致箇所の背景（gold-a4）。
  final Color highlight;

  /// Radixライトパレット（indigo / gray / amber / red）。
  static const light = MuziaColors(
    accent: Color(0xFF3E63DD), // indigo-9
    accentHover: Color(0xFF3358D4), // indigo-10
    accentText: Color(0xFF3A5BC7), // indigo-11
    accentSoft: Color(0xFFEDF2FE), // indigo-3
    onAccent: Color(0xFFFFFFFF),
    fgPrimary: Color(0xFF202020), // gray-12
    fgSecondary: Color(0xFF646464), // gray-11
    fgTertiary: Color(0xFF838383), // gray-10
    windowBg: Color(0xFFFFFFFF),
    sidebarBg: Color(0xFFF6F6F8),
    panel: Color(0xFFFFFFFF),
    rowStripe: Color(0x05000000), // gray-a1 ~2%
    rowHover: Color(0x0F000000), // gray-a3 ~6%
    borderSubtle: Color(0x29000000), // gray-a6 ~16%
    warn: Color(0xFFFFC53D), // amber-9
    warnText: Color(0xFFAD5700), // amber-11
    warnSurface: Color(0xFFFFF7C2), // amber-3
    warnTextStrong: Color(0xFF4F3422), // amber-12
    destructive: Color(0xFFCE2C31), // red-11
    alertBadge: Color(0xFFE5484D), // red-9
    overlay: Color(0x4D000000), // black-a6 ~30%
    panelTranslucent: Color(0xB3FFFFFF), // rgba(255,255,255,0.7)
    sliderTrack: Color(0x14000000), // gray-a4 ~8%
    rowDivider: Color(0x0A000000), // gray-a2 ~4%
    accentBorder: Color(0x473E63DD), // indigo-a5 ~28%
    warnBorder: Color(0x66FFC53D), // amber-a5 ~40%
    highlight: Color(0x3D978365), // gold-a4 ~24%
  );

  /// 同じRadixステップのダークパレット値。
  static const dark = MuziaColors(
    accent: Color(0xFF3E63DD), // indigo-9
    accentHover: Color(0xFF5472E4), // indigo-10 (dark)
    accentText: Color(0xFF9EB1FF), // indigo-11 (dark)
    accentSoft: Color(0xFF182449), // indigo-3 (dark)
    onAccent: Color(0xFFFFFFFF),
    fgPrimary: Color(0xFFEEEEEE), // gray-12 (dark)
    fgSecondary: Color(0xFFB4B4B4), // gray-11 (dark)
    fgTertiary: Color(0xFF7E7E7E), // gray-10 (dark)
    windowBg: Color(0xFF111111), // gray-1 (dark)
    sidebarBg: Color(0xFF191919), // gray-2 (dark)
    panel: Color(0xFF222222), // gray-3 (dark)
    rowStripe: Color(0x05FFFFFF),
    rowHover: Color(0x0FFFFFFF),
    borderSubtle: Color(0x29FFFFFF),
    warn: Color(0xFFFFC53D), // amber-9
    warnText: Color(0xFFFFCA16), // amber-11 (dark)
    warnSurface: Color(0xFF302008), // amber-3 (dark)
    warnTextStrong: Color(0xFFFFE7B3), // amber-12 (dark)
    destructive: Color(0xFFFF9592), // red-11 (dark)
    alertBadge: Color(0xFFE5484D), // red-9
    overlay: Color(0x7A000000), // black-a8 ~48%
    panelTranslucent: Color(0x09FFFFFF), // gray-a2 (dark)
    sliderTrack: Color(0x17FFFFFF), // gray-a4 (dark) ~9%
    rowDivider: Color(0x0AFFFFFF), // gray-a2 (dark)
    accentBorder: Color(0x663E63DD), // indigo-a5 (dark)
    warnBorder: Color(0x66FFC53D), // amber-a5 (dark)
    highlight: Color(0x52978365), // gold-a4 (dark)
  );

  @override
  MuziaColors copyWith({
    Color? accent,
    Color? accentHover,
    Color? accentText,
    Color? accentSoft,
    Color? onAccent,
    Color? fgPrimary,
    Color? fgSecondary,
    Color? fgTertiary,
    Color? windowBg,
    Color? sidebarBg,
    Color? panel,
    Color? rowStripe,
    Color? rowHover,
    Color? borderSubtle,
    Color? warn,
    Color? warnText,
    Color? warnSurface,
    Color? warnTextStrong,
    Color? destructive,
    Color? alertBadge,
    Color? overlay,
    Color? panelTranslucent,
    Color? sliderTrack,
    Color? rowDivider,
    Color? accentBorder,
    Color? warnBorder,
    Color? highlight,
  }) {
    return MuziaColors(
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentText: accentText ?? this.accentText,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      fgPrimary: fgPrimary ?? this.fgPrimary,
      fgSecondary: fgSecondary ?? this.fgSecondary,
      fgTertiary: fgTertiary ?? this.fgTertiary,
      windowBg: windowBg ?? this.windowBg,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      panel: panel ?? this.panel,
      rowStripe: rowStripe ?? this.rowStripe,
      rowHover: rowHover ?? this.rowHover,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      warn: warn ?? this.warn,
      warnText: warnText ?? this.warnText,
      warnSurface: warnSurface ?? this.warnSurface,
      warnTextStrong: warnTextStrong ?? this.warnTextStrong,
      destructive: destructive ?? this.destructive,
      alertBadge: alertBadge ?? this.alertBadge,
      overlay: overlay ?? this.overlay,
      panelTranslucent: panelTranslucent ?? this.panelTranslucent,
      sliderTrack: sliderTrack ?? this.sliderTrack,
      rowDivider: rowDivider ?? this.rowDivider,
      accentBorder: accentBorder ?? this.accentBorder,
      warnBorder: warnBorder ?? this.warnBorder,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  MuziaColors lerp(MuziaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return MuziaColors(
      accent: mix(accent, other.accent),
      accentHover: mix(accentHover, other.accentHover),
      accentText: mix(accentText, other.accentText),
      accentSoft: mix(accentSoft, other.accentSoft),
      onAccent: mix(onAccent, other.onAccent),
      fgPrimary: mix(fgPrimary, other.fgPrimary),
      fgSecondary: mix(fgSecondary, other.fgSecondary),
      fgTertiary: mix(fgTertiary, other.fgTertiary),
      windowBg: mix(windowBg, other.windowBg),
      sidebarBg: mix(sidebarBg, other.sidebarBg),
      panel: mix(panel, other.panel),
      rowStripe: mix(rowStripe, other.rowStripe),
      rowHover: mix(rowHover, other.rowHover),
      borderSubtle: mix(borderSubtle, other.borderSubtle),
      warn: mix(warn, other.warn),
      warnText: mix(warnText, other.warnText),
      warnSurface: mix(warnSurface, other.warnSurface),
      warnTextStrong: mix(warnTextStrong, other.warnTextStrong),
      destructive: mix(destructive, other.destructive),
      alertBadge: mix(alertBadge, other.alertBadge),
      overlay: mix(overlay, other.overlay),
      panelTranslucent: mix(panelTranslucent, other.panelTranslucent),
      sliderTrack: mix(sliderTrack, other.sliderTrack),
      rowDivider: mix(rowDivider, other.rowDivider),
      accentBorder: mix(accentBorder, other.accentBorder),
      warnBorder: mix(warnBorder, other.warnBorder),
      highlight: mix(highlight, other.highlight),
    );
  }
}

/// 4pxベースのスペーシングスケール。
abstract final class MuziaSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s7 = 40;
  static const double s8 = 48;
  static const double s9 = 64;
}

/// 角丸スケール（medium mode）。
abstract final class MuziaRadius {
  static const double r1 = 3;
  static const double r2 = 4;
  static const double r3 = 6;
  static const double r4 = 8;
  static const double r5 = 12;
  static const double r6 = 16;
}

/// タイポグラフィ（システムフォント前提のサイズ/ウェイト）。
abstract final class MuziaTextStyles {
  static const heroTitle = TextStyle(
    fontSize: 33,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.33,
  );
  static const screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const windowTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static const rowTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  static const body = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static const secondary = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.44,
  );
}

/// エレベーション（DESIGN_TOKENS.md §5）。
///
/// shadow-1 はテキスト入力のインセットヘアラインで、Flutterでは [BoxShadow] で
/// 内側の影を表現できないため、`Border.all(color: colors.borderSubtle)` で代替する。
/// shadow-5/6（ダイアログ・メニュー）は [Dialog] / [PopupMenuButton] の
/// elevation に任せる。
abstract final class MuziaShadows {
  /// shadow-2: カード・カバー用の弱い影。
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// shadow-3: カードのホバー・ドロップダウン用の浮き上がり。
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x24000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

/// モーション（DESIGN_TOKENS.md §6）。
abstract final class MuziaMotion {
  /// `cubic-bezier(0.16, 1, 0.3, 1)`。スプリングに近い減速カーブ。
  static const Curve curve = Cubic(0.16, 1, 0.3, 1);

  static const Duration open = Duration(milliseconds: 160);
  static const Duration close = Duration(milliseconds: 100);

  /// 再生中イコライザのループ周期。
  static const Duration equalizerLoop = Duration(milliseconds: 900);

  /// OSの視差効果軽減（Reduce Motion）が有効なら [Duration.zero] を返す。
  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}

/// トークンを反映した [ThemeData] を組み立てる。
abstract final class MuziaTheme {
  static ThemeData light() => _build(Brightness.light, MuziaColors.light);

  static ThemeData dark() => _build(Brightness.dark, MuziaColors.dark);

  static ThemeData _build(Brightness brightness, MuziaColors colors) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent,
          brightness: brightness,
        ).copyWith(
          primary: colors.accent,
          onPrimary: colors.onAccent,
          surface: colors.windowBg,
          onSurface: colors.fgPrimary,
          error: colors.destructive,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.windowBg,
      dividerColor: colors.borderSubtle,
      splashFactory: NoSplash.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MuziaRadius.r3),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.panel,
        barrierColor: colors.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MuziaRadius.r5),
        ),
      ),
      extensions: [colors],
    );
  }
}
