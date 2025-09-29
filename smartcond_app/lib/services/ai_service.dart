import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class AIService {
  final storage = const FlutterSecureStorage();

  /// Login facial usando reconocimiento avanzado
  Future<Map<String, dynamic>> loginFacial(String imagenBase64) async {
    try {
      print('🤖 Iniciando login facial con IA...');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/security/login-facial/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imagen_base64': imagenBase64}),
      );

      print('📊 Respuesta login facial: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Login facial exitoso: ${data['login_exitoso']}');

        if (data['login_exitoso']) {
          // Guardar token y datos del usuario
          final token = data['token'];
          await storage.write(key: 'access_token', value: token);

          final userData = data['usuario'];
          await storage.write(
            key: 'user_type',
            value: userData['role'] ?? 'resident',
          );
          await storage.write(key: 'user_id', value: userData['id'].toString());
          await storage.write(key: 'username', value: userData['username']);

          print(
            '👤 Usuario reconocido: ${userData['username']}, Rol: ${userData['role']}',
          );

          return {
            'success': true,
            'data': userData,
            'token': token,
            'mensaje_ia': data['mensaje_ia'],
          };
        } else {
          print('❌ Login facial fallido: ${data['mensaje']}');
          return {
            'success': false,
            'error': data['mensaje'] ?? 'Rostro no reconocido',
            'mensaje_ia': data['mensaje_ia'],
          };
        }
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error en login facial: ${errorData}');
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error en reconocimiento facial',
        };
      }
    } catch (e) {
      print('❌ Excepción en login facial: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Registrar rostro usando IA avanzada
  Future<Map<String, dynamic>> registrarRostro(
    String imagenBase64,
    String nombreIdentificador, {
    double confianzaMinima = 0.7,
  }) async {
    try {
      print('📝 Registrando rostro con IA...');

      // Obtener token para autenticación
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        return {'success': false, 'error': 'No hay sesión activa'};
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/security/rostros/registrar_con_ia/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'imagen_base64': imagenBase64,
          'nombre_identificador': nombreIdentificador,
          'confianza_minima': confianzaMinima,
        }),
      );

      print('📊 Respuesta registro: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Registro exitoso: ${data['mensaje_ia']}');
        return {
          'success': true,
          'data': data['data'],
          'mensaje_ia': data['mensaje_ia'],
        };
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error en registro: ${errorData}');
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error en registro facial',
        };
      }
    } catch (e) {
      print('❌ Excepción en registro: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Obtener rostros registrados
  Future<Map<String, dynamic>> getRostrosRegistrados() async {
    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        return {'success': false, 'error': 'No hay sesión activa'};
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/security/rostros/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Error al obtener rostros'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Eliminar rostro registrado
  Future<Map<String, dynamic>> eliminarRostro(String rostroId) async {
    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        return {'success': false, 'error': 'No hay sesión activa'};
      }

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/security/rostros/$rostroId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        return {'success': false, 'error': 'Error al eliminar rostro'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Lectura de placa vehicular
  Future<Map<String, dynamic>> lecturaPlaca(
    String imagenBase64,
    String ubicacion,
  ) async {
    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        return {'success': false, 'error': 'No hay sesión activa'};
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/security/lectura-placa/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'imagen_base64': imagenBase64,
          'ubicacion': ubicacion,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error en lectura de placa',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Reconocimiento facial en tiempo real
  Future<Map<String, dynamic>> reconocimientoFacial(
    String imagenBase64,
    String ubicacion,
  ) async {
    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        return {'success': false, 'error': 'No hay sesión activa'};
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/security/reconocimiento-facial/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'imagen_base64': imagenBase64,
          'ubicacion': ubicacion,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error en reconocimiento',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Convertir imagen a base64
  String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  /// Preprocesar imagen para mejor calidad
  Future<String> preprocessImage(String base64Image) async {
    // Por ahora retornamos la imagen sin procesar
    // En el futuro podríamos implementar procesamiento en Flutter
    return base64Image;
  }
}
