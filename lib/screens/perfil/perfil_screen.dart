
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_screen.dart';
import '../../services/perfil_service.dart';
import '../admin/admin_dashboard_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
 SupabaseClient get _supabase => Supabase.instance.client;

Future<String?> _obtenerRol() async {
  return PerfilService().obtenerRolActual();
}
Future<void> _abrirPanelAdministrativo() async {
  try {
    final esAdmin = await PerfilService().esAdministrador();

    if (!mounted) return;

    if (!esAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos de administrador'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardScreen(),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo verificar el acceso al panel'),
      ),
    );
  }
}
  Future<void> _abrirAutenticacion() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthScreen(),
      ),
    );

    if (mounted) setState(() {});
  }

  Future<void> _cerrarSesion() async {
    try {
      await _supabase.auth.signOut();
      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada correctamente'),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _supabase.auth.currentUser;
    final autenticado = usuario != null;

    final nombre = autenticado
        ? (usuario.userMetadata?['nombre']?.toString() ??
            'Usuario Llacctany')
        : 'Bienvenido a Llacctany';

    final correo = autenticado
        ? (usuario.email ?? '')
        : 'Inicia sesión o crea tu cuenta';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage:
                  AssetImage('assets/images/logo_radio.jpg'),
            ),

            const SizedBox(height: 15),

            Text(
              nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            Text(
              correo,
              style: const TextStyle(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (autenticado)
  FutureBuilder<String?>(
    future: _obtenerRol(),
    builder: (context, snapshot) {
      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        );
      }

      if (snapshot.hasError) {
        return const Text(
          'No se pudo consultar el rol',
        );
      }

      final rol = snapshot.data ?? 'usuario';

      return Column(
  children: [
    const SizedBox(height: 8),

    Chip(
      avatar: Icon(
        rol == 'administrador'
            ? Icons.admin_panel_settings
            : Icons.person,
      ),
      label: Text(
        rol == 'administrador'
            ? 'Administrador'
            : 'Usuario',
      ),
    ),

    if (rol == 'administrador') ...[
      const SizedBox(height: 16),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _abrirPanelAdministrativo,
          icon: const Icon(Icons.admin_panel_settings),
          label: const Text('Panel Administrativo'),
        ),
      ),
    ],
  ],
);
    },
  ),

            const SizedBox(height: 25),

            if (!autenticado)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _abrirAutenticacion,
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Iniciar sesión / Registrarse',
                  ),
                ),
              ),

            const SizedBox(height: 20),

            _profileCard(
              Icons.favorite,
              'Radiotones apoyadas',
              '0 campañas solidarias',
              Colors.pink,
            ),

            _profileCard(
              Icons.card_giftcard,
              'Sorteos participados',
              '0 participaciones',
              Colors.amber,
            ),

            _profileCard(
              Icons.campaign,
              'Reportes enviados',
              '0 reportes ciudadanos',
              Colors.orange,
            ),

            _profileCard(
              Icons.mic,
              'Podcasts escuchados',
              '0 episodios',
              Colors.cyan,
            ),

            const SizedBox(height: 25),

            _settingsTile(
              Icons.notifications,
              'Notificaciones',
            ),

            _settingsTile(
              Icons.dark_mode,
              'Modo oscuro',
            ),

            _settingsTile(
              Icons.info_outline,
              'Acerca de la radio',
            ),

            if (autenticado)
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Color(0xFFFF4D9D),
                ),
                title: const Text('Cerrar sesión'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: _cerrarSesion,
              ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
  ) {
    return ListTile(
      leading: Icon(
  icon,
  color: const Color(0xFFFF4D9D),
),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
    );
  }
}
