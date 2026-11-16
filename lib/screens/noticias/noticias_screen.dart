
import 'package:flutter/material.dart';
import '../../services/noticias_service.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  final NoticiasService _noticiasService = NoticiasService();

  late Future<List<Map<String, dynamic>>> _noticiasFuture;

  @override
  void initState() {
    super.initState();
    _cargarNoticias();
  }

  void _cargarNoticias() {
    _noticiasFuture = _obtenerNoticiasPublicadas();
  }

  Future<List<Map<String, dynamic>>>
      _obtenerNoticiasPublicadas() async {
    final noticias = await _noticiasService.obtenerNoticias();

    return noticias
        .where((noticia) => noticia['publicada'] == true)
        .toList();
  }

  Future<void> _actualizarNoticias() async {
    setState(() {
      _cargarNoticias();
    });

    try {
      await _noticiasFuture;
    } catch (_) {
      // El FutureBuilder mostrará el error.
    }
  }

  void _mostrarDetalle(Map<String, dynamic> noticia) {
    final titulo = noticia['titulo']?.toString() ?? '';
    final contenido = noticia['contenido']?.toString() ?? '';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: SingleChildScrollView(
          child: Text(contenido),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
      ),
      body: RefreshIndicator(
        onRefresh: _actualizarNoticias,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _noticiasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No se pudieron cargar las noticias',
                    ),
                  ),
                ],
              );
            }

            final noticias = snapshot.data ?? [];

            if (noticias.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Icon(
                    Icons.article_outlined,
                    color: Colors.white54,
                    size: 70,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Todavía no hay noticias publicadas',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: noticias.length,
              itemBuilder: (context, index) {
                final noticia = noticias[index];

                final titulo =
                    noticia['titulo']?.toString() ?? '';

                final contenido =
                    noticia['contenido']?.toString() ?? '';

                return Card(
                  color: const Color(0xFF1B1B2F),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    leading: const Icon(
                      Icons.article,
                      color: Colors.cyan,
                      size: 36,
                    ),
                    title: Text(titulo),
                    subtitle: Text(
                      contenido,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () => _mostrarDetalle(noticia),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
