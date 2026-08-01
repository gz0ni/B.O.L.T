import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/subscription_converter.dart';
import 'package:test/test.dart';

void main() {
  Uint8List bytes(String text) => Uint8List.fromList(utf8.encode(text));

  String? configFrom(String text) {
    final result = convertSubscriptionToConfig(bytes(text));
    return utf8.decode(result);
  }

  group('convertSubscriptionToConfig', () {
    test('returns yaml config unchanged', () {
      const yaml = 'mixed-port: 7890\nproxies:\n  - name: test\n';
      expect(configFrom(yaml), yaml);
    });

    test('converts hysteria2 links to yaml config', () {
      const link =
          'hysteria2://pass@example.com:443?sni=example.com&alpn=h3#My Node';
      final config = configFrom(link);
      expect(config, contains('proxies:'));
      expect(config, contains('type: hysteria2'));
      expect(config, contains('server: example.com'));
      expect(config, contains('password: pass'));
      expect(config, contains('name: "My Node"'));
      expect(config, contains('proxy-groups:'));
      expect(config, contains('name: "🌍 VPN"'));
      expect(config, contains('name: "⚡️ Fastest"'));
      expect(config, contains('rules:'));
      expect(config, contains('MATCH,🌍 VPN'));
    });

    test('converts base64 subscription of hysteria2 links', () {
      const link = 'hysteria2://pass@example.com:443?sni=example.com#Node1';
      final encoded = base64.encode(utf8.encode('$link\n$link'));
      final config = configFrom(encoded);
      expect(config, contains('type: hysteria2'));
      expect(config, contains('name: Node1'));
    });

    test('converts base64 without padding', () {
      const link = 'hysteria2://pass@example.com:443?sni=example.com#Node1';
      final encoded = base64.encode(utf8.encode(link)).replaceAll('=', '');
      final config = configFrom(encoded);
      expect(config, contains('type: hysteria2'));
    });

    test('converts plain vless, trojan and ss links', () {
      const links = '''
vless://uuid@server.com:443?security=tls&sni=server.com&type=tcp#VL
trojan://pass@trojan.com:443?sni=trojan.com#TR
ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@ss.com:8388#SS
''';
      final config = configFrom(links);
      expect(config, contains('type: vless'));
      expect(config, contains('type: trojan'));
      expect(config, contains('type: ss'));
      expect(config, contains('name: VL'));
      expect(config, contains('name: TR'));
      expect(config, contains('name: SS'));
    });

    test('converts vmess base64 link', () {
      final vmessPayload = base64.encode(
        utf8.encode(json.encode({
          'v': '2',
          'ps': 'VM',
          'add': 'vmess.com',
          'port': '443',
          'id': 'uuid-123',
          'aid': '0',
          'scy': 'auto',
          'net': 'ws',
          'host': 'vmess.com',
          'path': '/ws',
          'tls': 'tls',
        })),
      );
      final config = configFrom('vmess://$vmessPayload');
      expect(config, contains('type: vmess'));
      expect(config, contains('server: vmess.com'));
      expect(config, contains('uuid: uuid-123'));
      expect(config, contains('network: ws'));
      expect(config, contains('name: VM'));
    });

    test('decodes base64 yaml subscription', () {
      const yaml = 'mixed-port: 7890\nproxies:\n  - name: test\n';
      final encoded = base64.encode(utf8.encode(yaml));
      expect(configFrom(encoded), yaml);
    });

    test('returns garbage unchanged', () {
      const garbage = 'not a subscription !!!';
      expect(configFrom(garbage), garbage);
    });

    test('returns empty text unchanged', () {
      expect(configFrom(''), '');
    });
  });
}
