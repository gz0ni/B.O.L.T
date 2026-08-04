import 'package:bolt/common/format.dart';
import 'package:bolt/l10n/l10n.dart';
import 'package:bolt/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('ru'));
  });

  group('formatSize', () {
    test('formats gigabytes with comma', () {
      expect(formatSize(12 * 1024 * 1024 * 1024 + 400 * 1024 * 1024), '12,4 ГБ');
    });

    test('formats megabytes', () {
      expect(formatSize(50 * 1024 * 1024), '50 МБ');
    });

    test('formats kilobytes', () {
      expect(formatSize(2048), '2 КБ');
    });

    test('handles zero', () {
      expect(formatSize(0), '0 Б');
    });
  });

  group('usageSummary', () {
    test('returns null without total', () {
      expect(usageSummary(null), isNull);
      expect(usageSummary(const SubscriptionInfo(total: 0)), isNull);
    });

    test('reports used and total', () {
      final info = SubscriptionInfo(
        upload: 1 * 1024 * 1024 * 1024,
        download: 2 * 1024 * 1024 * 1024,
        total: 100 * 1024 * 1024 * 1024,
      );
      final summary = usageSummary(info);
      expect(summary, isNotNull);
      expect(summary, contains('97,0 ГБ из 100,0 ГБ'));
      expect(summary, isNot(contains('Осталось')));
    });

    test('reports days left', () {
      final info = SubscriptionInfo(
        total: 100 * 1024 * 1024 * 1024,
        expire: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 5 * 86400,
      );
      final summary = usageSummary(info);
      expect(summary, contains('Осталось 5 дн.'));
    });

    test('reports expired subscription', () {
      final info = SubscriptionInfo(
        total: 100 * 1024 * 1024 * 1024,
        expire: 1000,
      );
      final summary = usageSummary(info);
      expect(summary, contains('Подписка истекла'));
    });

    test('reports exhausted traffic', () {
      final info = SubscriptionInfo(
        upload: 60 * 1024 * 1024 * 1024,
        download: 60 * 1024 * 1024 * 1024,
        total: 100 * 1024 * 1024 * 1024,
      );
      expect(usageSummary(info), 'Трафик исчерпан');
    });
  });

  group('subscriptionDaysLeft', () {
    test('returns null without expiry', () {
      expect(subscriptionDaysLeft(null), isNull);
      expect(subscriptionDaysLeft(const SubscriptionInfo(expire: 0)), isNull);
    });

    test('computes days left', () {
      final info = SubscriptionInfo(
        expire: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2 * 86400,
      );
      expect(subscriptionDaysLeft(info), 2);
    });
  });
}
