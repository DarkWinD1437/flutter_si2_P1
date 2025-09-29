import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/reservas_service.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  bool _isInitialized = false;
  List<dynamic> _misReservas = [];
  List<dynamic> _areasComunes = [];
  String? _userRole;
  final AuthService _authService = AuthService();
  final ReservasService _reservasService = ReservasService();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _userRole = await _authService.getUserType();

    // Si no se puede obtener el rol del usuario, redirigir al login
    if (_userRole == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // Para seguridad, solo mostrar 1 pestaña (Áreas Comunes)
    // Para residentes, mostrar 2 pestañas (Mis Reservas y Áreas Comunes)
    final tabCount = (_userRole == 'security') ? 1 : 2;
    _tabController = TabController(length: tabCount, vsync: this);

    // Marcar como inicializado antes de cargar datos
    setState(() {
      _isInitialized = true;
    });

    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Cargar áreas comunes
      final areasResponse = await _reservasService.getAreasComunes();
      if (areasResponse['success'] && mounted) {
        setState(() {
          _areasComunes = areasResponse['data'];
        });
      } else {
        _mostrarError(
          'Error al cargar áreas comunes: ${areasResponse['error']}',
        );
      }

      // Cargar mis reservas solo si es residente
      if (_userRole == 'resident') {
        final reservasResponse = await _reservasService.getMisReservas();
        if (reservasResponse['success'] && mounted) {
          setState(() {
            _misReservas = reservasResponse['data'];
          });
        } else {
          _mostrarError(
            'Error al cargar reservas: ${reservasResponse['error']}',
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _mostrarError('Error al cargar los datos');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  Widget _buildMisReservasTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_misReservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes reservas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ve a "Áreas Comunes" para hacer una reserva',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _misReservas.length,
        itemBuilder: (context, index) {
          final reserva = _misReservas[index];
          final estado = reserva['estado'] ?? 'pendiente';

          Color colorEstado;
          IconData iconoEstado;

          switch (estado) {
            case 'confirmada':
              colorEstado = Colors.green;
              iconoEstado = Icons.check_circle;
              break;
            case 'pendiente':
              colorEstado = Colors.orange;
              iconoEstado = Icons.pending;
              break;
            case 'cancelada':
              colorEstado = Colors.red;
              iconoEstado = Icons.cancel;
              break;
            default:
              colorEstado = Colors.grey;
              iconoEstado = Icons.help;
          }

          return Card(
            color: Color(0xFF232336),
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reserva['area_comun_info'] != null
                              ? reserva['area_comun_info']['nombre'] ?? 'Área'
                              : 'Área',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorEstado, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconoEstado, size: 16, color: colorEstado),
                            SizedBox(width: 4),
                            Text(
                              estado.toUpperCase(),
                              style: TextStyle(
                                color: colorEstado,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _formatDate(reserva['fecha']),
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.access_time, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        '${reserva['hora_inicio']} - ${reserva['hora_fin']}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reserva['area_comun_info'] != null
                              ? reserva['area_comun_info']['nombre'] ?? 'Área'
                              : 'Área',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '\$${_formatCurrency(reserva['costo_total'])}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (estado == 'pendiente') ...[
                            TextButton(
                              onPressed: () => _cancelarReserva(reserva),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          TextButton(
                            onPressed: () => _verDetalleReserva(reserva),
                            child: Text(
                              'Ver detalles',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAreasComunesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _areasComunes.length,
        itemBuilder: (context, index) {
          final area = _areasComunes[index];

          return Card(
            color: Color(0xFF232336),
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          area['nombre'] ?? 'Área',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: area['estado'] == 'activa'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: area['estado'] == 'activa'
                                ? Colors.green
                                : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          area['estado'] == 'activa'
                              ? 'DISPONIBLE'
                              : 'NO DISPONIBLE',
                          style: TextStyle(
                            color: area['estado'] == 'activa'
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    area['tipo_display'] ?? 'Tipo no especificado',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 12),
                  // Información de restricciones y límites
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restricciones y límites:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.schedule,
                          'Duración: ${(num.tryParse(area['tiempo_minimo_reserva']?.toString() ?? '1') ?? 1).toInt()}-${(num.tryParse(area['tiempo_maximo_reserva']?.toString() ?? '8') ?? 8).toInt()} horas',
                        ),
                        _buildInfoRow(
                          Icons.access_time,
                          'Anticipación: ${(num.tryParse(area['anticipacion_minima_horas']?.toString() ?? '24') ?? 24).toInt()} horas mínimas',
                        ),
                        _buildInfoRow(
                          Icons.people,
                          'Capacidad máxima: ${(num.tryParse(area['capacidad_maxima']?.toString() ?? '10') ?? 10).toInt()} personas',
                        ),
                        _buildInfoRow(
                          Icons.attach_money,
                          'Costo por hora: \$${_formatCurrency(area['costo_por_hora'])}',
                          color: Colors.green,
                        ),
                        if ((num.tryParse(
                                  area['costo_reserva']?.toString() ?? '0',
                                ) ??
                                0) >
                            0)
                          _buildInfoRow(
                            Icons.add_circle,
                            'Costo fijo: \$${_formatCurrency(area['costo_reserva'])}',
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _verDisponibilidad(area),
                        child: Text('Ver disponibilidad'),
                      ),
                      if (_userRole == 'resident') ...[
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: area['estado'] == 'activa'
                              ? () => _hacerReserva(area)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: area['estado'] == 'activa'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: Text('Reservar'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0.00';

    // Si ya es un String, devolverlo tal cual
    if (amount is String) {
      return amount;
    }

    // Si es un número, formatearlo
    if (amount is num) {
      return amount.toStringAsFixed(2);
    }

    // Caso por defecto
    return amount.toString();
  }

  void _cancelarReserva(Map<String, dynamic> reserva) async {
    final motivoController = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text('Cancelar Reserva', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que deseas cancelar la reserva de ${reserva['area_comun_info'] != null ? reserva['area_comun_info']['nombre'] : 'esta área'}?',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            TextField(
              controller: motivoController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Motivo de cancelación (opcional)',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, motivoController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (motivo != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _reservasService.cancelarReserva(
          reserva['id'],
          motivo,
        );
        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          setState(() {
            reserva['estado'] = 'cancelada';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reserva cancelada exitosamente'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          _mostrarError('Error al cancelar reserva: ${response['error']}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _mostrarError('Error al cancelar la reserva');
      }
    }
  }

  void _verDetalleReserva(Map<String, dynamic> reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text(
          'Detalle de Reserva',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem(
                'Área:',
                reserva['area_comun_info'] != null
                    ? reserva['area_comun_info']['nombre']
                    : 'N/A',
              ),
              _buildDetalleItem('Fecha:', _formatDate(reserva['fecha'])),
              _buildDetalleItem(
                'Hora:',
                '${reserva['hora_inicio']} - ${reserva['hora_fin']}',
              ),
              _buildDetalleItem(
                'Duración:',
                '${reserva['duracion_horas']} horas',
              ),
              _buildDetalleItem(
                'Personas:',
                reserva['numero_personas']?.toString() ?? 'N/A',
              ),
              _buildDetalleItem(
                'Costo:',
                '\$${_formatCurrency(reserva['costo_total'])}',
              ),
              _buildDetalleItem(
                'Estado:',
                reserva['estado_display'] ?? reserva['estado'] ?? 'N/A',
              ),
              _buildDetalleItem(
                'Fecha de reserva:',
                _formatDate(reserva['created_at']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _verDisponibilidad(Map<String, dynamic> area) async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (fechaSeleccionada == null) return;

    final fechaStr = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _reservasService.getDisponibilidad(
        area['id'],
        fechaStr,
      );
      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        final disponibilidad = response['data'];
        _mostrarDisponibilidadDialog(area, fechaSeleccionada, disponibilidad);
      } else {
        _mostrarError('Error al obtener disponibilidad: ${response['error']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al consultar disponibilidad');
    }
  }

  void _mostrarDisponibilidadDialog(
    Map<String, dynamic> area,
    DateTime fecha,
    Map<String, dynamic> disponibilidad,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text(
          'Disponibilidad - ${area['nombre']}',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(fecha)}',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Horarios disponibles:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              if (disponibilidad['slots_disponibles'] != null &&
                  (disponibilidad['slots_disponibles'] as List).isNotEmpty)
                ...((disponibilidad['slots_disponibles'] as List).map((slot) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 4),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: slot['disponible'] == true
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: slot['disponible'] == true
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${slot['hora_inicio']} - ${slot['hora_fin']}',
                          style: TextStyle(
                            color: slot['disponible'] == true
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        if (slot['disponible'] == true)
                          Text(
                            '\$${_formatCurrency(slot['costo_total'])}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList())
              else
                Text(
                  'No hay horarios disponibles para esta fecha',
                  style: TextStyle(color: Colors.orange),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _hacerReserva(Map<String, dynamic> area) {
    final fechaController = TextEditingController();
    final horaInicioController = TextEditingController();
    final numeroPersonasController = TextEditingController(text: '1');
    final propositoController = TextEditingController();

    DateTime? fechaSeleccionada;
    TimeOfDay? horaInicioSeleccionada;
    int duracionSeleccionada = 1; // en horas
    int numeroPersonasSeleccionado = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color(0xFF232336),
          title: Text(
            'Nueva Reserva - ${area['nombre']}',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha
                TextField(
                  controller: fechaController,
                  style: TextStyle(color: Colors.white),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha *',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.white70),
                      onPressed: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            Duration(
                              days: area['anticipacion_minima_horas'] ~/ 24 + 1,
                            ),
                          ),
                          firstDate: DateTime.now().add(
                            Duration(
                              days: area['anticipacion_minima_horas'] ~/ 24,
                            ),
                          ),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          helpText: 'Selecciona fecha de reserva',
                          cancelText: 'Cancelar',
                          confirmText: 'Seleccionar',
                        );
                        if (fecha != null) {
                          print('Fecha seleccionada: $fecha');
                          setState(() {
                            fechaSeleccionada = fecha;
                          });
                          fechaController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(fecha);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Anticipación mínima: ${(num.tryParse(area['anticipacion_minima_horas']?.toString() ?? '24') ?? 24).toInt()} horas',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 16),

                // Hora de inicio
                Text(
                  'Hora de inicio *',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<TimeOfDay>(
                  value: horaInicioSeleccionada,
                  dropdownColor: Color(0xFF232336),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: Text(
                    'Selecciona hora de inicio',
                    style: TextStyle(color: Colors.white54),
                  ),
                  items: _generarOpcionesHorario(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        horaInicioSeleccionada = value;
                      });
                      horaInicioController.text = value.format(context);
                    }
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'Horarios disponibles cada 30 minutos',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 16),

                // Duración
                Text(
                  'Duración (horas) *',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: duracionSeleccionada,
                        dropdownColor: Color(0xFF232336),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: List.generate(
                          (num.tryParse(
                                        area['tiempo_maximo_reserva']
                                                ?.toString() ??
                                            '8',
                                      ) ??
                                      8)
                                  .toInt() -
                              (num.tryParse(
                                        area['tiempo_minimo_reserva']
                                                ?.toString() ??
                                            '1',
                                      ) ??
                                      1)
                                  .toInt() +
                              1,
                          (index) => DropdownMenuItem(
                            value:
                                (num.tryParse(
                                          area['tiempo_minimo_reserva']
                                                  ?.toString() ??
                                              '1',
                                        ) ??
                                        1)
                                    .toInt() +
                                index,
                            child: Text(
                              '${(num.tryParse(area['tiempo_minimo_reserva']?.toString() ?? '1') ?? 1).toInt() + index} hora(s)',
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              duracionSeleccionada = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tiempo mínimo: ${(num.tryParse(area['tiempo_minimo_reserva']?.toString() ?? '1') ?? 1).toInt()}h, máximo: ${(num.tryParse(area['tiempo_maximo_reserva']?.toString() ?? '8') ?? 8).toInt()}h',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 16),

                // Número de personas
                TextField(
                  controller: numeroPersonasController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de personas *',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    helperText:
                        'Máximo: ${(num.tryParse(area['capacidad_maxima']?.toString() ?? '10') ?? 10).toInt()} personas',
                    helperStyle: TextStyle(color: Colors.white54),
                  ),
                  onChanged: (value) {
                    final num = int.tryParse(value);
                    if (num != null) {
                      setState(() {
                        numeroPersonasSeleccionado = num;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),

                // Propósito
                TextField(
                  controller: propositoController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Propósito de la reserva *',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Reunión familiar, evento deportivo, etc.',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                SizedBox(height: 16),

                // Información del costo
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de la reserva:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (fechaSeleccionada != null) ...[
                        Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(fechaSeleccionada!)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                      if (horaInicioSeleccionada != null) ...[
                        Text(
                          'Horario: ${horaInicioSeleccionada!.format(context)} - ${_calcularHoraFin(horaInicioSeleccionada!, duracionSeleccionada).format(context)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                      Text(
                        'Duración: $duracionSeleccionada hora(s)',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Personas: $numeroPersonasSeleccionado',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Costo total:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_calcularCostoTotal(area, duracionSeleccionada)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${_formatCurrency(area['costo_por_hora'])}/hora + \$${_formatCurrency(area['costo_reserva'])} (reserva)',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validarReservaCompleta(
                  fechaSeleccionada,
                  horaInicioSeleccionada,
                  duracionSeleccionada,
                  numeroPersonasSeleccionado,
                  area,
                  propositoController.text,
                )) {
                  _crearReservaAPI(
                    area,
                    fechaSeleccionada!,
                    horaInicioSeleccionada!,
                    duracionSeleccionada,
                    numeroPersonasSeleccionado,
                    propositoController.text,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Crear Reserva'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white70),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color ?? Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<TimeOfDay>> _generarOpcionesHorario() {
    final opciones = <DropdownMenuItem<TimeOfDay>>[];

    // Generar horarios desde 6:00 AM hasta 10:00 PM cada 30 minutos
    for (int hora = 6; hora <= 22; hora++) {
      for (int minuto = 0; minuto < 60; minuto += 30) {
        final timeOfDay = TimeOfDay(hour: hora, minute: minuto);
        opciones.add(
          DropdownMenuItem(
            value: timeOfDay,
            child: Text(timeOfDay.format(context)),
          ),
        );
      }
    }

    return opciones;
  }

  TimeOfDay _calcularHoraFin(TimeOfDay horaInicio, int duracionHoras) {
    final minutosTotales =
        horaInicio.hour * 60 + horaInicio.minute + (duracionHoras * 60);
    final horaFin = TimeOfDay(
      hour: minutosTotales ~/ 60,
      minute: minutosTotales % 60,
    );
    return horaFin;
  }

  String _calcularCostoTotal(Map<String, dynamic> area, int duracionHoras) {
    final costoHoras =
        (num.tryParse(area['costo_por_hora']?.toString() ?? '0') ?? 0) *
        duracionHoras;
    final costoReserva =
        num.tryParse(area['costo_reserva']?.toString() ?? '0') ?? 0;
    final total = costoHoras + costoReserva;
    return _formatCurrency(total);
  }

  bool _validarReservaCompleta(
    DateTime? fecha,
    TimeOfDay? horaInicio,
    int duracion,
    int numeroPersonas,
    Map<String, dynamic> area,
    String proposito,
  ) {
    // Validar campos obligatorios
    if (fecha == null) {
      _mostrarError('Debes seleccionar una fecha');
      return false;
    }

    if (horaInicio == null) {
      _mostrarError('Debes seleccionar una hora de inicio');
      return false;
    }

    if (proposito.trim().isEmpty) {
      _mostrarError('Debes indicar el propósito de la reserva');
      return false;
    }

    // Validar anticipación mínima
    final ahora = DateTime.now();
    final fechaHoraReserva = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaInicio.hour,
      horaInicio.minute,
    );
    final horasAnticipacion = fechaHoraReserva.difference(ahora).inHours;

    if (horasAnticipacion <
        (num.tryParse(area['anticipacion_minima_horas']?.toString() ?? '24') ??
                24)
            .toInt()) {
      _mostrarError(
        'La reserva debe hacerse con al menos ${(num.tryParse(area['anticipacion_minima_horas']?.toString() ?? '24') ?? 24).toInt()} horas de anticipación',
      );
      return false;
    }

    // Validar duración
    final tiempoMinimo =
        (num.tryParse(area['tiempo_minimo_reserva']?.toString() ?? '1') ?? 1)
            .toInt();
    final tiempoMaximo =
        (num.tryParse(area['tiempo_maximo_reserva']?.toString() ?? '8') ?? 8)
            .toInt();

    if (duracion < tiempoMinimo || duracion > tiempoMaximo) {
      _mostrarError(
        'La duración debe estar entre $tiempoMinimo y $tiempoMaximo horas',
      );
      return false;
    }

    // Validar capacidad
    final capacidadMaxima =
        (num.tryParse(area['capacidad_maxima']?.toString() ?? '10') ?? 10)
            .toInt();
    if (numeroPersonas > capacidadMaxima) {
      _mostrarError(
        'El número de personas ($numeroPersonas) excede la capacidad máxima ($capacidadMaxima)',
      );
      return false;
    }

    if (numeroPersonas <= 0) {
      _mostrarError('El número de personas debe ser mayor a 0');
      return false;
    }

    // Validar que la fecha no sea en el pasado
    if (fecha.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      _mostrarError('No se pueden hacer reservas para fechas pasadas');
      return false;
    }

    return true;
  }

  void _crearReservaAPI(
    Map<String, dynamic> area,
    DateTime fecha,
    TimeOfDay horaInicio,
    int duracionHoras,
    int numeroPersonas,
    String proposito,
  ) async {
    // Convertir fecha a formato ISO
    final fechaISO = DateFormat('yyyy-MM-dd').format(fecha);

    // Convertir hora de inicio a string
    final horaInicioStr =
        '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';

    // Calcular hora fin
    final horaFin = _calcularHoraFin(horaInicio, duracionHoras);
    final horaFinStr =
        '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';

    final datosReserva = {
      'fecha': fechaISO,
      'hora_inicio': horaInicioStr,
      'hora_fin': horaFinStr,
      'numero_personas': numeroPersonas,
      'observaciones': proposito,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _reservasService.crearReserva(
        area['id'],
        datosReserva,
      );
      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        final nuevaReserva = response['data'];
        setState(() {
          _misReservas.add(nuevaReserva);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Cambiar a la pestaña de mis reservas
        if (_tabController.length > 1) {
          _tabController.animateTo(0);
        }

        // Mostrar diálogo de confirmación de pago
        _mostrarDialogoPago(nuevaReserva);
      } else {
        _mostrarError('Error al crear reserva: ${response['error']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al crear la reserva: $e');
    }
  }

  void _mostrarDialogoPago(Map<String, dynamic> reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text('Confirmar Pago', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reserva creada exitosamente. ¿Desea confirmar el pago ahora?',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Total a pagar:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_formatCurrency(reserva['costo_total'])}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Después'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmarPagoReserva(reserva);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Pagar Ahora'),
          ),
        ],
      ),
    );
  }

  void _confirmarPagoReserva(Map<String, dynamic> reserva) async {
    // Simular datos de pago (en una implementación real, esto vendría de un formulario de pago)
    final datosPago = {
      'metodo_pago': 'tarjeta_credito',
      'monto': reserva['costo_total'],
      'referencia': 'Pago reserva ${reserva['id']}',
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _reservasService.confirmarPagoReserva(
        reserva['id'],
        datosPago,
      );
      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        // Actualizar el estado de la reserva
        setState(() {
          reserva['estado'] = 'confirmada';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago confirmado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _mostrarError('Error al confirmar pago: ${response['error']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al procesar el pago');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si aún no se ha completado la inicialización, mostrar loading
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF18181B),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = _userRole == 'security'
        ? [Tab(icon: Icon(Icons.location_on), text: 'Áreas Comunes')]
        : [
            Tab(icon: Icon(Icons.event), text: 'Mis Reservas'),
            Tab(icon: Icon(Icons.location_on), text: 'Áreas Comunes'),
          ];

    final tabViews = _userRole == 'security'
        ? [_buildAreasComunesTab()]
        : [_buildMisReservasTab(), _buildAreasComunesTab()];

    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: Text(
          _userRole == 'security' ? 'Consultar Disponibilidad' : 'Reservas',
        ),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: tabs,
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: _userRole!,
          selected: 'reservas',
          onSelect: (key) {
            Navigator.pop(context);
            if (key != 'reservas') {
              Navigator.pushReplacementNamed(context, '/$key');
            }
          },
        ),
      ),
      body: TabBarView(controller: _tabController, children: tabViews),
    );
  }
}
