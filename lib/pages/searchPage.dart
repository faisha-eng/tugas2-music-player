import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../services/musicService.dart';
import '../../widgets/songList.dart';

class SearchPage extends StatefulWidget {
  final bool Function(Song) cekFavorit;
  final void Function(Song) ubahFavorit;
  final void Function(Song) tambahRecent;

  const SearchPage({
    super.key,
    required this.cekFavorit,
    required this.ubahFavorit,
    required this.tambahRecent,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  final service = MusicService();

  List<Song> songs = [];
  bool isLoading = false;
  bool sudahCari = false;
  String pesanError = '';

  Future<void> cariLagu() async {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul lagu tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      pesanError = '';
    });

    try {
      final hasil = await service.cariLagu(controller.text);

      setState(() {
        songs = hasil;
        sudahCari = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        songs = [];
        isLoading = false;
        pesanError = 'Gagal memuat data, cek koneksi internet kamu';
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // isi bagian hasil: loading, error, atau daftar lagu
    Widget hasil;

    if (isLoading) {
      hasil = const Center(child: CircularProgressIndicator());
    } else if (pesanError.isNotEmpty) {
      hasil = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pesanError),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: cariLagu,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else {
      hasil = SongList(
        songs: songs,
        pesanKosong: sudahCari ? 'Lagu tidak ditemukan' : 'Belum ada hasil',
        cekFavorit: widget.cekFavorit,
        ubahFavorit: widget.ubahFavorit,
        tambahRecent: widget.tambahRecent,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                cariLagu();
              },
              decoration: const InputDecoration(
                labelText: 'Judul lagu atau lagu artis',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cariLagu,
                child: const Text('Cari Lagu'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: hasil),
          ],
        ),
      ),
    );
  }
}