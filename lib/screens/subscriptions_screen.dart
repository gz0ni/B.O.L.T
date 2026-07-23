import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/subscriptions_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key, required this.service, this.onClose, this.onActivated});

  final SubscriptionsService service;
  final VoidCallback? onClose;
  final VoidCallback? onActivated; // сообщить наружу, что активный профиль сменился (обновить локации/статус)

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Material(
      color: surfaces.card2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        side: BorderSide(color: surfaces.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s2),
          child: Icon(icon, size: 18, color: surfaces.text2),
        ),
      ),
    );
  }
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> _subs = [];
  String? _activeId;
  bool _loading = true;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subs = await widget.service.loadSubscriptions();
    final active = await widget.service.loadActiveId();
    if (!mounted) return;
    setState(() {
      _subs = subs;
      _activeId = active;
      _loading = false;
    });
  }

  Future<void> _openAddFlow() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _AddSubscriptionFlow(service: widget.service),
        fullscreenDialog: true,
      ),
    );
    if (added == true) await _load();
  }

  Future<void> _activate(String? id) async {
    setState(() => _busyId = id ?? '__base__');
    try {
      await widget.service.activate(id);
      await _load();
      widget.onActivated?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось переключиться: $e')));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _refresh(Subscription sub) async {
    if (sub.url.isEmpty) return;
    setState(() => _busyId = sub.id);
    try {
      await widget.service.addFromUrl(name: sub.name, url: sub.url, existingId: sub.id);
      if (_activeId == sub.id) {
        // Если это активный профиль — перечитываем его же, чтобы обновление сразу применилось
        await widget.service.activate(sub.id);
        widget.onActivated?.call();
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(Subscription sub) async {
    setState(() => _busyId = sub.id);
    try {
      await widget.service.remove(sub);
      await _load();
      widget.onActivated?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось удалить: $e')));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Container(
      color: surfaces.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Row(
              children: [
                Text('Подписки',
                    style: TextStyle(
                        fontSize: AppFontSize.lg, fontWeight: FontWeight.w600, color: surfaces.text1)),
                const Spacer(),
                _HeaderIconButton(icon: Icons.add, tooltip: 'Добавить', onTap: _openAddFlow),
                if (widget.onClose != null) ...[
                  const SizedBox(width: AppSpace.s2),
                  _HeaderIconButton(icon: Icons.close, tooltip: 'Закрыть', onTap: widget.onClose!),
                ],
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                    children: [
                      _SubscriptionTile(
                        name: 'Основной конфиг',
                        subtitle: 'Ваш рукописный config.yaml',
                        isActive: _activeId == null,
                        busy: _busyId == '__base__',
                        pinned: true,
                        onTap: () => _activate(null),
                        onOpenYaml: () => widget.service.openProfileFile(null),
                      ),
                      const SizedBox(height: AppSpace.s2),
                      for (final sub in _subs) ...[
                        _SubscriptionTile(
                          name: sub.name,
                          subtitle: sub.url.isEmpty ? 'Локальный источник' : sub.url,
                          isActive: _activeId == sub.id,
                          busy: _busyId == sub.id,
                          canRefresh: sub.url.isNotEmpty,
                          onTap: () => _activate(sub.id),
                          onRefresh: () => _refresh(sub),
                          onOpenYaml: () => widget.service.openProfileFile(sub),
                          onDelete: () => _remove(sub),
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

/// Карточка подписки/профиля. Клик по всей карточке — активировать
/// (переключить работающий конфиг), иконки справа — вспомогательные
/// действия, появляются по наведению.
class _SubscriptionTile extends StatefulWidget {
  const _SubscriptionTile({
    required this.name,
    required this.subtitle,
    required this.isActive,
    required this.busy,
    required this.onTap,
    required this.onOpenYaml,
    this.canRefresh = false,
    this.pinned = false,
    this.onRefresh,
    this.onDelete,
  });

  final String name;
  final String subtitle;
  final bool isActive;
  final bool busy;
  final bool canRefresh;
  final bool pinned;
  final VoidCallback onTap;
  final VoidCallback onOpenYaml;
  final VoidCallback? onRefresh;
  final VoidCallback? onDelete;

  @override
  State<_SubscriptionTile> createState() => _SubscriptionTileState();
}

class _SubscriptionTileState extends State<_SubscriptionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final semantic = context.semanticColors;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: widget.isActive ? surfaces.card2 : surfaces.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: widget.busy ? null : widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: AppSpace.s3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: widget.isActive ? semantic.on : surfaces.border),
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
                    widget.pinned ? Icons.tune : Icons.dns_outlined,
                    size: 16,
                    color: surfaces.text2,
                  ),
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.md)),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
                      ),
                    ],
                  ),
                ),
                if (widget.busy)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else ...[
                  AnimatedOpacity(
                    duration: AppMotion.fast,
                    opacity: _hovered ? 1 : 0.35,
                    child: Row(
                      children: [
                        if (widget.canRefresh)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            tooltip: 'Обновить',
                            onPressed: widget.onRefresh,
                            visualDensity: VisualDensity.compact,
                          ),
                        IconButton(
                          icon: const Icon(Icons.code, size: 18),
                          tooltip: 'Открыть YAML',
                          onPressed: widget.onOpenYaml,
                          visualDensity: VisualDensity.compact,
                        ),
                        if (!widget.pinned)
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: semantic.danger),
                            tooltip: 'Удалить',
                            onPressed: widget.onDelete,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isActive ? semantic.on : Colors.transparent,
                      border: Border.all(
                        color: widget.isActive ? semantic.on : surfaces.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Многошаговый flow добавления
// ============================================================

class _AddSubscriptionFlow extends StatelessWidget {
  const _AddSubscriptionFlow({required this.service});
  final SubscriptionsService service;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Scaffold(
      backgroundColor: surfaces.card,
      body: SafeArea(child: _MethodPicker(service: service)),
    );
  }
}

class _MethodPicker extends StatelessWidget {
  const _MethodPicker({required this.service});
  final SubscriptionsService service;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    void push(Widget screen) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpace.s4),
          child: Row(
            children: [
              Text('Добавить подписку',
                  style: TextStyle(
                      fontSize: AppFontSize.lg, fontWeight: FontWeight.w600, color: surfaces.text1)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(false)),
            ],
          ),
        ),
        _MethodTile(
          icon: Icons.content_paste,
          title: 'Из буфера обмена',
          subtitle: 'Вставить скопированную ссылку или конфиг',
          onTap: () => push(_ClipboardStep(service: service)),
        ),
        _MethodTile(
          icon: Icons.link,
          title: 'Ввести URL вручную',
          subtitle: 'Ссылка на подписку Remnawave',
          onTap: () => push(_ManualUrlStep(service: service)),
        ),
        _MethodTile(
          icon: Icons.insert_drive_file_outlined,
          title: 'Из файла',
          subtitle: 'Импорт .yaml / .yml / .json',
          onTap: () => push(_FileImportStep(service: service)),
        ),
        _MethodTile(
          icon: Icons.qr_code_2,
          title: 'QR-код',
          subtitle: 'Сканировать камерой',
          onTap: () => push(_QrStep(service: service)),
        ),
        _MethodTile(
          icon: Icons.vpn_key_outlined,
          title: 'Сырой ключ',
          subtitle: 'vless:// trojan:// ss:// — свои ключи',
          onTap: () => push(_RawKeysStep(service: service)),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: AppSpace.s3),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: surfaces.card2, borderRadius: BorderRadius.circular(AppRadius.xs)),
              child: Icon(icon, size: 18, color: surfaces.text2),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.md)),
                  Text(subtitle, style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: surfaces.text3),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Scaffold(
      backgroundColor: surfaces.card,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpace.s4),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: AppSpace.s2),
                  Text(title,
                      style: TextStyle(
                          fontSize: AppFontSize.lg, fontWeight: FontWeight.w600, color: surfaces.text1)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpace.s4), child: child)),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s1),
      child: Text(text, style: TextStyle(color: context.surfaces.text3, fontSize: AppFontSize.xs)),
    );
  }
}

InputDecoration _fieldDecoration(BuildContext context, String hint) {
  final surfaces = context.surfaces;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: surfaces.text3, fontSize: AppFontSize.sm),
    filled: true,
    fillColor: surfaces.card2,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: AppSpace.s3),
  );
}

void _closeFlow(BuildContext context) {
  Navigator.of(context).pop();
  Navigator.of(context).pop(true);
}

class _ManualUrlStep extends StatefulWidget {
  const _ManualUrlStep({required this.service});
  final SubscriptionsService service;

  @override
  State<_ManualUrlStep> createState() => _ManualUrlStepState();
}

class _ManualUrlStepState extends State<_ManualUrlStep> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _url.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.service.addFromUrl(name: _name.text.trim(), url: _url.text.trim());
      if (!mounted) return;
      _closeFlow(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Ссылка на подписку',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Название подписки'),
          TextField(controller: _name, decoration: _fieldDecoration(context, 'Например, Личная')),
          const SizedBox(height: AppSpace.s4),
          const _FieldLabel('Ссылка на подписку'),
          TextField(controller: _url, decoration: _fieldDecoration(context, 'https://sub.remnawave.example.com/...')),
          const SizedBox(height: AppSpace.s5),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Добавить подписку'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipboardStep extends StatefulWidget {
  const _ClipboardStep({required this.service});
  final SubscriptionsService service;

  @override
  State<_ClipboardStep> createState() => _ClipboardStepState();
}

class _ClipboardStepState extends State<_ClipboardStep> {
  final _name = TextEditingController();
  String? _clipboardText;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Clipboard.getData(Clipboard.kTextPlain).then((data) {
      if (mounted) setState(() => _clipboardText = data?.text?.trim());
    });
  }

  Future<void> _submit() async {
    final text = _clipboardText;
    if (text == null || text.isEmpty || _name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      if (text.startsWith('http://') || text.startsWith('https://')) {
        await widget.service.addFromUrl(name: _name.text.trim(), url: text);
      } else {
        await widget.service.addFromRawText(name: _name.text.trim(), rawText: text);
      }
      if (!mounted) return;
      _closeFlow(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return _StepScaffold(
      title: 'Из буфера обмена',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Название подписки'),
          TextField(controller: _name, decoration: _fieldDecoration(context, 'Например, Личная')),
          const SizedBox(height: AppSpace.s4),
          const _FieldLabel('Содержимое буфера обмена'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpace.s3),
            decoration: BoxDecoration(color: surfaces.card2, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Text(
              _clipboardText?.isNotEmpty == true ? _clipboardText! : 'Буфер обмена пуст',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: surfaces.text2, fontSize: AppFontSize.xs, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: AppSpace.s5),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_loading || _clipboardText == null || _clipboardText!.isEmpty) ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Добавить подписку'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileImportStep extends StatefulWidget {
  const _FileImportStep({required this.service});
  final SubscriptionsService service;

  @override
  State<_FileImportStep> createState() => _FileImportStepState();
}

class _FileImportStepState extends State<_FileImportStep> {
  final _name = TextEditingController();
  String? _filePath;
  bool _loading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yaml', 'yml', 'json', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _filePath = result.files.single.path);
    }
  }

  Future<void> _submit() async {
    if (_filePath == null || _name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final content = await File(_filePath!).readAsString();
      await widget.service.addFromRawText(name: _name.text.trim(), rawText: content);
      if (!mounted) return;
      _closeFlow(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return _StepScaffold(
      title: 'Импорт из файла',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Название подписки'),
          TextField(controller: _name, decoration: _fieldDecoration(context, 'Например, Рабочая')),
          const SizedBox(height: AppSpace.s4),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: surfaces.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, color: surfaces.text3),
                  const SizedBox(height: AppSpace.s2),
                  Text(_filePath ?? 'Выбрать файл конфигурации',
                      style: TextStyle(color: surfaces.text2, fontSize: AppFontSize.sm)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s5),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Добавить подписку'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrStep extends StatelessWidget {
  const _QrStep({required this.service});
  final SubscriptionsService service;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return _StepScaffold(
      title: 'QR-код подписки',
      child: Column(
        children: [
          Container(
            width: 220,
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: surfaces.border), borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(Icons.qr_code_scanner, size: 48, color: surfaces.text3),
          ),
          const SizedBox(height: AppSpace.s3),
          Text(
            'Сканирование камерой пока не реализовано — нужен отдельный нативный пакет с доступом к камере на десктопе.',
            textAlign: TextAlign.center,
            style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs),
          ),
          const SizedBox(height: AppSpace.s4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: null, child: const Text('Загрузить изображение с QR')),
          ),
        ],
      ),
    );
  }
}

class _RawKeysStep extends StatefulWidget {
  const _RawKeysStep({required this.service});
  final SubscriptionsService service;

  @override
  State<_RawKeysStep> createState() => _RawKeysStepState();
}

class _RawKeysStepState extends State<_RawKeysStep> {
  final _keys = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_keys.text.trim().isEmpty || _name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final nodes = widget.service.parseRawLinks(_keys.text);
      await widget.service.addFromNodes(name: _name.text.trim(), nodes: nodes);
      if (!mounted) return;
      _closeFlow(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return _StepScaffold(
      title: 'Сырые ключи',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Ключи (по одному на строку)'),
          TextField(
            controller: _keys,
            maxLines: 6,
            style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm, fontFamily: 'monospace'),
            decoration: _fieldDecoration(context, 'vless://...\ntrojan://...\nss://...'),
          ),
          const SizedBox(height: AppSpace.s2),
          Text('Ключи разбираются локальным парсером приложения',
              style: TextStyle(color: surfaces.text3, fontSize: AppFontSize.xs)),
          const SizedBox(height: AppSpace.s4),
          const _FieldLabel('Название новой подписки'),
          TextField(controller: _name, decoration: _fieldDecoration(context, 'Мои ключи')),
          const SizedBox(height: AppSpace.s5),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Добавить ключи'),
            ),
          ),
        ],
      ),
    );
  }
}