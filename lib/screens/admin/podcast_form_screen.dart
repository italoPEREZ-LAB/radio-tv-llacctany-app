
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/podcasts_service.dart';
import '../../services/podcasts_storage_service.dart';

class PodcastFormScreen extends StatefulWidget {
  final Map<String, dynamic>? podcast;

  const PodcastFormScreen({
    super.key,
    this.podcast,
  });

  @override
  State<PodcastFormScreen> createState() =>
      _PodcastFormScreenState();
}

class _PodcastFormScreenState extends State<PodcastFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _podcastsService = PodcastsService();
  final _storageService = PodcastsStorageService();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _audioController = TextEditingController();
  final _imagenController = TextEditingController();
  final _duracionController = TextEditingController();

  // Audios nuevos subidos durante esta sesión.
  final Set<String> _audiosTemporales = {};

  DateTime _fechaPublicacion = DateTime.now();

  bool _publicado = false;
  bool _guardando = false;
  bool _subiendoAudio = false;
  bool _saliendo = false;
  bool _permitirSalida = false;

  String? _nombreAudioSeleccionado;

  bool get _esEdicion => widget.podcast != null;

  bool get _ocupado =>
      _guardando || _subiendoAudio || _saliendo;

  @override
  void initState() {
    super.initState();

    final podcast = widget.podcast;

    if (podcast != null) {
      _tituloController.text =
          podcast['titulo']?.toString() ?? '';

      _descripcionController.text =
          podcast['descripcion']?.toString() ?? '';

      _audioController.text =
          podcast['audio_url']?.toString() ?? '';

      _imagenController.text =
          podcast['imagen_url']?.toString() ?? '';

      final duracion = podcast['duracion_segundos'];

      if (duracion != null) {
        _duracionController.text = duracion.toString();
      }

      final fecha = podcast['fecha_publicacion'];

      if (fecha != null) {
        _fechaPublicacion =
            DateTime.tryParse(fecha.toString()) ??
                DateTime.now();
      }

      _publicado = podcast['publicado'] == true;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _audioController.dispose();
    _imagenController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  bool _urlValida(String valor) {
    final uri = Uri.tryParse(valor.trim());

    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  Future<void> _seleccionarFecha() async {
    if (_ocupado) return;

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaPublicacion,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaPublicacion = fecha;
      });
    }
  }

  // Elimina los MP3 nuevos que no quedaron guardados.
  //
  // Si una eliminación falla, conserva su URL en el
  // conjunto para poder reintentar la limpieza.
  Future<List<String>> _limpiarAudiosTemporales() async {
    final errores = <String>[];

    for (final url in _audiosTemporales.toList()) {
      try {
        await _storageService.eliminarAudioTemporal(url);
        _audiosTemporales.remove(url);
      } catch (error) {
        errores.add(error.toString());
      }
    }

    return errores;
  }

  // Se ejecuta al pulsar Atrás o Cancelar.
  Future<void> _cancelarFormulario() async {
    if (_ocupado || _permitirSalida) return;

    setState(() {
      _saliendo = true;
    });

    final errores = await _limpiarAudiosTemporales();

    if (!mounted) return;

    if (errores.isNotEmpty) {
      setState(() {
        _saliendo = false;
      });

      _mostrarMensaje(
        'No se pudieron limpiar todos los MP3. '
        'Verifica la conexión e intenta regresar nuevamente. '
        'Detalle: ${errores.first}',
      );

      return;
    }

    setState(() {
      _permitirSalida = true;
      _saliendo = false;
    });

    Navigator.of(context).pop(false);
  }

  Future<void> _seleccionarAudio() async {
    if (_ocupado) return;

    try {
      final archivos = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );

      if (archivos.isEmpty) return;

      final archivo = archivos.first;

      if (!archivo.name.toLowerCase().endsWith('.mp3')) {
        throw Exception(
          'Selecciona un archivo MP3 válido.',
        );
      }

      final ruta = archivo.path;

      if (ruta == null || ruta.isEmpty) {
        throw Exception(
          'No se pudo obtener la ruta del archivo MP3.',
        );
      }

      if (!mounted) return;

      setState(() {
        _subiendoAudio = true;
        _nombreAudioSeleccionado = archivo.name;
      });

      final bytes = await File(ruta).readAsBytes();

      final url = await _storageService.subirAudio(
        archivo: bytes,
        nombreArchivo: archivo.name,
      );

      // Registrar inmediatamente el archivo nuevo.
      _audiosTemporales.add(url);

      if (!mounted) return;

      setState(() {
        _audioController.text = url;
      });

      _mostrarMensaje(
        'Archivo MP3 subido correctamente a Supabase.',
      );
    } catch (error) {
      _mostrarMensaje(
        'No se pudo subir el audio: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _subiendoAudio = false;
        });
      }
    }
  }

  Future<void> _guardarPodcast() async {
    if (_ocupado) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final audioSeleccionado =
        _audioController.text.trim();

    final duracionTexto =
        _duracionController.text.trim();

    final int? duracionSegundos =
        duracionTexto.isEmpty
            ? null
            : int.tryParse(duracionTexto);

    setState(() {
      _guardando = true;
    });

    try {
      if (_esEdicion) {
        await _podcastsService.actualizarPodcast(
          id: widget.podcast!['id'].toString(),
          titulo: _tituloController.text.trim(),
          descripcion:
              _descripcionController.text.trim(),
          audioUrl: audioSeleccionado,
          imagenUrl: _imagenController.text.trim(),
          duracionSegundos: duracionSegundos,
          fechaPublicacion: _fechaPublicacion,
          publicado: _publicado,
        );
      } else {
        await _podcastsService.crearPodcast(
          titulo: _tituloController.text.trim(),
          descripcion:
              _descripcionController.text.trim(),
          audioUrl: audioSeleccionado,
          imagenUrl: _imagenController.text.trim(),
          duracionSegundos: duracionSegundos,
          fechaPublicacion: _fechaPublicacion,
          publicado: _publicado,
        );
      }

      // El podcast ya se guardó correctamente.
      // Su MP3 seleccionado deja de ser temporal.
      _audiosTemporales.remove(audioSeleccionado);

      // Limpiar otros MP3 subidos en esta sesión
      // que finalmente no fueron utilizados.
      final errores = await _limpiarAudiosTemporales();

      if (!mounted) return;

      if (errores.isNotEmpty) {
        _mostrarMensaje(
          'Podcast guardado correctamente, pero '
          'quedaron MP3 sin limpiar. '
          'Puedes reintentar la limpieza al salir.',
        );

        setState(() {
          _guardando = false;
        });

        return;
      }

      setState(() {
        _permitirSalida = true;
      });

      Navigator.of(context).pop(true);
    } catch (error) {
      _mostrarMensaje(
        'No se pudo guardar el podcast: $error',
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _permitirSalida,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _cancelarFormulario();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _esEdicion
                ? 'Editar podcast'
                : 'Nuevo podcast',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                _ocupado ? null : _cancelarFormulario,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _tituloController,
                enabled: !_ocupado,
                decoration: const InputDecoration(
                  labelText: 'Título del podcast',
                  prefixIcon: Icon(Icons.mic),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Ingresa el título del podcast';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                enabled: !_ocupado,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon:
                      Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Archivo de audio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Selecciona un archivo MP3 desde tu '
                'dispositivo o ingresa una URL de audio.',
              ),

              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: _ocupado
                    ? null
                    : _seleccionarAudio,
                icon: _subiendoAudio
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _subiendoAudio
                      ? 'Subiendo audio...'
                      : 'Seleccionar archivo MP3',
                ),
              ),

              if (_nombreAudioSeleccionado != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Archivo: $_nombreAudioSeleccionado',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFF4D9D),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: _audioController,
                keyboardType: TextInputType.url,
                enabled: !_ocupado,
                decoration: const InputDecoration(
                  labelText: 'URL del audio',
                  hintText:
                      'https://ejemplo.com/audio.mp3',
                  prefixIcon:
                      Icon(Icons.audiotrack),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return 'Selecciona un MP3 o ingresa una URL';
                  }

                  if (!_urlValida(valor)) {
                    return 'Ingresa una URL HTTP o HTTPS válida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _imagenController,
                enabled: !_ocupado,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText:
                      'URL de portada (opcional)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor != null &&
                      valor.trim().isNotEmpty &&
                      !_urlValida(valor)) {
                    return 'Ingresa una URL válida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _duracionController,
                enabled: !_ocupado,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText:
                      'Duración en segundos (opcional)',
                  hintText:
                      'Ejemplo: 1800 = 30 minutos',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null ||
                      valor.trim().isEmpty) {
                    return null;
                  }

                  final duracion =
                      int.tryParse(valor.trim());

                  if (duracion == null ||
                      duracion < 0) {
                    return 'Ingresa una duración válida en segundos';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed:
                    _ocupado ? null : _seleccionarFecha,
                icon:
                    const Icon(Icons.calendar_month),
                label: Text(
                  'Fecha: ${_formatearFecha(_fechaPublicacion)}',
                ),
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title:
                    const Text('Publicar podcast'),
                subtitle: Text(
                  _publicado
                      ? 'Visible para los oyentes'
                      : 'Guardar como borrador',
                ),
                value: _publicado,
                onChanged: _ocupado
                    ? null
                    : (valor) {
                        setState(() {
                          _publicado = valor;
                        });
                      },
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed:
                    _ocupado ? null : _guardarPodcast,
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando
                      ? 'Guardando...'
                      : _esEdicion
                          ? 'Guardar cambios'
                          : 'Registrar podcast',
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed:
                    _ocupado ? null : _cancelarFormulario,
                icon: _saliendo
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.close),
                label: Text(
                  _saliendo
                      ? 'Limpiando archivos...'
                      : 'Cancelar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
