import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';

class SeguridadGuardScreen extends StatefulWidget {
  const SeguridadGuardScreen({super.key});

  @override
  State<SeguridadGuardScreen> createState() => _SeguridadGuardScreenState();
}

class _SeguridadGuardScreenState extends State<SeguridadGuardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  List<dynamic> _visitantesHoy = [];
  List<dynamic> _incidentesActivos = [];
  List<dynamic> _alertas = [];
  List<dynamic> _rondas = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        _visitantesHoy = [
          {
            'id': 1,
            'nombre': 'Juan Pérez',
            'documento': '12345678',
            'unidad': 'Apt 301',
            'hora_llegada': '14:30',
            'estado': 'esperando',
            'motivo': 'Visita familiar',
            'telefono': '+57 300 123 4567',
            'residente_autoriza': 'María García',
          },
          {
            'id': 2,
            'nombre': 'Ana Rodríguez',
            'documento': '87654321',
            'unidad': 'Apt 502',
            'hora_llegada': '15:45',
            'estado': 'autorizado',
            'motivo': 'Servicio técnico',
            'telefono': '+57 301 987 6543',
            'residente_autoriza': 'Carlos López',
            'hora_entrada': '15:50',
          },
        ];

        _incidentesActivos = [
          {
            'id': 1,
            'titulo': 'Sistema IA: Movimiento sospechoso',
            'descripcion':
                'Se detectó movimiento inusual en el parqueadero sector B',
            'tipo': 'ia_alert',
            'prioridad': 'alta',
            'fecha': DateTime.now()
                .subtract(Duration(minutes: 15))
                .toIso8601String(),
            'ubicacion': 'Parqueadero B',
            'estado': 'activo',
            'asignado_a': 'Guardia 1',
          },
          {
            'id': 2,
            'titulo': 'Ruido excesivo reportado',
            'descripcion': 'Vecinos reportan música alta en unidad 403',
            'tipo': 'ruido',
            'prioridad': 'media',
            'fecha': DateTime.now()
                .subtract(Duration(hours: 1))
                .toIso8601String(),
            'ubicacion': 'Torre A - Piso 4',
            'estado': 'en_proceso',
            'asignado_a': 'Guardia 2',
          },
        ];

        _alertas = [
          {
            'id': 1,
            'tipo': 'ia_security',
            'mensaje': 'Persona no autorizada detectada en zona de piscina',
            'timestamp': DateTime.now()
                .subtract(Duration(minutes: 5))
                .toIso8601String(),
            'nivel': 'critico',
            'ubicacion': 'Área de piscina',
            'camara': 'CAM-005',
            'accion_requerida': 'Verificar inmediatamente',
          },
          {
            'id': 2,
            'tipo': 'system',
            'mensaje': 'Cámara CAM-012 fuera de línea',
            'timestamp': DateTime.now()
                .subtract(Duration(minutes: 20))
                .toIso8601String(),
            'nivel': 'advertencia',
            'ubicacion': 'Entrada secundaria',
            'camara': 'CAM-012',
            'accion_requerida': 'Revisar conexión',
          },
        ];

        _rondas = [
          {
            'id': 1,
            'nombre': 'Ronda nocturna completa',
            'estado': 'completada',
            'hora_inicio': '22:00',
            'hora_fin': '22:45',
            'puntos_control': [
              {'ubicacion': 'Lobby principal', 'hora': '22:05', 'estado': 'ok'},
              {'ubicacion': 'Parqueadero A', 'hora': '22:15', 'estado': 'ok'},
              {'ubicacion': 'Piscina', 'hora': '22:25', 'estado': 'ok'},
              {'ubicacion': 'Terraza', 'hora': '22:35', 'estado': 'ok'},
              {'ubicacion': 'Entrada trasera', 'hora': '22:42', 'estado': 'ok'},
            ],
            'observaciones': 'Todo en orden, sin novedades',
            'guardia': 'Carlos Martínez',
            'fecha': DateTime.now()
                .subtract(Duration(hours: 2))
                .toIso8601String(),
          },
          {
            'id': 2,
            'nombre': 'Inspección matutina',
            'estado': 'en_curso',
            'hora_inicio': '06:00',
            'puntos_control': [
              {'ubicacion': 'Lobby principal', 'hora': '06:05', 'estado': 'ok'},
              {
                'ubicacion': 'Parqueadero A',
                'hora': '06:15',
                'estado': 'pendiente',
              },
              {'ubicacion': 'Piscina', 'hora': null, 'estado': 'pendiente'},
            ],
            'guardia': 'Ana Jiménez',
            'fecha': DateTime.now().toIso8601String(),
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos de seguridad: $e');
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al cargar los datos');
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
        // Estadísticas rápidas
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Hoy',
                  '${_visitantesHoy.length}',
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Esperando',
                  '${_visitantesHoy.where((v) => v['estado'] == 'esperando').length}',
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Adentro',
                  '${_visitantesHoy.where((v) => v['estado'] == 'autorizado').length}',
                  Colors.green,
                ),
              ),
            ],
          ),
        ),

        // Lista de visitantes
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _visitantesHoy.length,
              itemBuilder: (context, index) {
                final visitante = _visitantesHoy[index];
                final estado = visitante['estado'] ?? 'esperando';

                Color colorEstado;
                IconData iconoEstado;

                switch (estado) {
                  case 'autorizado':
                    colorEstado = Colors.green;
                    iconoEstado = Icons.check_circle;
                    break;
                  case 'rechazado':
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visitante['nombre'] ?? 'Visitante',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Doc: ${visitante['documento']} | ${visitante['unidad']}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
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
                        SizedBox(height: 8),
                        Text(
                          'Motivo: ${visitante['motivo'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Autoriza: ${visitante['residente_autoriza'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.white54,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Llegada: ${visitante['hora_llegada']}',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            if (visitante['hora_entrada'] != null) ...[
                              SizedBox(width: 16),
                              Text(
                                'Entrada: ${visitante['hora_entrada']}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (estado == 'esperando') ...[
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _rechazarVisitante(visitante),
                                child: Text(
                                  'Rechazar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _llamarResidente(visitante),
                                icon: Icon(Icons.phone, size: 16),
                                label: Text('Llamar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _autorizarVisitante(visitante),
                                child: Text('Autorizar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
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

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _incidentesActivos.length,
        itemBuilder: (context, index) {
          final incidente = _incidentesActivos[index];
          final prioridad = incidente['prioridad'] ?? 'baja';

          Color colorPrioridad;
          switch (prioridad) {
            case 'alta':
              colorPrioridad = Colors.red;
              break;
            case 'media':
              colorPrioridad = Colors.orange;
              break;
            default:
              colorPrioridad = Colors.blue;
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
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorPrioridad,
                          borderRadius: BorderRadius.circular(2),
                        ),
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
                          color: colorPrioridad.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorPrioridad, width: 1),
                        ),
                        child: Text(
                          prioridad.toUpperCase(),
                          style: TextStyle(
                            color: colorPrioridad,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    incidente['descripcion'] ?? '',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.white54),
                      SizedBox(width: 4),
                      Text(
                        incidente['ubicacion'] ?? 'Sin ubicación',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.person, size: 16, color: Colors.white54),
                      SizedBox(width: 4),
                      Text(
                        'Asignado: ${incidente['asignado_a'] ?? 'Sin asignar'}',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (incidente['tipo'] == 'ia_alert')
                        TextButton.icon(
                          onPressed: () => _verCamara(incidente),
                          icon: Icon(Icons.videocam, size: 16),
                          label: Text('Ver cámara'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      TextButton(
                        onPressed: () => _resolverIncidente(incidente),
                        child: Text('Resolver'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
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
    );
  }

  Widget _buildAlertasTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _alertas.length,
        itemBuilder: (context, index) {
          final alerta = _alertas[index];
          final nivel = alerta['nivel'] ?? 'info';

          Color colorNivel;
          IconData iconoNivel;

          switch (nivel) {
            case 'critico':
              colorNivel = Colors.red;
              iconoNivel = Icons.error;
              break;
            case 'advertencia':
              colorNivel = Colors.orange;
              iconoNivel = Icons.warning;
              break;
            default:
              colorNivel = Colors.blue;
              iconoNivel = Icons.info;
          }

          return Card(
            color: Color(0xFF232336),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorNivel,
                child: Icon(iconoNivel, color: Colors.white),
              ),
              title: Text(
                alerta['mensaje'] ?? 'Alerta',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación: ${alerta['ubicacion'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (alerta['camara'] != null)
                    Text(
                      'Cámara: ${alerta['camara']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  Text(
                    _formatDateTime(alerta['timestamp']),
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              trailing: TextButton(
                onPressed: () => _atenderAlerta(alerta),
                child: Text('Atender'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRondasTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Botón para nueva ronda
        Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _iniciarRonda,
            icon: Icon(Icons.directions_walk),
            label: Text('Iniciar Nueva Ronda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ),

        // Lista de rondas
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _rondas.length,
              itemBuilder: (context, index) {
                final ronda = _rondas[index];
                final estado = ronda['estado'] ?? 'pendiente';

                Color colorEstado;
                IconData iconoEstado;

                switch (estado) {
                  case 'completada':
                    colorEstado = Colors.green;
                    iconoEstado = Icons.check_circle;
                    break;
                  case 'en_curso':
                    colorEstado = Colors.blue;
                    iconoEstado = Icons.pending;
                    break;
                  default:
                    colorEstado = Colors.grey;
                    iconoEstado = Icons.schedule;
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
                                ronda['nombre'] ?? 'Ronda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
                        Text(
                          'Guardia: ${ronda['guardia'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Inicio: ${ronda['hora_inicio']}${ronda['hora_fin'] != null ? ' | Fin: ${ronda['hora_fin']}' : ''}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 8),
                        if (ronda['puntos_control'] != null) ...[
                          Text(
                            'Puntos de control:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          ...((ronda['puntos_control'] as List).map((punto) {
                            Color colorPunto = punto['estado'] == 'ok'
                                ? Colors.green
                                : punto['estado'] == 'pendiente'
                                ? Colors.orange
                                : Colors.grey;
                            return Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: colorPunto,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      punto['ubicacion'] ?? 'Punto',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (punto['hora'] != null)
                                    Text(
                                      punto['hora'],
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList()),
                        ],
                        if (estado == 'en_curso') ...[
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _continuarRonda(ronda),
                            child: Text('Continuar Ronda'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
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

  Widget _buildStatCard(String titulo, String valor, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF232336),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(titulo, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _autorizarVisitante(Map<String, dynamic> visitante) {
    setState(() {
      visitante['estado'] = 'autorizado';
      visitante['hora_entrada'] = DateFormat('HH:mm').format(DateTime.now());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visitante autorizado y registrado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rechazarVisitante(Map<String, dynamic> visitante) {
    setState(() {
      visitante['estado'] = 'rechazado';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visitante rechazado'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _llamarResidente(Map<String, dynamic> visitante) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamando a ${visitante['residente_autoriza']}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _resolverIncidente(Map<String, dynamic> incidente) {
    setState(() {
      incidente['estado'] = 'resuelto';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Incidente marcado como resuelto'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _verCamara(Map<String, dynamic> incidente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        title: Text('Vista de Cámara', style: TextStyle(color: Colors.white)),
        content: Container(
          width: 300,
          height: 200,
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, size: 48, color: Colors.white54),
                SizedBox(height: 8),
                Text(
                  'Transmisión en vivo',
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  '${incidente['ubicacion']}',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
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

  void _atenderAlerta(Map<String, dynamic> alerta) {
    setState(() {
      _alertas.remove(alerta);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alerta atendida'), backgroundColor: Colors.green),
    );
  }

  void _iniciarRonda() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: Iniciar nueva ronda'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _continuarRonda(Map<String, dynamic> ronda) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Continuando ronda: ${ronda['nombre']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Puesto de Guardia'),
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
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.people), text: 'Visitantes'),
            Tab(icon: Icon(Icons.report), text: 'Incidentes'),
            Tab(icon: Icon(Icons.notification_important), text: 'Alertas'),
            Tab(icon: Icon(Icons.directions_walk), text: 'Rondas'),
          ],
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: 'security',
          selected: 'dashboard',
          onSelect: (key) {
            Navigator.pop(context);
            if (key == 'profile') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else if (key == 'estado_cuenta') {
              Navigator.pushNamed(context, '/estado_cuenta');
            } else if (key == 'reservas') {
              Navigator.pushNamed(context, '/reservas');
            } else if (key == 'logout') {
              _handleLogout(context);
            } else if (key != 'dashboard') {
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
          _buildAlertasTab(),
          _buildRondasTab(),
        ],
      ),
    );
  }
}
