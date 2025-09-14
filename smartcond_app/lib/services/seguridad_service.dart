import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SeguridadService {
  static const String baseUrl =
      'https://smart-condominium-backend.onrender.com';
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

  // Obtener registros de acceso (para personal de seguridad)
  Future<Map<String, dynamic>> getRegistrosAcceso({String? fecha}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/api/security/accesos/';
      if (fecha != null) {
        url += '?fecha=$fecha';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error':
              'Error al obtener registros de acceso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Registrar nueva entrada/salida
  Future<Map<String, dynamic>> registrarAcceso(
    Map<String, dynamic> datosAcceso,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/security/registrar-acceso/'),
        headers: headers,
        body: json.encode(datosAcceso),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al registrar acceso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener incidentes de seguridad
  Future<Map<String, dynamic>> getIncidentes({
    String? tipo,
    String? fecha,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/api/security/incidentes/';
      List<String> params = [];
      if (tipo != null) params.add('tipo=$tipo');
      if (fecha != null) params.add('fecha=$fecha');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener incidentes: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Reportar nuevo incidente
  Future<Map<String, dynamic>> reportarIncidente(
    Map<String, dynamic> datosIncidente,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/security/incidentes/'),
        headers: headers,
        body: json.encode(datosIncidente),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al reportar incidente: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener alertas de IA
  Future<Map<String, dynamic>> getAlertasIA() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/security/alertas-ia/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener alertas IA: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener datos de reconocimiento facial
  Future<Map<String, dynamic>> getReconocimientoFacial() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/security/reconocimiento-facial/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error':
              'Error al obtener datos de reconocimiento facial: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener registros de vehículos (OCR placas)
  Future<Map<String, dynamic>> getRegistrosVehiculos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/security/vehiculos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error':
              'Error al obtener registros de vehículos: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Autorizar vehículo
  Future<Map<String, dynamic>> autorizarVehiculo(
    Map<String, dynamic> datosVehiculo,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/security/autorizar-vehiculo/'),
        headers: headers,
        body: json.encode(datosVehiculo),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al autorizar vehículo: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener estadísticas de seguridad
  Future<Map<String, dynamic>> getEstadisticasSeguridad() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/security/estadisticas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener estadísticas: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
