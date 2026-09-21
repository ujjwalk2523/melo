import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

class SyncQueueOperation {
  final String id;
  final String? userId;
  final String entityType; // 'favorite', 'playlist', 'playlist_song', 'history', 'preference'
  final String entityId;
  final String operationType; // 'upsert', 'delete'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final String status; // 'pending', 'syncing', 'failed', 'completed'

  const SyncQueueOperation({
    required this.id,
    this.userId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.status = 'pending',
  });

  Map<String, dynamic> toApiPayload() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'operationType': operationType,
    'payload': payload,
    'clientTimestamp': createdAt.toIso8601String(),
  };
}

class SyncQueue {
  final AppDatabase _db;

  SyncQueue(this._db);

  Future<void> enqueue({
    required String id,
    String? userId,
    required String entityType,
    required String entityId,
    required String operationType,
    required Map<String, dynamic> payload,
  }) async {
    await _db.into(_db.syncQueueTable).insertOnConflictUpdate(
          SyncQueueTableCompanion(
            id: Value(id),
            userId: Value(userId),
            entityType: Value(entityType),
            entityId: Value(entityId),
            operationType: Value(operationType),
            payload: Value(jsonEncode(payload)),
            createdAt: Value(DateTime.now()),
            retryCount: const Value(0),
            status: const Value('pending'),
          ),
        );
  }

  Future<List<SyncQueueOperation>> getPendingOperations({int limit = 100}) async {
    final query = _db.select(_db.syncQueueTable)
      ..where((tbl) => tbl.status.equals('pending') | tbl.status.equals('failed'))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((r) {
      Map<String, dynamic> payload = {};
      try {
        payload = jsonDecode(r.payload) as Map<String, dynamic>;
      } catch (_) {}

      return SyncQueueOperation(
        id: r.id,
        userId: r.userId,
        entityType: r.entityType,
        entityId: r.entityId,
        operationType: r.operationType,
        payload: payload,
        createdAt: r.createdAt,
        retryCount: r.retryCount,
        lastError: r.lastError,
        status: r.status,
      );
    }).toList();
  }

  Future<int> getPendingCount() async {
    final query = _db.selectOnly(_db.syncQueueTable)
      ..addColumns([_db.syncQueueTable.id.count()])
      ..where(_db.syncQueueTable.status.equals('pending') | _db.syncQueueTable.status.equals('failed'));

    final result = await query.map((row) => row.read(_db.syncQueueTable.id.count())).getSingle();
    return result ?? 0;
  }

  Future<void> markCompleted(List<String> operationIds) async {
    if (operationIds.isEmpty) return;
    await (_db.delete(_db.syncQueueTable)
          ..where((tbl) => tbl.id.isIn(operationIds)))
        .go();
  }

  Future<void> markFailed(String operationId, String error) async {
    final row = await (_db.select(_db.syncQueueTable)..where((tbl) => tbl.id.equals(operationId))).getSingleOrNull();
    final retry = (row?.retryCount ?? 0) + 1;
    await (_db.update(_db.syncQueueTable)..where((tbl) => tbl.id.equals(operationId))).write(
      SyncQueueTableCompanion(
        status: const Value('failed'),
        lastError: Value(error),
        retryCount: Value(retry),
      ),
    );
  }

  Future<void> clearAll() async {
    await _db.delete(_db.syncQueueTable).go();
  }
}
