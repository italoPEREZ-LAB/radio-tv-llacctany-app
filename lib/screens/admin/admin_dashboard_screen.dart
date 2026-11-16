
import 'package:flutter/material.dart';

import 'noticias_admin_screen.dart';
import 'eventos_admin_screen.dart';
import 'podcasts_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Administración de Radio TV Estación Llacctany',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Gestiona los contenidos de tu radio desde un solo lugar.',
          ),

          const SizedBox(height: 24),

          // NOTICIAS
          _modulo(
            context,
            Icons.article,
            'Noticias',
            const NoticiasAdminScreen(),
          ),

          // EVENTOS
          _modulo(
            context,
            Icons.event,
            'Eventos',
            const EventosAdminScreen(),
          ),

          // PODCASTS
          _modulo(
            context,
            Icons.podcasts,
            'Podcasts',
            const PodcastsAdminScreen(),
          ),

          // PRÓXIMOS MÓDULOS
          _modulo(
            context,
            Icons.card_giftcard,
            'Sorteos',
            null,
          ),

          _modulo(
            context,
            Icons.volunteer_activism,
            'Radiotón',
            null,
          ),

          _modulo(
            context,
            Icons.photo_library,
            'Galería',
            null,
          ),

          _modulo(
            context,
            Icons.campaign,
            'Reportes ciudadanos',
            null,
          ),

          _modulo(
            context,
            Icons.people,
            'Usuarios',
            null,
          ),
        ],
      ),
    );
  }

  Widget _modulo(
    BuildContext context,
    IconData icono,
    String titulo,
    Widget? pantalla,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icono,
          color: const Color(0xFF7B61FF),
        ),
        title: Text(titulo),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: pantalla == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => pantalla,
                  ),
                );
              },
      ),
    );
  }
}
