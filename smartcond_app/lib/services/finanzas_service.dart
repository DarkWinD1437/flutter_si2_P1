import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class FinanzasService {
  static const String baseUrl = Config.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Obtener token de autenticación
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Headers con autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener estado de cuenta del usuario
  Future<Map<String, dynamic>> getEstadoCuenta() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.financesUrl}estado-cuenta/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener estado de cuenta: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener historial de pagos
  Future<Map<String, dynamic>> getHistorialPagos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.financesUrl}cargos/pagos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener historial: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener cuotas pendientes
  Future<Map<String, dynamic>> getCuotasPendientes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.financesUrl}cuotas-pendientes/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener cuotas pendientes: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Procesar pago de cuota
  Future<Map<String, dynamic>> pagarCuota(
    int cuotaId,
    Map<String, dynamic> datosPago,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${Config.financesUrl}pagar-cuota/'),
        headers: headers,
        body: json.encode({'cuota_id': cuotaId, ...datosPago}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al procesar pago: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Pagar un cargo específico (T3: Pagar cuota en línea)
  Future<Map<String, dynamic>> pagarCargo(
    int cargoId, {
    String? referenciaPago,
    String? observaciones,
    String metodoPago = 'online',
    double? montoPagado,
    bool confirmarPago = true,
  }) async {
    try {
      final headers = await _getHeaders();

      // Preparar datos del pago
      final datosPago = {
        'metodo_pago': metodoPago,
        'confirmar_pago': confirmarPago,
        if (referenciaPago != null && referenciaPago.isNotEmpty)
          'referencia_pago': referenciaPago,
        if (observaciones != null && observaciones.isNotEmpty)
          'observaciones': observaciones,
        if (montoPagado != null) 'monto_pagado': montoPagado,
      };

      final response = await http
          .post(
            Uri.parse('${Config.financesUrl}cargos/$cargoId/pagar/'),
            headers: headers,
            body: json.encode(datosPago),
          )
          .timeout(const Duration(seconds: 30)); // Timeout de 30 segundos

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        String errorMessage = 'Error al procesar pago';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          // Si no se puede parsear el JSON, usar mensaje genérico
          errorMessage = 'Error del servidor: ${response.statusCode}';
        }

        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      String errorMessage = 'Error de conexión';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Tiempo de espera agotado. Verifica tu conexión a internet.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'No se puede conectar al servidor. Verifica que el backend esté ejecutándose.';
      }

      return {
        'success': false,
        'error': errorMessage,
        'exception': e.toString(),
      };
    }
  }

  // Descargar comprobante de pago
  Future<Map<String, dynamic>> descargarComprobante(int cargoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.financesUrl}cargos/$cargoId/comprobante/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.bodyBytes,
          'contentType': response.headers['content-type'],
          'filename': response.headers['content-disposition'] != null
              ? response.headers['content-disposition']!
                    .split('filename=')[1]
                    .replaceAll('"', '')
              : 'comprobante.pdf',
          'numeroComprobante': response.headers['x-numero-comprobante'],
        };
      } else {
        String errorMessage = 'Error al descargar comprobante';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error del servidor: ${response.statusCode}';
        }
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener recordatorios de vencimiento
  Future<Map<String, dynamic>> getRecordatorios() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Config.financesUrl}recordatorios/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener recordatorios: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
