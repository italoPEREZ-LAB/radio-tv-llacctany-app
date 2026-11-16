
import 'package:flutter/material.dart';

import '../../services/podcasts_service.dart';
import 'podcast_form_screen.dart';

class PodcastsAdminScreen extends StatefulWidget {
  const PodcastsAdminScreen({super.key});

  @override
  State<PodcastsAdminScreen> createState() =>
      _PodcastsAdminScreenState();
}

class _PodcastsAdminScreenState
    extends State<PodcastsAdminScreen> {
  final PodcastsService _podcastsService = PodcastsService();

  late Future<List<Map<String, dynamic>>> _podcastsFuture;

  @override
  void initState() {
    super.initState();
    _cargarPodcasts();
  }

  void _cargarPodcasts() {
    _podcastsFuture = _podcastsService.obtenerPodcasts();
  }

  Future<void> _actualizarPodcasts() async {
    setState(() {
      _cargarPodcasts();
    });

    try {
      await _podcastsFuture;
    } catch (_) {
      // FutureBuilder mostrará el error.
    }
  }

  String _formatearFecha(dynamic valor) {
    if (valor == null) return 'Sin fecha';

    final fecha = DateTime.tryParse(valor.toString());

    if (fecha == null) return 'Sin fecha';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _formatearDuracion(dynamic valor) {
    if (valor == null) return 'Duración no especificada';

    final segundos = int.tryParse(valor.toString());

    if (segundos == null || segundos < 0) {
      return 'Duración no especificada';
    }

    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segundosRestantes = segundos % 60;

    if (horas > 0) {
      return '$horas h ${minutos} min';
    }

    if (minutos > 0) {
      return '$minutos min ${segundosRestantes} s';
    }

    return '$segundosRestantes s';
  }

  Future<void> _cambiarPublicacion(
    Map<String, dynamic> podcast,
  ) async {
    final publicado = podcast['publicado'] == true;

    try {
      await _podcastsService.cambiarPublicacion(
        id: podcast['id'].toString(),
        publicado: !publicado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            publicado
                ? 'Podcast despublicado correctamente'
                : 'Podcast publicado correctamente',
          ),
        ),
      );

      await _actualizarPodcasts();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cambiar la publicación: $error',
          ),
        ),
      );
    }
  }

  Future<void> _eliminarPodcast(
    Map<String, dynamic> podcast,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar podcast'),
          content: Text(
            '¿Deseas eliminar "${podcast['titulo']}"? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _podcastsService.eliminarPodcast(
        podcast['id'].toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Podcast eliminado correctamente'),
        ),
      );

      await _actualizarPodcasts();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el podcast: $error'),
        ),
      );
    }
  }

  
Future<void> _abrirFormulario({
  Map<String, dynamic>? podcast,
}) async {
  final resultado = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => PodcastFormScreen(
        podcast: podcast,
      ),
    ),
  );

  if (!mounted) return;

  if (resultado == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          podcast == null
              ? 'Podcast registrado correctamente'
              : 'Podcast actualizado correctamente',
        ),
      ),
    );

    await _actualizarPodcasts();
  }
}


  Widget _construirPodcast(
    Map<String, dynamic> podcast,
  ) {
    final titulo =
        podcast['titulo']?.toString() ?? 'Sin título';

    final descripcion =
        podcast['descripcion']?.toString() ?? '';

    final publicado = podcast['publicado'] == true;

    final imagenUrl =
        podcast['imagen_url']?.toString().trim() ?? '';

    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagenUrl.isNotEmpty)
            Image.network(
              imagenUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                Text(
                  'Fecha: ${_formatearFecha(podcast['fecha_publicacion'])}',
                ),

                const SizedBox(height: 6),

                Text(
                  'Duración: ${_formatearDuracion(podcast['duracion_segundos'])}',
                ),

                const SizedBox(height: 12),

                Chip(
                  label: Text(
                    publicado ? 'Publicado' : 'Borrador',
                  ),
                  avatar: Icon(
                    publicado
                        ? Icons.check_circle
                        : Icons.edit_note,
                    size: 18,
                  ),
                ),

                const Divider(height: 24),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _abrirFormulario(
                        podcast: podcast,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),

                    OutlinedButton.icon(
                      onPressed: () =>
                          _cambiarPublicacion(podcast),
                      icon: Icon(
                        publicado
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      label: Text(
                        publicado
                            ? 'Despublicar'
                            : 'Publicar',
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: () =>
                          _eliminarPodcast(podcast),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Podcasts'),
        actions: [
          IconButton(
            tooltip: 'Actualizar podcasts',
            onPressed: _actualizarPodcasts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _podcastsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar podcasts: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final podcasts = snapshot.data ?? [];

          if (podcasts.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no hay podcasts registrados.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _actualizarPodcasts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: podcasts.length,
              itemBuilder: (context, index) {
                return _construirPodcast(podcasts[index]);
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo podcast'),
      ),
    );
  }
}
