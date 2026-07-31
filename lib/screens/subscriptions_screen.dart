import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/theme/app_theme.dart';
import 'package:fl_clash/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  Future<void> _activate(Profile profile) async {
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> _refresh(Profile profile) async {
    try {
      await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile, showLoading: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить: $e')),
      );
    }
  }

  Future<void> _remove(Profile profile) async {
    await ref.read(profilesActionProvider.notifier).deleteProfile(profile.id);
  }

  Future<void> _openYaml(Profile profile) async {
    final path = await appPath.getProfilePath(profile.id.toString());
    final file = File(path);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл профиля ещё не создан')),
      );
      return;
    }
    await launchUrl(Uri.file(path));
  }

  Future<void> _addFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Буфер обмена пуст')),
      );
      return;
    }
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (text.startsWith('http://') || text.startsWith('https://')) {
      await profilesAction.addProfileFormURL(text);
    } else {
      try {
        final profile = await Profile.normal(
          label: 'Буфер обмена',
        ).saveFile(Uint8List.fromList(utf8.encode(text)));
        profilesAction.putProfile(profile);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось добавить: $e')),
        );
      }
    }
  }

  void _showAddMenu() {
    final surfaces = context.surfaces;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        Widget method({
          required IconData icon,
          required String title,
          required String subtitle,
          required VoidCallback onTap,
        }) {
          return ListTile(
            leading: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: surfaces.card2,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, size: 18, color: surfaces.text2),
            ),
            title: Text(title, style: TextStyle(color: surfaces.text1)),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
            ),
            onTap: () {
              Navigator.of(dialogContext).pop();
              onTap();
            },
          );
        }

        return AlertDialog(
          backgroundColor: surfaces.card,
          title: Text(
            'Добавить подписку',
            style: TextStyle(color: surfaces.text1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                method(
                  icon: Icons.link,
                  title: 'Ввести URL вручную',
                  subtitle: 'Ссылка на подписку Remnawave',
                  onTap: () => _showUrlDialog(),
                ),
                method(
                  icon: Icons.content_paste,
                  title: 'Из буфера обмена',
                  subtitle: 'Вставить скопированную ссылку или конфиг',
                  onTap: _addFromClipboard,
                ),
                method(
                  icon: Icons.insert_drive_file_outlined,
                  title: 'Из файла',
                  subtitle: 'Импорт .yaml / .yml / .json',
                  onTap: profilesAction.addProfileFormFile,
                ),
                method(
                  icon: Icons.qr_code_2,
                  title: 'QR-код',
                  subtitle: 'Сканировать камерой',
                  onTap: profilesAction.addProfileFormQrCode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUrlDialog() {
    final surfaces = context.surfaces;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surfaces.card,
          title: Text(
            'Ссылка на подписку',
            style: TextStyle(color: surfaces.text1),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: surfaces.text1),
            decoration: InputDecoration(
              hintText: 'https://sub.remnawave.example.com/...',
              hintStyle: TextStyle(color: surfaces.text3),
              filled: true,
              fillColor: surfaces.card2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              Navigator.of(dialogContext).pop();
              ref
                  .read(profilesActionProvider.notifier)
                  .addProfileFormURL(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final url = controller.text.trim();
                if (url.isEmpty) return;
                Navigator.of(dialogContext).pop();
                ref.read(profilesActionProvider.notifier).addProfileFormURL(url);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final profiles = ref.watch(profilesProvider);
    final currentProfileId = ref.watch(currentProfileIdProvider);

    return Container(
      color: surfaces.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Row(
              children: [
                Text(
                  'Подписки',
                  style: TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w600,
                    color: surfaces.text1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Добавить',
                  icon: const Icon(Icons.add),
                  onPressed: _showAddMenu,
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),
          Expanded(
            child: profiles.isEmpty
                ? Center(
                    child: Text(
                      'Подписок пока нет',
                      style: TextStyle(color: surfaces.text3),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                    children: [
                      for (final profile in profiles) ...[
                        _SubscriptionTile(
                          profile: profile,
                          isActive: currentProfileId == profile.id,
                          onTap: () => _activate(profile),
                          onRefresh: profile.type == ProfileType.url
                              ? () => _refresh(profile)
                              : null,
                          onOpenYaml: () => _openYaml(profile),
                          onDelete: () => _remove(profile),
                        ),
                        const SizedBox(height: AppSpace.s2),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile({
    required this.profile,
    required this.isActive,
    required this.onTap,
    required this.onOpenYaml,
    this.onRefresh,
    this.onDelete,
  });

  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onOpenYaml;
  final VoidCallback? onRefresh;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final updating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final subtitle = profile.type == ProfileType.url
        ? profile.url
        : 'Локальный источник';

    return Material(
      color: isActive ? surfaces.card2 : surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: updating ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isActive ? semantic.on : surfaces.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaces.card2,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(
                  Icons.dns_outlined,
                  size: 16,
                  color: surfaces.text2,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.realLabel,
                      style: TextStyle(
                        color: surfaces.text1,
                        fontSize: AppFontSize.md,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: surfaces.text3,
                        fontSize: AppFontSize.xs,
                      ),
                    ),
                  ],
                ),
              ),
              if (updating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Обновить',
                  onPressed: onRefresh,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.code, size: 18),
                  tooltip: 'Открыть YAML',
                  onPressed: onOpenYaml,
                  visualDensity: VisualDensity.compact,
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: semantic.danger,
                    ),
                    tooltip: 'Удалить',
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
              const SizedBox(width: AppSpace.s2),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? semantic.on : Colors.transparent,
                  border: Border.all(
                    color: isActive ? semantic.on : surfaces.border,
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
