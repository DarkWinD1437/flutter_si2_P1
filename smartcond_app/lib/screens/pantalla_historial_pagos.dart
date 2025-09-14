import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import '../services/finanzas_service.dart';

class PantallaHistorialPagos extends StatefulWidget {
  const PantallaHistorialPagos({super.key});

  @override
  State<PantallaHistorialPagos> createState() => _PantallaHistorialPagosState();
}

class _PantallaHistorialPagosState extends State<PantallaHistorialPagos> {
  final FinanzasService _finanzasService = FinanzasService();
  bool _isLoading = true;
  List<dynamic>? _historialPagos;
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _cargarHistorialPagos();
  }

  Future<void> _cargarHistorialPagos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _finanzasService.getHistorialPagos();
      if (result['success'] && mounted) {
        setState(() {
          _historialPagos = result['data']['pagos'] ?? [];
          _estadisticas = result['data']['estadisticas'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Error al cargar historial de pagos',
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarHistorialPagos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContenido(),
    );
  }

  Widget _buildContenido() {
    if (_historialPagos == null || _historialPagos!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'No tienes pagos registrados',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Estadísticas
        if (_estadisticas != null) _buildEstadisticas(),

        // Lista de pagos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _historialPagos!.length,
            itemBuilder: (context, index) {
              final pago = _historialPagos![index];
              return _buildPagoCard(pago);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticas() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF232336),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEstadisticaItem(
            'Total Pagos',
            _estadisticas!['total_pagos']?.toString() ?? '0',
            Colors.blue,
          ),
          _buildEstadisticaItem(
            'Monto Total',
            '\$${(double.tryParse(_estadisticas!['monto_total']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildPagoCard(Map<String, dynamic> pago) {
    final cargo = pago['concepto_nombre'] ?? 'Cargo sin nombre';
    final monto = double.tryParse(pago['monto']?.toString() ?? '0') ?? 0;
    final fechaPago = pago['fecha_pago'] ?? 'Fecha no disponible';
    final referencia = pago['referencia_pago'] ?? 'Sin referencia';

    return Card(
      color: const Color(0xFF232336),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cargo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'PAGADO',
                    style: TextStyle(
                      color: Colors.green,
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
                  child: _buildInfoItem(
                    'Monto',
                    '\$${monto.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Fecha',
                    _formatearFecha(fechaPago),
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (referencia != 'Sin referencia')
              _buildInfoItem('Referencia', referencia, Colors.white70),
            const SizedBox(height: 12),
            // Botón para generar comprobante
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generarComprobante(pago),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Generar Comprobante'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF312E81),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatearFecha(String fechaString) {
    try {
      // Si la fecha viene en formato ISO, intentar formatearla
      final fecha = DateTime.parse(fechaString);
      return '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
    } catch (e) {
      // Si no se puede parsear, devolver la fecha original
      return fechaString;
    }
  }

  Future<void> _abrirArchivo(String filePath) async {
    try {
      // Intentar primero con open_file
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        return; // Éxito
      }

      // Si open_file falla, intentar con url_launcher
      final fileUri = Uri.file(filePath);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri);
        return;
      }

      // Si ambos fallan, mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir el archivo. Instala una app para ver PDFs.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al abrir archivo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el archivo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<String?> _guardarComprobanteEnDescargas(
    List<int> bytes,
    String filename,
  ) async {
    try {
      if (Platform.isAndroid) {
        // Para Android: Usar la carpeta Download REAL del dispositivo
        const String downloadPath = '/storage/emulated/0/Download';
        final downloadDir = Directory(downloadPath);

        // Crear la carpeta si no existe
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final filePath = path.join(downloadPath, filename);
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        if (await file.exists()) {
          return filePath;
        }

        // Estrategia alternativa: usar getExternalStorageDirectory con Download
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final altDownloadPath = path.join(externalDir.path, 'Download');
          final altDownloadDir = Directory(altDownloadPath);

          if (!await altDownloadDir.exists()) {
            await altDownloadDir.create(recursive: true);
          }

          final altFilePath = path.join(altDownloadPath, filename);
          final altFile = File(altFilePath);
          await altFile.writeAsBytes(bytes);

          if (await altFile.exists()) {
            return altFilePath;
          }
        }

        // Última alternativa: carpeta privada de descargas
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final fallbackPath = path.join(downloadsDir.path, filename);
          final fallbackFile = File(fallbackPath);
          await fallbackFile.writeAsBytes(bytes);

          if (await fallbackFile.exists()) {
            return fallbackPath;
          }
        }
      } else {
        // Para iOS y otros sistemas
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final filePath = path.join(downloadsDir.path, filename);
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          return filePath;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error al guardar comprobante: $e');
      return null;
    }
  }

  Future<void> _generarComprobante(Map<String, dynamic> pago) async {
    final cargoId = pago['id'];
    if (cargoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID del cargo no disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generando comprobante...'),
            ],
          ),
        );
      },
    );

    try {
      final result = await _finanzasService.descargarComprobante(cargoId);

      // Cerrar el diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result['success']) {
        // Crear nombre del archivo
        final filename = result['filename'] ?? 'comprobante.pdf';

        // Intentar guardar el archivo usando múltiples estrategias
        final filePath = await _guardarComprobanteEnDescargas(
          result['data'],
          filename,
        );

        if (filePath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No se pudo guardar el comprobante. Verifica los permisos de almacenamiento.',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }

        // Verificar que el archivo se guardó correctamente
        final file = File(filePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint(
            'Archivo guardado exitosamente: $filePath (Tamaño: $fileSize bytes)',
          );
        }

        if (mounted) {
          final downloadFolder = Platform.isAndroid ? 'Download' : 'Descargas';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Comprobante guardado en $downloadFolder: $filename',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Abrir',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    // Verificar que el archivo existe antes de intentar abrirlo
                    if (await file.exists()) {
                      await _abrirArchivo(filePath);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El archivo no se encuentra en la ubicación esperada',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error al abrir archivo: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al abrir el archivo: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Error al generar comprobante'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar el diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
