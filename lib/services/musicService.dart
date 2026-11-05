import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/song.dart';

class MusicService {
  Future<List<Song>> cariLagu(String kata) async {
    final url = Uri.https(
      'itunes.apple.com',
      '/search',
      <String, String>{
        'term': kata,
        'entity': 'song',
        'limit': '20',
      },
    );
    final respons = await http.get(url);
    debugPrint('HTTP Status : ${respons.statusCode}');

    if (respons.statusCode != 200) {
      throw Exception('Gagal mengambil data (kode ${respons.statusCode})');
    }

    final data = jsonDecode(respons.body);
    final List hasil = data['results'];

    // lagu yang judul dan artisnya sama (misalnya rilis single dan album) cuma diambil satu
    final List<Song> daftar = [];
    for (int i = 0; i < hasil.length; i++) {
      final song = Song.fromJson(hasil[i]);

      bool sudahAda = false;
      for (int j = 0; j < daftar.length; j++) {
        final judulSama =
            daftar[j].trackName.toLowerCase() == song.trackName.toLowerCase();
        final artisSama =
            daftar[j].artistName.toLowerCase() == song.artistName.toLowerCase();

        if (judulSama && artisSama) {
          sudahAda = true;
          break;
        }
      }

      if (!sudahAda) {
        daftar.add(song);
      }
    }

    return daftar;
  }

  // ambil lirik dari lyrics.ovh berdasarkan nama artis dan judul lagu
  Future<String> ambilLirik(String artis, String judul) async {
    final url = Uri.https('api.lyrics.ovh', '/v1/$artis/$judul');
    final respons = await http.get(url);
    debugPrint('HTTP Status Lirik : ${respons.statusCode}');

    // validasi status code
    if (respons.statusCode != 200) {
      throw Exception('Lirik tidak ditemukan');
    }

    final data = jsonDecode(respons.body);
    return data['lyrics'] ?? 'Lirik tidak tersedia';
  }
}