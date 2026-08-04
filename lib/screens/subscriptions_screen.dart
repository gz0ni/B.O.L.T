import 'config_editor_screen.dart';
import 'package:bolt/common/common.dart';
import 'package:bolt/common/format.dart';
import 'package:bolt/database/database.dart';
import 'package:bolt/enum/enum.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/providers.dart';
import 'package:bolt/theme/app_theme.dart';
import 'package:bolt/theme/app_tokens.dart';
import 'package:bolt/widgets/bolt_buttons.dart';
import 'package:bolt/widgets/bolt_controls.dart';
import 'package:bolt/widgets/bolt_icon_button.dart';
import 'package:bolt/widgets/bolt_list.dart';
import 'package:bolt/widgets/bolt_surfaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ключи managed-профиля из БД (profile_keys);
/// null — профиль не хранит сырые ключи.
final managedKeysProvider = FutureProvider.family<List<String>?, int>((
  ref,
  profileId,
) async {
  final keys = await database.profileKeysDao.keysFor(profileId);
  return keys.isEmpty ? null : keys;
});

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({
    super.key,
    this.onClose,
    this.autoOpenAdd = false,
  });

  final VoidCallback? onClose;
  final bool autoOpenAdd;

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _updatingAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoOpenAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAddMenu();
      });
    }
  }

  Future<void> _updateAll() async {
    if (_updatingAll) return;
    setState(() => _updatingAll = true);
    try {
      await ref.read(profilesActionProvider.notifier).updateProfiles();
    } catch (e) {
      if (!mounted) return;
      showBoltToast(context, context.appLocalizations.updateFailed('$e'));
    } finally {
      if (mounted) setState(() => _updatingAll = false);
    }
  }

  void _openEditor(Profile profile) {
    showBoltSheet<void>(
      context,
      title: context.appLocalizations.configuration,
      heightFactor: 0.9,
      builder: (sheetContext) => ConfigEditorScreen(
        profileId: profile.id,
        onClose: () => Navigator.of(sheetContext).pop(),
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
      showBoltToast(context, context.appLocalizations.updateFailed('$e'));
    }
  }

  Future<void> _remove(Profile profile) async {
    await ref.read(profilesActionProvider.notifier).deleteProfile(profile.id);
  }

  void _showProfileMenu(Profile profile) {
    showBoltDialog<void>(
      context,
      title: profile.realLabel,
      content: Consumer(
        builder: (context, consumerRef, _) {
          final profiles = consumerRef.watch(profilesProvider);
          final index = profiles.indexWhere((p) => p.id == profile.id);
          if (index == -1) return const SizedBox.shrink();
          final current = profiles[index];
          final profilesAction = consumerRef.read(
            profilesActionProvider.notifier,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (current.subscriptionInfo != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.appLocalizations.trafficUsage,
                        style: TextStyle(
                          color: context.surfaces.text1,
                          fontSize: AppFontSize.md,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        usageSummary(current.subscriptionInfo) ?? '—',
                        style: TextStyle(
                          color: context.surfaces.text3,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (current.type == ProfileType.url) ...[
                _MethodRow(
                  icon: Icons.autorenew,
                  label: context.appLocalizations.autoUpdate,
                  description: current.autoUpdate
                      ? context.appLocalizations.backgroundUpdate(
                          _intervalLabel(current.autoUpdateDuration),
                        )
                      : context.appLocalizations.manualUpdate,
                  onTap: () {},
                  trailing: BoltSwitch(
                    value: current.autoUpdate,
                    onChanged: (value) =>
                        profilesAction.setProfileAutoUpdate(current, value),
                  ),
                ),
                _MethodRow(
                  icon: Icons.schedule,
                  label: context.appLocalizations.updateIntervalTitle,
                  description: _intervalLabel(current.autoUpdateDuration),
                  onTap: () => _showIntervalDialog(current),
                ),
              ],
              _MethodRow(
                icon: Icons.edit_outlined,
                label: context.appLocalizations.rename,
                description: context.appLocalizations.renameDesc,
                onTap: () {
                  Navigator.of(context).pop();
                  _showRenameDialog(profile);
                },
              ),
              _MethodRow(
                icon: Icons.delete_outline,
                label: context.appLocalizations.delete,
                description: context.appLocalizations.deleteSubDesc,
                danger: true,
                onTap: () {
                  Navigator.of(context).pop();
                  _remove(profile);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _intervalLabel(Duration duration) {
    final l = context.appLocalizations;
    if (duration.inMinutes == 30) return l.minutes30;
    if (duration.inHours == 1) return l.hour1;
    if (duration.inHours == 6) return l.hour6;
    if (duration.inHours == 12) return l.hour12;
    if (duration.inDays == 1) return l.days1;
    if (duration.inDays == 3) return l.days3;
    if (duration.inDays == 7) return l.days7;
    if (duration.inDays > 1) return l.daysCountLs(duration.inDays);
    if (duration.inHours > 1) return l.hoursCount(duration.inHours);
    return l.minutesCountLs(duration.inMinutes);
  }

  void _showIntervalDialog(Profile profile) {
    Navigator.of(context).pop();
    final l = context.appLocalizations;
    final presets = <(Duration, String)>[
      (const Duration(minutes: 30), l.minutes30),
      (const Duration(hours: 1), l.hour1),
      (const Duration(hours: 6), l.hour6),
      (const Duration(hours: 12), l.hour12),
      (const Duration(days: 1), l.days1),
      (const Duration(days: 3), l.days3),
      (const Duration(days: 7), l.days7),
    ];
    showBoltDialog<void>(
      context,
      title: l.updateIntervalTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (duration, label) in presets)
            _MethodRow(
              icon: duration == profile.autoUpdateDuration
                  ? Icons.check_circle
                  : Icons.schedule,
              label: label,
              description: duration == profile.autoUpdateDuration
                  ? l.currentInterval
                  : l.autoUpdateEvery(label),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(profilesActionProvider.notifier)
                    .setProfileAutoUpdateDuration(profile, duration);
              },
            ),
        ],
      ),
    );
  }

  void _showRenameDialog(Profile profile) {
    final l = context.appLocalizations;
    final controller = TextEditingController(text: profile.realLabel);
    showBoltDialog<void>(
      context,
      title: l.renameSubscription,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BoltTextField(
            controller: controller,
            autofocus: true,
            hint: l.name,
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              Navigator.of(context).pop();
              ref
                  .read(profilesActionProvider.notifier)
                  .renameProfile(profile, value.trim());
            },
          ),
        ],
      ),
      actions: [
        BoltSecondaryButton(
          label: l.cancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        BoltPrimaryButton(
          label: l.rename,
          onTap: () {
            final label = controller.text.trim();
            if (label.isEmpty) return;
            Navigator.of(context).pop();
            ref
                .read(profilesActionProvider.notifier)
                .renameProfile(profile, label);
          },
        ),
      ],
    );
  }

  Future<void> _addFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      if (!mounted) return;
      showBoltToast(context, context.appLocalizations.clipboardEmpty);
      return;
    }
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (text.startsWith('http://') || text.startsWith('https://')) {
      await profilesAction.addProfileFormURL(text);
    } else {
      try {
        await profilesAction.addProfileFromText(text);
      } catch (e) {
        if (!mounted) return;
        showBoltToast(context, context.appLocalizations.addFailed('$e'));
      }
    }
  }

  void _showAddMenu() {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final l = context.appLocalizations;
    showBoltDialog<void>(
      context,
      title: l.addSubscription,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MethodRow(
            icon: Icons.link,
            label: l.enterUrlManually,
            description: l.remnawaveSubscriptionLink,
            onTap: () {
              Navigator.of(context).pop();
              _showUrlDialog();
            },
          ),
          _MethodRow(
            icon: Icons.key,
            label: l.rawKey,
            description: l.rawKeyHint,
            onTap: () {
              Navigator.of(context).pop();
              _showRawKeyDialog();
            },
          ),
          _MethodRow(
            icon: Icons.content_paste,
            label: l.fromClipboard,
            description: l.fromClipboardDesc,
            onTap: () {
              Navigator.of(context).pop();
              _addFromClipboard();
            },
          ),
          _MethodRow(
            icon: Icons.insert_drive_file_outlined,
            label: l.fromFile,
            description: l.fromFileDesc,
            onTap: () {
              Navigator.of(context).pop();
              profilesAction.addProfileFormFile();
            },
          ),
          _MethodRow(
            icon: Icons.qr_code_2,
            label: l.qrcode,
            description: system.isAndroid ? l.scanQrCode : l.pickQrImageDesc,
            onTap: () {
              Navigator.of(context).pop();
              profilesAction.addProfileFormQrCode();
            },
          ),
        ],
      ),
    );
  }

  void _showUrlDialog() {
    final l = context.appLocalizations;
    final controller = TextEditingController();
    showBoltDialog<void>(
      context,
      title: l.remnawaveSubscriptionLink,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BoltTextField(
            controller: controller,
            autofocus: true,
            hint: 'https://sub.remnawave.example.com/...',
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              Navigator.of(context).pop();
              ref
                  .read(profilesActionProvider.notifier)
                  .addProfileFormURL(value.trim());
            },
          ),
        ],
      ),
      actions: [
        BoltSecondaryButton(
          label: l.cancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        BoltPrimaryButton(
          label: l.add,
          onTap: () {
            final url = controller.text.trim();
            if (url.isEmpty) return;
            Navigator.of(context).pop();
            ref.read(profilesActionProvider.notifier).addProfileFormURL(url);
          },
        ),
      ],
    );
  }

  void _showRawKeyDialog() {
    final l = context.appLocalizations;
    final controller = TextEditingController();
    showBoltDialog<void>(
      context,
      title: l.rawKey,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BoltTextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
            hint: 'hysteria2://...\nvless://...\ntrojan://...',
            fontFamily: AppTheme.monoFontFamily,
            onSubmitted: (_) {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(context).pop();
              ref
                  .read(profilesActionProvider.notifier)
                  .addProfileFromText(text);
            },
          ),
          Text(
            l.rawKeyHint,
            style: TextStyle(
              color: context.surfaces.text3,
              fontSize: AppFontSize.xs,
            ),
          ),
        ],
      ),
      actions: [
        BoltSecondaryButton(
          label: l.cancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        BoltPrimaryButton(
          label: l.add,
          onTap: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(context).pop();
            ref.read(profilesActionProvider.notifier).addProfileFromText(text);
          },
        ),
      ],
    );
  }

  Future<void> _showKeysDialog(Profile profile) async {
    final controller = TextEditingController();
    final listController = ScrollController();
    Future<void> addKeys(BuildContext dialogContext) async {
      final links = controller.text
          .split(RegExp(r'\r?\n'))
          .map((link) => link.trim())
          .where((link) => link.isNotEmpty)
          .toList();
      if (links.isEmpty) {
        if (!dialogContext.mounted) return;
        showBoltToast(dialogContext, dialogContext.appLocalizations.enterKey);
        return;
      }
      try {
        await ref
            .read(profilesActionProvider.notifier)
            .addKeysToProfile(profile, links);
        if (!dialogContext.mounted) return;
        controller.clear();
        showBoltToast(
          dialogContext,
          dialogContext.appLocalizations.keysAdded(links.length),
        );
        ref.invalidate(managedKeysProvider(profile.id));
        await ref.read(managedKeysProvider(profile.id).future);
        if (!dialogContext.mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!listController.hasClients) return;
          listController.animateTo(
            listController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        if (!dialogContext.mounted) return;
        showBoltToast(
          dialogContext,
          dialogContext.appLocalizations.addFailed('$e'),
        );
      }
    }

    Future<void> removeKey(BuildContext dialogContext, String link) async {
      try {
        final deleted = await ref
            .read(profilesActionProvider.notifier)
            .deleteKeyFromProfile(profile, link);
        if (!dialogContext.mounted) return;
        if (deleted) {
          Navigator.of(dialogContext).pop();
          return;
        }
        ref.invalidate(managedKeysProvider(profile.id));
      } catch (e) {
        if (!dialogContext.mounted) return;
        showBoltToast(
          dialogContext,
          dialogContext.appLocalizations.deleteFailed('$e'),
        );
      }
    }

    showBoltDialog<void>(
      context,
      title: context.appLocalizations.keysTitle(profile.realLabel),
      content: SizedBox(
        width: 440,
        child: Consumer(
          builder: (context, consumerRef, _) {
            final keysAsync = consumerRef.watch(
              managedKeysProvider(profile.id),
            );
            final keys = keysAsync.value ?? const <String>[];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (keysAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpace.s3),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (keys.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpace.s3),
                    child: Text(
                      context.appLocalizations.noKeys,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.surfaces.text3),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView(
                      controller: listController,
                      shrinkWrap: true,
                      children: [
                        for (final key in keys)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const BoltPillIcon(icon: Icons.key),
                                const SizedBox(width: AppSpace.s3),
                                Expanded(
                                  child: Text(
                                    key,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.surfaces.text1,
                                      fontFamily: AppTheme.monoFontFamily,
                                      fontSize: AppFontSize.xs,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpace.s2),
                                BoltIconButton(
                                  tooltip: context.appLocalizations.deleteKey,
                                  color: context.semanticColors.danger,
                                  danger: true,
                                  onTap: () => removeKey(context, key),
                                  icon: Icons.delete_outline,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpace.s3),
                BoltTextField(
                  controller: controller,
                  maxLines: 3,
                  hint: context.appLocalizations.enterKeyHint,
                  fontFamily: AppTheme.monoFontFamily,
                  onSubmitted: (_) => addKeys(context),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        BoltSecondaryButton(
          label: context.appLocalizations.close,
          onTap: () => Navigator.of(context).pop(),
        ),
        BoltPrimaryButton(
          label: context.appLocalizations.addKey,
          onTap: () => addKeys(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final profiles = ref.watch(profilesProvider);
    final currentProfileId = ref.watch(currentProfileIdProvider);
    final hasUpdatable = profiles.any((p) => p.type == ProfileType.url);

    return Container(
      color: surfaces.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              AppSpace.s3,
              AppSpace.s4,
              AppSpace.s3,
            ),
            child: Row(
              children: [
                Text(
                  context.appLocalizations.subscriptions,
                  style: TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w500,
                    color: surfaces.text1,
                    fontFamily: AppFontFamily.display,
                  ),
                ),
                const Spacer(),
                if (_updatingAll)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: surfaces.card,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: surfaces.border),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (hasUpdatable)
                  BoltIconButton(
                    tooltip: context.appLocalizations.updateAllSubs,
                    onTap: _updateAll,
                    icon: Icons.refresh,
                  ),
                const SizedBox(width: AppSpace.s2),
                BoltIconButton(
                  tooltip: context.appLocalizations.add,
                  onTap: _showAddMenu,
                  icon: Icons.add,
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: AppSpace.s2),
                  BoltIconButton(
                    tooltip: context.appLocalizations.close,
                    onTap: widget.onClose,
                    icon: Icons.close,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: profiles.isEmpty
                ? Center(
                    child: Text(
                      context.appLocalizations.noSubscriptions,
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
                            onSecondaryTap: () => _showProfileMenu(profile),
                            onRefresh: profile.type == ProfileType.url
                                ? () => _refresh(profile)
                                : null,
                            onEdit: () => _openEditor(profile),
                            onDelete: () => _remove(profile),
                            onManageKeys: () => _showKeysDialog(profile),
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
    this.onSecondaryTap,
    this.onRefresh,
    this.onEdit,
    this.onDelete,
    this.onManageKeys,
  });

  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onManageKeys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final updating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final keys = ref.watch(managedKeysProvider(profile.id));
    final subtitle = profile.type == ProfileType.url
        ? profile.url
        : (keys.value != null
              ? context.appLocalizations.keysCount(keys.value!.length)
              : context.appLocalizations.localSource);
    final info = profile.subscriptionInfo;
    final used = info == null ? 0 : info.upload + info.download;

    return Material(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: updating ? null : onTap,
        onSecondaryTap: updating ? null : onSecondaryTap,
        onLongPress: updating ? null : onSecondaryTap,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: surfaces.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.dns_outlined, size: 18, color: surfaces.text2),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.realLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: surfaces.text1,
                                  fontSize: AppFontSize.md,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: surfaces.text2,
                            fontSize: AppFontSize.sm,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          usageSummary(info) ??
                              context.appLocalizations.noTrafficData,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive ? semantic.on : surfaces.text3,
                            fontSize: AppFontSize.xs,
                            fontWeight: FontWeight.w500,
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
                    if (onRefresh != null) ...[
                      const SizedBox(width: AppSpace.s2),
                      BoltIconButton(
                        tooltip: context.appLocalizations.refresh,
                        onTap: onRefresh,
                        icon: Icons.refresh,
                      ),
                    ],
                    if (onEdit != null) ...[
                      const SizedBox(width: AppSpace.s2),
                      BoltIconButton(
                        tooltip: context.appLocalizations.editConfig,
                        onTap: onEdit,
                        icon: Icons.edit,
                      ),
                    ],
                    if (profile.type == ProfileType.file &&
                        keys.value != null &&
                        onManageKeys != null) ...[
                      const SizedBox(width: AppSpace.s2),
                      BoltIconButton(
                        tooltip: context.appLocalizations.keysList,
                        onTap: onManageKeys,
                        icon: Icons.key,
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: AppSpace.s2),
                      BoltIconButton(
                        tooltip: context.appLocalizations.delete,
                        color: semantic.danger,
                        danger: true,
                        onTap: onDelete,
                        icon: Icons.delete_outline,
                      ),
                    ],
                  ],
                  const SizedBox(width: AppSpace.s2),
                  BoltCheck(active: isActive),
                ],
              ),
            ),
            if (info != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: info.total > 0 ? (used / info.total).clamp(0, 1) : 1.0,
                  minHeight: 2,
                  backgroundColor: surfaces.borderSoft,
                  valueColor: AlwaysStoppedAnimation(semantic.on),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.danger = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool danger;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final color = danger ? semantic.danger : surfaces.text1;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: surfaces.border),
        ),
        child: Row(
          children: [
            BoltPillIcon(icon: icon, size: 34),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: AppFontSize.md,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: surfaces.text3, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, size: 16, color: surfaces.text3),
          ],
        ),
      ),
    );
  }
}
