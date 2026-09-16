import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';

/// 一括編集ダイアログの入力。空欄（null）の項目は変更しない。
class BulkEditRequest {
  const BulkEditRequest({
    this.artist,
    this.album,
    this.releaseYear,
    this.genre,
    this.includeUnselectedAlbumTracks = false,
  });

  final String? artist;
  final String? album;
  final int? releaseYear;
  final String? genre;

  /// アルバム名の変更を、選択していない同じアルバムの曲にも及ぼす（リネーム）。
  /// false なら選択曲だけを新しいアルバム名へ移す（分割）。
  final bool includeUnselectedAlbumTracks;

  bool get isEmpty =>
      artist == null && album == null && releaseYear == null && genre == null;
}

/// 一括編集の適用計画。確認ダイアログの文面と、実際の書き込み対象を持つ。
class BulkEditPlan {
  const BulkEditPlan({
    required this.request,
    required this.targets,
    required this.values,
    required this.summary,
    this.error,
  });

  final BulkEditRequest request;

  /// 書き込み対象の楽曲。リネーム時は選択外のアルバム収録曲を含む。
  final List<Track> targets;
  final MetadataValues values;

  /// 確認ダイアログに箇条書きで示す変更内容。
  final List<String> summary;

  /// 適用できない理由（既存アルバム名への変更など）。null なら適用可。
  final String? error;

  bool get isValid => error == null;
}

/// 選択曲とライブラリの状態から一括編集の適用計画を組み立てる。
///
/// - アルバム名の変更先がライブラリ内の既存アルバムと一致する場合は、
///   暗黙のマージを避けるため [BulkEditPlan.error] で保存をブロックする。
/// - 選択が単一アルバムの一部で、[BulkEditRequest.includeUnselectedAlbumTracks]
///   が true のときは、そのアルバムの全曲を対象にする（他の項目も同じ対象に適用する）。
BulkEditPlan planBulkEdit({
  required List<Track> selected,
  required LibraryCatalog catalog,
  required BulkEditRequest request,
}) {
  final selectedPaths = selected.map((track) => track.filePath).toSet();
  final sourceAlbums = selected.map((track) => track.album).toSet();
  final singleSourceAlbum = sourceAlbums.length == 1
      ? sourceAlbums.single
      : null;

  final targets = List<Track>.of(selected);
  final summary = <String>[];
  final fields = <MetadataField>{};
  String? error;

  final newAlbum = request.album;
  final albumChanges = newAlbum != null && newAlbum != singleSourceAlbum;
  if (albumChanges) {
    if (catalog.albums.contains(newAlbum)) {
      error = '「$newAlbum」という名前のアルバムが既に存在します。';
    } else if (singleSourceAlbum != null) {
      final members = catalog.tracksFor(album: singleSourceAlbum);
      final unselected = members
          .where((track) => !selectedPaths.contains(track.filePath))
          .toList(growable: false);
      if (unselected.isEmpty) {
        summary.add(
          'アルバム「$singleSourceAlbum」（${selected.length} 曲）を'
          '「$newAlbum」に変更します。',
        );
      } else if (request.includeUnselectedAlbumTracks) {
        targets.addAll(unselected);
        summary.add(
          'アルバム「$singleSourceAlbum」の全 ${members.length} 曲'
          '（選択していない ${unselected.length} 曲を含む）を「$newAlbum」に変更します。',
        );
      } else {
        summary.add(
          '選択した ${selected.length} 曲だけを「$newAlbum」へ分割します。'
          '残り ${unselected.length} 曲は「$singleSourceAlbum」のままです。',
        );
      }
    } else {
      summary.add('選択した ${selected.length} 曲のアルバム名を「$newAlbum」に変更します。');
    }
    fields.add(MetadataField.album);
  }

  final count = targets.length;
  if (request.artist != null) {
    fields.add(MetadataField.artist);
    summary.add('アーティストを「${request.artist}」に変更します（$count 曲）。');
  }
  if (request.releaseYear != null) {
    fields.add(MetadataField.releaseYear);
    summary.add('リリース年を ${request.releaseYear} に変更します（$count 曲）。');
  }
  if (request.genre != null) {
    fields.add(MetadataField.genre);
    summary.add('ジャンルを「${request.genre}」に変更します（$count 曲）。');
  }
  if (fields.isEmpty && error == null) {
    error = '変更する項目を入力してください。';
  }

  return BulkEditPlan(
    request: request,
    targets: targets,
    values: MetadataValues.partial(
      fields: Set.unmodifiable(fields),
      artist: request.artist,
      album: albumChanges ? newAlbum : null,
      releaseYear: request.releaseYear,
      genre: request.genre,
    ),
    summary: summary,
    error: error,
  );
}
