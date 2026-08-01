import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/common/subscription_converter.dart';
import 'package:test/test.dart';

void main() {
  Uint8List bytes(String text) => Uint8List.fromList(utf8.encode(text));

  String? configFrom(String text) {
    final result = convertSubscriptionToConfig(bytes(text));
    return utf8.decode(result);
  }

  Uint8List fixture(String name) =>
      File('test/common/fixtures/$name').readAsBytesSync();

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
      expect(config, contains('name: VPN'));
      expect(config, contains('rules:'));
      expect(config, contains('MATCH,VPN'));
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

    test('passes real skill-up yaml config unchanged', () {
      final source = fixture('skill_up.yaml');
      expect(convertSubscriptionToConfig(source), source);
    });

    test('passes second provider yaml config unchanged', () {
      final source = fixture('second_provider.yaml');
      expect(convertSubscriptionToConfig(source), source);
    });

    test('decodes base64 of real skill-up config to exact yaml', () {
      final source = fixture('skill_up.yaml');
      final encoded = base64.encode(source);
      expect(convertSubscriptionToConfig(bytes(encoded)), source);
    });

    test('generated config from real user keys is minimal', () {
      const links = '''
hysteria2://130701a5-b228-436c-b601-9b015cea686e@de01.skill-up.store:443/?sni=de01.skill-up.store&fm=%7B%22quicParams%22%3A%7B%22debug%22%3Afalse%2C%22congestion%22%3A%22bbr%22%7D%7D#Germany01-Hysteria2
trojan://uK1Vp-86J8VGb2hR6wA3Q@de03.skill-up.store:443?type=ws&path=%2Fws&security=tls&sni=de03.skill-up.store&fp=chrome#Germany03-Trojan
vless://130701a5-b228-436c-b601-9b015cea686e@de02.skill-up.store:443?encryption=none&flow=xtls-rprx-vision&type=tcp&security=reality&sni=videolink.okcdn.ru&fp=chrome&pbk=xgKrIKkuicarolThzm4nDv8-H20AgwWQfItV9HqmMik#Germani02-Vless
''';
      final config = configFrom(links)!;
      expect(config, contains('proxies:'));
      expect(config, contains('name: Germany01-Hysteria2'));
      expect(config, contains('name: Germany03-Trojan'));
      expect(config, contains('name: Germani02-Vless'));
      expect(config, contains('type: hysteria2'));
      expect(config, contains('type: trojan'));
      expect(config, contains('type: vless'));
      expect(config, contains('name: VPN'));
      expect(config, contains('MATCH,VPN'));
      expect(config, isNot(contains('🌍')));
      expect(config, isNot(contains('⚡️')));
      expect(config, isNot(contains('url-test')));
      expect(config, isNot(contains('generate_204')));
      expect(config, isNot(contains('interval')));
      expect(config, isNot(contains('tolerance')));
      expect(config, isNot(contains('REJECT')));
      expect(config, isNot(contains(',DIRECT')));
      expect(config, isNot(contains('GEOIP')));
      expect(config, isNot(contains('GEOSITE')));
      expect(config, isNot(contains('fake-ip')));
      expect(config, isNot(contains('dns:')));
    });

    test('generated config adds no provider rules or dns', () {
      const links = '''
hysteria2://pass@example.com:443?sni=example.com#Node1
vless://uuid@server.com:443?security=reality&type=tcp&sni=servername.com&pbk=public-key-here&sid=#Node2
trojan://trojan-pass@trojan.com:443?sni=trojan.com&type=ws&path=%2Fws#Node3
''';
      final config = configFrom(links)!;
      expect(config, contains('MATCH,VPN'));
      expect(config, isNot(contains('REJECT')));
      expect(config, isNot(contains(',DIRECT')));
      expect(config, isNot(contains('GEOIP')));
      expect(config, isNot(contains('GEOSITE')));
      expect(config, isNot(contains('fake-ip')));
      expect(config, isNot(contains('dns:')));
    });
  });

  group('managed keys config', () {
    const link1 = 'hysteria2://pass@example.com:443?sni=example.com#Node1';
    const link2 = 'vless://uuid@server.com:443?security=tls&type=tcp#Node2';

    test('generated config has marker header', () {
      final config = configFrom('$link1\n$link2')!;
      expect(config, startsWith(boltManagedKeysHeader));
      expect(config, contains('\n# $link1\n'));
      expect(config, contains('\n# $link2\n'));
    });

    test('base64 links also get marker and keys', () {
      final encoded = base64.encode(utf8.encode('$link1\n$link2'));
      final config = configFrom(encoded)!;
      expect(config, startsWith(boltManagedKeysHeader));
      expect(extractManagedKeys(config), [link1, link2]);
    });

    test('isManagedKeysConfig only true with marker', () {
      expect(
        isManagedKeysConfig('$boltManagedKeysHeader\n# x\nmixed-port: 7890'),
        isTrue,
      );
      expect(isManagedKeysConfig('mixed-port: 7890\nproxies:\n'), isFalse);
      expect(isManagedKeysConfig(''), isFalse);
    });

    test('yaml passthrough has no marker', () {
      const yaml = 'mixed-port: 7890\nproxies:\n  - name: test\n';
      expect(isManagedKeysConfig(configFrom(yaml)!), isFalse);
      expect(extractManagedKeys(yaml), isNull);
    });

    test('extractManagedKeys round-trips through buildConfigFromKeys', () {
      final config = configFrom('$link1\n$link2')!;
      final keys = extractManagedKeys(config);
      expect(keys, [link1, link2]);
      expect(buildConfigFromKeys(keys!), config);
    });

    test('buildConfigFromKeys skips unparsable keys', () {
      final rebuilt = buildConfigFromKeys([link1, 'not a link'])!;
      expect(extractManagedKeys(rebuilt), [link1]);
    });

    test('buildConfigFromKeys returns null for garbage', () {
      expect(buildConfigFromKeys(['not a link']), isNull);
    });
  });

  group('unsupportedKeyLinks', () {
    const link1 = 'hysteria2://pass@example.com:443?sni=example.com#Node1';
    const link2 = 'vless://uuid@server.com:443?security=tls&type=tcp#Node2';

    test('empty for supported links', () {
      expect(
        unsupportedKeyLinks([
          link1,
          link2,
          'trojan://pass@trojan.com:443?sni=trojan.com#TR',
          'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@ss.com:8388#SS',
        ]),
        isEmpty,
      );
    });

    test('finds unsupported schemes and garbage', () {
      expect(
        unsupportedKeyLinks([link1, 'tuic://uuid@host.com:443', 'garbage']),
        ['tuic://uuid@host.com:443', 'garbage'],
      );
    });

    test('trims whitespace before checking', () {
      expect(unsupportedKeyLinks(['  $link1\n']), isEmpty);
      expect(unsupportedKeyLinks(['  tuic://host.com:443  ']),
          ['tuic://host.com:443']);
    });
  });
}
