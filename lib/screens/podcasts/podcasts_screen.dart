
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../services/podcasts_service.dart';
import '../../services/audio_player_service.dart';

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  final PodcastsService _podcastsService = PodcastsService();
  final AudioPlayerService _audioService =
      AudioPlayerService.instance;

  late Future<List<Map<String, dynamic>>> _podcastsFuture;

  bool _cargandoAudio = false;
  String? _urlCargando;

  AudioPlayer get _player => _audioService.player;

  @override
  void initState() {
    super.initState();
    _cargarPodcasts();
  }

  void _cargarPodcasts() {
    _podcastsFuture =
        _podcastsService.obtenerPodcastsPublicados();
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

  bool _esPodcastActual(String url) {
    return !_audioService.isRadio &&
        _audioService.currentUrl == url;
  }

  String _formatearDuracion(dynamic valor) {
    if (valor == null) return 'Duración no especificada';

    final segundos = int.tryParse(valor.toString());

    if (segundos == null || segundos < 0) {
      return 'Duración no especificada';
    }

    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;

    if (horas > 0) {
      return '$horas h ${minutos} min';
    }

    if (minutos > 0) {
      return '$minutos min';
    }

    return '$segundos s';
  }

  Future<void> _reproducirPodcast(
    Map<String, dynamic> podcast,
  ) async {
    if (_cargandoAudio) return;

    final url =
        podcast['audio_url']?.toString().trim() ?? '';

    final titulo =
        podcast['titulo']?.toString() ?? 'Podcast';

    final imagenUrl =
        podcast['imagen_url']?.toString().trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este podcast no tiene audio.'),
        ),
      );
      return;
    }

    if (_esPodcastActual(url) && _player.playing) {
      await _audioService.pausar();
      return;
    }

    setState(() {
      _cargandoAudio = true;
      _urlCargando = url;
    });

    try {
      if (_esPodcastActual(url) &&
          _player.audioSource != null) {
        if (_player.processingState ==
            ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }

        _player.play();
      } else {
        await _audioService.reproducirPodcast(
          url: url,
          titulo: titulo,
          imagenUrl: imagenUrl,
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo reproducir el podcast: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargandoAudio = false;
          _urlCargando = null;
        });
      }
    }
  }

  Widget _construirPodcast(
    Map<String, dynamic> podcast,
  ) {
    final titulo =
        podcast['titulo']?.toString() ?? 'Sin título';

    final descripcion =
        podcast['descripcion']?.toString() ?? '';

    final url =
        podcast['audio_url']?.toString().trim() ?? '';

    final imagenUrl =
        podcast['imagen_url']?.toString().trim() ?? '';

    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final esActual = _esPodcastActual(url);

        final reproduciendo =
            esActual && _player.playing;

        final cargando =
            _cargandoAudio && _urlCargando == url;

        return Card(
          color: const Color(0xFF1B1B2F),
          margin: const EdgeInsets.only(bottom: 14),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (imagenUrl.isNotEmpty)
                Image.network(
                  imagenUrl,
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const SizedBox.shrink();
                  },
                ),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFF4D9D),
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  '$descripcion • '
                  '${_formatearDuracion(podcast['duracion_segundos'])}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                trailing: cargando
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        tooltip: reproduciendo
                            ? 'Pausar podcast'
                            : 'Reproducir podcast',
                        onPressed: () =>
                            _reproducirPodcast(podcast),
                        icon: Icon(
                          reproduciendo
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
              ),

              if (esActual)
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final posicion =
                        snapshot.data ?? Duration.zero;

                    final duracion = _player.duration;

                    if (duracion == null ||
                        duracion.inMilliseconds <= 0) {
                      return const SizedBox.shrink();
                    }

                    final maximo =
                        duracion.inMilliseconds.toDouble();

                    final valor = posicion.inMilliseconds
                        .toDouble()
                        .clamp(0.0, maximo);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: valor / maximo,
                            backgroundColor:
                                Colors.white24,
                            color: const Color(0xFFFF4D9D),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcasts'),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los podcasts.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _actualizarPodcasts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final podcasts = snapshot.data ?? [];

          if (podcasts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.podcasts,
                      size: 70,
                      color: Color(0xFFFF4D9D),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay podcasts publicados por el momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _actualizarPodcasts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ],
                ),
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
    );
  }
}
