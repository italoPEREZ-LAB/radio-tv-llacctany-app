
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> obtenerRolActual() async {
    final usuario = _supabase.auth.currentUser;

    if (usuario == null) {
      return null;
    }

    final perfil = await _supabase
        .from('perfiles')
        .select('rol')
        .eq('id', usuario.id)
        .single();

    return perfil['rol'] as String?;
  }

  Future<bool> esAdministrador() async {
    final rol = await obtenerRolActual();
    return rol == 'administrador';
  }
}

