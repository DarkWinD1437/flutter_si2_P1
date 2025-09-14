import 'package:flutter/material.dart';
import '../services/finanzas_service.dart';
import '../config.dart';

class PantallaPagoCargos extends StatefulWidget {
  final List<dynamic> cargosPendientes;
  final VoidCallback onPagoCompletado;

  const PantallaPagoCargos({
    super.key,
    required this.cargosPendientes,
    required this.onPagoCompletado,
  });

  @override
  State<PantallaPagoCargos> createState() => _PantallaPagoCargosState();
}

class _PantallaPagoCargosState extends State<PantallaPagoCargos> {
  final FinanzasService _finanzasService = FinanzasService();
  final Set<int> _cargosSeleccionados = {};
  bool _isLoading = false;

  double get _totalSeleccionado {
    return widget.cargosPendientes
        .where((cargo) => _cargosSeleccionados.contains(cargo['id']))
        .fold(0.0, (sum, cargo) {
          final monto = cargo['monto'];
          if (monto is String) {
            return sum + (double.tryParse(monto) ?? 0.0);
          } else if (monto is num) {
            return sum + monto.toDouble();
          }
          return sum;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Pagar Cargos'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Resumen del total
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF232336),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$${_totalSeleccionado.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Lista de cargos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.cargosPendientes.length,
              itemBuilder: (context, index) {
                final cargo = widget.cargosPendientes[index];
                final isSelected = _cargosSeleccionados.contains(cargo['id']);

                return Card(
                  color: const Color(0xFF232336),
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      cargo['concepto_nombre'] ?? 'Cargo sin nombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monto: \$${(double.tryParse(cargo['monto']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Vence: ${cargo['fecha_vencimiento'] ?? 'Sin fecha'}',
                          style: TextStyle(
                            color: cargo['esta_vencido'] == true
                                ? Colors.red
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _cargosSeleccionados.add(cargo['id']);
                        } else {
                          _cargosSeleccionados.remove(cargo['id']);
                        }
                      });
                    },
                    activeColor: const Color(0xFFF97316),
                    checkColor: Colors.white,
                  ),
                );
              },
            ),
          ),

          // Botón de pago
          if (_cargosSeleccionados.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _procesarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pagar \$${(_totalSeleccionado).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _procesarPago() async {
    if (_cargosSeleccionados.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool todosExitosos = true;
      final errores = <String>[];

      // Procesar cada cargo seleccionado
      for (final cargoId in _cargosSeleccionados) {
        final result = await _finanzasService.pagarCargo(
          cargoId,
          metodoPago: 'online',
          referenciaPago: 'Pago desde app móvil',
          confirmarPago: true,
        );

        if (!result['success']) {
          todosExitosos = false;
          String errorMsg = result['error'] ?? 'Error desconocido';

          // Agregar código de estado si está disponible
          if (result.containsKey('statusCode')) {
            errorMsg += ' (Código: ${result['statusCode']})';
          }

          errores.add('Cargo $cargoId: $errorMsg');
        }
      }

      if (mounted) {
        if (todosExitosos) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Pago procesado exitosamente!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Llamar callback para refrescar estado de cuenta
          widget.onPagoCompletado();

          // Regresar a la pantalla anterior
          Navigator.of(context).pop();
        } else {
          // Mostrar errores específicos
          String mensajeError = 'Errores en el pago:\n';
          mensajeError += errores
              .take(3)
              .join('\n'); // Mostrar máximo 3 errores

          if (errores.length > 3) {
            mensajeError += '\n...y ${errores.length - 3} errores más';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensajeError),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String mensajeError = 'Error inesperado: $e';
        if (e.toString().contains('timeout')) {
          mensajeError =
              'Tiempo de espera agotado. Verifica tu conexión a internet.';
        } else if (e.toString().contains('SocketException')) {
          mensajeError =
              'No se puede conectar al servidor. Verifica que el backend esté ejecutándose en ${Config.baseUrl}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
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
}
