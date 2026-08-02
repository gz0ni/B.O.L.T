part of 'database.dart';

/// Сырые ключи managed-профиля. Хранятся в БД, а не комментариями
/// в конфиге: профиль считается managed, если для него есть записи.
/// При удалении последнего ключа профиль удаляется целиком.
class ProfileKeys extends Table {
  @override
  String get tableName => 'profile_keys';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get link => text()();
}

@DriftAccessor(tables: [ProfileKeys])
class ProfileKeysDao extends DatabaseAccessor<Database>
    with _$ProfileKeysDaoMixin {
  ProfileKeysDao(super.attachedDatabase);

  /// Ключи профиля в порядке добавления.
  Future<List<String>> keysFor(int profileId) async {
    final stmt = select(profileKeys)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return (await stmt.get()).map((row) => row.link).toList();
  }

  /// Полная перезапись ключей профиля.
  Future<void> setKeys(int profileId, List<String> keys) async {
    await transaction(() async {
      await deleteForProfile(profileId);
      await batch((b) {
        b.insertAll(profileKeys, [
          for (final link in keys)
            ProfileKeysCompanion.insert(profileId: profileId, link: link),
        ]);
      });
    });
  }

  /// True, если профиль хранит хотя бы один сырой ключ.
  Future<bool> hasKeys(int profileId) async {
    final query = selectOnly(profileKeys)
      ..addColumns([countAll()])
      ..where(profileKeys.profileId.equals(profileId));
    final row = await query.getSingle();
    return (row.read(countAll()) ?? 0) > 0;
  }

  Future<void> deleteForProfile(int profileId) async {
    await (delete(
      profileKeys,
    )..where((t) => t.profileId.equals(profileId))).go();
  }
}
