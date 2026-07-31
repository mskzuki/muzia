import 'package:flutter/material.dart';
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Text(
            'アーティスト',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ...artists.map((artist) {
          final artistTracks = tracks
              .where((track) => !track.isRemoved && track.artist == artist)
              .length;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            selected: artist == selectedArtist,
            selectedTileColor: const Color(0x1F3E63DD),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF5C6380),
              child: Icon(Icons.person_outline, color: Colors.white70),
            ),
            title: Text(
              artist,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '$artistTracks曲',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF5C6380),
              child: Icon(Icons.person, size: 42, color: Colors.white70),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'アーティスト',
                    style: TextStyle(
                      color: Color(0xFF3A5BC7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    artist,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${albums.length}アルバム · ${songs.length}曲',
                    style: const TextStyle(color: Color(0xFF646464)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'アルバム',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C536F), Color(0xFF8B91AE)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(color: const Color(0xFF3E63DD), width: 2)
                        : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.album_outlined,
                    size: 42,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF646464)),
            ),
          ],
        ),
      ),
    );
  }
}
