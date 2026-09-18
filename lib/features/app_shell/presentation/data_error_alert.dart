import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';
import 'package:muzia/shared/widgets/muzia_dialog.dart';

/// ライブラリを開けない致命的エラーのアラート（`12-error`）。
///
/// 背後のコンテンツを [MuziaColors.overlay] のスクリムで覆い、中央に 296px の
/// アラートを重ねる。Enter で「再試行」を実行する。
class DataErrorAlert extends StatefulWidget {
  const DataErrorAlert({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onQuit,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  @override
  State<DataErrorAlert> createState() => _DataErrorAlertState();
}

class _DataErrorAlertState extends State<DataErrorAlert> {
  final _focusNode = FocusNode(debugLabel: 'data-error-alert');

  @override
  void initState() {
    super.initState();
    // ページ側の autofocus に負けないよう、表示後に明示的にフォーカスを取る。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final onRetry = widget.onRetry;
    final onQuit = widget.onQuit;
    final message = widget.message;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): onRetry,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): onRetry,
      },
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          key: const ValueKey('data-error-scrim'),
          color: colors.overlay,
          alignment: Alignment.center,
          child: Container(
            key: const ValueKey('data-error-alert'),
            width: 296,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: colors.panel,
              borderRadius: BorderRadius.circular(MuziaRadius.r5),
              border: Border.all(color: colors.borderSubtle, width: 0.5),
              boxShadow: MuziaShadows.raised,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AppIconWithBadge(colors: colors),
                const SizedBox(height: 12),
                Text(
                  'ライブラリを開けません',
                  textAlign: TextAlign.center,
                  style: MuziaTextStyles.windowTitle.copyWith(
                    color: colors.fgPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: MuziaTextStyles.secondary.copyWith(
                    color: colors.fgSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('data-error-retry'),
                    onPressed: onRetry,
                    child: const Text('再試行'),
                  ),
                ),
                const SizedBox(height: MuziaSpacing.s2),
                SizedBox(
                  width: double.infinity,
                  child: MuziaSoftButton(
                    key: const ValueKey('data-error-quit'),
                    onPressed: onQuit,
                    child: const Text('終了'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// アプリアイコンのプレースホルダ（ブランド未決定）+ 赤い警告バッジ。
class _AppIconWithBadge extends StatelessWidget {
  const _AppIconWithBadge({required this.colors});

  final MuziaColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.accent, colors.accentText],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: MuziaShadows.raised,
            ),
            child: Icon(Icons.music_note, size: 30, color: colors.onAccent),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colors.alertBadge,
                shape: BoxShape.circle,
                border: Border.all(color: colors.panel, width: 2.5),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 13,
                color: colors.onAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
