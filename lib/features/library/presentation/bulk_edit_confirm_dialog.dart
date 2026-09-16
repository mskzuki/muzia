import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/bulk_edit_plan.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

/// 一括編集の確認ダイアログ（`19-bulk-confirm`）。
///
/// 「適用」で true、「戻る」で false を返す。バリア操作で閉じた場合は null。
class BulkEditConfirmDialog extends StatelessWidget {
  const BulkEditConfirmDialog({super.key, required this.plan});

  final BulkEditPlan plan;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MuziaRadius.r5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '次の変更を適用します',
                style: MuziaTextStyles.sectionTitle.copyWith(
                  color: colors.fgPrimary,
                ),
              ),
              const SizedBox(height: 10),
              for (final line in plan.summary)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: MuziaTextStyles.body.copyWith(
                          color: colors.fgPrimary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(width: MuziaSpacing.s2),
                      Expanded(
                        child: Text(
                          line,
                          style: MuziaTextStyles.body.copyWith(
                            color: colors.fgPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: MuziaSpacing.s2),
              Text(
                'ファイルには書き込まれません（編集はライブラリ内にのみ保存されます）。',
                style: MuziaTextStyles.secondary.copyWith(
                  color: colors.fgTertiary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.fgSecondary,
                      textStyle: MuziaTextStyles.rowTitle,
                    ),
                    child: const Text('戻る'),
                  ),
                  const SizedBox(width: MuziaSpacing.s2),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('適用'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
