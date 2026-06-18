import 'package:flutter/material.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Radio en Vivo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            const SizedBox(height: 5),

            const Text(
              "103.5 FM • Ranracancha - Chincheros",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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

                  const SizedBox(height: 25),

                  const Icon(
                    Icons.graphic_eq,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Transmitiendo por Facebook Live",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Streaming propio próximamente",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.facebook),
                    label: const Text("VER FACEBOOK LIVE"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _infoTile(
              Icons.schedule,
              "Programa actual",
              "Música, noticias y comunicación local",
            ),

            _infoTile(
              Icons.people,
              "Comunidad",
              "La voz de nuestro pueblo",
            ),

            _infoTile(
              Icons.wifi_tethering,
              "Streaming",
              "Próximamente con ZenoFM o AzuraCast",
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Card(
      color: const Color(0xFF1B1B2F),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF4D9D)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}