
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio_background/just_audio_background.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _player = AudioPlayer();

  // Colocaremos aquí la URL real de AzuraCast.
  static const String streamUrl =
      'https://ice1.somafm.com/groovesalad-128-mp3';

  bool _isConnecting = false;
  String? _errorMessage;

  bool get _hasStream => streamUrl.trim().isNotEmpty;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }


  Future<void> _togglePlayback() async {
    if (_isConnecting) return;

    if (!_hasStream) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Streaming todavía no configurado.'),
        ),
      );
      return;
    }

    if (_player.playing) {
      await _player.pause();
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      if (_player.audioSource == null) {
        final source = AudioSource.uri(
          Uri.parse(streamUrl),
          tag: MediaItem(
            id: streamUrl,
            title: 'Radio de prueba - Groove Salad',
            artist: 'SomaFM',
            album: 'Prueba técnica de Radio Llacctany',
            isLive: true,
          ),
        );

        await _player.setAudioSource(source);
      }

      // Inicia la reproducción sin esperar a que
      // termine una transmisión en vivo.
      _player.play();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'No se pudo conectar con el streaming.';
      });

      debugPrint('Error de audio: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }


  Future<void> _openFacebook() async {
    final uri = Uri.parse(
      'https://www.facebook.com/RadioTvEstacionLlacctany/',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Facebook.'),
        ),
      );
    }
  }

  Widget _infoTile(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      color: const Color(0xFF1B1B2F),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFF4D9D),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio en Vivo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage:
              AssetImage('assets/images/logo_radio.jpg'),
            ),

            const SizedBox(height: 20),

            const Text(
              'Radio TV Estación Llacctany',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              '103.5 FM • Ranracancha - Chincheros',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF2575FC),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'RADIO LLACCTANY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Icon(
                    Icons.graphic_eq,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 15),

                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;

                      final playing = state?.playing ?? false;
                      final processing =
                          state?.processingState;

                      final loading = _isConnecting ||
                          processing == ProcessingState.loading ||
                          processing == ProcessingState.buffering;

                      String status;

                      if (!_hasStream) {
                        status = 'STREAMING PENDIENTE';
                      } else if (_errorMessage != null) {
                        status = 'SIN CONEXIÓN';
                      } else if (loading) {
                        status = 'CONECTANDO...';
                      } else if (playing) {
                        status = 'EN VIVO';
                      } else {
                        status = 'RADIO DETENIDA';
                      }

                      return Column(
                        children: [
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: loading
                                ? null
                                : _togglePlayback,
                            icon: Icon(
                              playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              playing
                                  ? 'PAUSAR RADIO'
                                  : 'ESCUCHAR RADIO',
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 18),

                  OutlinedButton.icon(
                    onPressed: _openFacebook,
                    icon: const Icon(Icons.facebook),
                    label: const Text('VER FACEBOOK LIVE'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _infoTile(
              Icons.schedule,
              'Programa actual',
              'Música, noticias y comunicación local',
            ),

            _infoTile(
              Icons.people,
              'Comunidad',
              'La voz de nuestro pueblo',
            ),

            _infoTile(
              Icons.wifi_tethering,
              'Streaming',
              _hasStream
                  ? 'Reproductor configurado'
                  : 'Esperando conexión con AzuraCast',
            ),
          ],
        ),
      ),
    );
  }
}
