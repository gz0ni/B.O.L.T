import 'dart:convert';
import 'dart:typed_data';

/// Приводит контент подписки к clash-совместимому YAML-конфигу:
/// - уже YAML → возвращается как есть;
/// - base64-строка → декодируется (YAML или список ссылок);
/// - список ссылок (hysteria2://, vless://, vmess://, trojan://, ss://) →
///   конвертируется в полноценный YAML-конфиг с proxies, группами и rules;
/// - непонятный контент → возвращается как есть, ошибку вернёт ядро.
Uint8List convertSubscriptionToConfig(Uint8List bytes) {
  final text = utf8.decode(bytes, allowMalformed: true).trim();
  if (text.isEmpty || _isYamlConfig(text)) return bytes;

  final decoded = _tryDecodeBase64(text);
  if (decoded != null) {
    if (_isYamlConfig(decoded)) {
      return Uint8List.fromList(utf8.encode(decoded));
    }
    final config = _buildConfigFromLinks(decoded);
    if (config != null) return Uint8List.fromList(utf8.encode(config));
    return bytes;
  }

  final config = _buildConfigFromLinks(text);
  if (config != null) return Uint8List.fromList(utf8.encode(config));
  return bytes;
}

bool _isYamlConfig(String text) {
  return text.contains('proxies:') ||
      text.contains('proxy-groups:') ||
      text.contains('mixed-port:') ||
      text.contains('port:') ||
      text.contains('tun:') ||
      text.contains('dns:') ||
      text.contains('rules:');
}

String? _tryDecodeBase64(String text) {
  final normalized = text.replaceAll(RegExp(r'\s'), '');
  if (normalized.length < 20) return null;
  final padding = (4 - normalized.length % 4) % 4;
  final padded = padding == 0
      ? normalized
      : normalized.padRight(normalized.length + padding, '=');
  try {
    return utf8.decode(base64.decode(padded), allowMalformed: true);
  } catch (_) {
    try {
      return utf8.decode(
        base64Url.decode(base64Url.normalize(padded)),
        allowMalformed: true,
      );
    } catch (_) {
      return null;
    }
  }
}

String? _buildConfigFromLinks(String text) {
  final proxies = <Map<String, dynamic>>[];
  for (final line in text.split(RegExp(r'\r?\n'))) {
    final link = line.trim();
    if (link.isEmpty) continue;
    final proxy = _tryParseLink(link);
    if (proxy != null) proxies.add(proxy);
  }
  if (proxies.isEmpty) return null;
  return _buildConfig(proxies);
}

Map<String, dynamic>? _tryParseLink(String link) {
  try {
    final uri = Uri.parse(link);
    switch (uri.scheme) {
      case 'vless':
        return _parseVless(uri);
      case 'vmess':
        return _parseVmess(link);
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

String _name(Uri uri, String fallback) {
  final fragment = uri.fragment;
  return fragment.isNotEmpty ? Uri.decodeComponent(fragment) : fallback;
}

Map<String, dynamic> _parseVless(Uri uri) {
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

Map<String, dynamic>? _parseVmess(String link) {
  final raw = link.substring(link.indexOf('://') + 3);
  final decoded = _tryDecodeBase64(raw);
  if (decoded == null) return null;
  final Object? jsonData;
  try {
    jsonData = json.decode(decoded);
  } catch (_) {
    return null;
  }
  if (jsonData is! Map) return null;
  final data = jsonData.cast<String, dynamic>();
  final net = (data['net'] as String?) ?? 'tcp';
  final map = <String, dynamic>{
    'name': (data['ps'] as String?) ?? 'VMess-${data['add']}',
    'type': 'vmess',
    'server': data['add'] ?? '',
    'port': int.tryParse(data['port']?.toString() ?? '') ?? 443,
    'uuid': data['id'],
    'alterId': int.tryParse(data['aid']?.toString() ?? '') ?? 0,
    'cipher': (data['scy'] as String?) ?? 'auto',
    'udp': true,
    if (net != 'tcp') 'network': net,
    if (data['tls'] == 'tls' || data['tls'] == true) 'tls': true,
    if (data['sni'] != null) 'servername': data['sni'],
    if (data['fp'] != null) 'client-fingerprint': data['fp'],
  };

  if (net == 'ws') {
    map['ws-opts'] = {
      'path': (data['path'] as String?) ?? '/',
      if (data['host'] != null) 'headers': {'Host': data['host']},
    };
  }

  if (net == 'grpc') {
    map['grpc-opts'] = {
      'grpc-service-name': (data['path'] as String?) ?? '',
    };
  }

  return map;
}

Map<String, dynamic> _parseTrojan(Uri uri) {
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

Map<String, dynamic> _parseShadowsocks(Uri uri) {
  String method;
  String password;
  String host;
  int port;

  if (uri.host.isNotEmpty && uri.userInfo.isNotEmpty) {
    final decoded = _tryDecodeBase64(uri.userInfo);
    if (decoded == null) {
      final parts = uri.userInfo.split(':');
      method = parts.first;
      password = parts.sublist(1).join(':');
    } else {
      final parts = decoded.split(':');
      method = parts.first;
      password = parts.sublist(1).join(':');
    }
    host = uri.host;
    port = uri.port;
  } else {
    final decoded = _tryDecodeBase64(uri.host + uri.path) ?? '';
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

Map<String, dynamic> _parseHysteria2(Uri uri) {
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

String _buildConfig(List<Map<String, dynamic>> proxies) {
  final names = proxies.map((p) => p['name'] as String).toList();
  final sb = StringBuffer()
    ..writeln('mixed-port: 7890')
    ..writeln('allow-lan: false')
    ..writeln('mode: rule')
    ..writeln('log-level: info')
    ..writeln('proxies:');
  for (final proxy in proxies) {
    sb.writeln(_proxyToYaml(proxy));
  }
  sb.writeln('proxy-groups:');
  sb.writeln(
    _groupToYaml('🌍 VPN', 'select', names),
  );
  sb.writeln(
    _groupToYaml(
      '⚡️ Fastest',
      'url-test',
      names,
      url: 'http://www.gstatic.com/generate_204',
    ),
  );
  sb.writeln('rules:');
  sb.writeln('  - MATCH,🌍 VPN');
  return sb.toString();
}

String _groupToYaml(String name, String type, List<String> names,
    {String? url}) {
  final sb = StringBuffer()
    ..writeln('  - name: ${_quote(name)}')
    ..writeln('    type: $type');
  if (type == 'url-test') {
    sb.writeln('    url: ${_quote(url ?? 'http://www.gstatic.com/generate_204')}');
    sb.writeln('    interval: 300');
    sb.writeln('    tolerance: 50');
  }
  sb.writeln('    proxies:');
  for (final n in names) {
    sb.writeln('      - ${_quote(n)}');
  }
  return sb.toString();
}

String _proxyToYaml(Map<String, dynamic> proxy) {
  final sb = StringBuffer();
  var first = true;
  for (final entry in proxy.entries) {
    if (!first) sb.writeln();
    sb.write(first ? '  - ' : '    ');
    sb.write('${entry.key}:');
    final value = _yamlValue(entry.value, '      ');
    if (value.isNotEmpty) sb.write(value);
    first = false;
  }
  return sb.toString();
}

String _yamlValue(Object? value, String indent) {
  if (value is String) return ' ${_quote(value)}';
  if (value is num || value is bool) return ' $value';
  if (value is Map) {
    final sb = StringBuffer();
    for (final entry in value.entries) {
      sb.writeln();
      sb.write('$indent${entry.key}:');
      final inner = _yamlValue(entry.value, '$indent  ');
      if (inner.isNotEmpty) sb.write(inner);
    }
    return sb.toString();
  }
  if (value is List) {
    final sb = StringBuffer();
    for (final item in value) {
      sb.writeln();
      final inner = _yamlValue(item, '$indent  ');
      sb.write('$indent- ${inner.isNotEmpty ? inner.trimLeft() : ''}');
    }
    return sb.toString();
  }
  return ' ${_quote(value.toString())}';
}

String _quote(String value) {
  final isSafe = RegExp(r'^[a-zA-Z0-9_\-./+=]+$').hasMatch(value) &&
      !RegExp(r'^-?[0-9]+(\.[0-9]+)?$').hasMatch(value) &&
      value != 'true' &&
      value != 'false' &&
      value != 'null' &&
      value != 'yes' &&
      value != 'no' &&
      value != 'on' &&
      value != 'off';
  if (isSafe) return value;
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}
