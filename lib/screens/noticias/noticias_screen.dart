import 'package:flutter/material.dart';

class NoticiasScreen extends StatelessWidget {
  const NoticiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noticias = [
      ["Campaña médica gratuita", "Atención para vecinos del distrito", Icons.local_hospital],
      ["Obra de mejoramiento de vías", "Nueva gestión para la comunidad", Icons.construction],
      ["Equipo local clasificó", "Gran triunfo deportivo", Icons.sports_soccer],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Noticias")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: noticias.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF1B1B2F),
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: Icon(noticias[index][2] as IconData, color: Colors.cyan, size: 36),
              title: Text(noticias[index][0] as String),
              subtitle: Text(noticias[index][1] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}