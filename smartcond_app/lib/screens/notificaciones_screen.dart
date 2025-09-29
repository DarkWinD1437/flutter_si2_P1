import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _notificaciones = [];
  String _userRole = 'resident'; // Default role

  @override
  void initState() {
    super.initState();
    _loadNotificaciones();
  }

  void _onSidebarSelect(String key) {
    if (key == 'logout') {
      // TODO: Implement logout
      Navigator.pushReplacementNamed(context, '/login');
    } else if (key != 'notificaciones') {
      Navigator.pushReplacementNamed(context, '/$key');
    }
  }

  Future<void> _loadNotificaciones() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carga de notificaciones
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _notificaciones = [
          {
            'id': 1,
            'titulo': 'Pago de cuota pendiente',
            'mensaje':
                'Tienes un pago pendiente de \$50.000 por concepto de cuota mensual.',
            'fecha': '2025-09-25',
            'tipo': 'financiero',
            'leida': false,
          },
          {
            'id': 2,
            'titulo': 'Mantenimiento programado',
            'mensaje':
                'Se realizará mantenimiento en el ascensor el próximo sábado de 8:00 a 12:00.',
            'fecha': '2025-09-24',
            'tipo': 'mantenimiento',
            'leida': true,
          },
          {
            'id': 3,
            'titulo': 'Nueva reserva aprobada',
            'mensaje': 'Tu reserva para el salón de eventos ha sido aprobada.',
            'fecha': '2025-09-23',
            'tipo': 'reserva',
            'leida': false,
          },
          {
            'id': 4,
            'titulo': 'Actualización de seguridad',
            'mensaje':
                'Se han actualizado las medidas de seguridad del condominio.',
            'fecha': '2025-09-22',
            'tipo': 'seguridad',
            'leida': true,
          },
        ];
        _isLoading = false;
      });
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'financiero':
        return Colors.red;
      case 'mantenimiento':
        return Colors.orange;
      case 'reserva':
        return Colors.green;
      case 'seguridad':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'financiero':
        return Icons.payment;
      case 'mantenimiento':
        return Icons.build;
      case 'reserva':
        return Icons.event;
      case 'seguridad':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  void _marcarComoLeida(int id) {
    setState(() {
      final index = _notificaciones.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notificaciones[index]['leida'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Notificaciones IA'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotificaciones,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: _userRole,
          selected: 'notificaciones',
          onSelect: (key) {
            Navigator.pop(context);
            _onSidebarSelect(key);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotificaciones,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = _notificaciones[index];
                  final bool leida = notificacion['leida'] ?? false;

                  return Card(
                    color: leida
                        ? const Color(0xFF232336)
                        : const Color(0xFF2A2A3C),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _marcarComoLeida(notificacion['id']),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getTipoColor(
                                  notificacion['tipo'],
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getTipoIcon(notificacion['tipo']),
                                color: _getTipoColor(notificacion['tipo']),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notificacion['titulo'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: leida
                                                ? Colors.white70
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (!leida)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF97316),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notificacion['mensaje'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: leida
                                          ? Colors.white60
                                          : Colors.white.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.white54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        notificacion['fecha'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTipoColor(
                                            notificacion['tipo'],
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _getTipoColor(
                                              notificacion['tipo'],
                                            ).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          notificacion['tipo'].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getTipoColor(
                                              notificacion['tipo'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
