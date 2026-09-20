import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SongsTable,
    FavoritesTable,
    ListeningHistoryTable,
    PlaylistsTable,
    PlaylistSongsTable,
    DownloadsTable,
    PlayerSnapshotsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  AppDatabase.forTesting(super.connection);

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future schema migrations will preserve user data.
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'melo_user_data.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
