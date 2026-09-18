import 'package:muzia/features/library/domain/metadata_values.dart';

class Track {
  const Track({
    required this.filePath,
    required this.fileExtension,
    this.title,
    this.artist,
    this.album,
    this.releaseInfo,
    this.durationMs,
    this.trackNumber,
    this.releaseYear,
    this.genre,
    this.isRemoved = false,
    this.isAvailable = true,
  });

  final String filePath;
  final String fileExtension;
  final String? title;
  final String? artist;
  final String? album;
  final String? releaseInfo;

  /// 再生時間（ミリ秒）。タグから取得できない場合はnull。
  final int? durationMs;
  final int? trackNumber;

  /// リリース年（4桁）。自由記述の [releaseInfo] とは別に構造化して保持する。
  final int? releaseYear;
  final String? genre;
  final bool isRemoved;

  /// ファイルが前回の確認時点で存在したか。移動・削除されていれば false
  /// （ライブラリには残し、再生せずに理由を表示する）。
  final bool isAvailable;

  Track copyWith({
    String? title,
    String? artist,
    String? album,
    String? releaseInfo,
    int? durationMs,
    int? trackNumber,
    int? releaseYear,
    String? genre,
    bool? isRemoved,
    bool? isAvailable,
  }) {
    return Track(
      filePath: filePath,
      fileExtension: fileExtension,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      durationMs: durationMs ?? this.durationMs,
      trackNumber: trackNumber ?? this.trackNumber,
      releaseYear: releaseYear ?? this.releaseYear,
      genre: genre ?? this.genre,
      isRemoved: isRemoved ?? this.isRemoved,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  /// 数値項目は編集フォームで扱う文字列表現を返す。
  String? valueOf(MetadataField field) => switch (field) {
    MetadataField.title => title,
    MetadataField.artist => artist,
    MetadataField.album => album,
    MetadataField.releaseInfo => releaseInfo,
    MetadataField.trackNumber => trackNumber?.toString(),
    MetadataField.releaseYear => releaseYear?.toString(),
    MetadataField.genre => genre,
  };

  /// [values] が更新対象とした項目だけを差し替える。
  /// 対象外の項目は現在値を保持する。
  Track replaceMetadata(MetadataValues values) {
    return Track(
      filePath: filePath,
      fileExtension: fileExtension,
      title: values.changes(MetadataField.title) ? values.title : title,
      artist: values.changes(MetadataField.artist) ? values.artist : artist,
      album: values.changes(MetadataField.album) ? values.album : album,
      releaseInfo: values.changes(MetadataField.releaseInfo)
          ? values.releaseInfo
          : releaseInfo,
      durationMs: durationMs,
      trackNumber: values.changes(MetadataField.trackNumber)
          ? values.trackNumber
          : trackNumber,
      releaseYear: values.changes(MetadataField.releaseYear)
          ? values.releaseYear
          : releaseYear,
      genre: values.changes(MetadataField.genre) ? values.genre : genre,
      isRemoved: isRemoved,
      isAvailable: isAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Track &&
        other.filePath == filePath &&
        other.fileExtension == fileExtension &&
        other.title == title &&
        other.artist == artist &&
        other.album == album &&
        other.releaseInfo == releaseInfo &&
        other.durationMs == durationMs &&
        other.trackNumber == trackNumber &&
        other.releaseYear == releaseYear &&
        other.genre == genre &&
        other.isRemoved == isRemoved &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode => Object.hash(
    filePath,
    fileExtension,
    title,
    artist,
    album,
    releaseInfo,
    durationMs,
    trackNumber,
    releaseYear,
    genre,
    isRemoved,
    isAvailable,
  );
}
