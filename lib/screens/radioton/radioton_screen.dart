import 'package:flutter/material.dart';

class RadiotonScreen extends StatelessWidget {
  const RadiotonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Radiotón Solidaria")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B2F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 70),
                  const SizedBox(height: 15),
                  const Text(
                    "Ayudemos a María Quispe",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Campaña pro salud para operación urgente"),
                  const SizedBox(height: 20),
                  const Text("Meta: S/ 20,000"),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.78,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 10),
                  const Text("Recaudado: S/ 15,750 - 78%"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone_android),
              label: const Text("Donar con Yape"),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.payment),
              label: const Text("Donar con Plin"),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text("Reportar comprobante"),
            ),
          ],
        ),
      ),
    );
  }
}