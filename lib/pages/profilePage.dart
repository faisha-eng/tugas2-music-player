import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final bool isDarkMode;
  final Future<void> Function(String) onSave;
  final Future<void> Function(bool) onThemeChanged;
  final int jumlahFavorit;
  final int jumlahRecent;

  const ProfilePage({
    super.key,
    required this.username,
    required this.isDarkMode,
    required this.onSave,
    required this.onThemeChanged,
    required this.jumlahFavorit,
    required this.jumlahRecent,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // warna ikut dark mode
    final bgColor = widget.isDarkMode ? Colors.black : Colors.grey.shade200;
    final cardColor = widget.isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    final lebarLayar = MediaQuery.of(context).size.width;
    final isLargeScreen = lebarLayar > 600;

    final avatar = Stack(
      children: [
        CircleAvatar(
          radius: 60,
          child: widget.username.isEmpty
              ? const Icon(Icons.person, size: 60)
              : Text(
            widget.username[0].toUpperCase(),
            style: const TextStyle(fontSize: 48),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bgColor, width: 2),
            ),
            child: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 16,
            ),
          ),
        ),
      ],
    );

    // sapaan nama
    final sapaan = Text(
      widget.username.isEmpty ? 'Selamat Datang!' : 'Halo, ${widget.username}!',
      textAlign: isLargeScreen ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // judul halaman
                Row(
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: textColor, width: 1.5),
                      ),
                      child: Icon(Icons.more_horiz, size: 18, color: textColor),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // foto profile dan sapaan
                Flex(
                  direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    avatar,
                    SizedBox(
                      width: isLargeScreen ? 24 : 0,
                      height: isLargeScreen ? 0 : 16,
                    ),
                    isLargeScreen ? Flexible(child: sapaan) : sapaan,
                  ],
                ),

                const SizedBox(height: 16),

                // statistik jumlah lagu favorit dan lagu terakhir diputar
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                        icon: Icons.favorite,
                        angka: widget.jumlahFavorit,
                        label: 'Favorit',
                        cardColor: cardColor,
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatBox(
                        icon: Icons.history,
                        angka: widget.jumlahRecent,
                        label: 'Terakhir Diputar',
                        cardColor: cardColor,
                        textColor: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // isi nama pengguna
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Nama Pengguna',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: cardColor,
                  ),
                ),

                const SizedBox(height: 12),

                // tombol simpan nama
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama tidak boleh kosong'),
                          ),
                        );
                        return;
                      }

                      await widget.onSave(name);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nama berhasil disimpan'),
                        ),
                      );
                    },
                    child: const Text('Simpan Nama'),
                  ),
                ),

                const SizedBox(height: 24),

                // menu edit profile
                MenuCard(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  cardColor: cardColor,
                  textColor: textColor,
                ),

                // menu subscription
                MenuCard(
                  icon: Icons.card_membership,
                  title: 'Subscription',
                  cardColor: cardColor,
                  textColor: textColor,
                ),

                // menu dark mode
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    child: SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(fontSize: 15, color: textColor),
                      ),
                      subtitle: Text(widget.isDarkMode ? 'Aktif' : 'Nonaktif'),
                      secondary: Icon(
                        widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: textColor,
                      ),
                      value: widget.isDarkMode,
                      onChanged: (value) async {
                        await widget.onThemeChanged(value);
                      },
                    ),
                  ),
                ),

                // menu settings
                MenuCard(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// kartu menu
class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color cardColor;
  final Color textColor;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 15, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

// kotak statistik
class StatBox extends StatelessWidget {
  final IconData icon;
  final int angka;
  final String label;
  final Color cardColor;
  final Color textColor;

  const StatBox({
    super.key,
    required this.icon,
    required this.angka,
    required this.label,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$angka',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}