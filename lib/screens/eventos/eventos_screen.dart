import 'package:flutter/material.dart';

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventos = [
      ["20 JUN", "Aniversario del Distrito", "Plaza de Armas - 9:00 AM"],
      ["22 JUN", "Festival de la Canción", "Local municipal - 6:00 PM"],
      ["30 JUN", "Feria Gastronómica", "Sector central - 10:00 AM"],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Eventos")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF1B1B2F),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pink,
                child: Text(eventos[index][0]),
              ),
              title: Text(eventos[index][1]),
              subtitle: Text(eventos[index][2]),
            ),
          );
        },
      ),
    );
  }
}