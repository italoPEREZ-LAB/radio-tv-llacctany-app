import 'package:flutter/material.dart';

class GaleriaScreen extends StatelessWidget {
  const GaleriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ["Radiotón Solidaria", Icons.favorite, Colors.pink],
      ["Eventos Comunales", Icons.event, Colors.green],
      ["Cabina de Radio", Icons.mic, Colors.cyan],
      ["Videos en Vivo", Icons.videocam, Colors.red],
      ["Aniversario", Icons.celebration, Colors.amber],
      ["Deportes", Icons.sports_soccer, Colors.orange],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Galería Multimedia"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B2F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index][1] as IconData,
                    size: 55,
                    color: items[index][2] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    items[index][0] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}