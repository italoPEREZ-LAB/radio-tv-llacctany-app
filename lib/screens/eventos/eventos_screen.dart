
import 'package:flutter/material.dart';

import '../../services/eventos_service.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final EventosService _eventosService = EventosService();

  late Future<List<Map<String, dynamic>>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  void _cargarEventos() {
    _eventosFuture = _eventosService.obtenerEventosPublicados();
  }

  Future<void> _actualizarEventos() async {
    setState(() {
      _cargarEventos();
    });

    try {
      await _eventosFuture;
    } catch (_) {
      // El FutureBuilder mostrará el error correspondiente.
    }
  }

  DateTime? _obtenerFecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  String _formatearFecha(dynamic valor) {
    final fecha = _obtenerFecha(valor);

    if (fecha == null) return 'Sin fecha';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _formatearHora(dynamic valor) {
    if (valor == null || valor.toString().isEmpty) {
      return 'Hora por confirmar';
    }

    final partes = valor.toString().split(':');

    if (partes.length < 2) {
      return valor.toString();
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) {
      return valor.toString();
    }

    final periodo = hora >= 12 ? 'PM' : 'AM';
    final hora12 = hora % 12 == 0 ? 12 : hora % 12;

    return '$hora12:${minuto.toString().padLeft(2, '0')} $periodo';
  }

  String _fechaCorta(dynamic valor) {
    final fecha = _obtenerFecha(valor);

    if (fecha == null) return '--';

    const meses = [
      'ENE', 'FEB', 'MAR', 'ABR',
      'MAY', 'JUN', 'JUL', 'AGO',
      'SEP', 'OCT', 'NOV', 'DIC',
    ];

    return '${fecha.day}\n${meses[fecha.month - 1]}';
  }

  void _mostrarDetalle(Map<String, dynamic> evento) {
    final titulo = evento['titulo']?.toString() ?? 'Evento';
    final descripcion =
        evento['descripcion']?.toString() ?? '';
    final lugar = evento['lugar']?.toString() ?? '';
    final imagenUrl =
        evento['imagen_url']?.toString().trim() ?? '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(titulo),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imagenUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagenUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(descripcion),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatearFecha(evento['fecha_evento']),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatearHora(evento['hora_evento']),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(lugar)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _construirEvento(Map<String, dynamic> evento) {
    final titulo =
        evento['titulo']?.toString() ?? 'Sin título';

    final lugar =
        evento['lugar']?.toString() ?? 'Lugar por confirmar';

    final hora = _formatearHora(evento['hora_evento']);

    final imagenUrl =
        evento['imagen_url']?.toString().trim() ?? '';

    return Card(
      color: const Color(0xFF1B1B2F),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarDetalle(evento),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagenUrl.isNotEmpty)
              Image.network(
                imagenUrl,
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return const SizedBox.shrink();
                },
              ),

            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.pink,
                child: Text(
                  _fechaCorta(evento['fecha_evento']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              title: Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('$lugar - $hora'),
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
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
        title: const Text('Eventos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar eventos',
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los eventos.',
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_busy,
                      size: 70,
                      color: Colors.pinkAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay eventos publicados por el momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _actualizarEventos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _actualizarEventos,
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
    );
  }
}
