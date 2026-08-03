import 'dart:io';

import 'package:bolt/common/common.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/providers.dart';
import 'package:bolt/theme/app_theme.dart';
import 'package:bolt/theme/app_tokens.dart';
import 'package:bolt/widgets/bolt_buttons.dart';
import 'package:bolt/widgets/bolt_icon_button.dart';
import 'package:bolt/widgets/bolt_surfaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigEditorScreen extends ConsumerStatefulWidget {
  const ConfigEditorScreen({super.key, required this.profileId, this.onClose});

  final int profileId;
  final VoidCallback? onClose;

  @override
  ConsumerState<ConfigEditorScreen> createState() => _ConfigEditorScreenState();
}

class _ConfigEditorScreenState extends ConsumerState<ConfigEditorScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = true;
  bool _saving = false;
  bool _focused = false;
  String? _path;

  Profile? get _profile =>
      ref.read(profilesProvider).getProfile(widget.profileId);

  @override
  void initState() {
    super.initState();
    _load();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = _profile;
    if (profile == null) {
      setState(() => _loading = false);
      return;
    }
    final path = await appPath.getProfilePath(profile.id.toString());
    final file = File(path);
    if (await file.exists()) {
      _controller.text = await file.readAsString();
    }
    if (!mounted) return;
    setState(() {
      _path = path;
      _loading = false;
    });
  }

  Future<void> _openExternal() async {
    final path = _path;
    if (path == null) return;
    await launchUrl(Uri.file(path));
  }

  Future<void> _save() async {
    if (_saving) return;
    final profile = _profile;
    if (profile == null) return;
    setState(() => _saving = true);
    try {
      final tempPath = await appPath.tempFilePath;
      final tempFile = File(tempPath);
      await tempFile.safeWriteAsString(_controller.text);
      final updated = await profile.saveFileWithPath(tempPath);
      ref.read(profilesActionProvider.notifier).setProfileAndAutoApply(updated);
      if (!mounted) return;
      showBoltToast(context, context.appLocalizations.configSavedApplied);
    } catch (e) {
      if (!mounted) return;
      showBoltToast(context, context.appLocalizations.saveFailed('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;
    final profile = _profile;
    final ready = !_loading && profile != null;

    return Container(
      color: surfaces.bgSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              AppSpace.s2,
              AppSpace.s4,
              AppSpace.s2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    profile == null
                        ? context.appLocalizations.profileNotFound
                        : profile.realLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: surfaces.text2,
                      fontSize: AppFontSize.sm,
                    ),
                  ),
                ),
                BoltIconButton(
                  tooltip: context.appLocalizations.openExternalEditor,
                  onTap: _path == null ? null : _openExternal,
                  icon: Icons.open_in_new,
                ),
                const SizedBox(width: AppSpace.s2),
                BoltIconButton(
                  tooltip: context.appLocalizations.resetChanges,
                  onTap: _loading ? null : _load,
                  icon: Icons.restart_alt,
                ),
                const SizedBox(width: AppSpace.s2),
                BoltIconButton(
                  tooltip: context.appLocalizations.close,
                  onTap: widget.onClose,
                  icon: Icons.close,
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                ? Center(
                    child: Text(
                      context.appLocalizations.profileNotFound,
                      style: TextStyle(color: surfaces.text3),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s4,
                      0,
                      AppSpace.s4,
                      AppSpace.s4,
                    ),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      curve: AppMotion.ease,
                      decoration: BoxDecoration(
                        color: surfaces.card,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: _focused ? semantic.on : surfaces.border,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        style: TextStyle(
                          color: surfaces.text1,
                          fontSize: AppFontSize.sm,
                          fontFamily: AppTheme.monoFontFamily,
                          height: 1.6,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(AppSpace.s4),
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s4,
              0,
              AppSpace.s4,
              AppSpace.s4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BoltSecondaryButton(
                    label: context.appLocalizations.resetChanges,
                    onTap: _loading ? null : _load,
                    enabled: !_loading,
                  ),
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: BoltPrimaryButton(
                    label: context.appLocalizations.saveAndApply,
                    onTap: ready ? _save : null,
                    enabled: ready && !_saving,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
