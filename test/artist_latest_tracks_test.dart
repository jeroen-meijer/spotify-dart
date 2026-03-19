import 'package:test/test.dart';
import 'spotify_mock.dart';

void main() {
  final spotify = SpotifyApiMock.create();

  group('Artist Latest Tracks including features', () {
    test('Find latest track including featured appearances', () async {
      const artistId = '4UJP03mzC9b90Qq1TqavvN';

      // 1. Fetch albums, singles, and appearances
      final albumsPages = spotify.artists.albums(
        artistId,
        includeGroups: ['album', 'single', 'appears_on'],
      );

      final firstPage = await albumsPages.first();
      final albums = firstPage.items!;

      expect(albums, isNotEmpty);
      expect(albums.any((a) => a.name!.contains('Samurai')), isTrue);

      // 2. Sort by release date
      final sortedAlbums = albums.toList()
        ..sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));

      expect(sortedAlbums.first.name, contains('Samurai'));
      expect(sortedAlbums.first.releaseDate, '2024-05-10');

      // 3. Find tracks on the latest album that feature the artist
      final latestAlbum = sortedAlbums.first;
      final tracks = await spotify.albums.getTracks(latestAlbum.id!).all();

      final featuredTracks = tracks
          .where((track) => track.artists?.any((a) => a.id == artistId) ?? false)
          .toList();

      expect(featuredTracks, isNotEmpty);
      expect(featuredTracks.first.name, contains('Samurai'));
      expect(featuredTracks.first.artists!.any((a) => a.id == artistId), isTrue);
    });
  });
}
