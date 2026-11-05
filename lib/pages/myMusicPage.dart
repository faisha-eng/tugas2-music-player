import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/songList.dart';

class MyMusicPage extends StatelessWidget {
  final List<Song> favorit;
  final List<Song> recent;
  final bool Function(Song) cekFavorit;
  final void Function(Song) ubahFavorit;
  final void Function(Song) tambahRecent;
  final void Function() hapusRecent;

  const MyMusicPage({
    super.key,
    required this.favorit,
    required this.recent,
    required this.cekFavorit,
    required this.ubahFavorit,
    required this.tambahRecent,
    required this.hapusRecent,
  });

  @override
  Widget build(BuildContext context) {
    // warna kotak otomatis berubah saat dark mode
    final warna = Theme.of(context).colorScheme;

    // tombol hapus riwayat, cuma muncul kalau riwayat tidak kosong
    Widget tombolHapus = const SizedBox();

    if (recent.isNotEmpty) {
      tombolHapus = TextButton.icon(
        onPressed: () {
          hapusRecent();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Riwayat dihapus'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: warna.onSecondaryContainer,
        ),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Hapus'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Music'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // kotak favorit
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warna.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Favorit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: warna.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SongList(
                        songs: favorit,
                        pesanKosong: 'Belum ada lagu favorit',
                        cekFavorit: cekFavorit,
                        ubahFavorit: ubahFavorit,
                        tambahRecent: tambahRecent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // kotak terakhir diputar
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warna.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: warna.onSecondaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          'Terakhir Diputar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: warna.onSecondaryContainer,
                          ),
                        ),
                        const Spacer(),
                        tombolHapus,
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SongList(
                        songs: recent,
                        pesanKosong: 'Belum ada lagu yang diputar',
                        cekFavorit: cekFavorit,
                        ubahFavorit: ubahFavorit,
                        tambahRecent: tambahRecent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}