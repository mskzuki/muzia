import 'package:flutter/material.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

class LibraryRemovalDialog extends StatelessWidget {
  const LibraryRemovalDialog({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return AlertDialog(
      title: const Text('ライブラリから削除'),
      content: Text(
        '$count曲をライブラリから削除しますか？\n\n'
        '元の音楽ファイルは削除、移動、変更されません。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        // 破壊的操作はデザインの destructive(red-11)で示す。
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.destructive,
            foregroundColor: colors.onAccent,
          ),
          child: const Text('ライブラリから削除'),
        ),
      ],
    );
  }
}
