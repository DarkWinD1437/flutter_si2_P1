class Config {
  // URL base del backend Django
  // Para desarrollo local con React y Flutter: usar IP local de la máquina
  // Para dispositivo físico: usar IP de red local (192.168.0.7)
  // Para emulador Android: usar IP de la máquina host
  static const String baseUrl = 'http://192.168.0.7:8000';

  // ⚠️ IMPORTANTE: Si cambias esta URL, debes:
  // 1. Limpiar datos de la app (tokens antiguos no funcionarán)
  // 2. Reiniciar la app completamente
  // 3. Hacer logout y login nuevamente

  // Opciones alternativas según el entorno:
  // static const String baseUrl = 'http://localhost:8000'; // Para desarrollo local
  // static const String baseUrl = 'http://192.168.0.7:8000'; // Para dispositivo físico
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador Android

  // URLs de autenticación JWT
  static const String tokenUrl =
      '$baseUrl/api/token/'; // POST - Obtener tokens JWT
  static const String refreshTokenUrl =
      '$baseUrl/api/token/refresh/'; // POST - Refrescar token
  static const String verifyTokenUrl =
      '$baseUrl/api/token/verify/'; // POST - Verificar token

  // URLs de API
  static const String userProfileUrl =
      '$baseUrl/api/me/'; // GET - Perfil de usuario
  static const String updateProfileUrl =
      '$baseUrl/api/me/'; // PUT/PATCH - Actualizar perfil
  static const String changePasswordUrl =
      '$baseUrl/api/profile/change-password/'; // POST - Cambiar contraseña
  static const String usersListUrl =
      '$baseUrl/api/users/'; // GET - Lista de usuarios (admin)
  static const String apiStatusUrl =
      '$baseUrl/api/status/'; // GET - Estado de la API

  // URLs de logout
  static const String logoutUrl = '$baseUrl/api/logout/'; // POST - Logout
  static const String logoutAllUrl =
      '$baseUrl/api/logout-all/'; // POST - Logout de todas las sesiones

  // URLs de módulos
  static const String financesUrl =
      '$baseUrl/api/finances/'; // URLs de finanzas
  static const String communicationsUrl =
      '$baseUrl/api/communications/'; // URLs de comunicaciones
  static const String auditUrl = '$baseUrl/api/audit/'; // URLs de auditoría

  // Configuración para desarrollo
  static const bool debugMode = false; // Cambiar a true para desarrollo
}
