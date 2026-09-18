import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/domain/track_sort.dart';
import 'package:muzia/features/library/presentation/track_actions.dart';
import 'package:muzia/shared/format/count_format.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';
import 'package:muzia/shared/widgets/now_playing_equalizer.dart';

/// アーティスト一覧（`03-artists`）→ アーティスト詳細（`05-artist-detail`）→
/// アルバム詳細（`06-album-detail`）のブラウザ。
class ArtistAlbumBrowser extends StatefulWidget {
  ArtistAlbumBrowser({
    super.key,
    required this.tracks,
    this.initialArtist,
    this.initialAlbum,
    TrackActions? actions,
    this.playingPath,
    this.playbackActive = false,
  }) : actions = actions ?? TrackActions.none;

  final List<Track> tracks;

  /// 検索結果などから開く際の初期選択。以降の選択は内部状態で管理する。
  final String? initialArtist;
  final String? initialAlbum;

  /// 楽曲行の再生 / 編集 / 削除。
  final TrackActions actions;
  final String? playingPath;
  final bool playbackActive;

  @override
  State<ArtistAlbumBrowser> createState() => _ArtistAlbumBrowserState();
}

class _ArtistAlbumBrowserState extends State<ArtistAlbumBrowser> {
  late String? _artist = widget.initialArtist;
  late String? _album = widget.initialAlbum;

  @override
  Widget build(BuildContext context) {
    final catalog = LibraryCatalog(widget.tracks);
    final artists = catalog.artists;
    if (artists.isEmpty) {
      return const Center(child: Text('アーティストはありません'));
    }
    final selectedArtist = artists.contains(_artist) ? _artist! : artists.first;
    final albums = catalog.albumsFor(selectedArtist);
    final selectedAlbum = albums.contains(_album) ? _album : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ArtistList(
          artists: artists,
          selectedArtist: selectedArtist,
          catalog: catalog,
          onSelected: (artist) => setState(() {
            _artist = artist;
            _album = null;
          }),
        ),
        Expanded(
          child: selectedAlbum == null
              ? _ArtistDetail(
                  key: ValueKey('artist-detail-$selectedArtist'),
                  artist: selectedArtist,
                  albums: albums,
                  catalog: catalog,
                  actions: widget.actions,
                  playingPath: widget.playingPath,
                  playbackActive: widget.playbackActive,
                  onAlbumSelected: (album) => setState(() => _album = album),
                )
              : _AlbumDetail(
                  key: ValueKey('album-detail-$selectedAlbum'),
                  artist: selectedArtist,
                  album: selectedAlbum,
                  catalog: catalog,
                  actions: widget.actions,
                  playingPath: widget.playingPath,
                  playbackActive: widget.playbackActive,
                  onBack: () => setState(() => _album = null),
                ),
        ),
      ],
    );
  }
}

/// 左のマスター列（`.artist-master`）: 見出し + 件数 + 行一覧。
class _ArtistList extends StatelessWidget {
  const _ArtistList({
    required this.artists,
    required this.selectedArtist,
    required this.catalog,
    required this.onSelected,
  });

  final List<String> artists;
  final String selectedArtist;
  final LibraryCatalog catalog;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Container(
      key: const ValueKey('artist-master'),
      width: 332,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: colors.borderSubtle, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 9),
            child: Text(
              'アーティスト',
              // app.css `.am-head h1` は 26px（README のスクリーンH1 22px と不一致。
              // 2609021654 事象5。px は app.css を正とする）。
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.26,
                color: colors.fgPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 11),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${formatCount(artists.length)} アーティスト',
                  style: MuziaTextStyles.secondary.copyWith(
                    color: colors.fgTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                // MVPにソート機能はないため、並び順（名前順）の表示のみ。
                Icon(Icons.arrow_downward, size: 12, color: colors.fgSecondary),
                const SizedBox(width: 5),
                Text(
                  '名前順',
                  style: MuziaTextStyles.secondary.copyWith(
                    color: colors.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              itemCount: artists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final artist = artists[index];
                return _ArtistRow(
                  key: ValueKey('artist-row-$artist'),
                  artist: artist,
                  summary: catalog.artistSummary(artist),
                  selected: artist == selectedArtist,
                  onTap: () => onSelected(artist),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// アーティスト行（`.am-row`）: 44px 角丸サムネ + 名前 + ジャンル。
class _ArtistRow extends StatelessWidget {
  const _ArtistRow({
    super.key,
    required this.artist,
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  final String artist;
  final ArtistSummary summary;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final subtitle =
        summary.genre ??
        '${formatCount(summary.albumCount)}アルバム · '
            '${formatCount(summary.trackCount)}曲';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MuziaRadius.r3),
        hoverColor: colors.rowStripe,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colors.accentSoft : null,
            borderRadius: BorderRadius.circular(MuziaRadius.r3),
            border: Border.all(
              color: selected ? colors.accentBorder : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              _PlaceholderArt(size: 44, radius: MuziaRadius.r3),
              const SizedBox(width: MuziaSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selected ? colors.accentText : colors.fgPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MuziaTextStyles.secondary.copyWith(
                        color: selected
                            ? colors.accentText
                            : colors.fgSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// アーティスト詳細（`05-artist-detail`）: ヒーロー + アルバムグリッド + 楽曲。
class _ArtistDetail extends StatelessWidget {
  const _ArtistDetail({
    super.key,
    required this.artist,
    required this.albums,
    required this.catalog,
    required this.actions,
    required this.playingPath,
    required this.playbackActive,
    required this.onAlbumSelected,
  });

  final String artist;
  final List<String> albums;
  final LibraryCatalog catalog;
  final TrackActions actions;
  final String? playingPath;
  final bool playbackActive;
  final ValueChanged<String> onAlbumSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final summary = catalog.artistSummary(artist);
    // Top Songs は再生履歴がMVP後のため、全楽曲（アルバム順・トラック順）に読み替える。
    final songs = catalog.tracksFor(artist: artist);
    final meta = [
      '${formatCount(summary.albumCount)}アルバム',
      '${formatCount(summary.trackCount)}曲',
      ?summary.genre,
      if (summary.totalDurationMs > 0)
        formatTotalDuration(summary.totalDurationMs),
    ].join(' · ');
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle, width: 0.5),
            ),
          ),
          child: _Hero(
            gap: 24,
            art: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                color: colors.rowHover,
                shape: BoxShape.circle,
                boxShadow: MuziaShadows.raised,
              ),
              child: Icon(Icons.person, size: 52, color: colors.fgTertiary),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Kicker('アーティスト'),
                const SizedBox(height: 6),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.34,
                    height: 1.04,
                    color: colors.fgPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meta,
                  key: const ValueKey('artist-hero-meta'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MuziaTextStyles.body.copyWith(
                    color: colors.fgSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _PlayButton(
                  key: const ValueKey('artist-play'),
                  enabled: songs.isNotEmpty,
                  onPressed: () => actions.onPlay(songs.first, queue: songs),
                ),
              ],
            ),
          ),
        ),
        if (albums.isNotEmpty) ...[
          const _SectionTitle('アルバム'),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 4;
                const gap = 18.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final album in albums)
                      SizedBox(
                        width: width,
                        child: _AlbumCard(
                          key: ValueKey('album-card-$album'),
                          album: album,
                          summary: catalog.albumSummary(album, artist: artist),
                          onTap: () => onAlbumSelected(album),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
        if (songs.isNotEmpty) ...[
          const _SectionTitle('楽曲'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: [
                for (final (index, track) in songs.indexed)
                  _TopSongRow(
                    key: ValueKey('artist-song-$index'),
                    index: index,
                    track: track,
                    queue: songs,
                    playing: playingPath == track.filePath,
                    playbackActive: playbackActive,
                    actions: actions,
                    catalog: catalog,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// アルバム詳細（`06-album-detail`）: ヒーロー + # / タイトル / 時間 のトラックリスト。
class _AlbumDetail extends StatelessWidget {
  const _AlbumDetail({
    super.key,
    required this.artist,
    required this.album,
    required this.catalog,
    required this.actions,
    required this.playingPath,
    required this.playbackActive,
    required this.onBack,
  });

  final String artist;
  final String album;
  final LibraryCatalog catalog;
  final TrackActions actions;
  final String? playingPath;
  final bool playbackActive;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final tracks = catalog.tracksFor(artist: artist, album: album);
    final summary = catalog.albumSummary(album, artist: artist);
    final meta = [
      if (summary.releaseYear != null) '${summary.releaseYear}',
      '${formatCount(summary.trackCount)}曲',
      if (summary.totalDurationMs > 0)
        formatTotalDuration(summary.totalDurationMs),
    ].join(' · ');
    final headerStyle = MuziaTextStyles.caption.copyWith(
      color: colors.fgTertiary,
    );
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 戻る/進むチェブロンは見送ったため、アーティスト詳細へ戻る導線をここに置く。
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('album-back'),
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left, size: 16),
              label: Text(artist),
              style: TextButton.styleFrom(
                foregroundColor: colors.fgSecondary,
                textStyle: MuziaTextStyles.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: MuziaSpacing.s2,
                ),
                minimumSize: const Size(0, 28),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(34, 8, 34, 26),
          child: _Hero(
            gap: 26,
            art: Container(
              width: 184,
              height: 184,
              decoration: BoxDecoration(
                color: colors.rowHover,
                borderRadius: BorderRadius.circular(MuziaRadius.r4),
                boxShadow: MuziaShadows.raised,
              ),
              child: Icon(
                Icons.album_outlined,
                size: 64,
                color: colors.fgTertiary,
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Kicker('アルバム'),
                const SizedBox(height: 6),
                Text(
                  album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // app.css `.ad-hero h1` 42px（README §6 は 32px。2609021654 事象5）。
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.42,
                    height: 1.04,
                    color: colors.fgPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, color: colors.fgSecondary),
                ),
                const SizedBox(height: 10),
                Text(
                  meta,
                  key: const ValueKey('album-hero-meta'),
                  style: MuziaTextStyles.body.copyWith(
                    color: colors.fgSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 16),
                _PlayButton(
                  key: const ValueKey('album-play'),
                  enabled: tracks.isNotEmpty,
                  onPressed: () => actions.onPlay(tracks.first, queue: tracks),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.borderSubtle, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      child: Text(
                        '#',
                        textAlign: TextAlign.center,
                        style: headerStyle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text('タイトル', style: headerStyle)),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '時間',
                        textAlign: TextAlign.right,
                        style: headerStyle,
                      ),
                    ),
                  ],
                ),
              ),
              for (final (index, track) in tracks.indexed)
                _AlbumTrackRow(
                  key: ValueKey('album-track-$index'),
                  index: index,
                  track: track,
                  queue: tracks,
                  playing: playingPath == track.filePath,
                  playbackActive: playbackActive,
                  actions: actions,
                  catalog: catalog,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// アルバムカード（`.albcard`）: 正方形カバー + アルバム名 + 年。
class _AlbumCard extends StatefulWidget {
  const _AlbumCard({
    super.key,
    required this.album,
    required this.summary,
    required this.onTap,
  });

  final String album;
  final AlbumSummary summary;
  final VoidCallback onTap;

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.rowHover,
                  borderRadius: BorderRadius.circular(MuziaRadius.r3),
                  boxShadow: _hovered ? MuziaShadows.raised : MuziaShadows.card,
                ),
                child: Icon(
                  Icons.album_outlined,
                  size: 42,
                  color: colors.fgTertiary,
                ),
              ),
            ),
            const SizedBox(height: MuziaSpacing.s2),
            Text(
              widget.album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: colors.fgPrimary,
              ),
            ),
            if (widget.summary.releaseYear != null)
              Text(
                '${widget.summary.releaseYear}',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.fgTertiary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// アーティスト詳細の楽曲行（`.ts-row`）: 番号 + 28px カバー + タイトル + アルバム + 時間。
class _TopSongRow extends StatelessWidget {
  const _TopSongRow({
    super.key,
    required this.index,
    required this.track,
    required this.queue,
    required this.playing,
    required this.playbackActive,
    required this.actions,
    required this.catalog,
  });

  final int index;
  final Track track;
  final List<Track> queue;
  final bool playing;
  final bool playbackActive;
  final TrackActions actions;
  final LibraryCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final titleColor = playing ? colors.accentText : colors.fgPrimary;
    return _InteractiveRow(
      track: track,
      queue: queue,
      actions: actions,
      catalog: catalog,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: BorderRadius.circular(MuziaRadius.r2),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: playing
                ? NowPlayingEqualizer(
                    color: colors.accent,
                    animating: playbackActive,
                  )
                : Text(
                    '${index + 1}',
                    textAlign: TextAlign.right,
                    style: MuziaTextStyles.body.copyWith(
                      color: colors.fgTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
          const SizedBox(width: 11),
          _PlaceholderArt(size: 28, radius: MuziaRadius.r1),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              track.title?.isNotEmpty == true ? track.title! : 'タイトル不明',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.rowTitle.copyWith(color: titleColor),
            ),
          ),
          const SizedBox(width: 11),
          Flexible(
            child: Text(
              track.album ?? 'アルバム不明',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.secondary.copyWith(
                color: colors.fgTertiary,
              ),
            ),
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 40,
            child: Text(
              formatTrackDuration(track.durationMs),
              textAlign: TextAlign.right,
              style: MuziaTextStyles.secondary.copyWith(
                color: colors.fgTertiary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// アルバム詳細のトラック行（`.ad-trk`）: # / タイトル / 時間。# はトラック番号。
class _AlbumTrackRow extends StatelessWidget {
  const _AlbumTrackRow({
    super.key,
    required this.index,
    required this.track,
    required this.queue,
    required this.playing,
    required this.playbackActive,
    required this.actions,
    required this.catalog,
  });

  final int index;
  final Track track;
  final List<Track> queue;
  final bool playing;
  final bool playbackActive;
  final TrackActions actions;
  final LibraryCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final fg = playing ? colors.accentText : null;
    return _InteractiveRow(
      track: track,
      queue: queue,
      actions: actions,
      catalog: catalog,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: playing ? colors.accentSoft : null,
      bottomBorder: playing ? Colors.transparent : colors.rowDivider,
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: playing
                ? NowPlayingEqualizer(
                    color: colors.accent,
                    animating: playbackActive,
                    alignment: Alignment.center,
                  )
                : Text(
                    '${track.trackNumber ?? index + 1}',
                    textAlign: TextAlign.center,
                    style: MuziaTextStyles.body.copyWith(
                      color: fg ?? colors.fgTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              track.title?.isNotEmpty == true ? track.title! : 'タイトル不明',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: fg ?? colors.fgPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 56,
            child: Text(
              formatTrackDuration(track.durationMs),
              textAlign: TextAlign.right,
              style: MuziaTextStyles.body.copyWith(
                color: fg ?? colors.fgTertiary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ダブルクリックで再生、右クリックでコンテキストメニューを開く行。
class _InteractiveRow extends StatefulWidget {
  const _InteractiveRow({
    required this.track,
    required this.queue,
    required this.actions,
    required this.catalog,
    required this.height,
    required this.padding,
    required this.child,
    this.color,
    this.borderRadius,
    this.bottomBorder,
  });

  final Track track;

  /// 行が属する一覧。再生時の暗黙のキューになる。
  final List<Track> queue;
  final TrackActions actions;
  final LibraryCatalog catalog;
  final double height;
  final EdgeInsets padding;
  final Widget child;
  final Color? color;
  final BorderRadius? borderRadius;
  final Color? bottomBorder;

  @override
  State<_InteractiveRow> createState() => _InteractiveRowState();
}

class _InteractiveRowState extends State<_InteractiveRow> {
  bool _hovered = false;

  Future<void> _showMenu(Offset position) async {
    final action = await showTrackContextMenu(context, position);
    if (!mounted) return;
    switch (action) {
      case TrackMenuAction.play:
        widget.actions.onPlay(widget.track, queue: widget.queue);
      case TrackMenuAction.edit:
        await widget.actions.editTrack(context, widget.track, widget.catalog);
      case TrackMenuAction.remove:
        await widget.actions.confirmRemove(context, [widget.track]);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kSecondaryMouseButton) {
          unawaited(_showMenu(event.position));
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () =>
              widget.actions.onPlay(widget.track, queue: widget.queue),
          child: Container(
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color ?? (_hovered ? colors.rowStripe : null),
              borderRadius: widget.borderRadius,
              border: widget.bottomBorder == null
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: widget.bottomBorder!,
                        width: 0.5,
                      ),
                    ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// ヒーロー（カバー + テキスト）。幅が足りないときは縦積みにして溢れを防ぐ。
class _Hero extends StatelessWidget {
  const _Hero({required this.art, required this.body, required this.gap});

  final Widget art;
  final Widget body;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              art,
              SizedBox(height: gap),
              body,
            ],
          );
        }
        return Row(
          children: [
            art,
            SizedBox(width: gap),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.play_arrow, size: 15),
        label: const Text('再生'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: MuziaTextStyles.rowTitle,
        ),
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Text(
      label,
      style: MuziaTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.77,
        color: colors.accentText,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
      child: Text(
        label,
        style: MuziaTextStyles.sectionTitle.copyWith(color: colors.fgPrimary),
      ),
    );
  }
}

/// アートワーク（MVP後）の代替プレースホルダ。
class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.size, required this.radius});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.rowHover,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: MuziaShadows.card,
      ),
      child: Icon(
        Icons.music_note,
        size: size * 0.45,
        color: colors.fgTertiary,
      ),
    );
  }
}
