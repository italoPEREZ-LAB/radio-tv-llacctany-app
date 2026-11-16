
import 'package:flutter/material.dart';

import '../../services/eventos_service.dart';
import 'evento_form_screen.dart';

class EventosAdminScreen extends StatefulWidget {
  const EventosAdminScreen({super.key});

  @override
  State<EventosAdminScreen> createState() =>
      _EventosAdminScreenState();
}

class _EventosAdminScreenState extends State<EventosAdminScreen> {
  final EventosService _eventosService = EventosService();

  late Future<List<Map<String, dynamic>>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  void _cargarEventos() {
    _eventosFuture = _eventosService.obtenerEventos();
  }

  void _actualizarEventos() {
    setState(() {
      _cargarEventos();
    });
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Sin fecha';

    final texto = fecha.toString();
    final partes = texto.split('-');

    if (partes.length != 3) return texto;

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Future<void> _cambiarPublicacion(
    Map<String, dynamic> evento,
  ) async {
    final publicado = evento['publicado'] == true;

    try {
      await _eventosService.cambiarPublicacion(
        id: evento['id'].toString(),
        publicado: !publicado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            publicado
                ? 'Evento despublicado correctamente'
                : 'Evento publicado correctamente',
          ),
        ),
      );

      _actualizarEventos();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el evento: $error'),
        ),
      );
    }
  }

  Future<void> _eliminarEvento(
    Map<String, dynamic> evento,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar evento'),
          content: Text(
            '¿Estás seguro de eliminar "${evento['titulo']}"? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _eventosService.eliminarEvento(
        evento['id'].toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento eliminado correctamente'),
        ),
      );

      _actualizarEventos();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el evento: $error'),
        ),
      );
    }
  }

  // Se conectará al formulario en el siguiente paso.
  Future<void> _abrirFormulario({
  Map<String, dynamic>? evento,
}) async {
  final resultado = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => EventoFormScreen(evento: evento),
    ),
  );

  if (!mounted) return;

  if (resultado == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          evento == null
              ? 'Evento registrado correctamente'
              : 'Evento actualizado correctamente',
        ),
      ),
    );

    _actualizarEventos();
  }
}

  Widget _construirEvento(Map<String, dynamic> evento) {
    final publicado = evento['publicado'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evento['titulo']?.toString() ?? 'Sin título',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              evento['descripcion']?.toString() ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),
                const SizedBox(width: 8),
                Text(_formatearFecha(evento['fecha_evento'])),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    evento['lugar']?.toString() ?? '',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Chip(
              label: Text(
                publicado ? 'Publicado' : 'Borrador',
              ),
              avatar: Icon(
                publicado
                    ? Icons.check_circle
                    : Icons.edit_note,
                size: 18,
              ),
            ),

            const Divider(),

            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _abrirFormulario(evento: evento),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),

                TextButton.icon(
                  onPressed: () => _cambiarPublicacion(evento),
                  icon: Icon(
                    publicado
                        ? Icons.visibility_off
                        : Icons.public,
                  ),
                  label: Text(
                    publicado ? 'Despublicar' : 'Publicar',
                  ),
                ),

                TextButton.icon(
                  onPressed: () => _eliminarEvento(evento),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar eventos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizarEventos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 50),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar eventos:\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _actualizarEventos,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final eventos = snapshot.data ?? [];

          if (eventos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 70,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Todavía no hay eventos registrados',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presiona + para registrar el primer evento.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _actualizarEventos();
              await _eventosFuture;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                return _construirEvento(eventos[index]);
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
      ),
    );
  }
}
