import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  List<dynamic> _misReservas = [];
  List<dynamic> _areasComunes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular datos hasta que el backend esté listo
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _misReservas = [
          {
            'id': 1,
            'area': 'Salón de Eventos',
            'fecha': DateTime.now().add(Duration(days: 5)).toIso8601String(),
            'hora_inicio': '18:00',
            'hora_fin': '22:00',
            'estado': 'confirmada',
            'proposito': 'Celebración familiar',
            'fecha_creacion': DateTime.now()
                .subtract(Duration(days: 2))
                .toIso8601String(),
            'costo': 150.00,
          },
          {
            'id': 2,
            'area': 'Piscina',
            'fecha': DateTime.now().add(Duration(days: 12)).toIso8601String(),
            'hora_inicio': '14:00',
            'hora_fin': '18:00',
            'estado': 'pendiente',
            'proposito': 'Reunión de amigos',
            'fecha_creacion': DateTime.now()
                .subtract(Duration(hours: 6))
                .toIso8601String(),
            'costo': 50.00,
          },
        ];

        _areasComunes = [
          {
            'id': 1,
            'nombre': 'Salón de Eventos',
            'descripcion': 'Salón para celebraciones y reuniones familiares',
            'capacidad': 80,
            'costo_hora': 25.00,
            'horarios': '8:00 AM - 11:00 PM',
            'disponible': true,
            'imagen': 'salon_eventos.jpg',
            'servicios': [
              'Sonido',
              'Iluminación',
              'Aire acondicionado',
              'Cocina',
            ],
          },
          {
            'id': 2,
            'nombre': 'Piscina',
            'descripcion': 'Área de piscina con zona de descanso',
            'capacidad': 20,
            'costo_hora': 12.50,
            'horarios': '6:00 AM - 9:00 PM',
            'disponible': true,
            'imagen': 'piscina.jpg',
            'servicios': ['Duchas', 'Zona de descanso', 'Salvavidas'],
          },
          {
            'id': 3,
            'nombre': 'Cancha de Tenis',
            'descripcion': 'Cancha profesional de tenis',
            'capacidad': 4,
            'costo_hora': 15.00,
            'horarios': '6:00 AM - 10:00 PM',
            'disponible': false,
            'imagen': 'cancha_tenis.jpg',
            'servicios': ['Iluminación nocturna', 'Raquetas disponibles'],
          },
          {
            'id': 4,
            'nombre': 'Gimnasio',
            'descripcion': 'Gimnasio completamente equipado',
            'capacidad': 15,
            'costo_hora': 8.00,
            'horarios': '5:00 AM - 11:00 PM',
            'disponible': true,
            'imagen': 'gimnasio.jpg',
            'servicios': [
              'Equipos cardiovasculares',
              'Pesas',
              'Aire acondicionado',
            ],
          },
          {
            'id': 5,
            'nombre': 'Salón de Juegos',
            'descripcion': 'Área recreativa para niños y adultos',
            'capacidad': 25,
            'costo_hora': 10.00,
            'horarios': '8:00 AM - 10:00 PM',
            'disponible': true,
            'imagen': 'salon_juegos.jpg',
            'servicios': ['Mesa de billar', 'Ping pong', 'Juegos de mesa'],
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando reservas: $e');
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al cargar las reservas');
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
                          reserva['area'] ?? 'Área',
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
                      Icon(Icons.description, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reserva['proposito'] ?? 'Sin descripción',
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
                            '\$${reserva['costo']?.toStringAsFixed(2) ?? '0.00'}',
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
          final disponible = area['disponible'] ?? false;

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
                          color: disponible
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: disponible ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          disponible ? 'DISPONIBLE' : 'NO DISPONIBLE',
                          style: TextStyle(
                            color: disponible ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    area['descripcion'] ?? '',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'Capacidad: ${area['capacidad']} personas',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'Horario: ${area['horarios']}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '\$${area['costo_hora']?.toStringAsFixed(2)}/hora',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (area['servicios'] != null &&
                      (area['servicios'] as List).isNotEmpty) ...[
                    SizedBox(height: 12),
                    Text(
                      'Servicios incluidos:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (area['servicios'] as List).map<Widget>((
                        servicio,
                      ) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Text(
                            servicio,
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _verDisponibilidad(area),
                        child: Text('Ver disponibilidad'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: disponible
                            ? () => _hacerReserva(area)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: disponible
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: Text('Reservar'),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _cancelarReserva(Map<String, dynamic> reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text('Cancelar Reserva', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que deseas cancelar la reserva de ${reserva['area']}?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                reserva['estado'] = 'cancelada';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reserva cancelada exitosamente'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sí, cancelar'),
          ),
        ],
      ),
    );
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
              _buildDetalleItem('Área:', reserva['area'] ?? 'N/A'),
              _buildDetalleItem('Fecha:', _formatDate(reserva['fecha'])),
              _buildDetalleItem(
                'Hora:',
                '${reserva['hora_inicio']} - ${reserva['hora_fin']}',
              ),
              _buildDetalleItem('Propósito:', reserva['proposito'] ?? 'N/A'),
              _buildDetalleItem(
                'Costo:',
                '\$${reserva['costo']?.toStringAsFixed(2) ?? '0.00'}',
              ),
              _buildDetalleItem('Estado:', reserva['estado'] ?? 'N/A'),
              _buildDetalleItem(
                'Fecha de reserva:',
                _formatDate(reserva['fecha_creacion']),
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

  void _verDisponibilidad(Map<String, dynamic> area) {
    // Implementar calendario de disponibilidad
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text(
          'Disponibilidad - ${area['nombre']}',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Próximamente: Calendario interactivo de disponibilidad',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Horario de funcionamiento:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                area['horarios'] ?? 'N/A',
                style: TextStyle(color: Colors.white70),
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
    final horaFinController = TextEditingController();
    final propositoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text(
          'Nueva Reserva - ${area['nombre']}',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fechaController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Fecha (DD/MM/YYYY)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white70),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (fecha != null) {
                        fechaController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(fecha);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: horaInicioController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Hora inicio (HH:MM)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: horaFinController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Hora fin (HH:MM)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: propositoController,
                style: TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Propósito de la reserva',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Costo estimado:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${area['costo_hora']?.toStringAsFixed(2)}/hora',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
              if (_validarReserva(
                fechaController.text,
                horaInicioController.text,
                horaFinController.text,
                propositoController.text,
              )) {
                _confirmarReserva(
                  area,
                  fechaController.text,
                  horaInicioController.text,
                  horaFinController.text,
                  propositoController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Confirmar Reserva'),
          ),
        ],
      ),
    );
  }

  bool _validarReserva(
    String fecha,
    String horaInicio,
    String horaFin,
    String proposito,
  ) {
    if (fecha.isEmpty ||
        horaInicio.isEmpty ||
        horaFin.isEmpty ||
        proposito.isEmpty) {
      _mostrarError('Todos los campos son obligatorios');
      return false;
    }
    return true;
  }

  void _confirmarReserva(
    Map<String, dynamic> area,
    String fecha,
    String horaInicio,
    String horaFin,
    String proposito,
  ) {
    // Simular creación de reserva
    final nuevaReserva = {
      'id': _misReservas.length + 1,
      'area': area['nombre'],
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': 'pendiente',
      'proposito': proposito,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'costo': area['costo_hora'] ?? 0.0,
    };

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
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Reservas'),
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
          tabs: [
            Tab(icon: Icon(Icons.event), text: 'Mis Reservas'),
            Tab(icon: Icon(Icons.location_on), text: 'Áreas Comunes'),
          ],
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: 'resident',
          selected: 'reservas',
          onSelect: (key) {
            Navigator.pop(context);
            if (key != 'reservas') {
              Navigator.pushReplacementNamed(context, '/$key');
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMisReservasTab(), _buildAreasComunesTab()],
      ),
    );
  }
}
