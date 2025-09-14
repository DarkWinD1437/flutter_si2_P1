import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';
import '../services/comunicaciones_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ComunicacionesScreen extends StatefulWidget {
  final String userRole;

  const ComunicacionesScreen({super.key, this.userRole = 'resident'});

  @override
  State<ComunicacionesScreen> createState() => _ComunicacionesScreenState();
}

class _ComunicacionesScreenState extends State<ComunicacionesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ComunicacionesService _comunicacionesService = ComunicacionesService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  List<dynamic> _avisos = [];
  String _userRole = 'resident'; // Default role

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserRoleAndData();
  }

  Future<void> _loadUserRoleAndData() async {
    // Read user role from storage
    final storedRole = await _storage.read(key: 'user_type');
    if (storedRole != null && mounted) {
      setState(() {
        _userRole = storedRole;
      });
    }

    // Load communications data
    await _cargarDatosComunicaciones();
  }

  Future<void> _limpiarDatosYRecargar() async {
    // Limpiar todos los datos almacenados
    await _storage.deleteAll();

    // Mostrar mensaje
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Datos limpiados. Reinicia la app para aplicar cambios.',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }

    // Recargar datos
    await _cargarDatosComunicaciones();
  }

  Future<void> _cargarDatosComunicaciones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar dashboard de avisos
      final dashboardResult = await _comunicacionesService.getDashboardAvisos();

      if (dashboardResult['success']) {
        // Dashboard data loaded successfully
      }

      // Cargar lista de avisos
      final avisosResult = await _comunicacionesService.getAvisos();

      if (avisosResult['success']) {
        setState(() {
          _avisos = avisosResult['data']['results'] ?? avisosResult['data'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(avisosResult['error'] ?? 'Error al cargar avisos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvisosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_avisos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.announcement, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay avisos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatosComunicaciones,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _avisos.length,
        itemBuilder: (context, index) {
          final aviso = _avisos[index];
          final prioridad = aviso['prioridad'] ?? 'baja';
          final autor = aviso['autor'] ?? {};
          final usuarioHaLeido = aviso['usuario_ha_leido'] ?? false;

          Color colorPrioridad;
          IconData iconoPrioridad;

          switch (prioridad) {
            case 'urgente':
              colorPrioridad = Colors.red;
              iconoPrioridad = Icons.warning;
              break;
            case 'alta':
              colorPrioridad = Colors.orange;
              iconoPrioridad = Icons.priority_high;
              break;
            case 'media':
              colorPrioridad = Colors.blue;
              iconoPrioridad = Icons.info;
              break;
            default:
              colorPrioridad = Colors.grey;
              iconoPrioridad = Icons.announcement;
          }

          return Card(
            color: Color(0xFF232336),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: colorPrioridad,
                    child: Icon(iconoPrioridad, color: Colors.white),
                  ),
                  if (!usuarioHaLeido)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                aviso['titulo'] ?? 'Aviso',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: usuarioHaLeido
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar remitente
                  Text(
                    'De: ${autor['nombre_completo'] ?? autor['username'] ?? 'Administración'}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    aviso['resumen'] ?? aviso['contenido'] ?? '',
                    style: TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.white54),
                      SizedBox(width: 4),
                      Text(
                        'Publicado: ${_formatDate(aviso['fecha_publicacion'])}',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => _mostrarDetalleAviso(aviso),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificacionesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar avisos no leídos como notificaciones
    final avisosNoLeidos = _avisos
        .where((aviso) => !(aviso['usuario_ha_leido'] ?? true))
        .toList();

    if (avisosNoLeidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes notificaciones nuevas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatosComunicaciones,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: avisosNoLeidos.length,
        itemBuilder: (context, index) {
          final aviso = avisosNoLeidos[index];
          final prioridad = aviso['prioridad'] ?? 'baja';

          Color colorTipo;
          IconData iconoTipo;

          switch (prioridad) {
            case 'urgente':
              colorTipo = Colors.red;
              iconoTipo = Icons.warning;
              break;
            case 'alta':
              colorTipo = Colors.orange;
              iconoTipo = Icons.priority_high;
              break;
            case 'media':
              colorTipo = Colors.blue;
              iconoTipo = Icons.info;
              break;
            default:
              colorTipo = Colors.grey;
              iconoTipo = Icons.notifications;
          }

          return Card(
            color: Color(0xFF232336),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorTipo,
                child: Icon(iconoTipo, color: Colors.white),
              ),
              title: Text(
                aviso['titulo'] ?? 'Notificación',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aviso['resumen'] ?? aviso['contenido'] ?? '',
                    style: TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatDateTime(aviso['fecha_publicacion']),
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              onTap: () => _mostrarDetalleAviso(aviso),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMensajesTab() {
    return Column(
      children: [
        // Botón para nueva comunicación (solo para admins y seguridad)
        if (_userRole == 'admin' || _userRole == 'security') ...[
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _mostrarDialogoNuevaComunicacion,
              icon: Icon(Icons.add),
              label: Text('Nueva Comunicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],

        // Lista de comunicaciones recientes o placeholder
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _avisos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay comunicaciones',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _avisos.length,
                  itemBuilder: (context, index) {
                    final aviso = _avisos[index];
                    final autor = aviso['autor'] ?? {};

                    return Card(
                      color: Color(0xFF232336),
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.message, color: Colors.white),
                        ),
                        title: Text(
                          aviso['titulo'] ?? 'Comunicación',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'De: ${autor['nombre_completo'] ?? autor['username'] ?? 'Desconocido'}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              aviso['resumen'] ?? aviso['contenido'] ?? '',
                              style: TextStyle(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatDateTime(aviso['fecha_publicacion']),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _mostrarDetalleAviso(aviso),
                      ),
                    );
                  },
                ),
        ),
      ],
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

  void _mostrarDetalleAviso(Map<String, dynamic> aviso) {
    // Marcar como leído si no lo está
    if (!(aviso['usuario_ha_leido'] ?? true)) {
      _comunicacionesService.marcarComoLeido(aviso['id']);
      setState(() {
        aviso['usuario_ha_leido'] = true;
      });
    }

    final autor = aviso['autor'] ?? {};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF232336),
          title: Text(
            aviso['titulo'] ?? 'Aviso',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información del remitente
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'De: ${autor['nombre_completo'] ?? autor['username'] ?? 'Administración'}',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Contenido del aviso
                Text(
                  aviso['contenido'] ?? '',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Divider(color: Colors.white30),
                // Información adicional
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.white54),
                    SizedBox(width: 8),
                    Text(
                      'Publicado: ${_formatDate(aviso['fecha_publicacion'])}',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                if (aviso['fecha_vencimiento'] != null) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.white54),
                      SizedBox(width: 8),
                      Text(
                        'Expira: ${_formatDate(aviso['fecha_vencimiento'])}',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.white54),
                    SizedBox(width: 8),
                    Text(
                      'Visualizaciones: ${aviso['visualizaciones'] ?? 0}',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoNuevaComunicacion() {
    final tituloController = TextEditingController();
    final contenidoController = TextEditingController();
    String prioridad = 'media';
    String tipoDestinatario = 'todos';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Color(0xFF232336),
              title: Text(
                'Nueva Comunicación',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: contenidoController,
                      style: TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Contenido',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: prioridad,
                      decoration: InputDecoration(
                        labelText: 'Prioridad',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: Color(0xFF232336),
                      style: TextStyle(color: Colors.white),
                      items: [
                        DropdownMenuItem(value: 'baja', child: Text('Baja')),
                        DropdownMenuItem(value: 'media', child: Text('Media')),
                        DropdownMenuItem(value: 'alta', child: Text('Alta')),
                        DropdownMenuItem(
                          value: 'urgente',
                          child: Text('Urgente'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          prioridad = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tipoDestinatario,
                      decoration: InputDecoration(
                        labelText: 'Destinatarios',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: Color(0xFF232336),
                      style: TextStyle(color: Colors.white),
                      items: [
                        DropdownMenuItem(
                          value: 'todos',
                          child: Text('Todos los usuarios'),
                        ),
                        DropdownMenuItem(
                          value: 'residentes',
                          child: Text('Solo residentes'),
                        ),
                        DropdownMenuItem(
                          value: 'seguridad',
                          child: Text('Solo personal de seguridad'),
                        ),
                        DropdownMenuItem(
                          value: 'admin_seguridad',
                          child: Text('Administración y seguridad'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tipoDestinatario = value!;
                        });
                      },
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
                        contenidoController.text.isNotEmpty) {
                      _crearNuevaComunicacion(
                        tituloController.text,
                        contenidoController.text,
                        prioridad,
                        tipoDestinatario,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _crearNuevaComunicacion(
    String titulo,
    String contenido,
    String prioridad,
    String tipoDestinatario,
  ) async {
    final avisoData = {
      'titulo': titulo,
      'contenido': contenido,
      'prioridad': prioridad,
      'tipo_destinatario': tipoDestinatario,
    };

    final result = await _comunicacionesService.crearAviso(avisoData);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comunicación creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarDatosComunicaciones(); // Recargar la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al crear comunicación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Avisos y comunicados'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Limpiar datos',
            onPressed: _limpiarDatosYRecargar,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosComunicaciones,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.announcement), text: 'Avisos'),
            Tab(icon: Icon(Icons.notifications), text: 'Notificaciones'),
            Tab(icon: Icon(Icons.message), text: 'Comunicaciones'),
          ],
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: _userRole,
          selected: 'comunicados',
          onSelect: (key) {
            Navigator.pop(context);
            if (key != 'comunicados') {
              Navigator.pushReplacementNamed(context, '/$key');
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvisosTab(),
          _buildNotificacionesTab(),
          _buildMensajesTab(),
        ],
      ),
    );
  }
}
