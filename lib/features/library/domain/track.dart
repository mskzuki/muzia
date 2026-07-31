class Track {
  const Track({
    required this.filePath,
    required this.fileExtension,
    this.title,
    this.artist,
    this.album,
    this.releaseInfo,
  });

  final String filePath;
  final String fileExtension;
  final String? title;
  final String? artist;
  final String? album;
  final String? releaseInfo;
}
