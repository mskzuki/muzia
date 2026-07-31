import 'package:flutter/material.dart';

class LibraryRemovalDialog extends StatelessWidget {
  const LibraryRemovalDialog({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
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
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('ライブラリから削除'),
        ),
      ],
    );
  }
}
