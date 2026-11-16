
import 'package:flutter/material.dart';

import '../../services/noticias_service.dart';
import 'noticia_form_screen.dart';

class NoticiasAdminScreen extends StatefulWidget {
  const NoticiasAdminScreen({super.key});

  @override
  State<NoticiasAdminScreen> createState() =>
      _NoticiasAdminScreenState();
}

class _NoticiasAdminScreenState
    extends State<NoticiasAdminScreen> {
  final NoticiasService _noticiasService = NoticiasService();

  late Future<List<Map<String, dynamic>>> _noticiasFuture;

  @override
  void initState() {
    super.initState();
    _cargarNoticias();
  }

  void _cargarNoticias() {
    _noticiasFuture = _noticiasService.obtenerNoticias();
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
Future<void> _abrirFormulario() async {
  final resultado = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const NoticiaFormScreen(),
    ),
  );

  if (!mounted) return;

  if (resultado == true) {
    await _actualizarNoticias();
  }
}
Future<void> _cambiarEstadoNoticia(
  String id,
  bool publicada,
) async {
  try {
    await _noticiasService.cambiarPublicacion(
      id: id,
      publicada: !publicada,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          publicada
              ? 'Noticia cambiada a borrador'
              : 'Noticia publicada correctamente',
        ),
      ),
    );

    await _actualizarNoticias();
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cambiar publicación: $error'),
      ),
    );
  }
}

Future<void> _eliminarNoticia(
  String id,
  String titulo,
) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar noticia'),
      content: Text(
        '¿Estás seguro de eliminar "$titulo"? '
        'Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirmar != true || !mounted) return;

  try {
    await _noticiasService.eliminarNoticia(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Noticia eliminada correctamente'),
      ),
    );

    await _actualizarNoticias();
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al eliminar noticia: $error'),
      ),
    );
  }
}
Future<void> _editarNoticia(
  Map<String, dynamic> noticia,
) async {
  final resultado = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => NoticiaFormScreen(
        noticia: noticia,
      ),
    ),
  );

  if (!mounted) return;

  if (resultado == true) {
    await _actualizarNoticias();
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Noticias'),
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: _abrirFormulario,
  icon: const Icon(Icons.add),
  label: const Text('Nueva noticia'),
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
                      'Error al cargar las noticias',
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
                    size: 70,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Todavía no hay noticias registradas',
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

                final publicada =
                    noticia['publicada'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contenido,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(
                            publicada
                                ? 'Publicada'
                                : 'Borrador',
                          ),
                          avatar: Icon(
                            publicada
                                ? Icons.check_circle
                                : Icons.edit_note,
                            size: 18,
                          ),
                        ),const SizedBox(height: 8),

Align(
  alignment: Alignment.centerRight,
  child: OutlinedButton.icon(
    onPressed: () => _cambiarEstadoNoticia(
      noticia['id'].toString(),
      publicada,
    ),
    icon: Icon(
      publicada ? Icons.visibility_off : Icons.publish,
    ),
    label: Text(
      publicada ? 'Despublicar' : 'Publicar',
    ),
  ),
),
const SizedBox(height: 8),
const SizedBox(height: 8),

Align(
  alignment: Alignment.centerRight,
  child: OutlinedButton.icon(
    onPressed: () => _editarNoticia(noticia),
    icon: const Icon(Icons.edit),
    label: const Text('Editar noticia'),
  ),
),
Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () => _eliminarNoticia(
      noticia['id'].toString(),
      titulo,
    ),
    icon: const Icon(
      Icons.delete_outline,
      color: Colors.redAccent,
    ),
    label: const Text(
      'Eliminar noticia',
      style: TextStyle(color: Colors.redAccent),
    ),
  ),
),

                        
                      ],
                    ),
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
