import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/song.dart';
import 'pages/myMusicPage.dart';
import 'pages/searchPage.dart';
import 'pages/profilePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('Settings');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box settingsBox;

  int tabIndex = 0;
  String username = '';
  bool isDarkMode = false;
  bool isLoading = true;
  List<Song> favorit = [];
  List<Song> recent = [];

  @override
  void initState() {
    super.initState();

    settingsBox = Hive.box('Settings');
    loadData();
  }

  // ambil semua data yang tersimpan di hive
  Future<void> loadData() async {
    setState(() {
      username = settingsBox.get('username', defaultValue: '');
      isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);
      favorit = bacaList('favorit');
      recent = bacaList('recent');
      isLoading = false;
    });
  }

  // baca list lagu dari hive lalu ubah jadi objek Song
  List<Song> bacaList(String key) {
    final List data = settingsBox.get(key, defaultValue: []);
    final List<Song> hasil = [];

    for (int i = 0; i < data.length; i++) {
      hasil.add(Song.fromJson(data[i]));
    }

    return hasil;
  }

  // ubah list Song jadi Map lalu simpan ke hive
  Future<void> simpanList(String key, List<Song> daftar) async {
    final List data = [];

    for (int i = 0; i < daftar.length; i++) {
      data.add(daftar[i].toJson());
    }

    await settingsBox.put(key, data);
  }

  Future<void> saveUsername(String name) async {
    await settingsBox.put('username', name);

    setState(() {
      username = name;
    });
  }

  Future<void> saveTheme(bool value) async {
    await settingsBox.put('isDarkMode', value);

    setState(() {
      isDarkMode = value;
    });
  }

  // cek lagu sudah ada di favorit atau belum
  bool cekFavorit(Song song) {
    for (int i = 0; i < favorit.length; i++) {
      if (favorit[i].trackId == song.trackId) {
        return true;
      }
    }
    return false;
  }

  // tambah ke favorit kalau belum ada, hapus kalau sudah ada
  Future<void> ubahFavorit(Song song) async {
    final sudahAda = cekFavorit(song);

    setState(() {
      if (sudahAda) {
        for (int i = 0; i < favorit.length; i++) {
          if (favorit[i].trackId == song.trackId) {
            favorit.removeAt(i);
            break;
          }
        }
      } else {
        favorit.add(song);
      }
    });

    await simpanList('favorit', favorit);
  }

  // catat lagu yang terakhir diputar (maksimal 10)
  Future<void> tambahRecent(Song song) async {
    setState(() {
      for (int i = 0; i < recent.length; i++) {
        if (recent[i].trackId == song.trackId) {
          recent.removeAt(i);
          break;
        }
      }

      recent.insert(0, song);

      if (recent.length > 10) {
        recent.removeLast();
      }
    });

    await simpanList('recent', recent);
  }

  // hapus semua riwayat lagu yang terakhir diputar
  Future<void> hapusRecent() async {
    setState(() {
      recent.clear();
    });

    await simpanList('recent', recent);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: isLoading
          ? const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      )
          : Scaffold(
        // IndexedStack: biar halaman tidak ke-reset waktu pindah tab
        body: IndexedStack(
          index: tabIndex,
          children: [
            SearchPage(
              cekFavorit: cekFavorit,
              ubahFavorit: ubahFavorit,
              tambahRecent: tambahRecent,
            ),
            MyMusicPage(
              favorit: favorit,
              recent: recent,
              cekFavorit: cekFavorit,
              ubahFavorit: ubahFavorit,
              tambahRecent: tambahRecent,
              hapusRecent: hapusRecent,
            ),
            ProfilePage(
              username: username,
              isDarkMode: isDarkMode,
              onSave: saveUsername,
              onThemeChanged: saveTheme,
              jumlahFavorit: favorit.length,
              jumlahRecent: recent.length,
            ),
          ],
        ),
        // navigasi bawah
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabIndex,
          onTap: (index) {
            setState(() {
              tabIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'My Music',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}