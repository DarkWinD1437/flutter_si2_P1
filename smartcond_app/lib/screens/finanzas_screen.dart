import 'package:flutter/material.dart';
import '../services/finanzas_service.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen>
    with TickerProviderStateMixin {
  final FinanzasService _finanzasService = FinanzasService();
  late TabController _tabController;

  bool _isLoading = true;
  Map<String, dynamic> _estadoCuenta = {};
  List<dynamic> _cuotasPendientes = [];
  List<dynamic> _historialPagos = [];
  List<dynamic> _recordatorios = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarDatosFinancieros();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosFinancieros() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular datos por ahora hasta que el backend esté listo
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _estadoCuenta = {
          'saldo_total': '1,250,000',
          'saldo_pendiente': '450,000',
          'unidad': 'Apto 101',
          'ultima_actualizacion': DateTime.now().toIso8601String(),
          'proximo_vencimiento': DateTime.now()
              .add(Duration(days: 15))
              .toIso8601String(),
        };

        _cuotasPendientes = [
          {
            'id': 1,
            'concepto': 'Cuota Administración Septiembre 2025',
            'monto': '180,000',
            'fecha_vencimiento': DateTime.now()
                .add(Duration(days: 15))
                .toIso8601String(),
          },
          {
            'id': 2,
            'concepto': 'Multa por Ruido Excesivo',
            'monto': '50,000',
            'fecha_vencimiento': DateTime.now()
                .add(Duration(days: 10))
                .toIso8601String(),
          },
        ];

        _historialPagos = [
          {
            'id': 1,
            'concepto': 'Cuota Administración Agosto 2025',
            'monto_pagado': '180,000',
            'fecha_pago': DateTime.now()
                .subtract(Duration(days: 30))
                .toIso8601String(),
          },
          {
            'id': 2,
            'concepto': 'Cuota Administración Julio 2025',
            'monto_pagado': '180,000',
            'fecha_pago': DateTime.now()
                .subtract(Duration(days: 60))
                .toIso8601String(),
          },
        ];

        _recordatorios = [
          {
            'titulo': 'Recordatorio de Pago',
            'descripcion': 'Tu cuota vence en 15 días',
            'fecha_recordatorio': DateTime.now()
                .add(Duration(days: 15))
                .toIso8601String(),
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos financieros: $e');
      setState(() {
        _isLoading = false;
      });
      _mostrarError('Error al cargar los datos financieros');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  Widget _buildEstadoCuentaTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen financiero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Cuenta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Total',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '\$${_estadoCuenta['saldo_total'] ?? '0.00'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Pendiente',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '\$${_estadoCuenta['saldo_pendiente'] ?? '0.00'}',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Información adicional
          Card(
            color: Color(0xFF232336),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Unidad:',
                    _estadoCuenta['unidad'] ?? 'No asignada',
                  ),
                  _buildInfoRow(
                    'Última actualización:',
                    _formatDate(_estadoCuenta['ultima_actualizacion']),
                  ),
                  _buildInfoRow(
                    'Próximo vencimiento:',
                    _formatDate(_estadoCuenta['proximo_vencimiento']),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuotasPendientesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cuotasPendientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              '¡Al día con los pagos!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'No tienes cuotas pendientes',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _cuotasPendientes.length,
      itemBuilder: (context, index) {
        final cuota = _cuotasPendientes[index];
        return Card(
          color: Color(0xFF232336),
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.payment, color: Colors.white),
            ),
            title: Text(
              cuota['concepto'] ?? 'Cuota',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Vencimiento: ${_formatDate(cuota['fecha_vencimiento'])}',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${cuota['monto']}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _mostrarDialogoPago(cuota),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(60, 30),
                  ),
                  child: Text('Pagar', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorialPagosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historialPagos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sin historial de pagos',
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

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _historialPagos.length,
      itemBuilder: (context, index) {
        final pago = _historialPagos[index];
        return Card(
          color: Color(0xFF232336),
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white),
            ),
            title: Text(
              pago['concepto'] ?? 'Pago',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Pagado: ${_formatDate(pago['fecha_pago'])}',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${pago['monto_pagado']}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => _descargarComprobante(pago['id']),
                  child: Text('Comprobante', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordatoriosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _recordatorios.length + 1, // +1 para configuración
      itemBuilder: (context, index) {
        if (index == 0) {
          // Configuración de recordatorios
          return Card(
            color: Color(0xFF232336),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de Recordatorios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      'Notificaciones Push',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Recibe alertas en tu celular',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: true,
                    onChanged: (value) {
                      // Implementar configuración
                    },
                    activeColor: Colors.blue,
                  ),
                  SwitchListTile(
                    title: Text(
                      'Email de recordatorio',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '5 días antes del vencimiento',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: false,
                    onChanged: (value) {
                      // Implementar configuración
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
          );
        }

        final recordatorio = _recordatorios[index - 1];
        return Card(
          color: Color(0xFF232336),
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.schedule, color: Colors.white),
            ),
            title: Text(
              recordatorio['titulo'] ?? 'Recordatorio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              recordatorio['descripcion'] ?? '',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              _formatDate(recordatorio['fecha_recordatorio']),
              style: TextStyle(color: Colors.orange),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
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

  void _mostrarDialogoPago(Map<String, dynamic> cuota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF232336),
          title: Text('Pago de Cuota', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Concepto: ${cuota['concepto']}',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                'Monto: \$${cuota['monto']}',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Selecciona método de pago:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _procesarPago(cuota, 'transferencia');
                },
                icon: Icon(Icons.account_balance),
                label: Text('Transferencia Bancaria'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _procesarPago(cuota, 'tarjeta');
                },
                icon: Icon(Icons.credit_card),
                label: Text('Tarjeta de Crédito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _procesarPago(
    Map<String, dynamic> cuota,
    String metodoPago,
  ) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF232336),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Procesando pago...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    // Simular procesamiento
    await Future.delayed(Duration(seconds: 3));
    Navigator.pop(context); // Cerrar loading

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Pago procesado exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
    _cargarDatosFinancieros(); // Recargar datos
  }

  Future<void> _descargarComprobante(int pagoId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de descarga disponible próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Finanzas'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosFinancieros,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Estado'),
            Tab(icon: Icon(Icons.payment), text: 'Pendientes'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
            Tab(icon: Icon(Icons.notifications), text: 'Recordatorios'),
          ],
        ),
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: 'resident',
          selected: 'finanzas',
          onSelect: (key) {
            Navigator.pop(context);
            if (key != 'finanzas') {
              Navigator.pushReplacementNamed(context, '/$key');
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEstadoCuentaTab(),
          _buildCuotasPendientesTab(),
          _buildHistorialPagosTab(),
          _buildRecordatoriosTab(),
        ],
      ),
    );
  }
}
