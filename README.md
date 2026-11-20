# WIFI CONTROL

Aplicación multiplataforma en Flutter para descubrir y administrar routers compatibles de distintas marcas.

## Estado actual

Versión inicial del proyecto (0.1.0). Incluye estructura de aplicación, pantalla principal, fichas de referencia para equipos de prueba y una interfaz común para futuros adaptadores de router.

**Importante:** la detección inicial de red y una exploración local preliminar por puertos TCP ya están implementadas. La autenticación en routers, la lectura directa de sus listas de clientes y los cambios de configuración todavía no están implementados. Los perfiles Huawei y KAON incluyen adaptadores de referencia seguros, no integraciones completas.

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

## Detección inicial de red

La pantalla **Detectar mi red** consulta el SSID (cuando el sistema lo permite), la IP local, la puerta de enlace y la máscara de red mediante `network_info_plus`. También prueba una conexión TCP breve a los puertos 80 y 443 de la puerta de enlace.

Esta prueba **no identifica por sí sola el fabricante/modelo**, no garantiza que el panel web esté disponible y no modifica el router. En iOS, la información Wi-Fi puede estar limitada por los requisitos de Apple (entitlement y autorización); en Android, el SSID puede requerir permiso de ubicación y que los servicios de ubicación estén activos.

### Permisos Android para la detección

En `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` y antes de `<application>`, declarar los permisos que utiliza la app:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

La app solicita permiso de ubicación en tiempo de ejecución en Android para intentar leer el nombre de la red Wi-Fi. Si se deniega, intenta continuar con los demás datos disponibles.

## Identificación inicial del router

Después de leer la puerta de enlace, WIFI CONTROL realiza solicitudes HTTP GET de solo lectura a algunas rutas locales habituales y busca indicios en el título, cabeceras y contenido público de la página. La primera heurística reconoce menciones a Huawei/EchoLife/HG8245 y KAON/CG3000.

Esto es una **huella preliminar**, no una identificación garantizada: muchos operadores personalizan u ocultan el panel, usan HTTPS o bloquean HTTP. No se envían credenciales, no se siguen redirecciones a otros dominios y no se modifican configuraciones. El modelo exacto debe confirmarse antes de seleccionar un adaptador específico.

## Seguridad

No guardar contraseñas de routers, tokens, claves privadas ni datos sensibles en el repositorio. Solicitar autenticación local de forma segura cuando se implemente cada adaptador. No realizar cambios de configuración sin confirmación explícita del usuario.

## Arquitectura inicial

- `lib/models/`: modelos de routers y dispositivos.
- `lib/services/`: contrato de adaptadores y catálogo de perfiles.
- `lib/screens/`: interfaz de usuario.
- `test/`: pruebas automatizadas iniciales.

## Exploración preliminar de dispositivos locales

La pantalla de detección permite iniciar manualmente una búsqueda IPv4 dentro de la subred del teléfono. La exploración prueba, con concurrencia limitada y tiempos de espera breves, los puertos TCP habituales 80, 443, 22, 445, 5555 y 62078.

- La búsqueda es de solo lectura: no inicia sesión ni modifica equipos.
- Solo aparecen dispositivos que respondan en alguno de esos puertos.
- Los equipos que bloquean esos puertos pueden no aparecer, aunque estén conectados.
- El nombre mostrado describe el servicio detectado, no el nombre real del dispositivo.
- La dirección MAC, fabricante, banda Wi-Fi y velocidad de enlace no se obtienen con este método.
- La lista del router sigue siendo la fuente más fiable para conocer todos los clientes conectados.

La disponibilidad del escaneo depende de los permisos y restricciones de red local de cada sistema operativo. Esta función debe probarse en iOS y Android antes de considerarse validada.
