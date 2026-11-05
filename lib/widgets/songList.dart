// widget daftar lagu
// SongList: menampilkan list lagu, kalau kosong tampil pesan (dipakai di search, favorit, dan recent)
// SongItem: satu baris lagu, kalau di-tap pindah ke halaman detail

import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../pages/detailPage.dart';

class SongList extends StatelessWidget {
  final List<Song> songs;
  final String pesanKosong;
  final bool Function(Song) cekFavorit;
  final void Function(Song) ubahFavorit;
  final void Function(Song) tambahRecent;

  const SongList({
    super.key,
    required this.songs,
    required this.pesanKosong,
    required this.cekFavorit,
    required this.ubahFavorit,
    required this.tambahRecent,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Center(child: Text(pesanKosong));
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return SongItem(
          song: songs[index],
          cekFavorit: cekFavorit,
          ubahFavorit: ubahFavorit,
          tambahRecent: tambahRecent,
        );
      },
    );
  }
}

class SongItem extends StatelessWidget {
  final Song song;
  final bool Function(Song) cekFavorit;
  final void Function(Song) ubahFavorit;
  final void Function(Song) tambahRecent;

  const SongItem({
    super.key,
    required this.song,
    required this.cekFavorit,
    required this.ubahFavorit,
    required this.tambahRecent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            song.artworkUrl100,
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.music_note);
            },
          ),
        ),
        title: Text(
          song.trackName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        // halaman detail
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                song: song,
                cekFavorit: cekFavorit,
                ubahFavorit: ubahFavorit,
                tambahRecent: tambahRecent,
              ),
            ),
          );
        },
      ),
    );
  }
}