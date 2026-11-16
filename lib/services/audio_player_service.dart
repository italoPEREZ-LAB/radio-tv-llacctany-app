
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  AudioPlayerService._();

  static final AudioPlayerService instance =
      AudioPlayerService._();

  final AudioPlayer player = AudioPlayer();

  String? _currentUrl;
  bool _isRadio = false;

  bool get isRadio => _isRadio;
  String? get currentUrl => _currentUrl;

  Future<void> reproducirRadio({
    required String url,
    required String titulo,
    required String artista,
  }) async {
    if (_currentUrl != url || !_isRadio) {
      await player.stop();

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: titulo,
            artist: artista,
            album: 'Radio TV Estación Llacctany',
            isLive: true,
          ),
        ),
      );

      _currentUrl = url;
      _isRadio = true;
    }

    player.play();
  }

  Future<void> reproducirPodcast({
    required String url,
    required String titulo,
    String? imagenUrl,
  }) async {
    await player.stop();

    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: titulo,
          artist: 'Radio TV Estación Llacctany',
          album: 'Podcasts',
          artUri: imagenUrl != null &&
                  imagenUrl.trim().isNotEmpty
              ? Uri.tryParse(imagenUrl.trim())
              : null,
        ),
      ),
    );

    _currentUrl = url;
    _isRadio = false;

    player.play();
  }

  Future<void> pausar() async {
    await player.pause();
  }

  Future<void> detener() async {
    await player.stop();
  }
}
