import 'package:flutter/material.dart';

import '../../widgets/feature_card.dart';
import '../noticias/noticias_screen.dart';
import '../radioton/radioton_screen.dart';
import '../sorteos/sorteos_screen.dart';
import '../eventos/eventos_screen.dart';
import '../reportes/reportes_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Radio TV Estación Llacctany"),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
        ],
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF0A0A0A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo_radio.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Radio TV Estación Llacctany",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "103.5 FM",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            _drawerItem(context, Icons.home, "Inicio", null),
            _drawerItem(context, Icons.favorite, "Radiotón", const RadiotonScreen()),
            _drawerItem(context, Icons.card_giftcard, "Sorteos", const SorteosScreen()),
            _drawerItem(context, Icons.newspaper, "Noticias", const NoticiasScreen()),
            _drawerItem(context, Icons.event, "Eventos", const EventosScreen()),
            _drawerItem(context, Icons.campaign, "Reporta tu noticia", const ReportesScreen()),

            const Divider(color: Colors.white24),

            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blue),
              title: const Text("Facebook"),
              onTap: () {
                _openUrl("https://www.facebook.com/");
              },
            ),

            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.white),
              title: const Text("TikTok"),
              onTap: () {
                _openUrl("https://www.tiktok.com/");
              },
            ),

            ListTile(
              leading: const Icon(Icons.play_circle, color: Colors.red),
              title: const Text("YouTube"),
              onTap: () {
                _openUrl("https://www.youtube.com/");
              },
            ),

            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text("WhatsApp"),
              onTap: () {
                _openUrl("https://wa.me/51999999999");
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text("Acerca de la radio"),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/logo_radio.jpg'),
            ),

            const SizedBox(height: 12),

            const Text(
              "Radio TV Estación Llacctany",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "103.5 FM • Ranracancha - Chincheros",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            Container(
              height: 240,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "EN VIVO",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Icon(Icons.radio, size: 70, color: Colors.white),

                  const SizedBox(height: 10),

                  const Text(
                    "103.5 FM",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const Text("Ranracancha - Chincheros"),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("ESCUCHAR AHORA"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RadiotonScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "💝 Radiotón Solidaria",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Meta: S/ 20,000"),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.75,
                      borderRadius: BorderRadius.circular(20),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 10),
                    const Text("Recaudado: S/ 15,750"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SorteosScreen()),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.card_giftcard,
                    title: "Sorteos",
                    color: Colors.amber,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NoticiasScreen()),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.newspaper,
                    title: "Noticias",
                    color: Colors.cyan,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EventosScreen()),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.event,
                    title: "Eventos",
                    color: Colors.green,
                  ),
                ),

                const FeatureCard(
                  icon: Icons.photo_library,
                  title: "Galería",
                  color: Colors.purple,
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportesScreen()),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.campaign,
                    title: "Reporta tu noticia",
                    color: Colors.orange,
                  ),
                ),

                const FeatureCard(
                  icon: Icons.mic,
                  title: "Podcasts",
                  color: Colors.pink,
                ),
              ],
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "🔥 Últimas Noticias",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.local_hospital,
              title: "Campaña médica gratuita",
              subtitle: "Atención para vecinos del distrito",
              color: Colors.cyan,
            ),

            _infoCard(
              icon: Icons.celebration,
              title: "Festival Cultural",
              subtitle: "Este fin de semana",
              color: Colors.pink,
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "📅 Próximos Eventos",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 10),

            _infoCard(
              icon: Icons.event,
              title: "Aniversario Distrital",
              subtitle: "20 de junio • Plaza principal",
              color: Colors.green,
            ),

            _infoCard(
              icon: Icons.sports_soccer,
              title: "Campeonato Relámpago",
              subtitle: "Fútbol y vóley mixto",
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );

  }



  Widget _drawerItem(
      BuildContext context,
      IconData icon,
      String title,
      Widget? screen,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFFF4D9D),
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        }
      },
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('No se pudo abrir $url');
    }
  }
}