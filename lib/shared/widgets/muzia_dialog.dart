import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

/// デザインハンドオフの中央モーダル（`16-song-edit` / `18-bulk-dialog`）の共通外装。
///
/// ヘッダ（タイトル + 閉じる + 任意の補足行）・スクロールする本文・
/// 等幅2ボタンのフッタを、ヘアラインで区切って縦に並べる。
class MuziaDialog extends StatelessWidget {
  const MuziaDialog({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.header,
    this.width = 470,
    this.onClose,
  });

  final String title;

  /// タイトル行の下に置く補足（曲の識別情報など）。
  final Widget? header;
  final Widget body;
  final Widget footer;
  final double width;

  /// 閉じるボタンの動作。未指定ならダイアログを閉じる。
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MuziaRadius.r5),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: MuziaTextStyles.windowTitle.copyWith(
                            color: colors.fgPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '閉じる',
                        icon: const Icon(Icons.close, size: 15),
                        color: colors.fgTertiary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 26,
                          height: 26,
                        ),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MuziaRadius.r2),
                          ),
                        ),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  ?header,
                ],
              ),
            ),
            _Hairline(color: colors.borderSubtle),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: body,
              ),
            ),
            _Hairline(color: colors.borderSubtle),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

/// フッタの「キャンセル / 確定」。2つのボタンを等幅で並べる。
class MuziaDialogActions extends StatelessWidget {
  const MuziaDialogActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'キャンセル',
    this.onCancel,
  });

  final String confirmLabel;

  /// null なら確定ボタンを無効にする。
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MuziaSoftButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelLabel),
          ),
        ),
        const SizedBox(width: MuziaSpacing.s2),
        Expanded(
          child: SizedBox(
            height: 30,
            child: FilledButton(
              onPressed: onConfirm,
              child: Text(confirmLabel),
            ),
          ),
        ),
      ],
    );
  }
}

/// `.btn.soft`: gray-a3 の面に fgPrimary の文字。
class MuziaSoftButton extends StatelessWidget {
  const MuziaSoftButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return SizedBox(
      height: 30,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: colors.rowHover,
          foregroundColor: colors.fgPrimary,
          textStyle: MuziaTextStyles.rowTitle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MuziaRadius.r3),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// ラベル付きのフォーム項目（`.songd-field`）。
class MuziaDialogField extends StatelessWidget {
  const MuziaDialogField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: colors.fgTertiary,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

/// ダイアログ用のテキスト入力（`.albd-input`）。
///
/// 高さ32・角丸4・ヘアライン枠。フォーカス時はアクセント枠と柔らかいリング、
/// エラー時は赤枠と下部のメッセージを表示する。
class MuziaTextInput extends StatefulWidget {
  const MuziaTextInput({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool autofocus;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  State<MuziaTextInput> createState() => _MuziaTextInputState();
}

class _MuziaTextInputState extends State<MuziaTextInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final focused = _focusNode.hasFocus;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? colors.destructive
        : focused
        ? colors.accent
        : colors.borderSubtle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: colors.windowBg,
            borderRadius: BorderRadius.circular(MuziaRadius.r2),
            border: Border.all(color: borderColor),
            boxShadow: focused && !hasError
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.2),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            style: MuziaTextStyles.body.copyWith(color: colors.fgPrimary),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: MuziaTextStyles.body.copyWith(
                color: colors.fgTertiary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.errorText!,
              style: TextStyle(fontSize: 11.5, color: colors.destructive),
            ),
          ),
      ],
    );
  }
}

/// サジェスト用のチップ（`.albd-gchip`）。
class MuziaChip extends StatefulWidget {
  const MuziaChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  State<MuziaChip> createState() => _MuziaChipState();
}

class _MuziaChipState extends State<MuziaChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final highlighted = _hovered || widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: highlighted ? colors.accentSoft : colors.rowHover,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 11.5,
              color: highlighted ? colors.accentText : colors.fgSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.5, color: color);
  }
}
