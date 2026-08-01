import '../models/profile.dart';

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
  if (info == null || info.total <= 0) return null;
  final used = info.upload + info.download;
  final left = info.total - used;
  if (left < 0) return 'Трафик исчерпан';
  final parts = <String>[];
  final daysLeft = subscriptionDaysLeft(info);
  if (daysLeft != null) {
    parts.add(daysLeft >= 0 ? 'Осталось $daysLeft дн.' : 'Подписка истекла');
  }
  parts.add('${formatSize(left)} из ${formatSize(info.total)}');
  return parts.join(' · ');
}
