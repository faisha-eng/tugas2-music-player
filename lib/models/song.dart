class Song {
  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName;
  final String primaryGenreName;
  final String artworkUrl100;
  final String previewUrl;

  Song({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.primaryGenreName,
    required this.artworkUrl100,
    required this.previewUrl,
  });

  // ubah JSON (Map) jadi objek Song
  // kalau ada data yang kosong, diisi nilai bawaan supaya aplikasi tidak error
  factory Song.fromJson(Map json) {
    return Song(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? '-',
      artistName: json['artistName'] ?? '-',
      collectionName: json['collectionName'] ?? '-',
      primaryGenreName: json['primaryGenreName'] ?? '-',
      artworkUrl100: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
    );
  }

  // ubah objek Song jadi Map, dipakai waktu menyimpan ke hive
  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': trackName,
      'artistName': artistName,
      'collectionName': collectionName,
      'primaryGenreName': primaryGenreName,
      'artworkUrl100': artworkUrl100,
      'previewUrl': previewUrl,
    };
  }

  // gambar dari itunes ukurannya 100x100, diganti jadi 400x400 biar tidak pecah
  String get artworkBesar {
    return artworkUrl100.replaceAll('100x100', '400x400');
  }
}