import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/theme/app_theme.dart';
import 'package:fl_clash/theme/app_tokens.dart';
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
  bool _loading = true;
  bool _saving = false;
  String? _path;

  Profile? get _profile => ref.read(profilesProvider).getProfile(widget.profileId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Конфиг сохранён и применён')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final profile = _profile;

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
                  profile == null ? 'Редактор конфига' : 'Конфиг: ${profile.realLabel}',
                  style: TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: FontWeight.w600,
                    color: surfaces.text1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Открыть во внешнем редакторе',
                  icon: const Icon(Icons.open_in_new),
                  onPressed: _path == null ? null : _openExternal,
                ),
                IconButton(
                  tooltip: 'Сбросить изменения',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: _loading ? null : _load,
                ),
                FilledButton(
                  onPressed: (_loading || _saving) ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить и применить'),
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                    ? Center(
                        child: Text(
                          'Профиль не найден',
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaces.card,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: surfaces.border),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            expands: true,
                            style: TextStyle(
                              color: surfaces.text1,
                              fontSize: AppFontSize.xs,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(AppSpace.s3),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
