import 'dart:convert';
import 'dart:io';

enum RouterFingerprintVendor { huawei, kaon, unknown }

class RouterFingerprint {
  final String gatewayIp;
  final RouterFingerprintVendor vendor;
  final String manufacturer;
  final String? modelHint;
  final String? serverHeader;
  final String? pageTitle;
  final String checkedUrl;
  final String note;

  const RouterFingerprint({
    required this.gatewayIp,
    required this.vendor,
    required this.manufacturer,
    required this.checkedUrl,
    required this.note,
    this.modelHint,
    this.serverHeader,
    this.pageTitle,
  });
}

/// Performs read-only HTTP requests to the local gateway. It never submits
/// credentials, changes settings, or follows links outside the gateway.
class RouterFingerprintService {
  Future<RouterFingerprint> identify(String gatewayIp) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    String? server;
    String? title;
    String checkedUrl = 'http://$gatewayIp/';
    final evidence = <String>[];

    try {
      final paths = <String>['/', '/login.asp', '/html/index.html'];
      for (final path in paths) {
        final uri = Uri(scheme: 'http', host: gatewayIp, path: path);
        try {
          final request = await client.getUrl(uri).timeout(const Duration(seconds: 4));
          request.followRedirects = false;
          request.headers.set(HttpHeaders.userAgentHeader, 'WIFI-CONTROL/0.2 (local read-only identification)');
          final response = await request.close().timeout(const Duration(seconds: 4));
          checkedUrl = uri.toString();
          server ??= response.headers.value(HttpHeaders.serverHeader);
          final bytes = await response.fold<List<int>>(<int>[], (all, chunk) {
            if (all.length < 300000) {
              all.addAll(chunk.take(300000 - all.length));
            }
            return all;
          }).timeout(const Duration(seconds: 4));
          final body = utf8.decode(bytes, allowMalformed: true);
          final pageTitle = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true)
              .firstMatch(body)?.group(1)?.replaceAll(RegExp(r'\s+'), ' ').trim();
          title ??= pageTitle;
          evidence.addAll([response.headers.value(HttpHeaders.serverHeader) ?? '', pageTitle ?? '', body.substring(0, body.length > 12000 ? 12000 : body.length)]);
          if (body.isNotEmpty || response.statusCode < 500) break;
        } on SocketException {
          continue;
        } on HttpException {
          continue;
        } on FormatException {
          continue;
        } on Exception {
          continue;
        }
      }
    } finally {
      client.close(force: true);
    }

    final fingerprintText = evidence.join(' ').toLowerCase();
    // Require model-family evidence to avoid labeling a generic/login page
    // as a vendor when the page contains incidental brand strings.
    final huawei = fingerprintText.contains('hg8245w5') ||
        fingerprintText.contains('hg8245') ||
        fingerprintText.contains('echolife');
    final kaon = fingerprintText.contains('cg3000');

    if (huawei && kaon) {
      return RouterFingerprint(
        gatewayIp: gatewayIp,
        vendor: RouterFingerprintVendor.unknown,
        manufacturer: 'Puerta de enlace',
        serverHeader: server,
        pageTitle: title,
        checkedUrl: checkedUrl,
        note: 'La página contiene indicios de más de un fabricante; no se confirma el modelo automáticamente.',
      );
    }
    if (huawei) {
      return RouterFingerprint(
        gatewayIp: gatewayIp,
        vendor: RouterFingerprintVendor.huawei,
        manufacturer: 'Huawei',
        modelHint: fingerprintText.contains('hg8245w5') ? 'EchoLife HG8245W5-6T' : null,
        serverHeader: server,
        pageTitle: title,
        checkedUrl: checkedUrl,
        note: 'Se encontraron indicios de Huawei en la respuesta del panel. El modelo exacto requiere confirmación.',
      );
    }
    if (kaon) {
      return RouterFingerprint(
        gatewayIp: gatewayIp,
        vendor: RouterFingerprintVendor.kaon,
        manufacturer: 'KAON',
        modelHint: fingerprintText.contains('cg3000') ? 'CG3000' : null,
        serverHeader: server,
        pageTitle: title,
        checkedUrl: checkedUrl,
        note: 'Se encontraron indicios de KAON en la respuesta del panel. El modelo exacto requiere confirmación.',
      );
    }
    return RouterFingerprint(
      gatewayIp: gatewayIp,
      vendor: RouterFingerprintVendor.unknown,
      manufacturer: 'No identificado',
      serverHeader: server,
      pageTitle: title,
      checkedUrl: checkedUrl,
      note: 'La puerta de enlace no publicó una firma reconocible por HTTP. Puede usar HTTPS, otro puerto o una página genérica.',
    );
  }
}
