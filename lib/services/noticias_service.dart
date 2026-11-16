
import 'package:supabase_flutter/supabase_flutter.dart';

class NoticiasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Consultar noticias visibles según los permisos RLS.
  Future<List<Map<String, dynamic>>> obtenerNoticias() async {
    final respuesta = await _supabase
        .from('noticias')
        .select()
        .order('fecha_creacion', ascending: false);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  // Registrar una noticia nueva.
  Future<void> crearNoticia({
    required String titulo,
    required String contenido,
    String? imagenUrl,
    bool publicada = false,
  }) async {
    final usuario = _supabase.auth.currentUser;

    if (usuario == null) {
      throw Exception('Debes iniciar sesión');
    }

    await _supabase.from('noticias').insert({
      'titulo': titulo.trim(),
      'contenido': contenido.trim(),
      'imagen_url': imagenUrl,
      'autor_id': usuario.id,
      'publicada': publicada,
    });
  }

  // Actualizar una noticia.
  Future<void> actualizarNoticia({
    required String id,
    required String titulo,
    required String contenido,
    String? imagenUrl,
    required bool publicada,
  }) async {
    await _supabase.from('noticias').update({
      'titulo': titulo.trim(),
      'contenido': contenido.trim(),
      'imagen_url': imagenUrl,
      'publicada': publicada,
      'fecha_actualizacion':
          DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // Publicar o despublicar una noticia.
  Future<void> cambiarPublicacion({
    required String id,
    required bool publicada,
  }) async {
    await _supabase.from('noticias').update({
      'publicada': publicada,
      'fecha_actualizacion':
          DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // Eliminar una noticia.
  Future<void> eliminarNoticia(String id) async {
    await _supabase
        .from('noticias')
        .delete()
        .eq('id', id);
  }
}
