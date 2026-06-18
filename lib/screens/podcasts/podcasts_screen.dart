import 'package:flutter/material.dart';

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final podcasts = [
      ["Historias de mi Pueblo", "Entrevistas y relatos locales", "35 min", Icons.mic],
      ["Resumen Semanal", "Noticias importantes de la semana", "22 min", Icons.newspaper],
      ["Música Andina Especial", "Selección musical para la comunidad", "48 min", Icons.music_note],
      ["Voces de la Comunidad", "Participación de vecinos y autoridades", "30 min", Icons.groups],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcasts"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: podcasts.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF1B1B2F),
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFF4D9D),
                child: Icon(
                  podcasts[index][3] as IconData,
                  color: Colors.white,
                ),
              ),
              title: Text(
                podcasts[index][0] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${podcasts[index][1]} • ${podcasts[index][2]}",
              ),
              trailing: const Icon(Icons.play_circle_fill, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}