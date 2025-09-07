  // Para dispositivos físicos, usa la IP de tu computadora en la red local
  // Por ejemplo: 'http://192.168.1.100:8000/api'
  // Para emulador Android: 'http://10.0.2.2:8000/api'

class Config {
  static const String apiUrl = 'http://localhost:8000/api';
  static const String loginUrl = '$apiUrl/login/';           // POST
  static const String tokenUrl = '$apiUrl/token/';           // POST (para JWT)
  static const String refreshTokenUrl = '$apiUrl/token/refresh/'; // POST
  static const String userProfileUrl = '$apiUrl/me/';        // GET (con token)
}