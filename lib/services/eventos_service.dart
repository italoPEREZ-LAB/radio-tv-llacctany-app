
import 'package:supabase_flutter/supabase_flutter.dart';

class EventosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener eventos visibles según las políticas RLS.
  // Los administradores pueden ver también los borradores.
  Future<List<Map<String, dynamic>>> obtenerEventos() async {
    final respuesta = await _supabase
        .from('eventos')
        .select()
        .order('fecha_evento', ascending: true);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  // Obtener únicamente eventos publicados.
  Future<List<Map<String, dynamic>>> obtenerEventosPublicados() async {
    final respuesta = await _supabase
        .from('eventos')
        .select()
        .eq('publicado', true)
        .order('fecha_evento', ascending: true);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  // Registrar un nuevo evento.
  Future<void> crearEvento({
    required String titulo,
    required String descripcion,
    required DateTime fechaEvento,
    required String lugar,
    String? horaEvento,
    String? imagenUrl,
    bool publicado = false,
  }) async {
    final usuario = _supabase.auth.currentUser;

    if (usuario == null) {
      throw Exception('Debes iniciar sesión para registrar eventos.');
    }

    await _supabase.from('eventos').insert({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'fecha_evento': _formatearFecha(fechaEvento),
      'hora_evento': horaEvento,
      'lugar': lugar.trim(),
      'imagen_url': _normalizarTextoOpcional(imagenUrl),
      'organizador_id': usuario.id,
      'publicado': publicado,
    });
  }

  // Actualizar la información de un evento.
  Future<void> actualizarEvento({
    required String id,
    required String titulo,
    required String descripcion,
    required DateTime fechaEvento,
    required String lugar,
    String? horaEvento,
    String? imagenUrl,
    required bool publicado,
  }) async {
    await _supabase.from('eventos').update({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'fecha_evento': _formatearFecha(fechaEvento),
      'hora_evento': horaEvento,
      'lugar': lugar.trim(),
      'imagen_url': _normalizarTextoOpcional(imagenUrl),
      'publicado': publicado,
      'fecha_actualizacion':
          DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // Publicar o despublicar un evento.
  Future<void> cambiarPublicacion({
    required String id,
    required bool publicado,
  }) async {
    await _supabase.from('eventos').update({
      'publicado': publicado,
      'fecha_actualizacion':
          DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // Eliminar un evento.
  Future<void> eliminarEvento(String id) async {
    await _supabase
        .from('eventos')
        .delete()
        .eq('id', id);
  }

  // Convertir fecha al formato DATE de PostgreSQL.
  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }

  // Convertir textos opcionales vacíos a NULL.
  String? _normalizarTextoOpcional(String? valor) {
    final texto = valor?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }
}
