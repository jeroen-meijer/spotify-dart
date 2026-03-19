import 'dart:io';
import 'dart:convert';
import 'package:spotify/spotify.dart';

/// This example demonstrates how to find the latest tracks for an artist,
/// including tracks on albums where the artist is featured (but not the main artist).
void main() async {
  // Use your own credentials here
  final keyJson = await File('example/.apikeys').readAsString();
  final keyMap = json.decode(keyJson);

  final credentials = SpotifyApiCredentials(keyMap['id'], keyMap['secret']);
  final spotify = SpotifyApi(credentials);

  // Example Artist: Flint & Figure
  // https://open.spotify.com/artist/4UJP03mzC9b90Qq1TqavvN
  const artistId = '4UJP03mzC9b90Qq1TqavvN';

  print('Fetching releases for artist $artistId including appearances...');

  // 1. Fetch albums, singles, and appearances
  // 'appears_on' is the key here to include albums where the artist is a guest/featured.
  final albumsPages = spotify.artists.albums(
    artistId,
    includeGroups: ['album', 'single', 'appears_on'],
    country: Market.US, // Optional: specify market
  );

  // Get the first page of results (usually 20 items)
  final firstPage = await albumsPages.first();
  final albums = firstPage.items ?? [];

  if (albums.isEmpty) {
    print('No releases found.');
    return;
  }

  // 2. Sort albums by release date descending to get the latest first
  // Note: releaseDate can be "YYYY", "YYYY-MM", or "YYYY-MM-DD"
  final sortedAlbums = albums.toList()
    ..sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));

  print('\nLatest 5 releases (including features):');
  for (final album in sortedAlbums.take(5)) {
    print('------------------------------------------------------------');
    print('Album: ${album.name}');
    print('Type:  ${album.albumType}');
    print('Date:  ${album.releaseDate}');

    // 3. To find the specific tracks featuring the artist on these albums,
    // we need to fetch the album tracks.
    final tracks = await spotify.albums.getTracks(album.id!).all();

    for (final track in tracks) {
      // Check if our artist is among the track's artists
      final isFeatured = track.artists?.any((a) => a.id == artistId) ?? false;
      if (isFeatured) {
        print('  - Track: ${track.name} [ID: ${track.id}]');
      }
    }
  }
}
