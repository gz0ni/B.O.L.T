import 'package:bolt/common/context.dart';
import 'package:bolt/enum/enum.dart';
import 'package:bolt/models/models.dart';
import 'package:bolt/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../widgets/bolt_controls.dart';
import 'settings_widgets.dart';

/// Шторка «Контроль доступа»: включение, режим (только выбранные /
/// все, кроме), фильтры, сортировка, поиск и список приложений.
class AccessControlScreen extends ConsumerStatefulWidget {
  const AccessControlScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<AccessControlScreen> createState() =>
      _AccessControlScreenState();
}

class _AccessControlScreenState extends ConsumerState<AccessControlScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    ref.read(systemActionProvider.notifier).getPackages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateAccessControl(
    AccessControlProps Function(AccessControlProps) update,
  ) {
    ref.read(vpnSettingProvider.notifier).update(
      (state) => state.copyWith(
        accessControlProps: update(state.accessControlProps),
      ),
    );
  }

  void _togglePackage(String packageName) {
    final ac = ref.read(vpnSettingProvider).accessControlProps;
    final current = [...ac.currentList];
    if (current.contains(packageName)) {
      current.remove(packageName);
    } else {
      current.add(packageName);
    }
    _updateAccessControl((state) => state.copyWithNewList(current));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final surfaces = context.surfaces;
    final state = ref.watch(packageListSelectorStateProvider);
    final ac = state.accessControlProps;

    var packages = state.packages.getViewList(
      pinedList: ac.currentList,
      sortType: ac.sort,
      isFilterSystemApp: ac.isFilterSystemApp,
      isFilterNonInternetApp: ac.isFilterNonInternetApp,
    );
    if (_query.isNotEmpty) {
      packages = packages
          .where(
            (p) =>
                p.label.toLowerCase().contains(_query) ||
                p.packageName.toLowerCase().contains(_query),
          )
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsRow(
          title: l.accessControl,
          description: l.accessControlDesc,
          trailing: SettingsSwitch(
            value: ac.enable,
            onChanged: (v) =>
                _updateAccessControl((state) => state.copyWith(enable: v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s4,
            AppSpace.s1,
            AppSpace.s4,
            AppSpace.s1,
          ),
          child: BoltSegmented<AccessControlMode>(
            options: [
              BoltSegmentedOption(AccessControlMode.acceptSelected, l.accessControlAllow),
              BoltSegmentedOption(AccessControlMode.rejectSelected, l.accessControlNotAllow),
            ],
            value: ac.mode,
            expanded: true,
            onChanged: (v) =>
                _updateAccessControl((state) => state.copyWith(mode: v)),
          ),
        ),
        SettingsRow(
          title: l.accessControlShowSystemApps,
          trailing: SettingsSwitch(
            value: ac.isFilterSystemApp,
            onChanged: (v) => _updateAccessControl(
              (state) => state.copyWith(isFilterSystemApp: v),
            ),
          ),
        ),
        SettingsRow(
          title: l.accessControlShowNonInternet,
          trailing: SettingsSwitch(
            value: ac.isFilterNonInternetApp,
            onChanged: (v) => _updateAccessControl(
              (state) => state.copyWith(isFilterNonInternetApp: v),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s4,
            AppSpace.s1,
            AppSpace.s4,
            AppSpace.s2,
          ),
          child: BoltSegmented<AccessSortType>(
            options: [
              BoltSegmentedOption(AccessSortType.none, l.accessControlSortDefault),
              BoltSegmentedOption(AccessSortType.name, l.accessControlSortName),
              BoltSegmentedOption(AccessSortType.time, l.accessControlSortTime),
            ],
            value: ac.sort,
            expanded: true,
            onChanged: (v) =>
                _updateAccessControl((state) => state.copyWith(sort: v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s4,
            AppSpace.s1,
            AppSpace.s4,
            AppSpace.s2,
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: surfaces.text1, fontSize: AppFontSize.sm),
            decoration: InputDecoration(
              hintText: l.accessControlSearchHint,
              hintStyle: TextStyle(
                color: surfaces.text3,
                fontSize: AppFontSize.sm,
              ),
              prefixIcon: Icon(Icons.search, size: 18, color: surfaces.text3),
              filled: true,
              fillColor: surfaces.card2,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: packages.isEmpty
              ? Center(
                  child: Text(
                    l.accessControlEmpty,
                    style: TextStyle(color: surfaces.text3),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.s3,
                    0,
                    AppSpace.s3,
                    AppSpace.s2,
                  ),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return _AppTile(
                      package: package,
                      selected: ac.currentList.contains(package.packageName),
                      onToggle: () => _togglePackage(package.packageName),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s4,
            AppSpace.s1,
            AppSpace.s4,
            AppSpace.s3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${l.selected}: ${ac.currentList.length}',
                  style: TextStyle(
                    color: surfaces.text2,
                    fontSize: AppFontSize.sm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                l.accessControlReconnectHint,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: surfaces.text3,
                  fontSize: AppFontSize.xs,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Строка приложения: буква-плейсхолдер, название, packageName, свитч.
class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.package,
    required this.selected,
    required this.onToggle,
  });

  final Package package;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s1),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: surfaces.card2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                package.label.isEmpty ? '?' : package.label[0].toUpperCase(),
                style: TextStyle(
                  fontSize: AppFontSize.md,
                  fontWeight: FontWeight.w600,
                  color: surfaces.text2,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: surfaces.text1,
                    fontSize: AppFontSize.md,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  package.packageName,
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
          const SizedBox(width: AppSpace.s3),
          BoltSwitch(value: selected, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}
