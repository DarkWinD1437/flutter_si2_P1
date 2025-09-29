# Smart Condominium - Flutter App

## Funcionalidad de Reconocimiento Facial con IA

### Descripción
La aplicación Flutter ahora incluye reconocimiento facial avanzado con IA para login y registro de usuarios. Utiliza el backend Django con algoritmos de IA avanzados para proporcionar autenticación biométrica segura.

### Características
- **Login Facial**: Autenticación mediante reconocimiento de rostro con IA
- **Registro Facial**: Registro de rostros con embeddings avanzados
- **Interfaz Intuitiva**: Alternancia fácil entre login tradicional y facial
- **Seguridad Avanzada**: Validación robusta contra falsos positivos
- **Compatibilidad**: Funciona tanto en React como en Flutter

### Requisitos
- Flutter SDK >= 3.8.1
- Dependencias: `image_picker`, `camera`, `http`, `flutter_secure_storage`
- Backend Django con módulo IA activo
- Permisos de cámara en el dispositivo

### Instalación
1. Asegúrate de tener las dependencias instaladas:
```bash
flutter pub get
```

2. Para Android, los permisos de cámara ya están configurados en `AndroidManifest.xml`

3. Para iOS, agrega los siguientes permisos en `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Se requiere acceso a la cámara para reconocimiento facial</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Se requiere acceso a la galería para seleccionar imágenes</string>
```

### Uso

#### Login Facial
1. Abre la aplicación
2. Presiona "Cambiar a Login Facial"
3. Coloca tu rostro frente a la cámara
4. Presiona "Iniciar Sesión Facial"
5. La IA procesará tu imagen y te autenticará automáticamente

#### Registro Facial
El registro facial se realiza desde la aplicación web React o desde otras interfaces del sistema.

### API Endpoints Utilizados

#### Login Facial
```
POST /api/security/login-facial/
```
**Body:**
```json
{
  "imagen_base64": "string_base64"
}
```

**Respuesta Exitosa:**
```json
{
  "login_exitoso": true,
  "usuario": {...},
  "token": "token_jwt",
  "mensaje_ia": "Rostro reconocido exitosamente"
}
```

#### Registro Facial
```
POST /api/security/rostros/registrar_con_ia/
```
**Body:**
```json
{
  "imagen_base64": "string_base64",
  "nombre_identificador": "usuario_face",
  "confianza_minima": 0.7
}
```

### Manejo de Errores
- **Rostro no reconocido**: La IA no encontró coincidencia en la base de datos
- **Imagen de baja calidad**: La imagen no cumple con los requisitos de calidad
- **Error de conexión**: Problemas de red o servidor no disponible
- **Sin permisos de cámara**: El usuario debe otorgar permisos de cámara

### Seguridad
- Solo rostros registrados pueden hacer login
- Validación de calidad de imagen antes del procesamiento
- Embeddings de 128 dimensiones para mayor precisión
- Threshold de confianza mínimo del 75%
- Almacenamiento seguro de tokens JWT

### Desarrollo y Testing
Para ejecutar las pruebas:
```bash
flutter test test/ai_service_test.dart
```

Para ejecutar la aplicación:
```bash
flutter run
```

### Troubleshooting
1. **Error de permisos**: Asegúrate de que la app tenga permisos de cámara
2. **Login fallido**: Verifica que tu rostro esté registrado en el sistema
3. **Imagen borrosa**: Asegúrate de buena iluminación y enfoque
4. **Timeout**: Verifica la conexión a internet y que el backend esté activo

### Arquitectura
```
lib/
├── services/
│   ├── ai_service.dart          # Servicio de IA para reconocimiento facial
│   └── auth_service.dart        # Servicio de autenticación tradicional
├── screens/
│   └── login_screen.dart        # Pantalla de login con modo facial
└── config.dart                  # Configuración de URLs y constantes
```

### Próximas Funcionalidades
- Reconocimiento facial en tiempo real
- Registro múltiple de rostros por usuario
- Validación de liveness (detección de fotos vs rostro real)
- Integración con hardware de control de acceso