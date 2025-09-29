import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/sidebar.dart';
import 'pantalla_pago_cargos.dart';
import 'pantalla_historial_pagos.dart';

class EstadoCuentaScreen extends StatefulWidget {
  const EstadoCuentaScreen({super.key});

  @override
  State<EstadoCuentaScreen> createState() => _EstadoCuentaScreenState();
}

class _EstadoCuentaScreenState extends State<EstadoCuentaScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  String _userRole = '';
  bool _isLoading = true;
  Map<String, dynamic>? _estadoCuenta;
  List<dynamic>? _estadosCuentaUsuarios;
  Map<String, dynamic>? _estadisticasGenerales;

  // Para búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterEstado = 'todos'; // 'todos', 'vencido', 'pendiente', 'al_dia'

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndData();
  }

  Future<void> _loadUserRoleAndData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener información del usuario actual
      final profileResult = await _authService.getProfile();
      if (profileResult['success'] && mounted) {
        final userData = profileResult['data'];
        setState(() {
          _userRole = userData['role'] ?? 'resident';
        });

        // Cargar datos según el rol
        if (_userRole == 'resident') {
          await _loadEstadoCuentaPropio();
        } else if (_userRole == 'security' || _userRole == 'admin') {
          await _loadEstadosCuentaUsuarios();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar información del usuario'),
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

  Future<void> _loadEstadoCuentaPropio() async {
    try {
      final result = await _profileService.getEstadoCuenta();
      if (result['success'] && mounted) {
        setState(() {
          _estadoCuenta = result['data'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Error al cargar estado de cuenta',
              ),
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
    }
  }

  Future<void> _loadEstadosCuentaUsuarios() async {
    try {
      final result = await _profileService.getEstadosCuentaUsuarios(
        search: _searchQuery,
        estado: _filterEstado != 'todos' ? _filterEstado : null,
      );
      if (result['success'] && mounted) {
        setState(() {
          _estadosCuentaUsuarios = result['data']['estados_cuenta'];
          _estadisticasGenerales = result['data']['estadisticas_generales'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Error al cargar estados de cuenta',
              ),
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
    }
  }

  Future<void> _loadEstadoCuentaUsuarioEspecifico(int userId) async {
    try {
      final result = await _profileService.getEstadoCuentaUsuario(userId);
      if (result['success'] && mounted) {
        _showEstadoCuentaDialog(result['data']);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Error al cargar estado de cuenta',
              ),
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
    }
  }

  void _showEstadoCuentaDialog(Map<String, dynamic> estadoCuenta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF18181B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estado de Cuenta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información del residente
                        _buildInfoCard(
                          'Información del Residente',
                          estadoCuenta['residente_info'],
                        ),
                        const SizedBox(height: 16),

                        // Resumen general
                        _buildResumenGeneralCard(
                          estadoCuenta['resumen_general'],
                        ),
                        const SizedBox(height: 16),

                        // Alertas
                        if (estadoCuenta['alertas'] != null &&
                            estadoCuenta['alertas'].isNotEmpty)
                          _buildAlertasCard(estadoCuenta['alertas']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, Map<String, dynamic> info) {
    return Card(
      color: const Color(0xFF232336),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Nombre', info['nombre_completo'] ?? ''),
            _buildInfoRow('Usuario', info['username'] ?? ''),
            _buildInfoRow('Email', info['email'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonPago() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToPagoScreen(),
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text(
          'Pagar Cargos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonHistorialPagos() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _navigateToHistorialPagos(),
        icon: const Icon(Icons.history, color: Color(0xFFF97316)),
        label: const Text(
          'Historial de Pagos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF97316),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF97316)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResumenGeneralCard(Map<String, dynamic> resumen) {
    return Card(
      color: const Color(0xFF232336),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen Financiero',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMontoCard(
                    'Total Pendiente',
                    resumen['total_pendiente'] ?? 0,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMontoCard(
                    'Total Vencido',
                    resumen['total_vencido'] ?? 0,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMontoCard(
                    'Pagado este mes',
                    resumen['total_pagado_mes_actual'] ?? 0,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMontoCard(
                    'Pagado 6 meses',
                    resumen['total_pagado_6_meses'] ?? 0,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Cargos Pendientes',
              resumen['cantidad_cargos_pendientes']?.toString() ?? '0',
            ),
            _buildInfoRow(
              'Cargos Vencidos',
              resumen['cantidad_cargos_vencidos']?.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontoCard(String label, dynamic monto, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Text(
            '\$${(double.tryParse(monto?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertasCard(List<dynamic> alertas) {
    return Card(
      color: const Color(0xFF232336),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...alertas.map((alerta) => _buildAlertaItem(alerta)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaItem(Map<String, dynamic> alerta) {
    Color color;
    switch (alerta['severidad']) {
      case 'alta':
        color = Colors.red;
        break;
      case 'media':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alerta['titulo'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            alerta['mensaje'] ?? '',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onSidebarSelect(String key) {
    if (key == 'logout') {
      _authService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } else if (key != 'estado_cuenta') {
      Navigator.pushReplacementNamed(context, '/$key');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Estado de Cuenta'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (_userRole == 'security' || _userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEstadosCuentaUsuarios,
              tooltip: 'Actualizar',
            ),
        ],
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: _userRole,
          selected: 'estado_cuenta',
          onSelect: (key) {
            Navigator.pop(context);
            _onSidebarSelect(key);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userRole == 'resident'
          ? _buildEstadoCuentaResidente()
          : _buildEstadosCuentaUsuarios(),
    );
  }

  Widget _buildEstadoCuentaResidente() {
    if (_estadoCuenta == null) {
      return const Center(
        child: Text(
          'No se pudo cargar el estado de cuenta',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del residente
          _buildInfoCard('Mi Información', _estadoCuenta!['residente_info']),
          const SizedBox(height: 16),

          // Resumen general
          _buildResumenGeneralCard(_estadoCuenta!['resumen_general']),
          const SizedBox(height: 16),

          // Botón de pago (solo si hay cargos pendientes)
          if ((_estadoCuenta!['cargos_pendientes'] as List?)?.isNotEmpty ??
              false)
            _buildBotonPago(),
          const SizedBox(height: 16),

          // Botón de historial de pagos
          _buildBotonHistorialPagos(),
          const SizedBox(height: 16),

          // Próximo vencimiento
          if (_estadoCuenta!['proximo_vencimiento'] != null &&
              _estadoCuenta!['proximo_vencimiento']['cargo'] != null)
            _buildProximoVencimientoCard(_estadoCuenta!['proximo_vencimiento']),
          const SizedBox(height: 16),

          // Último pago
          if (_estadoCuenta!['ultimo_pago'] != null &&
              _estadoCuenta!['ultimo_pago']['cargo'] != null)
            _buildUltimoPagoCard(_estadoCuenta!['ultimo_pago']),
          const SizedBox(height: 16),

          // Alertas
          if (_estadoCuenta!['alertas'] != null &&
              _estadoCuenta!['alertas'].isNotEmpty)
            _buildAlertasCard(_estadoCuenta!['alertas']),
        ],
      ),
    );
  }

  Widget _buildProximoVencimientoCard(Map<String, dynamic> proximo) {
    return Card(
      color: const Color(0xFF232336),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Próximo Vencimiento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Concepto',
              proximo['cargo']?['concepto']?['nombre'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Monto',
              '\$${(double.tryParse(proximo['cargo']?['monto']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
            ),
            _buildInfoRow('Fecha', proximo['fecha'] ?? ''),
            _buildInfoRow(
              'Días restantes',
              proximo['dias_restantes']?.toString() ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimoPagoCard(Map<String, dynamic> ultimoPago) {
    return Card(
      color: const Color(0xFF232336),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Último Pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Concepto',
              ultimoPago['cargo']?['concepto']?['nombre'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Monto',
              '\$${(double.tryParse(ultimoPago['cargo']?['monto']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
            ),
            _buildInfoRow('Fecha', ultimoPago['fecha'] ?? ''),
            _buildInfoRow(
              'Hace días',
              ultimoPago['hace_dias']?.toString() ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadosCuentaUsuarios() {
    return Column(
      children: [
        // Estadísticas generales
        if (_estadisticasGenerales != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF232336),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEstadisticaItem(
                  'Total Residentes',
                  _estadisticasGenerales!['total_residentes']?.toString() ??
                      '0',
                  Colors.blue,
                ),
                _buildEstadisticaItem(
                  'Vencidos',
                  _estadisticasGenerales!['residentes_vencidos']?.toString() ??
                      '0',
                  Colors.red,
                ),
                _buildEstadisticaItem(
                  'Pendientes',
                  _estadisticasGenerales!['residentes_pendientes']
                          ?.toString() ??
                      '0',
                  Colors.orange,
                ),
                _buildEstadisticaItem(
                  'Al día',
                  _estadisticasGenerales!['residentes_al_dia']?.toString() ??
                      '0',
                  Colors.green,
                ),
              ],
            ),
          ),

        // Barra de búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1F1F2E),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, usuario o email...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: const Color(0xFFF97316)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3C),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _loadEstadosCuentaUsuarios();
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Filtrar por estado:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _filterEstado,
                      dropdownColor: const Color(0xFF2A2A3C),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'vencido',
                          child: Text('Vencidos'),
                        ),
                        DropdownMenuItem(
                          value: 'pendiente',
                          child: Text('Pendientes'),
                        ),
                        DropdownMenuItem(
                          value: 'al_dia',
                          child: Text('Al día'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterEstado = value!;
                        });
                        _loadEstadosCuentaUsuarios();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de residentes
        Expanded(
          child:
              _estadosCuentaUsuarios == null || _estadosCuentaUsuarios!.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron residentes',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _estadosCuentaUsuarios!.length,
                  itemBuilder: (context, index) {
                    final estadoCuenta = _estadosCuentaUsuarios![index];
                    return _buildResidenteCard(estadoCuenta);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEstadisticaItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResidenteCard(Map<String, dynamic> estadoCuenta) {
    final residente = estadoCuenta['residente_info'];
    final estadoFinanciero = estadoCuenta['estado_financiero'];

    Color estadoColor;
    String estadoText;
    switch (estadoFinanciero['estado_general']) {
      case 'vencido':
        estadoColor = Colors.red;
        estadoText = 'VENCIDO';
        break;
      case 'pendiente':
        estadoColor = Colors.orange;
        estadoText = 'PENDIENTE';
        break;
      default:
        estadoColor = Colors.green;
        estadoText = 'AL DÍA';
    }

    return Card(
      color: const Color(0xFF232336),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _loadEstadoCuentaUsuarioEspecifico(residente['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          residente['nombre_completo'] ?? residente['username'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '@${residente['username']}',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: estadoColor),
                    ),
                    child: Text(
                      estadoText,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMontoCard(
                      'Pendiente',
                      estadoFinanciero['total_pendiente'] ?? 0,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMontoCard(
                      'Vencido',
                      estadoFinanciero['total_vencido'] ?? 0,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (estadoFinanciero['proximo_vencimiento'] != null &&
                  estadoFinanciero['proximo_vencimiento']['fecha'] != null)
                Text(
                  'Próximo vencimiento: ${estadoFinanciero['proximo_vencimiento']['fecha']} '
                  '(${estadoFinanciero['proximo_vencimiento']['dias_restantes'] ?? 0} días)',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPagoScreen() {
    // Navegar a pantalla de pago con los cargos pendientes
    if (_estadoCuenta != null && _estadoCuenta!['cargos_pendientes'] != null) {
      final cargosPendientes =
          _estadoCuenta!['cargos_pendientes'] as List<dynamic>;
      if (cargosPendientes.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaPagoCargos(
              cargosPendientes: cargosPendientes,
              onPagoCompletado: _refreshEstadoCuenta,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay cargos pendientes para pagar'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  void _navigateToHistorialPagos() {
    // Navegar a pantalla de historial de pagos
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaHistorialPagos()),
    );
  }

  void _refreshEstadoCuenta() {
    // Refrescar el estado de cuenta después de un pago
    _loadUserRoleAndData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
