import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B2F),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: color,
            size: 35,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}