import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo_radio.jpg'),
            ),

            const SizedBox(height: 15),

            const Text(
              " Llacctany TV",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "ap2199066@gmail.com",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 25),

            _profileCard(
              Icons.favorite,
              "Radiotones apoyadas",
              "0 campañas solidarias",
              Colors.pink,
            ),

            _profileCard(
              Icons.card_giftcard,
              "Sorteos participados",
              "0 participaciones",
              Colors.amber,
            ),

            _profileCard(
              Icons.campaign,
              "Reportes enviados",
              "0 reportes ciudadanos",
              Colors.orange,
            ),

            _profileCard(
              Icons.mic,
              "Podcasts escuchados",
              "0 episodios",
              Colors.cyan,
            ),

            const SizedBox(height: 25),

            _settingsTile(Icons.notifications, "Notificaciones"),
            _settingsTile(Icons.dark_mode, "Modo oscuro"),
            _settingsTile(Icons.info_outline, "Acerca de la radio"),
            _settingsTile(Icons.logout, "Cerrar sesión"),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      ) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF4D9D)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}