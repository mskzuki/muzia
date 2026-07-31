import 'package:muzia/features/library/domain/metadata_values.dart';

class Track {
  const Track({
    required this.filePath,
    required this.fileExtension,
    this.title,
    this.artist,
    this.album,
    this.releaseInfo,
    this.isRemoved = false,
  });

  final String filePath;
  final String fileExtension;
  final String? title;
  final String? artist;
  final String? album;
  final String? releaseInfo;
  final bool isRemoved;

  Track copyWith({
    String? title,
    String? artist,
    String? album,
    String? releaseInfo,
    bool? isRemoved,
  }) {
    return Track(
      filePath: filePath,
      fileExtension: fileExtension,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }

  String? valueOf(MetadataField field) => switch (field) {
    MetadataField.title => title,
    MetadataField.artist => artist,
    MetadataField.album => album,
    MetadataField.releaseInfo => releaseInfo,
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
      isRemoved: isRemoved,
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
        other.isRemoved == isRemoved;
  }

  @override
  int get hashCode => Object.hash(
    filePath,
    fileExtension,
    title,
    artist,
    album,
    releaseInfo,
    isRemoved,
  );
}
