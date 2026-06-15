import 'package:flutter/material.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporta tu noticia")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Envía fotos, videos, audios o mensajes sobre lo que ocurre en tu distrito.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _option(Icons.camera_alt, "Tomar foto"),
            _option(Icons.videocam, "Grabar video"),
            _option(Icons.mic, "Grabar audio"),
            _option(Icons.message, "Escribir mensaje"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Enviar reporte"),
            )
          ],
        ),
      ),
    );
  }

  Widget _option(IconData icon, String text) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}