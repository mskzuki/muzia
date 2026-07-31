/// アプリ上で編集できるメタデータ項目。
enum MetadataField { title, artist, album, releaseInfo }

const Set<MetadataField> _allMetadataFields = {
  MetadataField.title,
  MetadataField.artist,
  MetadataField.album,
  MetadataField.releaseInfo,
};

/// メタデータの更新内容。
///
/// [fields] に含まれる項目だけが書き込み対象になる。含まれない項目は、
/// 呼び出し先で現在値が保持される。「未指定」と「空にする」を区別するために必要で、
/// 一括編集で入力しなかった項目が消えるのを防ぐ。
class MetadataValues {
  /// 4項目すべてを指定する。個別編集のように、フォームが現在値を全て持つ場合に使う。
  const MetadataValues({this.title, this.artist, this.album, this.releaseInfo})
    : fields = _allMetadataFields;

  /// [fields] に指定した項目だけを更新する。一括編集のように、
  /// 一部の項目だけを対象にする場合に使う。
  const MetadataValues.partial({
    required this.fields,
    this.title,
    this.artist,
    this.album,
    this.releaseInfo,
  });

  final String? title;
  final String? artist;
  final String? album;
  final String? releaseInfo;
  final Set<MetadataField> fields;

  /// [field] が更新対象かどうか。
  bool changes(MetadataField field) => fields.contains(field);

  /// [field] に書き込む値。更新対象でない場合に呼び出してはならない。
  String? valueOf(MetadataField field) => switch (field) {
    MetadataField.title => title,
    MetadataField.artist => artist,
    MetadataField.album => album,
    MetadataField.releaseInfo => releaseInfo,
  };
}
