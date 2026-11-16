
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class PodcastsStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _bucket = 'podcasts-audio';

  // ============================================
  // SUBIR ARCHIVO MP3
  // ============================================

  Future<String> subirAudio({
    required Uint8List archivo,
    required String nombreArchivo,
  }) async {
    final usuario = _supabase.auth.currentUser;

    if (usuario == null) {
      throw Exception(
        'Debes iniciar sesión para subir podcasts.',
      );
    }

    if (archivo.isEmpty) {
      throw Exception('El archivo está vacío.');
    }

    final extension = nombreArchivo
        .split('.')
        .last
        .toLowerCase();

    if (extension != 'mp3') {
      throw Exception(
        'Solo se permiten archivos MP3.',
      );
    }

    final nombreUnico =
        '${DateTime.now().microsecondsSinceEpoch}_'
        '${usuario.id}.mp3';

    final ruta = 'episodios/$nombreUnico';

    await _supabase.storage.from(_bucket).uploadBinary(
      ruta,
      archivo,
      fileOptions: const FileOptions(
        contentType: 'audio/mpeg',
        upsert: false,
      ),
    );

    return _supabase.storage
        .from(_bucket)
        .getPublicUrl(ruta);
  }

  // ============================================
  // ELIMINAR AUDIO RECIÉN SUBIDO
  // ============================================

  Future<void> eliminarAudioTemporal(String audioUrl) async {
    final uri = Uri.tryParse(audioUrl.trim());

    if (uri == null || uri.scheme != 'https') {
      throw Exception('La URL del audio no es válida.');
    }

    // Confirmar que la URL corresponde a este Supabase.
    final supabaseUri = Uri.tryParse(_supabase.rest.url);

    if (supabaseUri == null ||
        uri.host != supabaseUri.host ||
        uri.port != supabaseUri.port) {
      throw Exception(
        'El audio no pertenece a nuestro almacenamiento.',
      );
    }

    const prefijo =
        '/storage/v1/object/public/podcasts-audio/episodios/';

    if (!uri.path.startsWith(prefijo)) {
      throw Exception(
        'La URL no corresponde a la carpeta de podcasts.',
      );
    }

    final nombreArchivo = Uri.decodeComponent(
      uri.path.substring(prefijo.length),
    );

    if (nombreArchivo.isEmpty ||
        nombreArchivo.contains('/') ||
        nombreArchivo.contains('\\') ||
        !nombreArchivo.toLowerCase().endsWith('.mp3')) {
      throw Exception(
        'La ruta del archivo MP3 no es válida.',
      );
    }

    final ruta = 'episodios/$nombreArchivo';

    // Protección adicional:
    // no eliminar si algún podcast utiliza este audio.
    final referencias = await _supabase
        .from('podcasts')
        .select('id')
        .eq('audio_url', audioUrl)
        .limit(1);

    if (referencias.isNotEmpty) {
      throw Exception(
        'Este audio ya está asociado a un podcast.',
      );
    }

    await _supabase.storage.from(_bucket).remove([ruta]);
  }
}
