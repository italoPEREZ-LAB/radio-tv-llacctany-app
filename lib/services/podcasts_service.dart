
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

  // ============================================
// ELIMINAR PODCAST, AUDIO Y PORTADA
// ============================================

Future<void> eliminarPodcast(String id) async {
  // 1. Obtener los archivos asociados al podcast.
  final podcast = await _supabase
      .from('podcasts')
      .select('id, audio_url, imagen_url')
      .eq('id', id)
      .single();

  final audioUrl = podcast['audio_url']?.toString() ?? '';
  final imagenUrl = podcast['imagen_url']?.toString() ?? '';

  final rutaAudio = _obtenerRutaAudioStorage(audioUrl);
  final rutaPortada = _obtenerRutaPortadaStorage(imagenUrl);

  // 2. Eliminar el registro de la base de datos.
  await _supabase
      .from('podcasts')
      .delete()
      .eq('id', id);

  // 3. Eliminar el MP3 si ningún otro podcast lo utiliza.
  if (rutaAudio != null) {
    final referenciasAudio = await _supabase
        .from('podcasts')
        .select('id')
        .eq('audio_url', audioUrl)
        .limit(1);

    if (referenciasAudio.isEmpty) {
      await _supabase.storage
          .from('podcasts-audio')
          .remove([rutaAudio]);
    }
  }

  // 4. Eliminar la portada si ningún otro podcast la utiliza.
  if (rutaPortada != null) {
    final referenciasPortada = await _supabase
        .from('podcasts')
        .select('id')
        .eq('imagen_url', imagenUrl)
        .limit(1);

    if (referenciasPortada.isEmpty) {
      await _supabase.storage
          .from('podcasts-portadas')
          .remove([rutaPortada]);
    }
  }
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
  // LIMPIAR ARCHIVOS ANTIGUOS DESPUÉS DE EDITAR
  // ============================================

  Future<void> limpiarArchivosAnteriores({
    required String audioAnterior,
    required String audioActual,
    required String portadaAnterior,
    required String portadaActual,
  }) async {
    // Limpiar el MP3 anterior si fue reemplazado.
    if (audioAnterior.trim().isNotEmpty &&
        audioAnterior.trim() != audioActual.trim()) {
      final rutaAudio = _obtenerRutaAudioStorage(audioAnterior);

      if (rutaAudio != null) {
        final referencias = await _supabase
            .from('podcasts')
            .select('id')
            .eq('audio_url', audioAnterior.trim())
            .limit(1);

        if (referencias.isEmpty) {
          await _supabase.storage
              .from('podcasts-audio')
              .remove([rutaAudio]);
        }
      }
    }

    // Limpiar la portada anterior si fue reemplazada.
    if (portadaAnterior.trim().isNotEmpty &&
        portadaAnterior.trim() != portadaActual.trim()) {
      final rutaPortada =
          _obtenerRutaPortadaStorage(portadaAnterior);

      if (rutaPortada != null) {
        final referencias = await _supabase
            .from('podcasts')
            .select('id')
            .eq('imagen_url', portadaAnterior.trim())
            .limit(1);

        if (referencias.isEmpty) {
          await _supabase.storage
              .from('podcasts-portadas')
              .remove([rutaPortada]);
        }
      }
    }
  }

  // ============================================
  // FORMATEAR FECHA PARA SUPABASE
  // ============================================

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }// ============================================
// IDENTIFICAR PORTADA DE NUESTRO STORAGE
// ============================================

String? _obtenerRutaPortadaStorage(String imagenUrl) {
  final uri = Uri.tryParse(imagenUrl.trim());

  if (uri == null || uri.scheme != 'https') {
    return null;
  }

  final supabaseUri = Uri.tryParse(_supabase.rest.url);

  if (supabaseUri == null ||
      uri.host != supabaseUri.host ||
      uri.port != supabaseUri.port) {
    return null;
  }

  const prefijo =
      '/storage/v1/object/public/podcasts-portadas/';

  if (!uri.path.startsWith(prefijo)) {
    return null;
  }

  final ruta = uri.path.substring(prefijo.length);

  if (ruta.isEmpty || !ruta.startsWith('imagenes/')) {
    return null;
  }

  if (!ruta.toLowerCase().endsWith('.jpg') &&
      !ruta.toLowerCase().endsWith('.jpeg') &&
      !ruta.toLowerCase().endsWith('.png')) {
    return null;
  }

  return Uri.decodeComponent(ruta);
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
