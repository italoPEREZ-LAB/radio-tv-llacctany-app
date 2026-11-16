
import 'package:flutter/material.dart';

import '../../services/eventos_service.dart';

class EventoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? evento;

  const EventoFormScreen({
    super.key,
    this.evento,
  });

  @override
  State<EventoFormScreen> createState() =>
      _EventoFormScreenState();
}

class _EventoFormScreenState extends State<EventoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventosService = EventosService();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _lugarController = TextEditingController();
  final _imagenController = TextEditingController();

  DateTime? _fechaEvento;
  TimeOfDay? _horaEvento;

  bool _publicado = false;
  bool _guardando = false;

  bool get _esEdicion => widget.evento != null;

  @override
  void initState() {
    super.initState();

    final evento = widget.evento;

    if (evento != null) {
      _tituloController.text =
          evento['titulo']?.toString() ?? '';

      _descripcionController.text =
          evento['descripcion']?.toString() ?? '';

      _lugarController.text =
          evento['lugar']?.toString() ?? '';

      _imagenController.text =
          evento['imagen_url']?.toString() ?? '';

      _publicado = evento['publicado'] == true;

      final fecha = evento['fecha_evento']?.toString();

      if (fecha != null && fecha.isNotEmpty) {
        _fechaEvento = DateTime.tryParse(fecha);
      }

      final hora = evento['hora_evento']?.toString();

      if (hora != null && hora.isNotEmpty) {
        final partes = hora.split(':');

        if (partes.length >= 2) {
          final horas = int.tryParse(partes[0]);
          final minutos = int.tryParse(partes[1]);

          if (horas != null &&
              minutos != null &&
              horas >= 0 &&
              horas <= 23 &&
              minutos >= 0 &&
              minutos <= 59) {
            _horaEvento = TimeOfDay(
              hour: horas,
              minute: minutos,
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _lugarController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _formatearHora(TimeOfDay hora) {
    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');

    return '$horas:$minutos';
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaEvento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaEvento = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaEvento ?? TimeOfDay.now(),
    );

    if (hora != null && mounted) {
      setState(() {
        _horaEvento = hora;
      });
    }
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaEvento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha del evento'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final hora = _horaEvento == null
          ? null
          : _formatearHora(_horaEvento!);

      if (_esEdicion) {
        await _eventosService.actualizarEvento(
          id: widget.evento!['id'].toString(),
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          fechaEvento: _fechaEvento!,
          lugar: _lugarController.text,
          horaEvento: hora,
          imagenUrl: _imagenController.text,
          publicado: _publicado,
        );
      } else {
        await _eventosService.crearEvento(
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          fechaEvento: _fechaEvento!,
          lugar: _lugarController.text,
          horaEvento: hora,
          imagenUrl: _imagenController.text,
          publicado: _publicado,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el evento: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar evento' : 'Nuevo evento',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título del evento',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa el título del evento';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descripcionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _fechaEvento == null
                    ? 'Seleccionar fecha'
                    : 'Fecha: ${_formatearFecha(_fechaEvento!)}',
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _seleccionarHora,
              icon: const Icon(Icons.access_time),
              label: Text(
                _horaEvento == null
                    ? 'Seleccionar hora (opcional)'
                    : 'Hora: ${_formatearHora(_horaEvento!)}',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _lugarController,
              decoration: const InputDecoration(
                labelText: 'Lugar del evento',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa el lugar del evento';
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
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Publicar evento'),
              subtitle: Text(
                _publicado
                    ? 'Visible para todos los usuarios'
                    : 'Guardar como borrador',
              ),
              value: _publicado,
              onChanged: (valor) {
                setState(() {
                  _publicado = valor;
                });
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarEvento,
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
                        ? 'Guardar cambios'
                        : 'Registrar evento',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
