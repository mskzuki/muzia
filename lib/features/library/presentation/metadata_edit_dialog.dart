import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';
import 'package:muzia/shared/widgets/muzia_dialog.dart';

/// 単曲のメタデータ編集ダイアログ（`16-song-edit`）。
///
/// リリース情報（タグ由来の自由記述）はデザインに合わせて編集対象外とし、
/// 保存時も現在値を保持する（課題 2609021646 確認事項4）。
class MetadataEditDialog extends StatefulWidget {
  const MetadataEditDialog({
    super.key,
    required this.track,
    this.genreSuggestions = const [],
  });

  final Track track;

  /// ライブラリ内の既存ジャンル。チップとして提示する。
  final List<String> genreSuggestions;

  /// このダイアログが更新対象にする項目。
  static const fields = <MetadataField>{
    MetadataField.title,
    MetadataField.artist,
    MetadataField.album,
    MetadataField.trackNumber,
    MetadataField.releaseYear,
    MetadataField.genre,
  };

  @override
  State<MetadataEditDialog> createState() => _MetadataEditDialogState();
}

class _MetadataEditDialogState extends State<MetadataEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _trackNumber;
  late final TextEditingController _releaseYear;
  late final TextEditingController _genre;

  String? _titleError;
  String? _trackNumberError;
  String? _releaseYearError;

  @override
  void initState() {
    super.initState();
    final track = widget.track;
    _title = TextEditingController(text: track.title ?? '');
    _artist = TextEditingController(text: track.artist ?? '');
    _album = TextEditingController(text: track.album ?? '');
    _trackNumber = TextEditingController(
      text: track.trackNumber?.toString() ?? '',
    );
    _releaseYear = TextEditingController(
      text: track.releaseYear?.toString() ?? '',
    );
    _genre = TextEditingController(text: track.genre ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _trackNumber.dispose();
    _releaseYear.dispose();
    _genre.dispose();
    super.dispose();
  }

  /// 空欄は `null` として保存する。`''` と `null` が混在すると、
  /// アーティスト一覧の除外条件と楽曲一覧の代替表示がずれるため。
  static String? _normalize(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _save() {
    final title = _normalize(_title);
    final trackNumberText = _normalize(_trackNumber);
    final releaseYearText = _normalize(_releaseYear);
    final trackNumber = trackNumberText == null
        ? null
        : int.tryParse(trackNumberText);
    final releaseYear = releaseYearText == null
        ? null
        : int.tryParse(releaseYearText);

    final titleError = title == null ? '曲名を入力してください。' : null;
    final trackNumberError =
        trackNumberText != null && (trackNumber == null || trackNumber <= 0)
        ? 'トラック番号は1以上の整数で入力してください。'
        : null;
    final releaseYearError =
        releaseYearText != null &&
            (releaseYear == null || releaseYearText.length != 4)
        ? 'リリース年は4桁の数字で入力してください。'
        : null;
    if (titleError != null ||
        trackNumberError != null ||
        releaseYearError != null) {
      setState(() {
        _titleError = titleError;
        _trackNumberError = trackNumberError;
        _releaseYearError = releaseYearError;
      });
      return;
    }

    Navigator.of(context).pop(
      MetadataValues.partial(
        fields: MetadataEditDialog.fields,
        title: title,
        artist: _normalize(_artist),
        album: _normalize(_album),
        trackNumber: trackNumber,
        releaseYear: releaseYear,
        genre: _normalize(_genre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genre = _genre.text.trim();
    return MuziaDialog(
      title: '曲を編集',
      header: _TrackIdentity(track: widget.track),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MuziaDialogField(
            label: '曲名',
            child: MuziaTextInput(
              key: const ValueKey('edit-title'),
              controller: _title,
              autofocus: true,
              errorText: _titleError,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
          ),
          const SizedBox(height: 13),
          MuziaDialogField(
            label: 'アーティスト',
            child: MuziaTextInput(
              key: const ValueKey('edit-artist'),
              controller: _artist,
            ),
          ),
          const SizedBox(height: 13),
          MuziaDialogField(
            label: 'アルバム',
            child: MuziaTextInput(
              key: const ValueKey('edit-album'),
              controller: _album,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: MuziaDialogField(
                  label: 'トラック',
                  child: MuziaTextInput(
                    key: const ValueKey('edit-track-number'),
                    controller: _trackNumber,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    errorText: _trackNumberError,
                    onChanged: (_) {
                      if (_trackNumberError != null) {
                        setState(() => _trackNumberError = null);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: MuziaSpacing.s3),
              SizedBox(
                width: 96,
                child: MuziaDialogField(
                  label: 'リリース年',
                  child: MuziaTextInput(
                    key: const ValueKey('edit-release-year'),
                    controller: _releaseYear,
                    hintText: 'YYYY',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    errorText: _releaseYearError,
                    onChanged: (_) {
                      if (_releaseYearError != null) {
                        setState(() => _releaseYearError = null);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          MuziaDialogField(
            label: 'ジャンル',
            child: MuziaTextInput(
              key: const ValueKey('edit-genre'),
              controller: _genre,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (widget.genreSuggestions.isNotEmpty) ...[
            const SizedBox(height: MuziaSpacing.s2),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final suggestion in widget.genreSuggestions)
                  MuziaChip(
                    key: ValueKey('genre-chip-$suggestion'),
                    label: suggestion,
                    selected: suggestion == genre,
                    onTap: () => setState(() {
                      _genre
                        ..text = suggestion
                        ..selection = TextSelection.collapsed(
                          offset: suggestion.length,
                        );
                    }),
                  ),
              ],
            ),
          ],
        ],
      ),
      footer: MuziaDialogActions(confirmLabel: '保存', onConfirm: _save),
    );
  }
}

/// ヘッダの識別行: プレースホルダカバー + アーティスト + 「曲名 — アルバム」。
/// アートワークはMVP後のためプレースホルダで代替する。
class _TrackIdentity extends StatelessWidget {
  const _TrackIdentity({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final title = track.title ?? track.filePath.split(RegExp(r'[\\/]')).last;
    final primary = track.artist ?? title;
    final secondary = [
      if (track.artist != null) title,
      if (track.album != null) track.album!,
    ].join(' — ');
    return Padding(
      padding: const EdgeInsets.only(top: MuziaSpacing.s3),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.rowHover,
              borderRadius: BorderRadius.circular(MuziaRadius.r2),
              boxShadow: MuziaShadows.card,
            ),
            child: Icon(Icons.music_note, size: 20, color: colors.fgTertiary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.fgPrimary,
                  ),
                ),
                if (secondary.isNotEmpty)
                  Text(
                    secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: colors.fgTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
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
