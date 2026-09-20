// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTableTable extends SongsTable
    with TableInfo<$SongsTableTable, SongsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerTrackIdMeta = const VerificationMeta(
    'providerTrackId',
  );
  @override
  late final GeneratedColumn<String> providerTrackId = GeneratedColumn<String>(
    'provider_track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streamUrlMeta = const VerificationMeta(
    'streamUrl',
  );
  @override
  late final GeneratedColumn<String> streamUrl = GeneratedColumn<String>(
    'stream_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadUrlMeta = const VerificationMeta(
    'downloadUrl',
  );
  @override
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>(
    'download_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDownloadableMeta = const VerificationMeta(
    'isDownloadable',
  );
  @override
  late final GeneratedColumn<bool> isDownloadable = GeneratedColumn<bool>(
    'is_downloadable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloadable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    providerTrackId,
    title,
    artist,
    album,
    artworkUrl,
    streamUrl,
    downloadUrl,
    isDownloadable,
    durationMs,
    genre,
    releaseDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('provider_track_id')) {
      context.handle(
        _providerTrackIdMeta,
        providerTrackId.isAcceptableOrUnknown(
          data['provider_track_id']!,
          _providerTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_artworkUrlMeta);
    }
    if (data.containsKey('stream_url')) {
      context.handle(
        _streamUrlMeta,
        streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta),
      );
    }
    if (data.containsKey('download_url')) {
      context.handle(
        _downloadUrlMeta,
        downloadUrl.isAcceptableOrUnknown(
          data['download_url']!,
          _downloadUrlMeta,
        ),
      );
    }
    if (data.containsKey('is_downloadable')) {
      context.handle(
        _isDownloadableMeta,
        isDownloadable.isAcceptableOrUnknown(
          data['is_downloadable']!,
          _isDownloadableMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      providerTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_track_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      )!,
      streamUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_url'],
      ),
      downloadUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_url'],
      ),
      isDownloadable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloadable'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}release_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SongsTableTable createAlias(String alias) {
    return $SongsTableTable(attachedDatabase, alias);
  }
}

class SongsTableData extends DataClass implements Insertable<SongsTableData> {
  final String id;
  final String provider;
  final String? providerTrackId;
  final String title;
  final String artist;
  final String album;
  final String artworkUrl;
  final String? streamUrl;
  final String? downloadUrl;
  final bool isDownloadable;
  final int durationMs;
  final String? genre;
  final DateTime? releaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SongsTableData({
    required this.id,
    required this.provider,
    this.providerTrackId,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkUrl,
    this.streamUrl,
    this.downloadUrl,
    required this.isDownloadable,
    required this.durationMs,
    this.genre,
    this.releaseDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || providerTrackId != null) {
      map['provider_track_id'] = Variable<String>(providerTrackId);
    }
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['artwork_url'] = Variable<String>(artworkUrl);
    if (!nullToAbsent || streamUrl != null) {
      map['stream_url'] = Variable<String>(streamUrl);
    }
    if (!nullToAbsent || downloadUrl != null) {
      map['download_url'] = Variable<String>(downloadUrl);
    }
    map['is_downloadable'] = Variable<bool>(isDownloadable);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SongsTableCompanion toCompanion(bool nullToAbsent) {
    return SongsTableCompanion(
      id: Value(id),
      provider: Value(provider),
      providerTrackId: providerTrackId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerTrackId),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      artworkUrl: Value(artworkUrl),
      streamUrl: streamUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(streamUrl),
      downloadUrl: downloadUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadUrl),
      isDownloadable: Value(isDownloadable),
      durationMs: Value(durationMs),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SongsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongsTableData(
      id: serializer.fromJson<String>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      providerTrackId: serializer.fromJson<String?>(json['providerTrackId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      artworkUrl: serializer.fromJson<String>(json['artworkUrl']),
      streamUrl: serializer.fromJson<String?>(json['streamUrl']),
      downloadUrl: serializer.fromJson<String?>(json['downloadUrl']),
      isDownloadable: serializer.fromJson<bool>(json['isDownloadable']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      genre: serializer.fromJson<String?>(json['genre']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'provider': serializer.toJson<String>(provider),
      'providerTrackId': serializer.toJson<String?>(providerTrackId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'artworkUrl': serializer.toJson<String>(artworkUrl),
      'streamUrl': serializer.toJson<String?>(streamUrl),
      'downloadUrl': serializer.toJson<String?>(downloadUrl),
      'isDownloadable': serializer.toJson<bool>(isDownloadable),
      'durationMs': serializer.toJson<int>(durationMs),
      'genre': serializer.toJson<String?>(genre),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SongsTableData copyWith({
    String? id,
    String? provider,
    Value<String?> providerTrackId = const Value.absent(),
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    Value<String?> streamUrl = const Value.absent(),
    Value<String?> downloadUrl = const Value.absent(),
    bool? isDownloadable,
    int? durationMs,
    Value<String?> genre = const Value.absent(),
    Value<DateTime?> releaseDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SongsTableData(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    providerTrackId: providerTrackId.present
        ? providerTrackId.value
        : this.providerTrackId,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    artworkUrl: artworkUrl ?? this.artworkUrl,
    streamUrl: streamUrl.present ? streamUrl.value : this.streamUrl,
    downloadUrl: downloadUrl.present ? downloadUrl.value : this.downloadUrl,
    isDownloadable: isDownloadable ?? this.isDownloadable,
    durationMs: durationMs ?? this.durationMs,
    genre: genre.present ? genre.value : this.genre,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SongsTableData copyWithCompanion(SongsTableCompanion data) {
    return SongsTableData(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      providerTrackId: data.providerTrackId.present
          ? data.providerTrackId.value
          : this.providerTrackId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      streamUrl: data.streamUrl.present ? data.streamUrl.value : this.streamUrl,
      downloadUrl: data.downloadUrl.present
          ? data.downloadUrl.value
          : this.downloadUrl,
      isDownloadable: data.isDownloadable.present
          ? data.isDownloadable.value
          : this.isDownloadable,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      genre: data.genre.present ? data.genre.value : this.genre,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongsTableData(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('providerTrackId: $providerTrackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('isDownloadable: $isDownloadable, ')
          ..write('durationMs: $durationMs, ')
          ..write('genre: $genre, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    providerTrackId,
    title,
    artist,
    album,
    artworkUrl,
    streamUrl,
    downloadUrl,
    isDownloadable,
    durationMs,
    genre,
    releaseDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongsTableData &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.providerTrackId == this.providerTrackId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.artworkUrl == this.artworkUrl &&
          other.streamUrl == this.streamUrl &&
          other.downloadUrl == this.downloadUrl &&
          other.isDownloadable == this.isDownloadable &&
          other.durationMs == this.durationMs &&
          other.genre == this.genre &&
          other.releaseDate == this.releaseDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SongsTableCompanion extends UpdateCompanion<SongsTableData> {
  final Value<String> id;
  final Value<String> provider;
  final Value<String?> providerTrackId;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<String> artworkUrl;
  final Value<String?> streamUrl;
  final Value<String?> downloadUrl;
  final Value<bool> isDownloadable;
  final Value<int> durationMs;
  final Value<String?> genre;
  final Value<DateTime?> releaseDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SongsTableCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.providerTrackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.isDownloadable = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.genre = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsTableCompanion.insert({
    required String id,
    required String provider,
    this.providerTrackId = const Value.absent(),
    required String title,
    required String artist,
    required String album,
    required String artworkUrl,
    this.streamUrl = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.isDownloadable = const Value.absent(),
    required int durationMs,
    this.genre = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       provider = Value(provider),
       title = Value(title),
       artist = Value(artist),
       album = Value(album),
       artworkUrl = Value(artworkUrl),
       durationMs = Value(durationMs);
  static Insertable<SongsTableData> custom({
    Expression<String>? id,
    Expression<String>? provider,
    Expression<String>? providerTrackId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? artworkUrl,
    Expression<String>? streamUrl,
    Expression<String>? downloadUrl,
    Expression<bool>? isDownloadable,
    Expression<int>? durationMs,
    Expression<String>? genre,
    Expression<DateTime>? releaseDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (providerTrackId != null) 'provider_track_id': providerTrackId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (downloadUrl != null) 'download_url': downloadUrl,
      if (isDownloadable != null) 'is_downloadable': isDownloadable,
      if (durationMs != null) 'duration_ms': durationMs,
      if (genre != null) 'genre': genre,
      if (releaseDate != null) 'release_date': releaseDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? provider,
    Value<String?>? providerTrackId,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<String>? artworkUrl,
    Value<String?>? streamUrl,
    Value<String?>? downloadUrl,
    Value<bool>? isDownloadable,
    Value<int>? durationMs,
    Value<String?>? genre,
    Value<DateTime?>? releaseDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SongsTableCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      providerTrackId: providerTrackId ?? this.providerTrackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      durationMs: durationMs ?? this.durationMs,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (providerTrackId.present) {
      map['provider_track_id'] = Variable<String>(providerTrackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    if (downloadUrl.present) {
      map['download_url'] = Variable<String>(downloadUrl.value);
    }
    if (isDownloadable.present) {
      map['is_downloadable'] = Variable<bool>(isDownloadable.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsTableCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('providerTrackId: $providerTrackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('isDownloadable: $isDownloadable, ')
          ..write('durationMs: $durationMs, ')
          ..write('genre: $genre, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTableTable extends FavoritesTable
    with TableInfo<$FavoritesTableTable, FavoritesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs_table (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, songId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoritesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {songId},
  ];
  @override
  FavoritesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoritesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTableTable createAlias(String alias) {
    return $FavoritesTableTable(attachedDatabase, alias);
  }
}

class FavoritesTableData extends DataClass
    implements Insertable<FavoritesTableData> {
  final int id;
  final String songId;
  final DateTime createdAt;
  const FavoritesTableData({
    required this.id,
    required this.songId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<String>(songId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesTableCompanion toCompanion(bool nullToAbsent) {
    return FavoritesTableCompanion(
      id: Value(id),
      songId: Value(songId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoritesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoritesTableData(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<String>(songId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoritesTableData copyWith({int? id, String? songId, DateTime? createdAt}) =>
      FavoritesTableData(
        id: id ?? this.id,
        songId: songId ?? this.songId,
        createdAt: createdAt ?? this.createdAt,
      );
  FavoritesTableData copyWithCompanion(FavoritesTableCompanion data) {
    return FavoritesTableData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoritesTableData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.createdAt == this.createdAt);
}

class FavoritesTableCompanion extends UpdateCompanion<FavoritesTableData> {
  final Value<int> id;
  final Value<String> songId;
  final Value<DateTime> createdAt;
  const FavoritesTableCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoritesTableCompanion.insert({
    this.id = const Value.absent(),
    required String songId,
    this.createdAt = const Value.absent(),
  }) : songId = Value(songId);
  static Insertable<FavoritesTableData> custom({
    Expression<int>? id,
    Expression<String>? songId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoritesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? songId,
    Value<DateTime>? createdAt,
  }) {
    return FavoritesTableCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesTableCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ListeningHistoryTableTable extends ListeningHistoryTable
    with TableInfo<$ListeningHistoryTableTable, ListeningHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs_table (id)',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, songId, playedAt, playCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
    );
  }

  @override
  $ListeningHistoryTableTable createAlias(String alias) {
    return $ListeningHistoryTableTable(attachedDatabase, alias);
  }
}

class ListeningHistoryTableData extends DataClass
    implements Insertable<ListeningHistoryTableData> {
  final int id;
  final String songId;
  final DateTime playedAt;
  final int playCount;
  const ListeningHistoryTableData({
    required this.id,
    required this.songId,
    required this.playedAt,
    required this.playCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<String>(songId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['play_count'] = Variable<int>(playCount);
    return map;
  }

  ListeningHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return ListeningHistoryTableCompanion(
      id: Value(id),
      songId: Value(songId),
      playedAt: Value(playedAt),
      playCount: Value(playCount),
    );
  }

  factory ListeningHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      playCount: serializer.fromJson<int>(json['playCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<String>(songId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'playCount': serializer.toJson<int>(playCount),
    };
  }

  ListeningHistoryTableData copyWith({
    int? id,
    String? songId,
    DateTime? playedAt,
    int? playCount,
  }) => ListeningHistoryTableData(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    playedAt: playedAt ?? this.playedAt,
    playCount: playCount ?? this.playCount,
  );
  ListeningHistoryTableData copyWithCompanion(
    ListeningHistoryTableCompanion data,
  ) {
    return ListeningHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryTableData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('playedAt: $playedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, playedAt, playCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningHistoryTableData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.playedAt == this.playedAt &&
          other.playCount == this.playCount);
}

class ListeningHistoryTableCompanion
    extends UpdateCompanion<ListeningHistoryTableData> {
  final Value<int> id;
  final Value<String> songId;
  final Value<DateTime> playedAt;
  final Value<int> playCount;
  const ListeningHistoryTableCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  ListeningHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String songId,
    this.playedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  }) : songId = Value(songId);
  static Insertable<ListeningHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? songId,
    Expression<DateTime>? playedAt,
    Expression<int>? playCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (playedAt != null) 'played_at': playedAt,
      if (playCount != null) 'play_count': playCount,
    });
  }

  ListeningHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? songId,
    Value<DateTime>? playedAt,
    Value<int>? playCount,
  }) {
    return ListeningHistoryTableCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      playedAt: playedAt ?? this.playedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('playedAt: $playedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTableTable extends PlaylistsTable
    with TableInfo<$PlaylistsTableTable, PlaylistsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    artworkUrl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaylistsTableTable createAlias(String alias) {
    return $PlaylistsTableTable(attachedDatabase, alias);
  }
}

class PlaylistsTableData extends DataClass
    implements Insertable<PlaylistsTableData> {
  final String id;
  final String name;
  final String? description;
  final String? artworkUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlaylistsTableData({
    required this.id,
    required this.name,
    this.description,
    this.artworkUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaylistsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaylistsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaylistsTableData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> artworkUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlaylistsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaylistsTableData copyWithCompanion(PlaylistsTableCompanion data) {
    return PlaylistsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, artworkUrl, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.artworkUrl == this.artworkUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsTableCompanion extends UpdateCompanion<PlaylistsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> artworkUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlaylistsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PlaylistsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? artworkUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? artworkUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaylistsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTableTable extends PlaylistSongsTable
    with TableInfo<$PlaylistSongsTableTable, PlaylistSongsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists_table (id)',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs_table (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    songId,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSongsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {playlistId, songId},
  ];
  @override
  PlaylistSongsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSongsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $PlaylistSongsTableTable createAlias(String alias) {
    return $PlaylistSongsTableTable(attachedDatabase, alias);
  }
}

class PlaylistSongsTableData extends DataClass
    implements Insertable<PlaylistSongsTableData> {
  final int id;
  final String playlistId;
  final String songId;
  final int position;
  final DateTime addedAt;
  const PlaylistSongsTableData({
    required this.id,
    required this.playlistId,
    required this.songId,
    required this.position,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistSongsTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsTableCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistSongsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSongsTableData(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistSongsTableData copyWith({
    int? id,
    String? playlistId,
    String? songId,
    int? position,
    DateTime? addedAt,
  }) => PlaylistSongsTableData(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistSongsTableData copyWithCompanion(PlaylistSongsTableCompanion data) {
    return PlaylistSongsTableData(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsTableData(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, songId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSongsTableData &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class PlaylistSongsTableCompanion
    extends UpdateCompanion<PlaylistSongsTableData> {
  final Value<int> id;
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<DateTime> addedAt;
  const PlaylistSongsTableCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  PlaylistSongsTableCompanion.insert({
    this.id = const Value.absent(),
    required String playlistId,
    required String songId,
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId);
  static Insertable<PlaylistSongsTableData> custom({
    Expression<int>? id,
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  PlaylistSongsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? position,
    Value<DateTime>? addedAt,
  }) {
    return PlaylistSongsTableCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsTableCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTableTable extends DownloadsTable
    with TableInfo<$DownloadsTableTable, DownloadsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs_table (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    status,
    localPath,
    downloadedBytes,
    totalBytes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {songId},
  ];
  @override
  DownloadsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadsTableTable createAlias(String alias) {
    return $DownloadsTableTable(attachedDatabase, alias);
  }
}

class DownloadsTableData extends DataClass
    implements Insertable<DownloadsTableData> {
  final String id;
  final String songId;
  final String status;
  final String? localPath;
  final int downloadedBytes;
  final int totalBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadsTableData({
    required this.id,
    required this.songId,
    required this.status,
    this.localPath,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['song_id'] = Variable<String>(songId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['total_bytes'] = Variable<int>(totalBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadsTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadsTableCompanion(
      id: Value(id),
      songId: Value(songId),
      status: Value(status),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      downloadedBytes: Value(downloadedBytes),
      totalBytes: Value(totalBytes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadsTableData(
      id: serializer.fromJson<String>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      status: serializer.fromJson<String>(json['status']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songId': serializer.toJson<String>(songId),
      'status': serializer.toJson<String>(status),
      'localPath': serializer.toJson<String?>(localPath),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadsTableData copyWith({
    String? id,
    String? songId,
    String? status,
    Value<String?> localPath = const Value.absent(),
    int? downloadedBytes,
    int? totalBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DownloadsTableData(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    status: status ?? this.status,
    localPath: localPath.present ? localPath.value : this.localPath,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    totalBytes: totalBytes ?? this.totalBytes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadsTableData copyWithCompanion(DownloadsTableCompanion data) {
    return DownloadsTableData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      status: data.status.present ? data.status.value : this.status,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsTableData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('status: $status, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songId,
    status,
    localPath,
    downloadedBytes,
    totalBytes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadsTableData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.status == this.status &&
          other.localPath == this.localPath &&
          other.downloadedBytes == this.downloadedBytes &&
          other.totalBytes == this.totalBytes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadsTableCompanion extends UpdateCompanion<DownloadsTableData> {
  final Value<String> id;
  final Value<String> songId;
  final Value<String> status;
  final Value<String?> localPath;
  final Value<int> downloadedBytes;
  final Value<int> totalBytes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadsTableCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.status = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsTableCompanion.insert({
    required String id,
    required String songId,
    this.status = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       songId = Value(songId);
  static Insertable<DownloadsTableData> custom({
    Expression<String>? id,
    Expression<String>? songId,
    Expression<String>? status,
    Expression<String>? localPath,
    Expression<int>? downloadedBytes,
    Expression<int>? totalBytes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (status != null) 'status': status,
      if (localPath != null) 'local_path': localPath,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? songId,
    Value<String>? status,
    Value<String?>? localPath,
    Value<int>? downloadedBytes,
    Value<int>? totalBytes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadsTableCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      status: status ?? this.status,
      localPath: localPath ?? this.localPath,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsTableCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('status: $status, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerSnapshotsTableTable extends PlayerSnapshotsTable
    with TableInfo<$PlayerSnapshotsTableTable, PlayerSnapshotsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerSnapshotsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentSongIdMeta = const VerificationMeta(
    'currentSongId',
  );
  @override
  late final GeneratedColumn<String> currentSongId = GeneratedColumn<String>(
    'current_song_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queueSongIdsMeta = const VerificationMeta(
    'queueSongIds',
  );
  @override
  late final GeneratedColumn<String> queueSongIds = GeneratedColumn<String>(
    'queue_song_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _currentQueueIndexMeta = const VerificationMeta(
    'currentQueueIndex',
  );
  @override
  late final GeneratedColumn<int> currentQueueIndex = GeneratedColumn<int>(
    'current_queue_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _isShuffleMeta = const VerificationMeta(
    'isShuffle',
  );
  @override
  late final GeneratedColumn<bool> isShuffle = GeneratedColumn<bool>(
    'is_shuffle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shuffle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentSongId,
    queueSongIds,
    currentQueueIndex,
    positionMs,
    repeatMode,
    isShuffle,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_snapshots_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerSnapshotsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('current_song_id')) {
      context.handle(
        _currentSongIdMeta,
        currentSongId.isAcceptableOrUnknown(
          data['current_song_id']!,
          _currentSongIdMeta,
        ),
      );
    }
    if (data.containsKey('queue_song_ids')) {
      context.handle(
        _queueSongIdsMeta,
        queueSongIds.isAcceptableOrUnknown(
          data['queue_song_ids']!,
          _queueSongIdsMeta,
        ),
      );
    }
    if (data.containsKey('current_queue_index')) {
      context.handle(
        _currentQueueIndexMeta,
        currentQueueIndex.isAcceptableOrUnknown(
          data['current_queue_index']!,
          _currentQueueIndexMeta,
        ),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('is_shuffle')) {
      context.handle(
        _isShuffleMeta,
        isShuffle.isAcceptableOrUnknown(data['is_shuffle']!, _isShuffleMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerSnapshotsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerSnapshotsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currentSongId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_song_id'],
      ),
      queueSongIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_song_ids'],
      )!,
      currentQueueIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_queue_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      isShuffle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shuffle'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayerSnapshotsTableTable createAlias(String alias) {
    return $PlayerSnapshotsTableTable(attachedDatabase, alias);
  }
}

class PlayerSnapshotsTableData extends DataClass
    implements Insertable<PlayerSnapshotsTableData> {
  final String id;
  final String? currentSongId;
  final String queueSongIds;
  final int currentQueueIndex;
  final int positionMs;
  final String repeatMode;
  final bool isShuffle;
  final DateTime updatedAt;
  const PlayerSnapshotsTableData({
    required this.id,
    this.currentSongId,
    required this.queueSongIds,
    required this.currentQueueIndex,
    required this.positionMs,
    required this.repeatMode,
    required this.isShuffle,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || currentSongId != null) {
      map['current_song_id'] = Variable<String>(currentSongId);
    }
    map['queue_song_ids'] = Variable<String>(queueSongIds);
    map['current_queue_index'] = Variable<int>(currentQueueIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['is_shuffle'] = Variable<bool>(isShuffle);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlayerSnapshotsTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerSnapshotsTableCompanion(
      id: Value(id),
      currentSongId: currentSongId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSongId),
      queueSongIds: Value(queueSongIds),
      currentQueueIndex: Value(currentQueueIndex),
      positionMs: Value(positionMs),
      repeatMode: Value(repeatMode),
      isShuffle: Value(isShuffle),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlayerSnapshotsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerSnapshotsTableData(
      id: serializer.fromJson<String>(json['id']),
      currentSongId: serializer.fromJson<String?>(json['currentSongId']),
      queueSongIds: serializer.fromJson<String>(json['queueSongIds']),
      currentQueueIndex: serializer.fromJson<int>(json['currentQueueIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      isShuffle: serializer.fromJson<bool>(json['isShuffle']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currentSongId': serializer.toJson<String?>(currentSongId),
      'queueSongIds': serializer.toJson<String>(queueSongIds),
      'currentQueueIndex': serializer.toJson<int>(currentQueueIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'isShuffle': serializer.toJson<bool>(isShuffle),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlayerSnapshotsTableData copyWith({
    String? id,
    Value<String?> currentSongId = const Value.absent(),
    String? queueSongIds,
    int? currentQueueIndex,
    int? positionMs,
    String? repeatMode,
    bool? isShuffle,
    DateTime? updatedAt,
  }) => PlayerSnapshotsTableData(
    id: id ?? this.id,
    currentSongId: currentSongId.present
        ? currentSongId.value
        : this.currentSongId,
    queueSongIds: queueSongIds ?? this.queueSongIds,
    currentQueueIndex: currentQueueIndex ?? this.currentQueueIndex,
    positionMs: positionMs ?? this.positionMs,
    repeatMode: repeatMode ?? this.repeatMode,
    isShuffle: isShuffle ?? this.isShuffle,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlayerSnapshotsTableData copyWithCompanion(
    PlayerSnapshotsTableCompanion data,
  ) {
    return PlayerSnapshotsTableData(
      id: data.id.present ? data.id.value : this.id,
      currentSongId: data.currentSongId.present
          ? data.currentSongId.value
          : this.currentSongId,
      queueSongIds: data.queueSongIds.present
          ? data.queueSongIds.value
          : this.queueSongIds,
      currentQueueIndex: data.currentQueueIndex.present
          ? data.currentQueueIndex.value
          : this.currentQueueIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      isShuffle: data.isShuffle.present ? data.isShuffle.value : this.isShuffle,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerSnapshotsTableData(')
          ..write('id: $id, ')
          ..write('currentSongId: $currentSongId, ')
          ..write('queueSongIds: $queueSongIds, ')
          ..write('currentQueueIndex: $currentQueueIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('isShuffle: $isShuffle, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentSongId,
    queueSongIds,
    currentQueueIndex,
    positionMs,
    repeatMode,
    isShuffle,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerSnapshotsTableData &&
          other.id == this.id &&
          other.currentSongId == this.currentSongId &&
          other.queueSongIds == this.queueSongIds &&
          other.currentQueueIndex == this.currentQueueIndex &&
          other.positionMs == this.positionMs &&
          other.repeatMode == this.repeatMode &&
          other.isShuffle == this.isShuffle &&
          other.updatedAt == this.updatedAt);
}

class PlayerSnapshotsTableCompanion
    extends UpdateCompanion<PlayerSnapshotsTableData> {
  final Value<String> id;
  final Value<String?> currentSongId;
  final Value<String> queueSongIds;
  final Value<int> currentQueueIndex;
  final Value<int> positionMs;
  final Value<String> repeatMode;
  final Value<bool> isShuffle;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlayerSnapshotsTableCompanion({
    this.id = const Value.absent(),
    this.currentSongId = const Value.absent(),
    this.queueSongIds = const Value.absent(),
    this.currentQueueIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.isShuffle = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerSnapshotsTableCompanion.insert({
    required String id,
    this.currentSongId = const Value.absent(),
    this.queueSongIds = const Value.absent(),
    this.currentQueueIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.isShuffle = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PlayerSnapshotsTableData> custom({
    Expression<String>? id,
    Expression<String>? currentSongId,
    Expression<String>? queueSongIds,
    Expression<int>? currentQueueIndex,
    Expression<int>? positionMs,
    Expression<String>? repeatMode,
    Expression<bool>? isShuffle,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentSongId != null) 'current_song_id': currentSongId,
      if (queueSongIds != null) 'queue_song_ids': queueSongIds,
      if (currentQueueIndex != null) 'current_queue_index': currentQueueIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (isShuffle != null) 'is_shuffle': isShuffle,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerSnapshotsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? currentSongId,
    Value<String>? queueSongIds,
    Value<int>? currentQueueIndex,
    Value<int>? positionMs,
    Value<String>? repeatMode,
    Value<bool>? isShuffle,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlayerSnapshotsTableCompanion(
      id: id ?? this.id,
      currentSongId: currentSongId ?? this.currentSongId,
      queueSongIds: queueSongIds ?? this.queueSongIds,
      currentQueueIndex: currentQueueIndex ?? this.currentQueueIndex,
      positionMs: positionMs ?? this.positionMs,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffle: isShuffle ?? this.isShuffle,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currentSongId.present) {
      map['current_song_id'] = Variable<String>(currentSongId.value);
    }
    if (queueSongIds.present) {
      map['queue_song_ids'] = Variable<String>(queueSongIds.value);
    }
    if (currentQueueIndex.present) {
      map['current_queue_index'] = Variable<int>(currentQueueIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (isShuffle.present) {
      map['is_shuffle'] = Variable<bool>(isShuffle.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerSnapshotsTableCompanion(')
          ..write('id: $id, ')
          ..write('currentSongId: $currentSongId, ')
          ..write('queueSongIds: $queueSongIds, ')
          ..write('currentQueueIndex: $currentQueueIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('isShuffle: $isShuffle, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTableTable songsTable = $SongsTableTable(this);
  late final $FavoritesTableTable favoritesTable = $FavoritesTableTable(this);
  late final $ListeningHistoryTableTable listeningHistoryTable =
      $ListeningHistoryTableTable(this);
  late final $PlaylistsTableTable playlistsTable = $PlaylistsTableTable(this);
  late final $PlaylistSongsTableTable playlistSongsTable =
      $PlaylistSongsTableTable(this);
  late final $DownloadsTableTable downloadsTable = $DownloadsTableTable(this);
  late final $PlayerSnapshotsTableTable playerSnapshotsTable =
      $PlayerSnapshotsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songsTable,
    favoritesTable,
    listeningHistoryTable,
    playlistsTable,
    playlistSongsTable,
    downloadsTable,
    playerSnapshotsTable,
  ];
}

typedef $$SongsTableTableCreateCompanionBuilder = SongsTableCompanion Function({
  required String id,
  required String provider,
  Value<String?> providerTrackId,
  required String title,
  required String artist,
  required String album,
  required String artworkUrl,
  Value<String?> streamUrl,
  Value<String?> downloadUrl,
  Value<bool> isDownloadable,
  required int durationMs,
  Value<String?> genre,
  Value<DateTime?> releaseDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SongsTableTableUpdateCompanionBuilder = SongsTableCompanion Function({
  Value<String> id,
  Value<String> provider,
  Value<String?> providerTrackId,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String> artworkUrl,
  Value<String?> streamUrl,
  Value<String?> downloadUrl,
  Value<bool> isDownloadable,
  Value<int> durationMs,
  Value<String?> genre,
  Value<DateTime?> releaseDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SongsTableTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTableTable, SongsTableData> {
  $$SongsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FavoritesTableTable, List<FavoritesTableData>>
  _favoritesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.favoritesTable,
    aliasName: 'songs_table__id__favorites_table__song_id',
  );

  $$FavoritesTableTableProcessedTableManager get favoritesTableRefs {
    final manager = $$FavoritesTableTableTableManager(
      $_db,
      $_db.favoritesTable,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_favoritesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ListeningHistoryTableTable,
    List<ListeningHistoryTableData>
  >
  _listeningHistoryTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.listeningHistoryTable,
        aliasName: 'songs_table__id__listening_history_table__song_id',
      );

  $$ListeningHistoryTableTableProcessedTableManager
  get listeningHistoryTableRefs {
    final manager = $$ListeningHistoryTableTableTableManager(
      $_db,
      $_db.listeningHistoryTable,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _listeningHistoryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PlaylistSongsTableTable,
    List<PlaylistSongsTableData>
  >
  _playlistSongsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistSongsTable,
        aliasName: 'songs_table__id__playlist_songs_table__song_id',
      );

  $$PlaylistSongsTableTableProcessedTableManager get playlistSongsTableRefs {
    final manager = $$PlaylistSongsTableTableTableManager(
      $_db,
      $_db.playlistSongsTable,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSongsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadsTableTable, List<DownloadsTableData>>
  _downloadsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadsTable,
    aliasName: 'songs_table__id__downloads_table__song_id',
  );

  $$DownloadsTableTableProcessedTableManager get downloadsTableRefs {
    final manager = $$DownloadsTableTableTableManager(
      $_db,
      $_db.downloadsTable,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloadable => $composableBuilder(
    column: $table.isDownloadable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> favoritesTableRefs(
    Expression<bool> Function($$FavoritesTableTableFilterComposer f) f,
  ) {
    final $$FavoritesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favoritesTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableTableFilterComposer(
            $db: $db,
            $table: $db.favoritesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> listeningHistoryTableRefs(
    Expression<bool> Function($$ListeningHistoryTableTableFilterComposer f) f,
  ) {
    final $$ListeningHistoryTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.listeningHistoryTable,
          getReferencedColumn: (t) => t.songId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ListeningHistoryTableTableFilterComposer(
                $db: $db,
                $table: $db.listeningHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> playlistSongsTableRefs(
    Expression<bool> Function($$PlaylistSongsTableTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongsTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadsTableRefs(
    Expression<bool> Function($$DownloadsTableTableFilterComposer f) f,
  ) {
    final $$DownloadsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadsTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableTableFilterComposer(
            $db: $db,
            $table: $db.downloadsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloadable => $composableBuilder(
    column: $table.isDownloadable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get providerTrackId => $composableBuilder(
    column: $table.providerTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streamUrl =>
      $composableBuilder(column: $table.streamUrl, builder: (column) => column);

  GeneratedColumn<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDownloadable => $composableBuilder(
    column: $table.isDownloadable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> favoritesTableRefs<T extends Object>(
    Expression<T> Function($$FavoritesTableTableAnnotationComposer a) f,
  ) {
    final $$FavoritesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favoritesTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.favoritesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> listeningHistoryTableRefs<T extends Object>(
    Expression<T> Function($$ListeningHistoryTableTableAnnotationComposer a) f,
  ) {
    final $$ListeningHistoryTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.listeningHistoryTable,
          getReferencedColumn: (t) => t.songId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ListeningHistoryTableTableAnnotationComposer(
                $db: $db,
                $table: $db.listeningHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playlistSongsTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistSongsTable,
          getReferencedColumn: (t) => t.songId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSongsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSongsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> downloadsTableRefs<T extends Object>(
    Expression<T> Function($$DownloadsTableTableAnnotationComposer a) f,
  ) {
    final $$DownloadsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadsTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTableTable,
          SongsTableData,
          $$SongsTableTableFilterComposer,
          $$SongsTableTableOrderingComposer,
          $$SongsTableTableAnnotationComposer,
          $$SongsTableTableCreateCompanionBuilder,
          $$SongsTableTableUpdateCompanionBuilder,
          (SongsTableData, $$SongsTableTableReferences),
          SongsTableData,
          PrefetchHooks Function({
            bool favoritesTableRefs,
            bool listeningHistoryTableRefs,
            bool playlistSongsTableRefs,
            bool downloadsTableRefs,
          })
        > {
  $$SongsTableTableTableManager(_$AppDatabase db, $SongsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String?> providerTrackId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> artworkUrl = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                Value<String?> downloadUrl = const Value.absent(),
                Value<bool> isDownloadable = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsTableCompanion(
                id: id,
                provider: provider,
                providerTrackId: providerTrackId,
                title: title,
                artist: artist,
                album: album,
                artworkUrl: artworkUrl,
                streamUrl: streamUrl,
                downloadUrl: downloadUrl,
                isDownloadable: isDownloadable,
                durationMs: durationMs,
                genre: genre,
                releaseDate: releaseDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String provider,
                Value<String?> providerTrackId = const Value.absent(),
                required String title,
                required String artist,
                required String album,
                required String artworkUrl,
                Value<String?> streamUrl = const Value.absent(),
                Value<String?> downloadUrl = const Value.absent(),
                Value<bool> isDownloadable = const Value.absent(),
                required int durationMs,
                Value<String?> genre = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsTableCompanion.insert(
                id: id,
                provider: provider,
                providerTrackId: providerTrackId,
                title: title,
                artist: artist,
                album: album,
                artworkUrl: artworkUrl,
                streamUrl: streamUrl,
                downloadUrl: downloadUrl,
                isDownloadable: isDownloadable,
                durationMs: durationMs,
                genre: genre,
                releaseDate: releaseDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongsTableTable, SongsTableData>(table),
                  $$SongsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                favoritesTableRefs = false,
                listeningHistoryTableRefs = false,
                playlistSongsTableRefs = false,
                downloadsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (favoritesTableRefs) db.favoritesTable,
                    if (listeningHistoryTableRefs) db.listeningHistoryTable,
                    if (playlistSongsTableRefs) db.playlistSongsTable,
                    if (downloadsTableRefs) db.downloadsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (favoritesTableRefs)
                        await $_getPrefetchedData<
                          SongsTableData,
                          $SongsTableTable,
                          FavoritesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableTableReferences
                              ._favoritesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).favoritesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (listeningHistoryTableRefs)
                        await $_getPrefetchedData<
                          SongsTableData,
                          $SongsTableTable,
                          ListeningHistoryTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableTableReferences
                              ._listeningHistoryTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).listeningHistoryTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistSongsTableRefs)
                        await $_getPrefetchedData<
                          SongsTableData,
                          $SongsTableTable,
                          PlaylistSongsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableTableReferences
                              ._playlistSongsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (downloadsTableRefs)
                        await $_getPrefetchedData<
                          SongsTableData,
                          $SongsTableTable,
                          DownloadsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableTableReferences
                              ._downloadsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SongsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTableTable,
      SongsTableData,
      $$SongsTableTableFilterComposer,
      $$SongsTableTableOrderingComposer,
      $$SongsTableTableAnnotationComposer,
      $$SongsTableTableCreateCompanionBuilder,
      $$SongsTableTableUpdateCompanionBuilder,
      (SongsTableData, $$SongsTableTableReferences),
      SongsTableData,
      PrefetchHooks Function({
        bool favoritesTableRefs,
        bool listeningHistoryTableRefs,
        bool playlistSongsTableRefs,
        bool downloadsTableRefs,
      })
    >;
typedef $$FavoritesTableTableCreateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<int> id,
      required String songId,
      Value<DateTime> createdAt,
    });
typedef $$FavoritesTableTableUpdateCompanionBuilder =
    FavoritesTableCompanion Function({
      Value<int> id,
      Value<String> songId,
      Value<DateTime> createdAt,
    });

final class $$FavoritesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FavoritesTableTable,
          FavoritesTableData
        > {
  $$FavoritesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTableTable _songIdTable(_$AppDatabase db) =>
      db.songsTable.createAlias('favorites_table__song_id__songs_table__id');

  $$SongsTableTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableTableManager(
      $_db,
      $_db.songsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FavoritesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableTableFilterComposer get songId {
    final $$SongsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableFilterComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableTableOrderingComposer get songId {
    final $$SongsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableOrderingComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTableTable> {
  $$FavoritesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SongsTableTableAnnotationComposer get songId {
    final $$SongsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTableTable,
          FavoritesTableData,
          $$FavoritesTableTableFilterComposer,
          $$FavoritesTableTableOrderingComposer,
          $$FavoritesTableTableAnnotationComposer,
          $$FavoritesTableTableCreateCompanionBuilder,
          $$FavoritesTableTableUpdateCompanionBuilder,
          (FavoritesTableData, $$FavoritesTableTableReferences),
          FavoritesTableData,
          PrefetchHooks Function({bool songId})
        > {
  $$FavoritesTableTableTableManager(
    _$AppDatabase db,
    $FavoritesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoritesTableCompanion(
                id: id,
                songId: songId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songId,
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoritesTableCompanion.insert(
                id: id,
                songId: songId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTableTable, FavoritesTableData>(table),
                  $$FavoritesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$FavoritesTableTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$FavoritesTableTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FavoritesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTableTable,
      FavoritesTableData,
      $$FavoritesTableTableFilterComposer,
      $$FavoritesTableTableOrderingComposer,
      $$FavoritesTableTableAnnotationComposer,
      $$FavoritesTableTableCreateCompanionBuilder,
      $$FavoritesTableTableUpdateCompanionBuilder,
      (FavoritesTableData, $$FavoritesTableTableReferences),
      FavoritesTableData,
      PrefetchHooks Function({bool songId})
    >;
typedef $$ListeningHistoryTableTableCreateCompanionBuilder =
    ListeningHistoryTableCompanion Function({
      Value<int> id,
      required String songId,
      Value<DateTime> playedAt,
      Value<int> playCount,
    });
typedef $$ListeningHistoryTableTableUpdateCompanionBuilder =
    ListeningHistoryTableCompanion Function({
      Value<int> id,
      Value<String> songId,
      Value<DateTime> playedAt,
      Value<int> playCount,
    });

final class $$ListeningHistoryTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ListeningHistoryTableTable,
          ListeningHistoryTableData
        > {
  $$ListeningHistoryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTableTable _songIdTable(_$AppDatabase db) => db.songsTable
      .createAlias('listening_history_table__song_id__songs_table__id');

  $$SongsTableTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableTableManager(
      $_db,
      $_db.songsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ListeningHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningHistoryTableTable> {
  $$ListeningHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableTableFilterComposer get songId {
    final $$SongsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableFilterComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListeningHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningHistoryTableTable> {
  $$ListeningHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableTableOrderingComposer get songId {
    final $$SongsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableOrderingComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListeningHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningHistoryTableTable> {
  $$ListeningHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  $$SongsTableTableAnnotationComposer get songId {
    final $$SongsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListeningHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListeningHistoryTableTable,
          ListeningHistoryTableData,
          $$ListeningHistoryTableTableFilterComposer,
          $$ListeningHistoryTableTableOrderingComposer,
          $$ListeningHistoryTableTableAnnotationComposer,
          $$ListeningHistoryTableTableCreateCompanionBuilder,
          $$ListeningHistoryTableTableUpdateCompanionBuilder,
          (ListeningHistoryTableData, $$ListeningHistoryTableTableReferences),
          ListeningHistoryTableData,
          PrefetchHooks Function({bool songId})
        > {
  $$ListeningHistoryTableTableTableManager(
    _$AppDatabase db,
    $ListeningHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningHistoryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ListeningHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ListeningHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => ListeningHistoryTableCompanion(
                id: id,
                songId: songId,
                playedAt: playedAt,
                playCount: playCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songId,
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => ListeningHistoryTableCompanion.insert(
                id: id,
                songId: songId,
                playedAt: playedAt,
                playCount: playCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ListeningHistoryTableTable,
                    ListeningHistoryTableData
                  >(table),
                  $$ListeningHistoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$ListeningHistoryTableTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$ListeningHistoryTableTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ListeningHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListeningHistoryTableTable,
      ListeningHistoryTableData,
      $$ListeningHistoryTableTableFilterComposer,
      $$ListeningHistoryTableTableOrderingComposer,
      $$ListeningHistoryTableTableAnnotationComposer,
      $$ListeningHistoryTableTableCreateCompanionBuilder,
      $$ListeningHistoryTableTableUpdateCompanionBuilder,
      (ListeningHistoryTableData, $$ListeningHistoryTableTableReferences),
      ListeningHistoryTableData,
      PrefetchHooks Function({bool songId})
    >;
typedef $$PlaylistsTableTableCreateCompanionBuilder =
    PlaylistsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> artworkUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableTableUpdateCompanionBuilder =
    PlaylistsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> artworkUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PlaylistsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData
        > {
  $$PlaylistsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaylistSongsTableTable,
    List<PlaylistSongsTableData>
  >
  _playlistSongsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistSongsTable,
        aliasName: 'playlists_table__id__playlist_songs_table__playlist_id',
      );

  $$PlaylistSongsTableTableProcessedTableManager get playlistSongsTableRefs {
    final manager = $$PlaylistSongsTableTableTableManager(
      $_db,
      $_db.playlistSongsTable,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSongsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongsTableRefs(
    Expression<bool> Function($$PlaylistSongsTableTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongsTable,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTableTable> {
  $$PlaylistsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistSongsTableRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playlistSongsTable,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaylistSongsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.playlistSongsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaylistsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTableTable,
          PlaylistsTableData,
          $$PlaylistsTableTableFilterComposer,
          $$PlaylistsTableTableOrderingComposer,
          $$PlaylistsTableTableAnnotationComposer,
          $$PlaylistsTableTableCreateCompanionBuilder,
          $$PlaylistsTableTableUpdateCompanionBuilder,
          (PlaylistsTableData, $$PlaylistsTableTableReferences),
          PlaylistsTableData,
          PrefetchHooks Function({bool playlistSongsTableRefs})
        > {
  $$PlaylistsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion(
                id: id,
                name: name,
                description: description,
                artworkUrl: artworkUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                artworkUrl: artworkUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTableTable, PlaylistsTableData>(table),
                  $$PlaylistsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistSongsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSongsTableRefs) db.playlistSongsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSongsTableRefs)
                    await $_getPrefetchedData<
                      PlaylistsTableData,
                      $PlaylistsTableTable,
                      PlaylistSongsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableTableReferences
                          ._playlistSongsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistSongsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTableTable,
      PlaylistsTableData,
      $$PlaylistsTableTableFilterComposer,
      $$PlaylistsTableTableOrderingComposer,
      $$PlaylistsTableTableAnnotationComposer,
      $$PlaylistsTableTableCreateCompanionBuilder,
      $$PlaylistsTableTableUpdateCompanionBuilder,
      (PlaylistsTableData, $$PlaylistsTableTableReferences),
      PlaylistsTableData,
      PrefetchHooks Function({bool playlistSongsTableRefs})
    >;
typedef $$PlaylistSongsTableTableCreateCompanionBuilder =
    PlaylistSongsTableCompanion Function({
      Value<int> id,
      required String playlistId,
      required String songId,
      Value<int> position,
      Value<DateTime> addedAt,
    });
typedef $$PlaylistSongsTableTableUpdateCompanionBuilder =
    PlaylistSongsTableCompanion Function({
      Value<int> id,
      Value<String> playlistId,
      Value<String> songId,
      Value<int> position,
      Value<DateTime> addedAt,
    });

final class $$PlaylistSongsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistSongsTableTable,
          PlaylistSongsTableData
        > {
  $$PlaylistSongsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTableTable _playlistIdTable(_$AppDatabase db) => db
      .playlistsTable
      .createAlias('playlist_songs_table__playlist_id__playlists_table__id');

  $$PlaylistsTableTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableTableManager(
      $_db,
      $_db.playlistsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongsTableTable _songIdTable(_$AppDatabase db) => db.songsTable
      .createAlias('playlist_songs_table__song_id__songs_table__id');

  $$SongsTableTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableTableManager(
      $_db,
      $_db.songsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistSongsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTableTable> {
  $$PlaylistSongsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableTableFilterComposer get playlistId {
    final $$PlaylistsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableFilterComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableTableFilterComposer get songId {
    final $$SongsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableFilterComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTableTable> {
  $$PlaylistSongsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableTableOrderingComposer get playlistId {
    final $$PlaylistsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableOrderingComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableTableOrderingComposer get songId {
    final $$SongsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableOrderingComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTableTable> {
  $$PlaylistSongsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableTableAnnotationComposer get playlistId {
    final $$PlaylistsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableTableAnnotationComposer get songId {
    final $$SongsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongsTableTable,
          PlaylistSongsTableData,
          $$PlaylistSongsTableTableFilterComposer,
          $$PlaylistSongsTableTableOrderingComposer,
          $$PlaylistSongsTableTableAnnotationComposer,
          $$PlaylistSongsTableTableCreateCompanionBuilder,
          $$PlaylistSongsTableTableUpdateCompanionBuilder,
          (PlaylistSongsTableData, $$PlaylistSongsTableTableReferences),
          PlaylistSongsTableData,
          PrefetchHooks Function({bool playlistId, bool songId})
        > {
  $$PlaylistSongsTableTableTableManager(
    _$AppDatabase db,
    $PlaylistSongsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => PlaylistSongsTableCompanion(
                id: id,
                playlistId: playlistId,
                songId: songId,
                position: position,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String playlistId,
                required String songId,
                Value<int> position = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => PlaylistSongsTableCompanion.insert(
                id: id,
                playlistId: playlistId,
                songId: songId,
                position: position,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistSongsTableTable, PlaylistSongsTableData>(
                    table,
                  ),
                  $$PlaylistSongsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$PlaylistSongsTableTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$PlaylistSongsTableTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$PlaylistSongsTableTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$PlaylistSongsTableTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistSongsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongsTableTable,
      PlaylistSongsTableData,
      $$PlaylistSongsTableTableFilterComposer,
      $$PlaylistSongsTableTableOrderingComposer,
      $$PlaylistSongsTableTableAnnotationComposer,
      $$PlaylistSongsTableTableCreateCompanionBuilder,
      $$PlaylistSongsTableTableUpdateCompanionBuilder,
      (PlaylistSongsTableData, $$PlaylistSongsTableTableReferences),
      PlaylistSongsTableData,
      PrefetchHooks Function({bool playlistId, bool songId})
    >;
typedef $$DownloadsTableTableCreateCompanionBuilder =
    DownloadsTableCompanion Function({
      required String id,
      required String songId,
      Value<String> status,
      Value<String?> localPath,
      Value<int> downloadedBytes,
      Value<int> totalBytes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadsTableTableUpdateCompanionBuilder =
    DownloadsTableCompanion Function({
      Value<String> id,
      Value<String> songId,
      Value<String> status,
      Value<String?> localPath,
      Value<int> downloadedBytes,
      Value<int> totalBytes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DownloadsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DownloadsTableTable,
          DownloadsTableData
        > {
  $$DownloadsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTableTable _songIdTable(_$AppDatabase db) =>
      db.songsTable.createAlias('downloads_table__song_id__songs_table__id');

  $$SongsTableTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableTableManager(
      $_db,
      $_db.songsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTableTable> {
  $$DownloadsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableTableFilterComposer get songId {
    final $$SongsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableFilterComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTableTable> {
  $$DownloadsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableTableOrderingComposer get songId {
    final $$SongsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableOrderingComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTableTable> {
  $$DownloadsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SongsTableTableAnnotationComposer get songId {
    final $$SongsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.songsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTableTable,
          DownloadsTableData,
          $$DownloadsTableTableFilterComposer,
          $$DownloadsTableTableOrderingComposer,
          $$DownloadsTableTableAnnotationComposer,
          $$DownloadsTableTableCreateCompanionBuilder,
          $$DownloadsTableTableUpdateCompanionBuilder,
          (DownloadsTableData, $$DownloadsTableTableReferences),
          DownloadsTableData,
          PrefetchHooks Function({bool songId})
        > {
  $$DownloadsTableTableTableManager(
    _$AppDatabase db,
    $DownloadsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsTableCompanion(
                id: id,
                songId: songId,
                status: status,
                localPath: localPath,
                downloadedBytes: downloadedBytes,
                totalBytes: totalBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String songId,
                Value<String> status = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsTableCompanion.insert(
                id: id,
                songId: songId,
                status: status,
                localPath: localPath,
                downloadedBytes: downloadedBytes,
                totalBytes: totalBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadsTableTable, DownloadsTableData>(table),
                  $$DownloadsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$DownloadsTableTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$DownloadsTableTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTableTable,
      DownloadsTableData,
      $$DownloadsTableTableFilterComposer,
      $$DownloadsTableTableOrderingComposer,
      $$DownloadsTableTableAnnotationComposer,
      $$DownloadsTableTableCreateCompanionBuilder,
      $$DownloadsTableTableUpdateCompanionBuilder,
      (DownloadsTableData, $$DownloadsTableTableReferences),
      DownloadsTableData,
      PrefetchHooks Function({bool songId})
    >;
typedef $$PlayerSnapshotsTableTableCreateCompanionBuilder =
    PlayerSnapshotsTableCompanion Function({
      required String id,
      Value<String?> currentSongId,
      Value<String> queueSongIds,
      Value<int> currentQueueIndex,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<bool> isShuffle,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PlayerSnapshotsTableTableUpdateCompanionBuilder =
    PlayerSnapshotsTableCompanion Function({
      Value<String> id,
      Value<String?> currentSongId,
      Value<String> queueSongIds,
      Value<int> currentQueueIndex,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<bool> isShuffle,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlayerSnapshotsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerSnapshotsTableTable> {
  $$PlayerSnapshotsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentSongId => $composableBuilder(
    column: $table.currentSongId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queueSongIds => $composableBuilder(
    column: $table.queueSongIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentQueueIndex => $composableBuilder(
    column: $table.currentQueueIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShuffle => $composableBuilder(
    column: $table.isShuffle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerSnapshotsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerSnapshotsTableTable> {
  $$PlayerSnapshotsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentSongId => $composableBuilder(
    column: $table.currentSongId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queueSongIds => $composableBuilder(
    column: $table.queueSongIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentQueueIndex => $composableBuilder(
    column: $table.currentQueueIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShuffle => $composableBuilder(
    column: $table.isShuffle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerSnapshotsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerSnapshotsTableTable> {
  $$PlayerSnapshotsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currentSongId => $composableBuilder(
    column: $table.currentSongId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get queueSongIds => $composableBuilder(
    column: $table.queueSongIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentQueueIndex => $composableBuilder(
    column: $table.currentQueueIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isShuffle =>
      $composableBuilder(column: $table.isShuffle, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayerSnapshotsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerSnapshotsTableTable,
          PlayerSnapshotsTableData,
          $$PlayerSnapshotsTableTableFilterComposer,
          $$PlayerSnapshotsTableTableOrderingComposer,
          $$PlayerSnapshotsTableTableAnnotationComposer,
          $$PlayerSnapshotsTableTableCreateCompanionBuilder,
          $$PlayerSnapshotsTableTableUpdateCompanionBuilder,
          (
            PlayerSnapshotsTableData,
            BaseReferences<
              _$AppDatabase,
              $PlayerSnapshotsTableTable,
              PlayerSnapshotsTableData
            >,
          ),
          PlayerSnapshotsTableData,
          PrefetchHooks Function()
        > {
  $$PlayerSnapshotsTableTableTableManager(
    _$AppDatabase db,
    $PlayerSnapshotsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerSnapshotsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerSnapshotsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlayerSnapshotsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> currentSongId = const Value.absent(),
                Value<String> queueSongIds = const Value.absent(),
                Value<int> currentQueueIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> isShuffle = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerSnapshotsTableCompanion(
                id: id,
                currentSongId: currentSongId,
                queueSongIds: queueSongIds,
                currentQueueIndex: currentQueueIndex,
                positionMs: positionMs,
                repeatMode: repeatMode,
                isShuffle: isShuffle,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> currentSongId = const Value.absent(),
                Value<String> queueSongIds = const Value.absent(),
                Value<int> currentQueueIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> isShuffle = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerSnapshotsTableCompanion.insert(
                id: id,
                currentSongId: currentSongId,
                queueSongIds: queueSongIds,
                currentQueueIndex: currentQueueIndex,
                positionMs: positionMs,
                repeatMode: repeatMode,
                isShuffle: isShuffle,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PlayerSnapshotsTableTable,
                    PlayerSnapshotsTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayerSnapshotsTableTable,
                    PlayerSnapshotsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerSnapshotsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerSnapshotsTableTable,
      PlayerSnapshotsTableData,
      $$PlayerSnapshotsTableTableFilterComposer,
      $$PlayerSnapshotsTableTableOrderingComposer,
      $$PlayerSnapshotsTableTableAnnotationComposer,
      $$PlayerSnapshotsTableTableCreateCompanionBuilder,
      $$PlayerSnapshotsTableTableUpdateCompanionBuilder,
      (
        PlayerSnapshotsTableData,
        BaseReferences<
          _$AppDatabase,
          $PlayerSnapshotsTableTable,
          PlayerSnapshotsTableData
        >,
      ),
      PlayerSnapshotsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableTableManager get songsTable =>
      $$SongsTableTableTableManager(_db, _db.songsTable);
  $$FavoritesTableTableTableManager get favoritesTable =>
      $$FavoritesTableTableTableManager(_db, _db.favoritesTable);
  $$ListeningHistoryTableTableTableManager get listeningHistoryTable =>
      $$ListeningHistoryTableTableTableManager(_db, _db.listeningHistoryTable);
  $$PlaylistsTableTableTableManager get playlistsTable =>
      $$PlaylistsTableTableTableManager(_db, _db.playlistsTable);
  $$PlaylistSongsTableTableTableManager get playlistSongsTable =>
      $$PlaylistSongsTableTableTableManager(_db, _db.playlistSongsTable);
  $$DownloadsTableTableTableManager get downloadsTable =>
      $$DownloadsTableTableTableManager(_db, _db.downloadsTable);
  $$PlayerSnapshotsTableTableTableManager get playerSnapshotsTable =>
      $$PlayerSnapshotsTableTableTableManager(_db, _db.playerSnapshotsTable);
}
