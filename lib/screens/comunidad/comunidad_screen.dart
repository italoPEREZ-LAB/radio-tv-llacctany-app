import 'package:flutter/material.dart';

import '../reportes/reportes_screen.dart';
import '../noticias/noticias_screen.dart';
import '../eventos/eventos_screen.dart';

class ComunidadScreen extends StatelessWidget {
  const ComunidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final publicaciones = [
      ["📢 Reporte ciudadano", "Vecinos reportan mejora de carretera comunal"],
      ["🎉 Felicitación", "Saludos por aniversario del distrito"],
      ["🏆 Deportes", "Equipo local ganó campeonato relámpago"],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comunidad"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ],
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.groups, size: 70, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    "La voz de nuestra comunidad",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Participa, informa y comparte lo que ocurre en tu distrito",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _quickButton(
                    context,
                    Icons.campaign,
                    "Reportar",
                    Colors.orange,
                    const ReportesScreen(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickButton(
                    context,
                    Icons.newspaper,
                    "Noticias",
                    Colors.cyan,
                    const NoticiasScreen(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickButton(
                    context,
                    Icons.event,
                    "Eventos",
                    Colors.green,
                    const EventosScreen(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "📌 Publicaciones destacadas",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 10),

            ...publicaciones.map(
                  (item) => Card(
                color: const Color(0xFF1B1B2F),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFF4D9D),
                    child: Icon(Icons.people, color: Colors.white),
                  ),
                  title: Text(item[0]),
                  subtitle: Text(item[1]),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "🤝 Participa con la radio",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 10),

            _participationCard(
              Icons.photo_camera,
              "Comparte una foto",
              "Envía imágenes de actividades, problemas o eventos.",
            ),

            _participationCard(
              Icons.mic,
              "Envía un audio",
              "Manda saludos, denuncias o mensajes para la radio.",
            ),

            _participationCard(
              Icons.volunteer_activism,
              "Apoya una Radiotón",
              "Participa en campañas solidarias del distrito.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      Widget screen,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B2F),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _participationCard(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF4D9D)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}