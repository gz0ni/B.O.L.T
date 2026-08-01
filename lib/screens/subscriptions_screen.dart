import 'dart:convert';

import 'config_editor_screen.dart';
import 'package:fl_clash/common/format.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/theme/app_theme.dart';
import 'package:fl_clash/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _updatingAll = false;

  Future<void> _updateAll() async {
    if (_updatingAll) return;
    setState(() => _updatingAll = true);
    try {
      await ref.read(profilesActionProvider.notifier).updateProfiles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingAll = false);
    }
  }

  void _openEditor(Profile profile) {
    final surfaces = context.surfaces;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaces.card,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      barrierColor: Colors.black54,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 1,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: surfaces.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ConfigEditorScreen(
                profileId: profile.id,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  void _showProfileMenu(Profile profile) {
    final surfaces = context.surfaces;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surfaces.card,
          title: Text(
            profile.realLabel,
            style: TextStyle(color: surfaces.text1),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: surfaces.text2),
                title: Text(
                  'Переименовать',
                  style: TextStyle(color: surfaces.text1),
                ),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _showRenameDialog(profile);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: context.semanticColors.danger),
                title: Text(
                  'Удалить',
                  style: TextStyle(color: context.semanticColors.danger),
                ),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _remove(profile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(Profile profile) {
    final surfaces = context.surfaces;
    final controller = TextEditingController(text: profile.realLabel);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surfaces.card,
          title: Text(
            'Переименовать подписку',
            style: TextStyle(color: surfaces.text1),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: surfaces.text1),
            decoration: InputDecoration(
              hintText: 'Название',
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
                  .renameProfile(profile, value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final label = controller.text.trim();
                if (label.isEmpty) return;
                Navigator.of(dialogContext).pop();
                ref
                    .read(profilesActionProvider.notifier)
                    .renameProfile(profile, label);
              },
              child: const Text('Переименовать'),
            ),
          ],
        );
      },
    );
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
                  icon: Icons.key,
                  title: 'Сырой ключ',
                  subtitle: 'vless:// trojan:// ss:// — свои ключи',
                  onTap: () => _showRawKeyDialog(),
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

  void _showRawKeyDialog() {
    final surfaces = context.surfaces;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          final text = controller.text.trim();
          if (text.isEmpty) return;
          Navigator.of(dialogContext).pop();
          ref
              .read(profilesActionProvider.notifier)
              .addProfileFromText(text);
        }

        return AlertDialog(
          backgroundColor: surfaces.card,
          title: Text(
            'Сырой ключ',
            style: TextStyle(color: surfaces.text1),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 5,
                style: TextStyle(color: surfaces.text1),
                decoration: InputDecoration(
                  hintText: 'hysteria2://...\nvless://...\ntrojan://...',
                  hintStyle: TextStyle(color: surfaces.text3),
                  filled: true,
                  fillColor: surfaces.card2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: AppSpace.s2),
              Text(
                'vless:// trojan:// ss:// — свои ключи',
                style: TextStyle(
                  color: surfaces.text3,
                  fontSize: AppFontSize.xs,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: submit,
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
                _SquareIconButton(
                  tooltip: 'Обновить все подписки',
                  onPressed: _updatingAll ? null : _updateAll,
                  child: _updatingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 18),
                ),
                const SizedBox(width: AppSpace.s2),
                _SquareIconButton(
                  tooltip: 'Добавить',
                  onPressed: _showAddMenu,
                  child: const Icon(Icons.add, size: 18),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: AppSpace.s2),
                  _SquareIconButton(
                    tooltip: 'Закрыть',
                    onPressed: widget.onClose,
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
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
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s4,
                      ),
                      children: [
                        for (final profile in profiles) ...[
                          _SubscriptionTile(
                            profile: profile,
                            isActive: currentProfileId == profile.id,
                            onTap: () => _activate(profile),
                            onLongPress: () => _showProfileMenu(profile),
                            onRefresh: profile.type == ProfileType.url
                                ? () => _refresh(profile)
                                : null,
                            onEdit: () => _openEditor(profile),
                            onDelete: () => _remove(profile),
                          ),
                          const SizedBox(height: AppSpace.s2),
                        ],
                      ],
                    ),
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
    this.onLongPress,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
  });

  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRefresh;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final updating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final subtitle = profile.type == ProfileType.url
        ? profile.url
        : 'Локальный источник';
    final usage = usageSummary(profile.subscriptionInfo);

    return Material(
      color: isActive ? surfaces.card2 : surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: updating ? null : onTap,
        onLongPress: updating ? null : onLongPress,
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
                    if (usage != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        usage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: semantic.on,
                          fontSize: AppFontSize.xs,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                _SquareIconButton(
                  tooltip: 'Обновить',
                  size: 28,
                  onPressed: onRefresh,
                  child: const Icon(Icons.refresh, size: 15),
                ),
                const SizedBox(width: AppSpace.s1),
                if (onEdit != null)
                  _SquareIconButton(
                    tooltip: 'Редактировать конфиг',
                    size: 28,
                    onPressed: onEdit,
                    child: const Icon(Icons.edit, size: 15),
                  ),
                const SizedBox(width: AppSpace.s1),
                if (onDelete != null)
                  _SquareIconButton(
                    tooltip: 'Удалить',
                    size: 28,
                    onPressed: onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: semantic.danger,
                    ),
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

class _SquareIconButton extends StatefulWidget {
  const _SquareIconButton({
    required this.onPressed,
    required this.tooltip,
    required this.child,
    this.size = 32,
  });

  final VoidCallback? onPressed;
  final String tooltip;
  final Widget child;
  final double size;

  @override
  State<_SquareIconButton> createState() => _SquareIconButtonState();
}

class _SquareIconButtonState extends State<_SquareIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final enabled = widget.onPressed != null;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: _hovered && enabled ? surfaces.card2 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            onTap: widget.onPressed,
            child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(
                  color: enabled
                      ? surfaces.border
                      : surfaces.border.withValues(alpha: 0.4),
                ),
              ),
              child: Opacity(
                opacity: enabled ? 1 : 0.4,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
