# WIFI CONTROL

Aplicación multiplataforma en Flutter para descubrir y administrar routers compatibles de distintas marcas.

## Estado actual

Versión inicial del proyecto (0.1.0). Incluye estructura de aplicación, pantalla principal, fichas de referencia para equipos de prueba y una interfaz común para futuros adaptadores de router.

**Importante:** la detección de red, autenticación, lectura de dispositivos y cambios de configuración todavía no están implementados. Los perfiles Huawei y KAON son referencias documentadas, no integraciones funcionales.

## Equipos de referencia

- Huawei EchoLife HG8245W5-6T (GPON/ONT).
- KAON CG3000 (Cable/DOCSIS).

## Módulos previstos

- Conexión y detección automática/manual.
- Dispositivos conectados.
- Wi-Fi 2.4 GHz y 5 GHz.
- Pruebas de velocidad.
- Seguridad.
- Diagnóstico y mantenimiento.

## Requisitos

- Flutter SDK estable.
- Android Studio para compilar Android.
- Xcode en macOS para compilar iOS.
- Flutter para escritorio según plataforma objetivo.

## Ejecutar

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Seguridad

No guardar contraseñas de routers, tokens, claves privadas ni datos sensibles en el repositorio. Solicitar autenticación local de forma segura cuando se implemente cada adaptador. No realizar cambios de configuración sin confirmación explícita del usuario.

## Arquitectura inicial

- `lib/models/`: modelos de routers y dispositivos.
- `lib/services/`: contrato de adaptadores y catálogo de perfiles.
- `lib/screens/`: interfaz de usuario.
- `test/`: pruebas automatizadas iniciales.
