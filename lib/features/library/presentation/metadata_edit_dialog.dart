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

  String? _titleError;

  /// 空欄は `null` として保存する。`''` と `null` が混在すると、
  /// アーティスト一覧の除外条件と楽曲一覧の代替表示がずれるため。
  static String? _normalize(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _save() {
    final title = _normalize(_title);
    if (title == null) {
      setState(() => _titleError = '曲名を入力してください。');
      return;
    }
    Navigator.of(context).pop(
      MetadataValues(
        title: title,
        artist: _normalize(_artist),
        album: _normalize(_album),
        releaseInfo: _normalize(_releaseInfo),
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
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: InputDecoration(
                labelText: '曲名',
                errorText: _titleError,
              ),
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

/// 一括編集で対象にできる項目。曲名は楽曲ごとに固有のため含めない。
const bulkEditableFields = <MetadataField>[
  MetadataField.artist,
  MetadataField.album,
  MetadataField.releaseInfo,
];

const _bulkFieldLabels = <MetadataField, String>{
  MetadataField.artist: 'アーティスト',
  MetadataField.album: 'アルバム名',
  MetadataField.releaseInfo: 'リリース年',
};

/// 一括編集の確認表示で使う項目名。
String bulkFieldLabel(MetadataField field) => _bulkFieldLabels[field]!;

class BulkMetadataEditDialog extends StatefulWidget {
  const BulkMetadataEditDialog({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  State<BulkMetadataEditDialog> createState() => _BulkMetadataEditDialogState();
}

class _BulkMetadataEditDialogState extends State<BulkMetadataEditDialog> {
  late final Map<MetadataField, TextEditingController> _controllers;
  final Set<MetadataField> _targetFields = {};

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in bulkEditableFields)
        field: TextEditingController(text: _sharedValue(field) ?? ''),
    };
  }

  /// 選択した全楽曲で値が一致する場合だけ、その値を初期表示する。
  /// 値が混在する場合は空欄にし、チェックするまで書き込まない。
  String? _sharedValue(MetadataField field) =>
      _hasSharedValue(field) ? widget.tracks.first.valueOf(field) : null;

  /// 全楽曲で値が一致するか。全曲が未設定（null）の場合も「一致」とする。
  /// これを [_sharedValue] の戻り値で判定すると、
  /// 「全曲が未設定」と「値が混在」を区別できない。
  bool _hasSharedValue(MetadataField field) =>
      widget.tracks.map((track) => track.valueOf(field)).toSet().length <= 1;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    String? valueFor(MetadataField field) {
      if (!_targetFields.contains(field)) return null;
      final text = _controllers[field]!.text.trim();
      return text.isEmpty ? null : text;
    }

    Navigator.of(context).pop(
      MetadataValues.partial(
        fields: Set.unmodifiable(_targetFields),
        artist: valueFor(MetadataField.artist),
        album: valueFor(MetadataField.album),
        releaseInfo: valueFor(MetadataField.releaseInfo),
      ),
    );
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
              '${widget.tracks.length}曲を選択中',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            const Text('曲名とトラック番号は、重複を避けるため一括編集できません。'),
            const SizedBox(height: 4),
            const Text('チェックした項目だけを変更します。'),
            for (final field in bulkEditableFields) ...[
              CheckboxListTile(
                key: ValueKey('bulk-target-${field.name}'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: _targetFields.contains(field),
                title: Text('${_bulkFieldLabels[field]}を変更する'),
                onChanged: (selected) => setState(() {
                  if (selected == true) {
                    _targetFields.add(field);
                  } else {
                    _targetFields.remove(field);
                  }
                }),
              ),
              TextField(
                controller: _controllers[field],
                enabled: _targetFields.contains(field),
                decoration: InputDecoration(
                  labelText: _bulkFieldLabels[field],
                  hintText: _hasSharedValue(field) ? null : '複数の値',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _targetFields.isEmpty ? null : _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
