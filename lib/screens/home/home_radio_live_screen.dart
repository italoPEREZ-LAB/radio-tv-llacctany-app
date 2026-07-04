import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeRadioLiveScreen extends StatelessWidget {
  const HomeRadioLiveScreen({super.key});

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("🚀 $title"),
        content: const Text(
          "Esta función estará disponible en una próxima actualización.\n\nGracias por utilizar Radio TV Estación Llacctany.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Radio TV Estación Llacctany"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo_radio.jpg'),
            ),

            const SizedBox(height: 20),

            const Text(
              "Radio TV Estación Llacctany",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "103.5 FM • Ranracancha - Chincheros",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "🔴 EN VIVO",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Icon(
                    Icons.radio,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showComingSoon(
                          context,
                          "Radio en vivo",
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("ESCUCHAR AHORA"),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Una Radio Diferente Que a los Demás",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Divider(color: Colors.white24),

            const SizedBox(height: 15),

            const Text(
              "Síguenos en nuestras redes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _socialButton(
              icon: Icons.facebook,
              text: "Facebook",
              color: Colors.blue,
              onTap: () {
                _openUrl("https://www.facebook.com/RadioTvEstacionLlacctany/");
              },
            ),

            _socialButton(
              icon: Icons.music_note,
              text: "TikTok",
              color: Colors.white,
              onTap: () {
                _openUrl("https://www.tiktok.com/@radioestacionllacctany");
              },
            ),

            _socialButton(
              icon: Icons.play_circle,
              text: "YouTube",
              color: Colors.red,
              onTap: () {
                _openUrl("https://www.youtube.com/@RadioEstacionLlacctany");
              },
            ),

            _socialButton(
              icon: Icons.phone,
              text: "WhatsApp",
              color: Colors.green,
              onTap: () {
                _openUrl(
                  "https://wa.me/51999566101?text=Hola%20Radio%20TV%20Estaci%C3%B3n%20Llacctany",
                );
              },
            ),

            const SizedBox(height: 30),

            const Divider(color: Colors.white24),

            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "🚀 Próximamente",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _comingSoonItem(context, Icons.newspaper, "Noticias"),
            _comingSoonItem(context, Icons.event, "Eventos"),
            _comingSoonItem(context, Icons.favorite, "Radiotón"),
            _comingSoonItem(context, Icons.mic, "Podcasts"),
            _comingSoonItem(context, Icons.card_giftcard, "Sorteos"),
            _comingSoonItem(context, Icons.groups, "Comunidad"),
            _comingSoonItem(context, Icons.photo_library, "Galería"),

            const SizedBox(height: 25),

            const Text(
              "Versión 1.0",
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _comingSoonItem(
      BuildContext context,
      IconData icon,
      String title,
      ) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF4D9D)),
        title: Text(title),
        subtitle: const Text("Disponible en una próxima actualización"),
        trailing: const Icon(Icons.lock_clock, size: 20),
        onTap: () => _showComingSoon(context, title),
      ),
    );
  }
}