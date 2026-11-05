import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../services/musicService.dart';

class DetailPage extends StatefulWidget {
  final Song song;
  final bool Function(Song) cekFavorit;
  final void Function(Song) ubahFavorit;
  final void Function(Song) tambahRecent;

  const DetailPage({
    super.key,
    required this.song,
    required this.cekFavorit,
    required this.ubahFavorit,
    required this.tambahRecent,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // pemutar musik dari package audioplayers
  final player = AudioPlayer();
  final service = MusicService();

  bool isPlaying = false;
  bool sudahMulai = false;
  bool isFavorit = false;
  String lirik = 'Memuat lirik...';

  @override
  void initState() {
    super.initState();

    isFavorit = widget.cekFavorit(widget.song);

    // kalau lagu selesai, tombol kembali jadi play
    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        sudahMulai = false;
      });
    });

    cariLirik();
  }

  // ambil lirik lewat service
  Future<void> cariLirik() async {
    try {
      final hasil = await service.ambilLirik(
        widget.song.artistName,
        widget.song.trackName,
      );

      setState(() {
        lirik = hasil;
      });
    } catch (e) {
      setState(() {
        lirik = 'Lirik tidak ditemukan';
      });
    }
  }

  // putar atau pause preview lagu (30 detik dari itunes)
  Future<void> putarLagu() async {
    if (widget.song.previewUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview lagu tidak tersedia')),
      );
      return;
    }

    if (isPlaying) {
      await player.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (sudahMulai) {
        await player.resume();
      } else {
        try {
          await player.play(UrlSource(widget.song.previewUrl));
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memutar lagu')),
          );
          return;
        }
        sudahMulai = true;
        widget.tambahRecent(widget.song);
      }
      setState(() {
        isPlaying = true;
      });
    }
  }

  // tombol favorit
  void tekanFavorit() {
    widget.ubahFavorit(widget.song);

    setState(() {
      isFavorit = !isFavorit;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorit ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.of(context).size.width;
    final isLargeScreen = lebarLayar > 600;
    double ukuranCover = 200;

    if (isLargeScreen) {
      ukuranCover = 280;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lagu'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: tekanFavorit,
            icon: Icon(
              isFavorit ? Icons.favorite : Icons.favorite_border,
              color: isFavorit ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // cover lagu
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.song.artworkBesar,
                width: ukuranCover,
                height: ukuranCover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.music_note, size: ukuranCover);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.song.trackName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            widget.song.artistName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // tombol putar
          Center(
            child: ElevatedButton.icon(
              onPressed: putarLagu,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? 'Pause' : 'Putar Preview'),
            ),
          ),
          const SizedBox(height: 16),
          // info lagu
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.album),
                  title: const Text('Album'),
                  subtitle: Text(widget.song.collectionName),
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Genre'),
                  subtitle: Text(widget.song.primaryGenreName),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // lirik
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lirik',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(lirik),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}