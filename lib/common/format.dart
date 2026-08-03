import '../models/profile.dart';
import 'app_localizations.dart';

String formatSize(int bytes) {
  if (bytes <= 0) return '0 Б';
  final gb = bytes / (1024 * 1024 * 1024);
  if (gb >= 1) return '${gb.toStringAsFixed(1).replaceAll('.', ',')} ГБ';
  final mb = bytes / (1024 * 1024);
  if (mb >= 1) return '${mb.toStringAsFixed(0)} МБ';
  return '${bytes ~/ 1024} КБ';
}

int? subscriptionDaysLeft(SubscriptionInfo? info) {
  if (info == null || info.expire <= 0) return null;
  final secondsLeft =
      info.expire - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  return (secondsLeft / 86400).ceil();
}

String? usageSummary(SubscriptionInfo? info) {
  if (info == null) return null;
  final l = currentAppLocalizations;
  final used = info.upload + info.download;
  if (info.total <= 0) {
    return used > 0 ? l.usedOf(formatSize(used)) : null;
  }
  final left = info.total - used;
  if (left < 0) return l.trafficExhausted;
  final parts = <String>[];
  final daysLeft = subscriptionDaysLeft(info);
  if (daysLeft != null) {
    parts.add(
      daysLeft >= 0 ? l.daysLeftCount(daysLeft) : l.subscriptionExpired,
    );
  }
  parts.add(l.leftOfTotal(formatSize(left), formatSize(info.total)));
  return parts.join(' · ');
}

/// Многострочный тултип для кнопки-спидометра: строка 1 — расход,
/// строка 2 — оставшиеся дни (если подписка с ограничением по времени).
String? usageTooltip(SubscriptionInfo? info) {
  if (info == null) return null;
  final l = currentAppLocalizations;
  final used = info.upload + info.download;
  final parts = <String>[];
  if (info.total > 0 && used > info.total) {
    parts.add(l.trafficExhausted);
  } else if (used > 0) {
    parts.add(
      info.total > 0
          ? l.usedOfTotal(formatSize(used), formatSize(info.total))
          : l.usedOf(formatSize(used)),
    );
  }
  final daysLeft = subscriptionDaysLeft(info);
  if (daysLeft != null) {
    parts.add(
      daysLeft >= 0 ? l.daysLeftCount(daysLeft) : l.subscriptionExpired,
    );
  }
  return parts.isEmpty ? null : parts.join('\n');
}
