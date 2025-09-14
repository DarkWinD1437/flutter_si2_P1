import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';

class SeguridadResidenteScreen extends StatefulWidget {
  const SeguridadResidenteScreen({super.key});

  @override
  State<SeguridadResidenteScreen> createState() =>
      _SeguridadResidenteScreenState();
}

class _SeguridadResidenteScreenState extends State<SeguridadResidenteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  List<dynamic> _visitantes = [];
  List<dynamic> _incidentes = [];
  List<dynamic> _accesos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        _visitantes = [
          {
            'id': 1,
            'nombre': 'Juan Pérez',
            'documento': '12345678',
            'fecha_visita': DateTime.now()
                .add(Duration(days: 1))
                .toIso8601String(),
            'hora_entrada': '15:00',
            'hora_salida': '18:00',
            'motivo': 'Visita familiar',
            'estado': 'autorizado',
            'fecha_registro': DateTime.now()
                .subtract(Duration(hours: 2))
                .toIso8601String(),
          },
          {
            'id': 2,
            'nombre': 'María González',
            'documento': '87654321',
            'fecha_visita': DateTime.now().toIso8601String(),
            'hora_entrada': '14:30',
            'hora_salida': '16:00',
            'motivo': 'Servicio de limpieza',
            'estado': 'completada',
            'fecha_registro': DateTime.now()
                .subtract(Duration(days: 1))
                .toIso8601String(),
          },
        ];

        _incidentes = [
          {
            'id': 1,
            'titulo': 'Ruido excesivo',
            'descripcion':
                'Se reporta ruido excesivo en el apartamento 501 durante horas de descanso',
            'tipo': 'ruido',
            'estado': 'en_proceso',
            'fecha': DateTime.now()
                .subtract(Duration(hours: 3))
                .toIso8601String(),
            'reportado_por': 'Sistema IA',
            'ubicacion': 'Torre A - Piso 5',
          },
          {
            'id': 2,
            'titulo': 'Puerta principal dañada',
            'descripcion':
                'La puerta principal del lobby presenta problemas con el mecanismo de cierre',
            'tipo': 'mantenimiento',
            'estado': 'resuelto',
            'fecha': DateTime.now()
                .subtract(Duration(days: 2))
                .toIso8601String(),
            'reportado_por': 'Conserje',
            'ubicacion': 'Lobby principal',
          },
        ];

        _accesos = [
          {
            'id': 1,
            'fecha': DateTime.now()
                .subtract(Duration(hours: 2))
                .toIso8601String(),
            'tipo': 'entrada',
            'ubicacion': 'Puerta principal',
            'metodo': 'Tarjeta de acceso',
          },
          {
            'id': 2,
            'fecha': DateTime.now()
                .subtract(Duration(hours: 8))
                .toIso8601String(),
            'tipo': 'salida',
            'ubicacion': 'Garage',
            'metodo': 'Control remoto',
          },
          {
            'id': 3,
            'fecha': DateTime.now()
                .subtract(Duration(days: 1, hours: 6))
                .toIso8601String(),
            'tipo': 'entrada',
            'ubicacion': 'Puerta principal',
            'metodo': 'Código de acceso',
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos de seguridad: $e');
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al cargar los datos de seguridad');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  Widget _buildVisitantesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Botón para registrar nuevo visitante
        Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _registrarVisitante,
            icon: Icon(Icons.person_add),
            label: Text('Registrar Visitante'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),

        // Lista de visitantes
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _visitantes.length,
              itemBuilder: (context, index) {
                final visitante = _visitantes[index];
                final estado = visitante['estado'] ?? 'pendiente';

                Color colorEstado;
                IconData iconoEstado;

                switch (estado) {
                  case 'autorizado':
                    colorEstado = Colors.green;
                    iconoEstado = Icons.check_circle;
                    break;
                  case 'completada':
                    colorEstado = Colors.blue;
                    iconoEstado = Icons.done_all;
                    break;
                  case 'cancelada':
                    colorEstado = Colors.red;
                    iconoEstado = Icons.cancel;
                    break;
                  default:
                    colorEstado = Colors.orange;
                    iconoEstado = Icons.pending;
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
                                visitante['nombre'] ?? 'Visitante',
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
                                border: Border.all(
                                  color: colorEstado,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    iconoEstado,
                                    size: 16,
                                    color: colorEstado,
                                  ),
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
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.badge, size: 16, color: Colors.white70),
                            SizedBox(width: 8),
                            Text(
                              'Doc: ${visitante['documento']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 8),
                            Text(
                              _formatDate(visitante['fecha_visita']),
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(width: 24),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${visitante['hora_entrada']} - ${visitante['hora_salida']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.description,
                              size: 16,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                visitante['motivo'] ??
                                    'Sin motivo especificado',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        if (estado == 'autorizado') ...[
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _cancelarVisitante(visitante),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _editarVisitante(visitante),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text('Editar'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Botón para reportar incidente
        Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _reportarIncidente,
            icon: Icon(Icons.report),
            label: Text('Reportar Incidente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),

        // Lista de incidentes
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _incidentes.length,
              itemBuilder: (context, index) {
                final incidente = _incidentes[index];
                final estado = incidente['estado'] ?? 'pendiente';
                final tipo = incidente['tipo'] ?? 'general';

                Color colorEstado;
                IconData iconoEstado;

                switch (estado) {
                  case 'resuelto':
                    colorEstado = Colors.green;
                    iconoEstado = Icons.check_circle;
                    break;
                  case 'en_proceso':
                    colorEstado = Colors.orange;
                    iconoEstado = Icons.pending;
                    break;
                  default:
                    colorEstado = Colors.red;
                    iconoEstado = Icons.error;
                }

                IconData iconoTipo;
                switch (tipo) {
                  case 'ruido':
                    iconoTipo = Icons.volume_up;
                    break;
                  case 'mantenimiento':
                    iconoTipo = Icons.build;
                    break;
                  case 'seguridad':
                    iconoTipo = Icons.security;
                    break;
                  default:
                    iconoTipo = Icons.report;
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
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 20,
                              child: Icon(iconoTipo, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    incidente['titulo'] ?? 'Incidente',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(incidente['fecha']),
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                                border: Border.all(
                                  color: colorEstado,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    iconoEstado,
                                    size: 16,
                                    color: colorEstado,
                                  ),
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
                        Text(
                          incidente['descripcion'] ?? '',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white54,
                            ),
                            SizedBox(width: 4),
                            Text(
                              incidente['ubicacion'] ?? 'Sin ubicación',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.person, size: 16, color: Colors.white54),
                            SizedBox(width: 4),
                            Text(
                              'Por: ${incidente['reportado_por'] ?? 'Desconocido'}',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccesosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _accesos.length,
        itemBuilder: (context, index) {
          final acceso = _accesos[index];
          final tipo = acceso['tipo'] ?? 'entrada';

          Color colorTipo = tipo == 'entrada' ? Colors.green : Colors.orange;
          IconData iconoTipo = tipo == 'entrada' ? Icons.login : Icons.logout;

          return Card(
            color: Color(0xFF232336),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorTipo,
                child: Icon(iconoTipo, color: Colors.white),
              ),
              title: Text(
                tipo.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación: ${acceso['ubicacion'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Método: ${acceso['metodo'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    _formatDateTime(acceso['fecha']),
                    style: TextStyle(color: Colors.white54, fontSize: 12),
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _registrarVisitante() {
    final nombreController = TextEditingController();
    final documentoController = TextEditingController();
    final fechaController = TextEditingController();
    final horaEntradaController = TextEditingController();
    final horaSalidaController = TextEditingController();
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text(
          'Registrar Visitante',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: documentoController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Documento de identidad',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: fechaController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Fecha de visita',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white70),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)),
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
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: horaEntradaController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Hora entrada',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: horaSalidaController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Hora salida',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: motivoController,
                style: TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Motivo de la visita',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
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
              if (_validarVisitante(
                nombreController.text,
                documentoController.text,
                fechaController.text,
                horaEntradaController.text,
                horaSalidaController.text,
              )) {
                _confirmarVisitante(
                  nombreController.text,
                  documentoController.text,
                  fechaController.text,
                  horaEntradaController.text,
                  horaSalidaController.text,
                  motivoController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Registrar'),
          ),
        ],
      ),
    );
  }

  bool _validarVisitante(
    String nombre,
    String documento,
    String fecha,
    String horaEntrada,
    String horaSalida,
  ) {
    if (nombre.isEmpty ||
        documento.isEmpty ||
        fecha.isEmpty ||
        horaEntrada.isEmpty ||
        horaSalida.isEmpty) {
      _mostrarError('Todos los campos son obligatorios');
      return false;
    }
    return true;
  }

  void _confirmarVisitante(
    String nombre,
    String documento,
    String fecha,
    String horaEntrada,
    String horaSalida,
    String motivo,
  ) {
    final nuevoVisitante = {
      'id': _visitantes.length + 1,
      'nombre': nombre,
      'documento': documento,
      'fecha_visita': fecha,
      'hora_entrada': horaEntrada,
      'hora_salida': horaSalida,
      'motivo': motivo,
      'estado': 'autorizado',
      'fecha_registro': DateTime.now().toIso8601String(),
    };

    setState(() {
      _visitantes.add(nuevoVisitante);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visitante registrado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editarVisitante(Map<String, dynamic> visitante) {
    // Implementar edición de visitante
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: Editar visitante'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _cancelarVisitante(Map<String, dynamic> visitante) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text(
          'Cancelar Visitante',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que deseas cancelar la visita de ${visitante['nombre']}?',
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
                visitante['estado'] = 'cancelada';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Visitante cancelado exitosamente'),
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

  void _reportarIncidente() {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();
    final ubicacionController = TextEditingController();
    String tipoIncidente = 'general';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color(0xFF232336),
          title: Text(
            'Reportar Incidente',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipoIncidente,
                  decoration: InputDecoration(
                    labelText: 'Tipo de incidente',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: Color(0xFF232336),
                  style: TextStyle(color: Colors.white),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'ruido', child: Text('Ruido')),
                    DropdownMenuItem(
                      value: 'mantenimiento',
                      child: Text('Mantenimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'seguridad',
                      child: Text('Seguridad'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      tipoIncidente = value!;
                    });
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: tituloController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Título del incidente',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: ubicacionController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Descripción detallada',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
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
                if (tituloController.text.isNotEmpty &&
                    descripcionController.text.isNotEmpty) {
                  _confirmarIncidente(
                    tipoIncidente,
                    tituloController.text,
                    descripcionController.text,
                    ubicacionController.text,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Reportar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarIncidente(
    String tipo,
    String titulo,
    String descripcion,
    String ubicacion,
  ) {
    final nuevoIncidente = {
      'id': _incidentes.length + 1,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'estado': 'pendiente',
      'fecha': DateTime.now().toIso8601String(),
      'reportado_por': 'Residente',
      'ubicacion': ubicacion,
    };

    setState(() {
      _incidentes.add(nuevoIncidente);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Incidente reportado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    // Cambiar a la pestaña de incidentes
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Seguridad'),
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
            Tab(icon: Icon(Icons.people), text: 'Visitantes'),
            Tab(icon: Icon(Icons.report), text: 'Incidentes'),
            Tab(icon: Icon(Icons.security), text: 'Accesos'),
          ],
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: 'resident',
          selected: 'seguridad',
          onSelect: (key) {
            Navigator.pop(context);
            if (key != 'seguridad') {
              Navigator.pushReplacementNamed(context, '/$key');
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVisitantesTab(),
          _buildIncidentesTab(),
          _buildAccesosTab(),
        ],
      ),
    );
  }
}
