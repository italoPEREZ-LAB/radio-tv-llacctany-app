
import 'package:supabase_flutter/supabase_flutter.dart';

class PodcastsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // OBTENER TODOS LOS PODCASTS (ADMINISTRADOR)
  // ============================================

  Future<List<Map<String, dynamic>>> obtenerPodcasts() async {
    final respuesta = await _supabase
        .from('podcasts')
        .select()
        .order('fecha_publicacion', ascending: false);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  // ============================================
  // OBTENER PODCASTS PUBLICADOS (USUARIOS)
  // ============================================

  Future<List<Map<String, dynamic>>> obtenerPodcastsPublicados() async {
    final respuesta = await _supabase
        .from('podcasts')
        .select()
        .eq('publicado', true)
        .order('fecha_publicacion', ascending: false);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  // ============================================
  // CREAR PODCAST
  // ============================================

  Future<void> crearPodcast({
    required String titulo,
    required String descripcion,
    required String audioUrl,
    String? imagenUrl,
    int? duracionSegundos,
    required DateTime fechaPublicacion,
    bool publicado = false,
  }) async {
    final usuario = _supabase.auth.currentUser;

    if (usuario == null) {
      throw Exception(
        'Debes iniciar sesión para registrar podcasts.',
      );
    }

    await _supabase.from('podcasts').insert({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'audio_url': audioUrl.trim(),
      'imagen_url': _normalizarTextoOpcional(imagenUrl),
      'duracion_segundos': duracionSegundos,
      'fecha_publicacion': _formatearFecha(fechaPublicacion),
      'autor_id': usuario.id,
      'publicado': publicado,
    });
  }

  // ============================================
  // ACTUALIZAR PODCAST
  // ============================================

  Future<void> actualizarPodcast({
    required String id,
    required String titulo,
    required String descripcion,
    required String audioUrl,
    String? imagenUrl,
    int? duracionSegundos,
    required DateTime fechaPublicacion,
    required bool publicado,
  }) async {
    await _supabase.from('podcasts').update({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'audio_url': audioUrl.trim(),
      'imagen_url': _normalizarTextoOpcional(imagenUrl),
      'duracion_segundos': duracionSegundos,
      'fecha_publicacion': _formatearFecha(fechaPublicacion),
      'publicado': publicado,
      'fecha_actualizacion':
          DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // ============================================
  // PUBLICAR O DESPUBLICAR PODCAST
  // ============================================

  Future<void> cambiarPublicacion({
    required String id,
    required bool publicado,
  }) async {
    await _supabase.from('podcasts').update({
      'publicado': publicado,
      'fecha_actualizacion':
          DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // ============================================
  // ELIMINAR PODCAST
  // ============================================

 
  // ============================================
  // ELIMINAR PODCAST Y SU AUDIO DE STORAGE
  // ============================================

  Future<void> eliminarPodcast(String id) async {
    const bucket = 'podcasts-audio';

    // Obtener el podcast antes de eliminarlo.
    final podcast = await _supabase
        .from('podcasts')
        .select('id, audio_url')
        .eq('id', id)
        .single();

    final audioUrl = podcast['audio_url']?.toString() ?? '';

    // Identificar si el audio pertenece a nuestro Storage.
    final rutaAudio = _obtenerRutaAudioStorage(audioUrl);

    // Eliminar primero el registro de la base de datos.
    await _supabase
        .from('podcasts')
        .delete()
        .eq('id', id);

    // Si es una URL externa, no eliminamos ningún archivo.
    if (rutaAudio == null) return;

    // Comprobar si otros podcasts utilizan el mismo audio.
    final referencias = await _supabase
        .from('podcasts')
        .select('id')
        .eq('audio_url', audioUrl)
        .limit(1);

    if (referencias.isNotEmpty) {
      return;
    }

    // Eliminar el MP3 de Supabase Storage.
    await _supabase.storage
        .from(bucket)
        .remove([rutaAudio]);
  }

  // ============================================
  // IDENTIFICAR AUDIO DE NUESTRO STORAGE
  // ============================================

  String? _obtenerRutaAudioStorage(String audioUrl) {
    final uri = Uri.tryParse(audioUrl.trim());

    if (uri == null || uri.scheme != 'https') {
      return null;
    }

   final supabaseUri = Uri.tryParse(
  _supabase.rest.url,
);

    if (supabaseUri == null ||
        uri.host != supabaseUri.host ||
        uri.port != supabaseUri.port) {
      return null;
    }

    const prefijo =
        '/storage/v1/object/public/podcasts-audio/';

    if (!uri.path.startsWith(prefijo)) {
      return null;
    }

    final ruta = uri.path.substring(prefijo.length);

    if (ruta.isEmpty ||
        !ruta.startsWith('episodios/') ||
        !ruta.toLowerCase().endsWith('.mp3')) {
      return null;
    }

    return Uri.decodeComponent(ruta);
  }


  // ============================================
  // FORMATEAR FECHA PARA SUPABASE
  // ============================================

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }

  // ============================================
  // NORMALIZAR CAMPOS OPCIONALES
  // ============================================

  String? _normalizarTextoOpcional(String? valor) {
    final texto = valor?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }
}
