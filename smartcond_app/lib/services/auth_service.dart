import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🌐 Conectando a: ${Config.tokenUrl}');

      final response = await http.post(
        Uri.parse(Config.tokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Guardar tokens JWT
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        final token = data['access'];
        print('🔑 TOKEN JWT (login): $token');

        print('✅ Login exitoso, obteniendo perfil de usuario...');

        // Obtener perfil del usuario para saber el tipo
        final profileResponse = await getProfile();
        if (profileResponse['success']) {
          final userData = profileResponse['data'];
          await storage.write(
            key: 'user_type',
            value: userData['role'] ?? 'resident',
          );
          await storage.write(key: 'user_id', value: userData['id'].toString());
          await storage.write(key: 'username', value: userData['username']);

          print(
            '👤 Usuario: ${userData['username']}, Rol: ${userData['role']}',
          );
          return {'success': true, 'data': userData};
        }

        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['detail'] ??
            errorData['error'] ??
            'Error de autenticación';
        print('❌ Error de login: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Excepción de login: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Refuerzo: leer el token justo antes de la petición
      final token = await storage.read(key: 'access_token');
      print('🔎 TOKEN JWT usado en getProfile: $token');
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'No hay token disponible'};
      }

      final response = await http
          .get(
            Uri.parse(Config.userProfileUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Timeout al obtener perfil');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🟢 Perfil recibido: $data');
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        // Token expirado o inválido, forzar logout
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
        await storage.delete(key: 'user_type');
        await storage.delete(key: 'user_id');
        await storage.delete(key: 'username');
        print('🔴 Token inválido o expirado en getProfile');
        return {'success': false, 'error': 'Sesión expirada o token inválido'};
      } else {
        print('🔴 Error al obtener perfil: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error al obtener perfil: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 Excepción en getProfile: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      final token = await storage.read(key: 'access_token');
      final refreshToken = await storage.read(key: 'refresh_token');

      if (token != null) {
        // Intentar hacer logout en el servidor
        try {
          await http.post(
            Uri.parse(Config.logoutUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'refresh_token': refreshToken}),
          );
        } catch (e) {
          print('⚠️ Error al hacer logout en servidor: $e');
        }
      }

      // Limpiar almacenamiento local
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      await storage.delete(key: 'user_type');
      await storage.delete(key: 'user_id');
      await storage.delete(key: 'username');

      print('✅ Logout completado');
    } catch (e) {
      print('❌ Error durante logout: $e');
      // Aun así limpiar el almacenamiento local
      await storage.deleteAll();
    }
  }

  Future<bool> isLoggedIn() async {
    print('🔐 Iniciando verificación de login...');

    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        print('🔐 No hay token guardado - retornando false');
        return false;
      }

      print('🔍 Token encontrado, validando con servidor...');
      print('🌐 URL: ${Config.userProfileUrl}');

      // Hacer una petición simple para validar el token con timeout más corto
      final response = await http
          .get(
            Uri.parse(Config.userProfileUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5)); // Timeout más corto: 5 segundos

      print('📊 Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Token válido - retornando true');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ Token expirado o inválido - intentando refresh...');
        // Intentar refrescar el token
        final refreshed = await refreshToken();
        if (refreshed) {
          print('🔄 Token refrescado exitosamente - retornando true');
          return true;
        } else {
          print(
            '❌ No se pudo refrescar el token - limpiando y retornando false',
          );
          // Limpiar tokens inválidos
          await storage.delete(key: 'access_token');
          await storage.delete(key: 'refresh_token');
          await storage.delete(key: 'user_type');
          await storage.delete(key: 'user_id');
          await storage.delete(key: 'username');
          return false;
        }
      } else {
        print(
          '❌ Error al validar token: ${response.statusCode} - ${response.body}',
        );
        print('⚠️ Asumiendo no logueado por seguridad');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timeout')) {
        print('⏰ Timeout en validación de token: $e');
        print('⚠️ Timeout - asumiendo no logueado');
      } else {
        print('❌ Error de conexión al validar token: $e');
        print('⚠️ Error de conexión - asumiendo no logueado');
      }
      // En caso de error de conexión, asumir que no está logueado
      // para evitar que la app se quede "atascada"
      return false;
    }
  }

  Future<String?> getUserType() async {
    return await storage.read(key: 'user_type');
  }

  Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == 'admin';
  }

  Future<bool> isResident() async {
    final userType = await getUserType();
    return userType == 'resident';
  }

  Future<void> clearAllData() async {
    print('🧹 Limpiando todos los datos almacenados...');
    await storage.deleteAll();
    print('✅ Todos los datos limpiados');
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        print('❌ No hay refresh token disponible');
        return false;
      }

      print('🔄 Refrescando token...');
      final response = await http.post(
        Uri.parse(Config.refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access'];

        // Guardar el nuevo access token
        await storage.write(key: 'access_token', value: newAccessToken);
        print('✅ Token refrescado exitosamente');
        return true;
      } else {
        print('❌ Error al refrescar token: ${response.statusCode}');
        // Limpiar tokens si el refresh falló
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
        await storage.delete(key: 'user_type');
        await storage.delete(key: 'user_id');
        await storage.delete(key: 'username');
        return false;
      }
    } catch (e) {
      print('❌ Excepción al refrescar token: $e');
      return false;
    }
  }
}