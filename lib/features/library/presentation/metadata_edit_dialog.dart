import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muzia/features/library/domain/bulk_edit_plan.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
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

/// アルバム情報の一括編集ダイアログ（`18-bulk-dialog`、ハンドオフ §14）。
///
/// 4項目を常時表示し、空欄のままの項目は変更しない。保存すると [BulkEditPlan]
/// を返し、呼び出し側が確認ダイアログを表示してから適用する。
class BulkMetadataEditDialog extends StatefulWidget {
  const BulkMetadataEditDialog({
    super.key,
    required this.tracks,
    required this.catalog,
    this.initialRequest,
  });

  /// 選択中の楽曲。
  final List<Track> tracks;

  /// ライブラリ全体。アルバムの収録曲・既存アルバム名・ジャンル候補の参照に使う。
  final LibraryCatalog catalog;

  /// 確認ダイアログから「戻る」で再表示するときの入力内容。
  final BulkEditRequest? initialRequest;

  @override
  State<BulkMetadataEditDialog> createState() => _BulkMetadataEditDialogState();
}

class _BulkMetadataEditDialogState extends State<BulkMetadataEditDialog> {
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _releaseYear;
  late final TextEditingController _genre;
  late bool _includeUnselectedAlbumTracks;
  String? _albumError;
  String? _releaseYearError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRequest;
    _artist = TextEditingController(text: initial?.artist ?? '');
    _album = TextEditingController(text: initial?.album ?? '');
    _releaseYear = TextEditingController(
      text: initial?.releaseYear?.toString() ?? '',
    );
    _genre = TextEditingController(text: initial?.genre ?? '');
    _includeUnselectedAlbumTracks =
        initial?.includeUnselectedAlbumTracks ?? false;
    for (final controller in [_artist, _album, _releaseYear, _genre]) {
      controller.addListener(_onChanged);
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _artist.dispose();
    _album.dispose();
    _releaseYear.dispose();
    _genre.dispose();
    super.dispose();
  }

  /// 選択した全楽曲で値が一致する場合だけ、その値をプレースホルダに出す。
  /// 値が混在する場合は「複数の値」。
  String _placeholder(String? Function(Track track) selector) {
    final values = widget.tracks.map(selector).toSet();
    if (values.length > 1) return '複数の値';
    return values.single ?? '';
  }

  /// 選択曲が属する唯一のアルバム名。複数アルバムにまたがる場合は null。
  String? get _singleSourceAlbum {
    final albums = widget.tracks.map((track) => track.album).toSet();
    return albums.length == 1 ? albums.single : null;
  }

  /// 「選択していない同じアルバムの曲も含めて変更する」を出す条件:
  /// 選択が単一アルバムの一部である場合のみ（確認事項3: 複数アルバムでは非表示）。
  bool get _showsIncludeAlbumOption {
    final album = _singleSourceAlbum;
    if (album == null) return false;
    final selectedPaths = widget.tracks.map((track) => track.filePath).toSet();
    return widget.catalog
        .tracksFor(album: album)
        .any((track) => !selectedPaths.contains(track.filePath));
  }

  static String? _normalize(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  bool get _hasInput => [
    _artist,
    _album,
    _releaseYear,
    _genre,
  ].any((c) => c.text.trim().isNotEmpty);

  void _save() {
    final yearText = _normalize(_releaseYear);
    final year = yearText == null ? null : int.tryParse(yearText);
    if (yearText != null && (year == null || yearText.length != 4)) {
      setState(() => _releaseYearError = 'リリース年は4桁の数字で入力してください。');
      return;
    }
    final plan = planBulkEdit(
      selected: widget.tracks,
      catalog: widget.catalog,
      request: BulkEditRequest(
        artist: _normalize(_artist),
        album: _normalize(_album),
        releaseYear: year,
        genre: _normalize(_genre),
        includeUnselectedAlbumTracks:
            _showsIncludeAlbumOption && _includeUnselectedAlbumTracks,
      ),
    );
    if (!plan.isValid) {
      setState(() => _albumError = plan.error);
      return;
    }
    Navigator.of(context).pop(plan);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final genre = _genre.text.trim();
    final sourceAlbum = _singleSourceAlbum;
    final albumCount = widget.tracks.map((track) => track.album).toSet().length;
    final yearPlaceholder = _placeholder(
      (track) => track.releaseYear?.toString(),
    );
    return MuziaDialog(
      title: 'アルバム情報の一括編集',
      width: 440,
      header: Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${widget.tracks.length} 曲を選択中',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.accentText,
                ),
              ),
            ),
            const SizedBox(width: MuziaSpacing.s2),
            Expanded(
              child: Text(
                sourceAlbum ?? '$albumCount 枚のアルバム',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: colors.fgTertiary),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: colors.rowStripe,
              borderRadius: BorderRadius.circular(MuziaRadius.r3),
            ),
            child: Text(
              '曲名とトラック番号は、重複を避けるため一括編集できません。',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                color: colors.fgTertiary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _BulkField(
            label: 'アーティスト',
            child: MuziaTextInput(
              key: const ValueKey('bulk-artist'),
              controller: _artist,
              hintText: _placeholder((track) => track.artist),
            ),
          ),
          const SizedBox(height: 14),
          _BulkField(
            label: 'アルバム名',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MuziaTextInput(
                  key: const ValueKey('bulk-album'),
                  controller: _album,
                  hintText: _placeholder((track) => track.album),
                  errorText: _albumError,
                  onChanged: (_) {
                    if (_albumError != null) setState(() => _albumError = null);
                  },
                ),
                if (_showsIncludeAlbumOption) ...[
                  const SizedBox(height: 9),
                  InkWell(
                    key: const ValueKey('bulk-include-album'),
                    borderRadius: BorderRadius.circular(MuziaRadius.r2),
                    onTap: () => setState(
                      () => _includeUnselectedAlbumTracks =
                          !_includeUnselectedAlbumTracks,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                          height: 15,
                          child: Checkbox(
                            value: _includeUnselectedAlbumTracks,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (value) => setState(
                              () => _includeUnselectedAlbumTracks =
                                  value ?? false,
                            ),
                          ),
                        ),
                        const SizedBox(width: MuziaSpacing.s2),
                        Text(
                          '選択していない同じアルバムの曲も含めて変更する',
                          style: MuziaTextStyles.secondary.copyWith(
                            color: colors.fgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _BulkField(
            label: 'リリース年',
            child: SizedBox(
              width: 120,
              child: MuziaTextInput(
                key: const ValueKey('bulk-release-year'),
                controller: _releaseYear,
                hintText: yearPlaceholder.isEmpty ? 'YYYY' : yearPlaceholder,
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
          const SizedBox(height: 14),
          _BulkField(
            label: 'ジャンル',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MuziaTextInput(
                  key: const ValueKey('bulk-genre'),
                  controller: _genre,
                  hintText: _placeholder((track) => track.genre),
                ),
                if (widget.catalog.genres.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final suggestion in widget.catalog.genres)
                        MuziaChip(
                          key: ValueKey('bulk-genre-chip-$suggestion'),
                          label: suggestion,
                          selected: suggestion == genre,
                          onTap: () => _genre
                            ..text = suggestion
                            ..selection = TextSelection.collapsed(
                              offset: suggestion.length,
                            ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      footer: MuziaDialogActions(
        confirmLabel: '保存',
        onConfirm: _hasInput ? _save : null,
      ),
    );
  }
}

/// 一括編集のフォーム項目（`.albf`）。ラベルは 13px/medium の fgSecondary。
class _BulkField extends StatelessWidget {
  const _BulkField({required this.label, required this.child});

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
          style: MuziaTextStyles.rowTitle.copyWith(color: colors.fgSecondary),
        ),
        const SizedBox(height: 11),
        child,
      ],
    );
  }
}
