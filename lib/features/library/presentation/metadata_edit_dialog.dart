import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';

class MetadataEditDialog extends StatefulWidget {
  const MetadataEditDialog({super.key, required this.track});

  final Track track;

  @override
  State<MetadataEditDialog> createState() => _MetadataEditDialogState();
}

class _MetadataEditDialogState extends State<MetadataEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _releaseInfo;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.track.title ?? '');
    _artist = TextEditingController(text: widget.track.artist ?? '');
    _album = TextEditingController(text: widget.track.album ?? '');
    _releaseInfo = TextEditingController(text: widget.track.releaseInfo ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _releaseInfo.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      MetadataValues(
        title: _title.text.trim(),
        artist: _artist.text.trim(),
        album: _album.text.trim(),
        releaseInfo: _releaseInfo.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('曲を編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: '曲名'),
            ),
            TextField(
              controller: _artist,
              decoration: const InputDecoration(labelText: 'アーティスト'),
            ),
            TextField(
              controller: _album,
              decoration: const InputDecoration(labelText: 'アルバム'),
            ),
            TextField(
              controller: _releaseInfo,
              decoration: const InputDecoration(labelText: 'リリース情報'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}

class BulkMetadataEditDialog extends StatefulWidget {
  const BulkMetadataEditDialog({super.key, required this.count});

  final int count;

  @override
  State<BulkMetadataEditDialog> createState() => _BulkMetadataEditDialogState();
}

class _BulkMetadataEditDialogState extends State<BulkMetadataEditDialog> {
  final _artist = TextEditingController();
  final _album = TextEditingController();
  final _releaseInfo = TextEditingController();

  @override
  void dispose() {
    _artist.dispose();
    _album.dispose();
    _releaseInfo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('アルバム情報の一括編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.count}曲を選択中',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            const Text('曲名とトラック番号は、重複を避けるため一括編集できません。'),
            TextField(
              controller: _artist,
              decoration: const InputDecoration(labelText: 'アーティスト'),
            ),
            TextField(
              controller: _album,
              decoration: const InputDecoration(labelText: 'アルバム名'),
            ),
            TextField(
              controller: _releaseInfo,
              decoration: const InputDecoration(labelText: 'リリース年'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            MetadataValues(
              artist: _artist.text.trim(),
              album: _album.text.trim(),
              releaseInfo: _releaseInfo.text.trim(),
            ),
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
