import 'package:flutter/material.dart';

class SorteosScreen extends StatelessWidget {
  const SorteosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sorteos = [
      ["Canasta Navideña", "Participa y gana premios", Icons.card_giftcard],
      ["Pack Electrodomésticos", "Sorteo especial para oyentes", Icons.kitchen],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Sorteos")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sorteos.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF1B1B2F),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(sorteos[index][2] as IconData, color: Colors.amber, size: 40),
              title: Text(sorteos[index][0] as String),
              subtitle: Text(sorteos[index][1] as String),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Participar"),
              ),
            ),
          );
        },
      ),
    );
  }
}