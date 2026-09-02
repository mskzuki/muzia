import 'package:flutter/material.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/track.dart';

class ArtistAlbumBrowser extends StatefulWidget {
  const ArtistAlbumBrowser({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  State<ArtistAlbumBrowser> createState() => _ArtistAlbumBrowserState();
}

class _ArtistAlbumBrowserState extends State<ArtistAlbumBrowser> {
  String? _artist;
  String? _album;

  @override
  Widget build(BuildContext context) {
    final catalog = LibraryCatalog(widget.tracks);
    final artists = catalog.artists;
    final selectedArtist = _artist ?? (artists.isEmpty ? null : artists.first);
    final albums = selectedArtist == null
        ? const <String>[]
        : catalog.albumsFor(selectedArtist);
    final songs = selectedArtist == null
        ? const <Track>[]
        : catalog.tracksFor(artist: selectedArtist, album: _album);

    if (artists.isEmpty) {
      return const Center(child: Text('アーティストはありません'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: _ArtistList(
            artists: artists,
            selectedArtist: selectedArtist!,
            tracks: widget.tracks,
            onSelected: (artist) => setState(() {
              _artist = artist;
              _album = null;
            }),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _ArtistDetail(
            artist: selectedArtist,
            albums: albums,
            songs: songs,
            selectedAlbum: _album,
            onAlbumSelected: (album) => setState(() => _album = album),
          ),
        ),
      ],
    );
  }
}

class _ArtistList extends StatelessWidget {
  const _ArtistList({
    required this.artists,
    required this.selectedArtist,
    required this.tracks,
    required this.onSelected,
  });

  final List<String> artists;
  final String selectedArtist;
  final List<Track> tracks;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: MuziaSpacing.s2),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Text(
            'アーティスト',
            style: MuziaTextStyles.screenTitle.copyWith(
              color: colors.fgPrimary,
            ),
          ),
        ),
        ...artists.map((artist) {
          final artistTracks = tracks
              .where((track) => !track.isRemoved && track.artist == artist)
              .length;
          final selected = artist == selectedArtist;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MuziaRadius.r2),
            ),
            selected: selected,
            selectedTileColor: colors.accentSoft,
            hoverColor: colors.rowHover,
            leading: CircleAvatar(
              backgroundColor: colors.rowHover,
              child: Icon(
                Icons.person_outline,
                size: 20,
                color: colors.fgTertiary,
              ),
            ),
            title: Text(
              artist,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? colors.accentText : colors.fgPrimary,
              ),
            ),
            subtitle: Text(
              '$artistTracks曲',
              style: MuziaTextStyles.secondary.copyWith(
                color: colors.fgSecondary,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: colors.fgTertiary,
            ),
            onTap: () => onSelected(artist),
          );
        }),
      ],
    );
  }
}

class _ArtistDetail extends StatelessWidget {
  const _ArtistDetail({
    required this.artist,
    required this.albums,
    required this.songs,
    required this.selectedAlbum,
    required this.onAlbumSelected,
  });

  final String artist;
  final List<String> albums;
  final List<Track> songs;
  final String? selectedAlbum;
  final ValueChanged<String> onAlbumSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: colors.rowHover,
              child: Icon(Icons.person, size: 42, color: colors.fgTertiary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'アーティスト',
                    style: MuziaTextStyles.caption.copyWith(
                      color: colors.accentText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    artist,
                    style: MuziaTextStyles.heroTitle.copyWith(
                      color: colors.fgPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${albums.length}アルバム · ${songs.length}曲',
                    style: MuziaTextStyles.body.copyWith(
                      color: colors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'アルバム',
          style: MuziaTextStyles.sectionTitle.copyWith(
            color: colors.fgPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            separatorBuilder: (_, _) => const SizedBox(width: 18),
            itemBuilder: (_, index) => _AlbumCard(
              album: albums[index],
              artist: artist,
              selected: albums[index] == selectedAlbum,
              onTap: () => onAlbumSelected(albums[index]),
            ),
          ),
        ),
        if (selectedAlbum != null) ...[
          const SizedBox(height: 28),
          Text(
            '楽曲',
            style: MuziaTextStyles.sectionTitle.copyWith(
              color: colors.fgPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...songs.asMap().entries.map(
            (entry) => ListTile(
              dense: true,
              leading: SizedBox(
                width: 24,
                child: Text('${entry.key + 1}', textAlign: TextAlign.right),
              ),
              title: Text(
                entry.value.title?.isNotEmpty == true
                    ? entry.value.title!
                    : 'タイトル不明',
              ),
              subtitle: Text(entry.value.album ?? 'アルバム不明'),
            ),
          ),
        ],
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.artist,
    required this.selected,
    required this.onTap,
  });

  final String album;
  final String artist;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(MuziaRadius.r4),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.rowHover,
                    borderRadius: BorderRadius.circular(MuziaRadius.r4),
                    border: selected
                        ? Border.all(color: colors.accent, width: 2)
                        : Border.all(color: colors.borderSubtle),
                    boxShadow: const [
                      // shadow-2: カード・カバー用の弱い影
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.album_outlined,
                    size: 42,
                    color: colors.fgTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.rowTitle.copyWith(
                color: colors.fgPrimary,
              ),
            ),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.secondary.copyWith(
                color: colors.fgSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
