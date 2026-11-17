
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class PodcastsPortadasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _bucket = 'podcasts-portadas';
  static const int _tamanoMaximo = 5 * 1024 * 1024;

  Future<String> subirPortada({
    required Uint8List archivo,
    required String nombreArchivo,
  }) async {
    if (archivo.isEmpty) {
      throw Exception('La imagen está vacía.');
    }

    if (archivo.lengthInBytes > _tamanoMaximo) {
      throw Exception(
        'La imagen no debe superar los 5 MB.',
      );
    }

    final extension =
        nombreArchivo.split('.').last.toLowerCase();

    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      throw Exception(
        'Solo se permiten imágenes JPG, JPEG o PNG.',
      );
    }

    final usuario = _supabase.auth.currentUser;

    if (usuario == null) {
      throw Exception(
        'Debes iniciar sesión como administrador.',
      );
    }

    final contentType = extension == 'png'
        ? 'image/png'
        : 'image/jpeg';

    final nombreUnico =
        '${DateTime.now().microsecondsSinceEpoch}_${usuario.id}.$extension';

    final ruta = 'imagenes/$nombreUnico';

    await _supabase.storage.from(_bucket).uploadBinary(
      ruta,
      archivo,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: false,
      ),
    );

    return _supabase.storage
        .from(_bucket)
        .getPublicUrl(ruta);
  }

  Future<void> eliminarPortadaTemporal(
    String imagenUrl,
  ) async {
    final url = imagenUrl.trim();
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    final supabaseUri =
        Uri.tryParse(_supabase.rest.url);

    if (uri == null ||
        supabaseUri == null ||
        uri.scheme != 'https' ||
        uri.host != supabaseUri.host) {
      throw Exception(
        'La portada no pertenece a este proyecto Supabase.',
      );
    }

    const prefijo =
        '/storage/v1/object/public/podcasts-portadas/imagenes/';

    if (!uri.path.startsWith(prefijo)) {
      throw Exception(
        'La URL no corresponde a una portada administrada.',
      );
    }

    final ruta = Uri.decodeComponent(
      uri.path.substring(
        '/storage/v1/object/public/podcasts-portadas/'
            .length,
      ),
    );

    // No eliminar imágenes asociadas a podcasts.
    final referencias = await _supabase
        .from('podcasts')
        .select('id')
        .eq('imagen_url', url)
        .limit(1);

    if (referencias.isNotEmpty) {
      return;
    }

    await _supabase.storage.from(_bucket).remove([ruta]);
  }
}
