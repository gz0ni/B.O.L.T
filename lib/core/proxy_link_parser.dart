import 'dart:convert';

/// Разбирает ссылки-шэры протоколов (vless://, trojan://, ss://,
/// hysteria2://) в Map, которая один в один ложится как элемент
/// секции `proxies:` в конфиге mihomo — та же форма, что мы вписывали
/// вручную в config.yaml на предыдущем шаге.
class ProxyLinkParser {
  ProxyLinkParser._();

  /// Пытается разобрать содержимое подписки — это может быть либо
  /// список ссылок построчно, либо тот же список в base64.
  static List<Map<String, dynamic>> parseSubscriptionBody(String body) {
    final text = _looksLikeBase64(body) ? _tryDecodeBase64(body) : body;
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);

    final result = <Map<String, dynamic>>[];
    for (final line in lines) {
      final parsed = tryParseLink(line);
      if (parsed != null) result.add(parsed);
    }
    return result;
  }

  static bool _looksLikeBase64(String s) {
    final trimmed = s.trim();
    if (trimmed.contains('://')) return false; // обычный список ссылок открытым текстом
    return RegExp(r'^[A-Za-z0-9+/=_\-\s]+$').hasMatch(trimmed) && trimmed.length > 20;
  }

  static String _tryDecodeBase64(String s) {
    try {
      final normalized = s.trim().replaceAll('-', '+').replaceAll('_', '/');
      final padded = normalized + '=' * ((4 - normalized.length % 4) % 4);
      return utf8.decode(base64.decode(padded));
    } catch (_) {
      return s; // не base64 — вернём как есть, распарсится построчно как обычно
    }
  }

  /// Разбирает одну ссылку. Возвращает null, если протокол не
  /// распознан или ссылка повреждена — вызывающий код просто
  /// пропускает такие строки.
  static Map<String, dynamic>? tryParseLink(String link) {
    try {
      final uri = Uri.parse(link);
      switch (uri.scheme) {
        case 'vless':
          return _parseVless(uri);
        case 'trojan':
          return _parseTrojan(uri);
        case 'ss':
          return _parseShadowsocks(uri);
        case 'hysteria2':
        case 'hy2':
          return _parseHysteria2(uri);
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static String _name(Uri uri, String fallback) {
    final fragment = uri.fragment;
    return fragment.isNotEmpty ? Uri.decodeComponent(fragment) : fallback;
  }

  static Map<String, dynamic> _parseVless(Uri uri) {
    final q = uri.queryParameters;
    final map = <String, dynamic>{
      'name': _name(uri, 'VLESS-${uri.host}'),
      'type': 'vless',
      'server': uri.host,
      'port': uri.port,
      'uuid': uri.userInfo,
      'network': q['type'] ?? 'tcp',
      'udp': true,
      'tls': q['security'] == 'tls' || q['security'] == 'reality',
      if (q['flow'] != null && q['flow']!.isNotEmpty) 'flow': q['flow'],
      if (q['sni'] != null) 'servername': q['sni'],
      if (q['fp'] != null) 'client-fingerprint': q['fp'],
    };

    if (q['security'] == 'reality') {
      map['reality-opts'] = {
        'public-key': q['pbk'] ?? '',
        'short-id': q['sid'] ?? '',
      };
    }

    if (q['type'] == 'ws') {
      map['ws-opts'] = {
        'path': q['path'] ?? '/',
        if (q['host'] != null) 'headers': {'Host': q['host']},
      };
    }

    return map;
  }

  static Map<String, dynamic> _parseTrojan(Uri uri) {
    final q = uri.queryParameters;
    final map = <String, dynamic>{
      'name': _name(uri, 'Trojan-${uri.host}'),
      'type': 'trojan',
      'server': uri.host,
      'port': uri.port,
      'password': uri.userInfo,
      'udp': true,
      'tls': true,
      if (q['sni'] != null) 'sni': q['sni'],
      'network': q['type'] ?? 'tcp',
    };

    if (q['type'] == 'ws') {
      map['ws-opts'] = {
        'path': q['path'] ?? '/',
        if (q['host'] != null) 'headers': {'Host': q['host']},
      };
    }

    return map;
  }

  static Map<String, dynamic> _parseShadowsocks(Uri uri) {
    // Два формата: ss://base64(method:password)@host:port#name
    // либо legacy ss://base64(method:password@host:port)#name
    String method;
    String password;
    String host;
    int port;

    if (uri.host.isNotEmpty && uri.userInfo.isNotEmpty) {
      final decoded = _tryDecodeBase64(uri.userInfo);
      final parts = decoded.split(':');
      method = parts.first;
      password = parts.sublist(1).join(':');
      host = uri.host;
      port = uri.port;
    } else {
      final decoded = _tryDecodeBase64(uri.host + uri.path);
      final match = RegExp(r'^(.+):(.+)@(.+):(\d+)$').firstMatch(decoded);
      if (match == null) throw const FormatException('bad ss:// link');
      method = match.group(1)!;
      password = match.group(2)!;
      host = match.group(3)!;
      port = int.parse(match.group(4)!);
    }

    return {
      'name': _name(uri, 'SS-$host'),
      'type': 'ss',
      'server': host,
      'port': port,
      'cipher': method,
      'password': password,
      'udp': true,
    };
  }

  static Map<String, dynamic> _parseHysteria2(Uri uri) {
    final q = uri.queryParameters;
    return {
      'name': _name(uri, 'Hysteria2-${uri.host}'),
      'type': 'hysteria2',
      'server': uri.host,
      'port': uri.port,
      'password': uri.userInfo,
      'udp': true,
      if (q['sni'] != null) 'sni': q['sni'],
      if (q['alpn'] != null) 'alpn': q['alpn']!.split(','),
      'client-fingerprint': q['fp'] ?? 'chrome',
    };
  }
}