

import 'package:flutter/material.dart';
import '../../services/noticias_service.dart';

class NoticiaFormScreen extends StatefulWidget {
  final Map<String, dynamic>? noticia;

  const NoticiaFormScreen({
    super.key,
    this.noticia,
  });

  @override
  State<NoticiaFormScreen> createState() =>
      _NoticiaFormScreenState();
}

class _NoticiaFormScreenState extends State<NoticiaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _imagenController = TextEditingController();

  final _noticiasService = NoticiasService();

  bool _publicada = false;
  bool _guardando = false;

  bool get _esEdicion => widget.noticia != null;

  @override
  void initState() {
    super.initState();

    final noticia = widget.noticia;

    if (noticia != null) {
      _tituloController.text =
          noticia['titulo']?.toString() ?? '';

      _contenidoController.text =
          noticia['contenido']?.toString() ?? '';

      _imagenController.text =
          noticia['imagen_url']?.toString() ?? '';

      _publicada = noticia['publicada'] == true;
    }
  }

  Future<void> _guardarNoticia() async {
    if (_guardando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final titulo = _tituloController.text.trim();
      final contenido = _contenidoController.text.trim();

      final imagenTexto = _imagenController.text.trim();
      final String? imagenUrl =
          imagenTexto.isEmpty ? null : imagenTexto;

      if (_esEdicion) {
        await _noticiasService.actualizarNoticia(
          id: widget.noticia!['id'].toString(),
          titulo: titulo,
          contenido: contenido,
          imagenUrl: imagenUrl,
          publicada: _publicada,
        );
      } else {
        await _noticiasService.crearNoticia(
          titulo: titulo,
          contenido: contenido,
          imagenUrl: imagenUrl,
          publicada: _publicada,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Noticia actualizada correctamente'
                : 'Noticia registrada correctamente',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar noticia: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Noticia' : 'Nueva Noticia',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _esEdicion
                    ? 'Actualizar noticia'
                    : 'Registrar noticia',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _tituloController,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Título de la noticia',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el título';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _contenidoController,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el contenido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _imagenController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen (opcional)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final texto = value?.trim() ?? '';

                  if (texto.isEmpty) return null;

                  final uri = Uri.tryParse(texto);

                  if (uri == null ||
                      !uri.hasAuthority ||
                      (uri.scheme != 'https' &&
                          uri.scheme != 'http')) {
                    return 'Ingresa una URL válida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Publicar noticia'),
                subtitle: Text(
                  _publicada
                      ? 'Visible para los oyentes'
                      : 'Guardar como borrador',
                ),
                value: _publicada,
                onChanged: _guardando
                    ? null
                    : (value) {
                        setState(() {
                          _publicada = value;
                        });
                      },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando
                      ? null
                      : _guardarNoticia,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : _esEdicion
                            ? 'Actualizar noticia'
                            : 'Guardar noticia',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

