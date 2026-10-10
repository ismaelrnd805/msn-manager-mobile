// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) => AppMetaData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeClientMeta =
      const VerificationMeta('typeClient');
  @override
  late final GeneratedColumn<String> typeClient = GeneratedColumn<String>(
      'type_client', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomAfficheMeta =
      const VerificationMeta('nomAffiche');
  @override
  late final GeneratedColumn<String> nomAffiche = GeneratedColumn<String>(
      'nom_affiche', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomLegalMeta =
      const VerificationMeta('nomLegal');
  @override
  late final GeneratedColumn<String> nomLegal = GeneratedColumn<String>(
      'nom_legal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telephonePrincipalMeta =
      const VerificationMeta('telephonePrincipal');
  @override
  late final GeneratedColumn<String> telephonePrincipal =
      GeneratedColumn<String>('telephone_principal', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailPrincipalMeta =
      const VerificationMeta('emailPrincipal');
  @override
  late final GeneratedColumn<String> emailPrincipal = GeneratedColumn<String>(
      'email_principal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _adresseMeta =
      const VerificationMeta('adresse');
  @override
  late final GeneratedColumn<String> adresse = GeneratedColumn<String>(
      'adresse', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
      'actif', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actif" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        typeClient,
        nomAffiche,
        nomLegal,
        telephonePrincipal,
        emailPrincipal,
        adresse,
        notes,
        actif,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(Insertable<Client> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type_client')) {
      context.handle(
          _typeClientMeta,
          typeClient.isAcceptableOrUnknown(
              data['type_client']!, _typeClientMeta));
    } else if (isInserting) {
      context.missing(_typeClientMeta);
    }
    if (data.containsKey('nom_affiche')) {
      context.handle(
          _nomAfficheMeta,
          nomAffiche.isAcceptableOrUnknown(
              data['nom_affiche']!, _nomAfficheMeta));
    } else if (isInserting) {
      context.missing(_nomAfficheMeta);
    }
    if (data.containsKey('nom_legal')) {
      context.handle(_nomLegalMeta,
          nomLegal.isAcceptableOrUnknown(data['nom_legal']!, _nomLegalMeta));
    }
    if (data.containsKey('telephone_principal')) {
      context.handle(
          _telephonePrincipalMeta,
          telephonePrincipal.isAcceptableOrUnknown(
              data['telephone_principal']!, _telephonePrincipalMeta));
    }
    if (data.containsKey('email_principal')) {
      context.handle(
          _emailPrincipalMeta,
          emailPrincipal.isAcceptableOrUnknown(
              data['email_principal']!, _emailPrincipalMeta));
    }
    if (data.containsKey('adresse')) {
      context.handle(_adresseMeta,
          adresse.isAcceptableOrUnknown(data['adresse']!, _adresseMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('actif')) {
      context.handle(
          _actifMeta, actif.isAcceptableOrUnknown(data['actif']!, _actifMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      typeClient: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_client'])!,
      nomAffiche: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom_affiche'])!,
      nomLegal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom_legal']),
      telephonePrincipal: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}telephone_principal']),
      emailPrincipal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email_principal']),
      adresse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adresse']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      actif: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actif'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String typeClient;
  final String nomAffiche;
  final String? nomLegal;
  final String? telephonePrincipal;
  final String? emailPrincipal;
  final String? adresse;
  final String? notes;
  final bool actif;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Client(
      {required this.id,
      required this.typeClient,
      required this.nomAffiche,
      this.nomLegal,
      this.telephonePrincipal,
      this.emailPrincipal,
      this.adresse,
      this.notes,
      required this.actif,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type_client'] = Variable<String>(typeClient);
    map['nom_affiche'] = Variable<String>(nomAffiche);
    if (!nullToAbsent || nomLegal != null) {
      map['nom_legal'] = Variable<String>(nomLegal);
    }
    if (!nullToAbsent || telephonePrincipal != null) {
      map['telephone_principal'] = Variable<String>(telephonePrincipal);
    }
    if (!nullToAbsent || emailPrincipal != null) {
      map['email_principal'] = Variable<String>(emailPrincipal);
    }
    if (!nullToAbsent || adresse != null) {
      map['adresse'] = Variable<String>(adresse);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['actif'] = Variable<bool>(actif);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      typeClient: Value(typeClient),
      nomAffiche: Value(nomAffiche),
      nomLegal: nomLegal == null && nullToAbsent
          ? const Value.absent()
          : Value(nomLegal),
      telephonePrincipal: telephonePrincipal == null && nullToAbsent
          ? const Value.absent()
          : Value(telephonePrincipal),
      emailPrincipal: emailPrincipal == null && nullToAbsent
          ? const Value.absent()
          : Value(emailPrincipal),
      adresse: adresse == null && nullToAbsent
          ? const Value.absent()
          : Value(adresse),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      actif: Value(actif),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Client.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      typeClient: serializer.fromJson<String>(json['typeClient']),
      nomAffiche: serializer.fromJson<String>(json['nomAffiche']),
      nomLegal: serializer.fromJson<String?>(json['nomLegal']),
      telephonePrincipal:
          serializer.fromJson<String?>(json['telephonePrincipal']),
      emailPrincipal: serializer.fromJson<String?>(json['emailPrincipal']),
      adresse: serializer.fromJson<String?>(json['adresse']),
      notes: serializer.fromJson<String?>(json['notes']),
      actif: serializer.fromJson<bool>(json['actif']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'typeClient': serializer.toJson<String>(typeClient),
      'nomAffiche': serializer.toJson<String>(nomAffiche),
      'nomLegal': serializer.toJson<String?>(nomLegal),
      'telephonePrincipal': serializer.toJson<String?>(telephonePrincipal),
      'emailPrincipal': serializer.toJson<String?>(emailPrincipal),
      'adresse': serializer.toJson<String?>(adresse),
      'notes': serializer.toJson<String?>(notes),
      'actif': serializer.toJson<bool>(actif),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Client copyWith(
          {String? id,
          String? typeClient,
          String? nomAffiche,
          Value<String?> nomLegal = const Value.absent(),
          Value<String?> telephonePrincipal = const Value.absent(),
          Value<String?> emailPrincipal = const Value.absent(),
          Value<String?> adresse = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? actif,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Client(
        id: id ?? this.id,
        typeClient: typeClient ?? this.typeClient,
        nomAffiche: nomAffiche ?? this.nomAffiche,
        nomLegal: nomLegal.present ? nomLegal.value : this.nomLegal,
        telephonePrincipal: telephonePrincipal.present
            ? telephonePrincipal.value
            : this.telephonePrincipal,
        emailPrincipal:
            emailPrincipal.present ? emailPrincipal.value : this.emailPrincipal,
        adresse: adresse.present ? adresse.value : this.adresse,
        notes: notes.present ? notes.value : this.notes,
        actif: actif ?? this.actif,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      typeClient:
          data.typeClient.present ? data.typeClient.value : this.typeClient,
      nomAffiche:
          data.nomAffiche.present ? data.nomAffiche.value : this.nomAffiche,
      nomLegal: data.nomLegal.present ? data.nomLegal.value : this.nomLegal,
      telephonePrincipal: data.telephonePrincipal.present
          ? data.telephonePrincipal.value
          : this.telephonePrincipal,
      emailPrincipal: data.emailPrincipal.present
          ? data.emailPrincipal.value
          : this.emailPrincipal,
      adresse: data.adresse.present ? data.adresse.value : this.adresse,
      notes: data.notes.present ? data.notes.value : this.notes,
      actif: data.actif.present ? data.actif.value : this.actif,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('typeClient: $typeClient, ')
          ..write('nomAffiche: $nomAffiche, ')
          ..write('nomLegal: $nomLegal, ')
          ..write('telephonePrincipal: $telephonePrincipal, ')
          ..write('emailPrincipal: $emailPrincipal, ')
          ..write('adresse: $adresse, ')
          ..write('notes: $notes, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      typeClient,
      nomAffiche,
      nomLegal,
      telephonePrincipal,
      emailPrincipal,
      adresse,
      notes,
      actif,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.typeClient == this.typeClient &&
          other.nomAffiche == this.nomAffiche &&
          other.nomLegal == this.nomLegal &&
          other.telephonePrincipal == this.telephonePrincipal &&
          other.emailPrincipal == this.emailPrincipal &&
          other.adresse == this.adresse &&
          other.notes == this.notes &&
          other.actif == this.actif &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> typeClient;
  final Value<String> nomAffiche;
  final Value<String?> nomLegal;
  final Value<String?> telephonePrincipal;
  final Value<String?> emailPrincipal;
  final Value<String?> adresse;
  final Value<String?> notes;
  final Value<bool> actif;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.typeClient = const Value.absent(),
    this.nomAffiche = const Value.absent(),
    this.nomLegal = const Value.absent(),
    this.telephonePrincipal = const Value.absent(),
    this.emailPrincipal = const Value.absent(),
    this.adresse = const Value.absent(),
    this.notes = const Value.absent(),
    this.actif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String typeClient,
    required String nomAffiche,
    this.nomLegal = const Value.absent(),
    this.telephonePrincipal = const Value.absent(),
    this.emailPrincipal = const Value.absent(),
    this.adresse = const Value.absent(),
    this.notes = const Value.absent(),
    this.actif = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        typeClient = Value(typeClient),
        nomAffiche = Value(nomAffiche),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? typeClient,
    Expression<String>? nomAffiche,
    Expression<String>? nomLegal,
    Expression<String>? telephonePrincipal,
    Expression<String>? emailPrincipal,
    Expression<String>? adresse,
    Expression<String>? notes,
    Expression<bool>? actif,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeClient != null) 'type_client': typeClient,
      if (nomAffiche != null) 'nom_affiche': nomAffiche,
      if (nomLegal != null) 'nom_legal': nomLegal,
      if (telephonePrincipal != null) 'telephone_principal': telephonePrincipal,
      if (emailPrincipal != null) 'email_principal': emailPrincipal,
      if (adresse != null) 'adresse': adresse,
      if (notes != null) 'notes': notes,
      if (actif != null) 'actif': actif,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? typeClient,
      Value<String>? nomAffiche,
      Value<String?>? nomLegal,
      Value<String?>? telephonePrincipal,
      Value<String?>? emailPrincipal,
      Value<String?>? adresse,
      Value<String?>? notes,
      Value<bool>? actif,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return ClientsCompanion(
      id: id ?? this.id,
      typeClient: typeClient ?? this.typeClient,
      nomAffiche: nomAffiche ?? this.nomAffiche,
      nomLegal: nomLegal ?? this.nomLegal,
      telephonePrincipal: telephonePrincipal ?? this.telephonePrincipal,
      emailPrincipal: emailPrincipal ?? this.emailPrincipal,
      adresse: adresse ?? this.adresse,
      notes: notes ?? this.notes,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (typeClient.present) {
      map['type_client'] = Variable<String>(typeClient.value);
    }
    if (nomAffiche.present) {
      map['nom_affiche'] = Variable<String>(nomAffiche.value);
    }
    if (nomLegal.present) {
      map['nom_legal'] = Variable<String>(nomLegal.value);
    }
    if (telephonePrincipal.present) {
      map['telephone_principal'] = Variable<String>(telephonePrincipal.value);
    }
    if (emailPrincipal.present) {
      map['email_principal'] = Variable<String>(emailPrincipal.value);
    }
    if (adresse.present) {
      map['adresse'] = Variable<String>(adresse.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('typeClient: $typeClient, ')
          ..write('nomAffiche: $nomAffiche, ')
          ..write('nomLegal: $nomLegal, ')
          ..write('telephonePrincipal: $telephonePrincipal, ')
          ..write('emailPrincipal: $emailPrincipal, ')
          ..write('adresse: $adresse, ')
          ..write('notes: $notes, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telephoneMeta =
      const VerificationMeta('telephone');
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
      'telephone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _canalPrefereMeta =
      const VerificationMeta('canalPrefere');
  @override
  late final GeneratedColumn<String> canalPrefere = GeneratedColumn<String>(
      'canal_prefere', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _principalMeta =
      const VerificationMeta('principal');
  @override
  late final GeneratedColumn<bool> principal = GeneratedColumn<bool>(
      'principal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("principal" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientId,
        nom,
        role,
        telephone,
        email,
        canalPrefere,
        principal,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('telephone')) {
      context.handle(_telephoneMeta,
          telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('canal_prefere')) {
      context.handle(
          _canalPrefereMeta,
          canalPrefere.isAcceptableOrUnknown(
              data['canal_prefere']!, _canalPrefereMeta));
    }
    if (data.containsKey('principal')) {
      context.handle(_principalMeta,
          principal.isAcceptableOrUnknown(data['principal']!, _principalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      telephone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telephone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      canalPrefere: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canal_prefere']),
      principal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}principal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String id;
  final String clientId;
  final String nom;
  final String? role;
  final String? telephone;
  final String? email;
  final String? canalPrefere;
  final bool principal;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Contact(
      {required this.id,
      required this.clientId,
      required this.nom,
      this.role,
      this.telephone,
      this.email,
      this.canalPrefere,
      required this.principal,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || telephone != null) {
      map['telephone'] = Variable<String>(telephone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || canalPrefere != null) {
      map['canal_prefere'] = Variable<String>(canalPrefere);
    }
    map['principal'] = Variable<bool>(principal);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      nom: Value(nom),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      telephone: telephone == null && nullToAbsent
          ? const Value.absent()
          : Value(telephone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      canalPrefere: canalPrefere == null && nullToAbsent
          ? const Value.absent()
          : Value(canalPrefere),
      principal: Value(principal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      nom: serializer.fromJson<String>(json['nom']),
      role: serializer.fromJson<String?>(json['role']),
      telephone: serializer.fromJson<String?>(json['telephone']),
      email: serializer.fromJson<String?>(json['email']),
      canalPrefere: serializer.fromJson<String?>(json['canalPrefere']),
      principal: serializer.fromJson<bool>(json['principal']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'nom': serializer.toJson<String>(nom),
      'role': serializer.toJson<String?>(role),
      'telephone': serializer.toJson<String?>(telephone),
      'email': serializer.toJson<String?>(email),
      'canalPrefere': serializer.toJson<String?>(canalPrefere),
      'principal': serializer.toJson<bool>(principal),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Contact copyWith(
          {String? id,
          String? clientId,
          String? nom,
          Value<String?> role = const Value.absent(),
          Value<String?> telephone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> canalPrefere = const Value.absent(),
          bool? principal,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Contact(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        nom: nom ?? this.nom,
        role: role.present ? role.value : this.role,
        telephone: telephone.present ? telephone.value : this.telephone,
        email: email.present ? email.value : this.email,
        canalPrefere:
            canalPrefere.present ? canalPrefere.value : this.canalPrefere,
        principal: principal ?? this.principal,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      nom: data.nom.present ? data.nom.value : this.nom,
      role: data.role.present ? data.role.value : this.role,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      email: data.email.present ? data.email.value : this.email,
      canalPrefere: data.canalPrefere.present
          ? data.canalPrefere.value
          : this.canalPrefere,
      principal: data.principal.present ? data.principal.value : this.principal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('nom: $nom, ')
          ..write('role: $role, ')
          ..write('telephone: $telephone, ')
          ..write('email: $email, ')
          ..write('canalPrefere: $canalPrefere, ')
          ..write('principal: $principal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clientId, nom, role, telephone, email,
      canalPrefere, principal, createdAt, updatedAt, version, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.nom == this.nom &&
          other.role == this.role &&
          other.telephone == this.telephone &&
          other.email == this.email &&
          other.canalPrefere == this.canalPrefere &&
          other.principal == this.principal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> nom;
  final Value<String?> role;
  final Value<String?> telephone;
  final Value<String?> email;
  final Value<String?> canalPrefere;
  final Value<bool> principal;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.nom = const Value.absent(),
    this.role = const Value.absent(),
    this.telephone = const Value.absent(),
    this.email = const Value.absent(),
    this.canalPrefere = const Value.absent(),
    this.principal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String clientId,
    required String nom,
    this.role = const Value.absent(),
    this.telephone = const Value.absent(),
    this.email = const Value.absent(),
    this.canalPrefere = const Value.absent(),
    this.principal = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientId = Value(clientId),
        nom = Value(nom),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Contact> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? nom,
    Expression<String>? role,
    Expression<String>? telephone,
    Expression<String>? email,
    Expression<String>? canalPrefere,
    Expression<bool>? principal,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (nom != null) 'nom': nom,
      if (role != null) 'role': role,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (canalPrefere != null) 'canal_prefere': canalPrefere,
      if (principal != null) 'principal': principal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientId,
      Value<String>? nom,
      Value<String?>? role,
      Value<String?>? telephone,
      Value<String?>? email,
      Value<String?>? canalPrefere,
      Value<bool>? principal,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return ContactsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      nom: nom ?? this.nom,
      role: role ?? this.role,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      canalPrefere: canalPrefere ?? this.canalPrefere,
      principal: principal ?? this.principal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (canalPrefere.present) {
      map['canal_prefere'] = Variable<String>(canalPrefere.value);
    }
    if (principal.present) {
      map['principal'] = Variable<bool>(principal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('nom: $nom, ')
          ..write('role: $role, ')
          ..write('telephone: $telephone, ')
          ..write('email: $email, ')
          ..write('canalPrefere: $canalPrefere, ')
          ..write('principal: $principal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServicesTable extends Services with TableInfo<$ServicesTable, Service> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categorieMeta =
      const VerificationMeta('categorie');
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
      'categorie', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uniteTarifaireMeta =
      const VerificationMeta('uniteTarifaire');
  @override
  late final GeneratedColumn<String> uniteTarifaire = GeneratedColumn<String>(
      'unite_tarifaire', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
      'actif', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actif" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _necessiteCahierChargesMeta =
      const VerificationMeta('necessiteCahierCharges');
  @override
  late final GeneratedColumn<bool> necessiteCahierCharges =
      GeneratedColumn<bool>('necessite_cahier_charges', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("necessite_cahier_charges" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _questionsQualificationJsonMeta =
      const VerificationMeta('questionsQualificationJson');
  @override
  late final GeneratedColumn<String> questionsQualificationJson =
      GeneratedColumn<String>(
          'questions_qualification_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        nom,
        description,
        categorie,
        uniteTarifaire,
        actif,
        necessiteCahierCharges,
        questionsQualificationJson,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(Insertable<Service> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('categorie')) {
      context.handle(_categorieMeta,
          categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta));
    } else if (isInserting) {
      context.missing(_categorieMeta);
    }
    if (data.containsKey('unite_tarifaire')) {
      context.handle(
          _uniteTarifaireMeta,
          uniteTarifaire.isAcceptableOrUnknown(
              data['unite_tarifaire']!, _uniteTarifaireMeta));
    } else if (isInserting) {
      context.missing(_uniteTarifaireMeta);
    }
    if (data.containsKey('actif')) {
      context.handle(
          _actifMeta, actif.isAcceptableOrUnknown(data['actif']!, _actifMeta));
    }
    if (data.containsKey('necessite_cahier_charges')) {
      context.handle(
          _necessiteCahierChargesMeta,
          necessiteCahierCharges.isAcceptableOrUnknown(
              data['necessite_cahier_charges']!, _necessiteCahierChargesMeta));
    }
    if (data.containsKey('questions_qualification_json')) {
      context.handle(
          _questionsQualificationJsonMeta,
          questionsQualificationJson.isAcceptableOrUnknown(
              data['questions_qualification_json']!,
              _questionsQualificationJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Service map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Service(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      categorie: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categorie'])!,
      uniteTarifaire: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}unite_tarifaire'])!,
      actif: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actif'])!,
      necessiteCahierCharges: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}necessite_cahier_charges'])!,
      questionsQualificationJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}questions_qualification_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class Service extends DataClass implements Insertable<Service> {
  final String id;
  final String code;
  final String nom;
  final String? description;
  final String categorie;
  final String uniteTarifaire;
  final bool actif;
  final bool necessiteCahierCharges;
  final String questionsQualificationJson;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Service(
      {required this.id,
      required this.code,
      required this.nom,
      this.description,
      required this.categorie,
      required this.uniteTarifaire,
      required this.actif,
      required this.necessiteCahierCharges,
      required this.questionsQualificationJson,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['categorie'] = Variable<String>(categorie);
    map['unite_tarifaire'] = Variable<String>(uniteTarifaire);
    map['actif'] = Variable<bool>(actif);
    map['necessite_cahier_charges'] = Variable<bool>(necessiteCahierCharges);
    map['questions_qualification_json'] =
        Variable<String>(questionsQualificationJson);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      id: Value(id),
      code: Value(code),
      nom: Value(nom),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categorie: Value(categorie),
      uniteTarifaire: Value(uniteTarifaire),
      actif: Value(actif),
      necessiteCahierCharges: Value(necessiteCahierCharges),
      questionsQualificationJson: Value(questionsQualificationJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Service.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Service(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      nom: serializer.fromJson<String>(json['nom']),
      description: serializer.fromJson<String?>(json['description']),
      categorie: serializer.fromJson<String>(json['categorie']),
      uniteTarifaire: serializer.fromJson<String>(json['uniteTarifaire']),
      actif: serializer.fromJson<bool>(json['actif']),
      necessiteCahierCharges:
          serializer.fromJson<bool>(json['necessiteCahierCharges']),
      questionsQualificationJson:
          serializer.fromJson<String>(json['questionsQualificationJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'nom': serializer.toJson<String>(nom),
      'description': serializer.toJson<String?>(description),
      'categorie': serializer.toJson<String>(categorie),
      'uniteTarifaire': serializer.toJson<String>(uniteTarifaire),
      'actif': serializer.toJson<bool>(actif),
      'necessiteCahierCharges': serializer.toJson<bool>(necessiteCahierCharges),
      'questionsQualificationJson':
          serializer.toJson<String>(questionsQualificationJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Service copyWith(
          {String? id,
          String? code,
          String? nom,
          Value<String?> description = const Value.absent(),
          String? categorie,
          String? uniteTarifaire,
          bool? actif,
          bool? necessiteCahierCharges,
          String? questionsQualificationJson,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Service(
        id: id ?? this.id,
        code: code ?? this.code,
        nom: nom ?? this.nom,
        description: description.present ? description.value : this.description,
        categorie: categorie ?? this.categorie,
        uniteTarifaire: uniteTarifaire ?? this.uniteTarifaire,
        actif: actif ?? this.actif,
        necessiteCahierCharges:
            necessiteCahierCharges ?? this.necessiteCahierCharges,
        questionsQualificationJson:
            questionsQualificationJson ?? this.questionsQualificationJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Service copyWithCompanion(ServicesCompanion data) {
    return Service(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      nom: data.nom.present ? data.nom.value : this.nom,
      description:
          data.description.present ? data.description.value : this.description,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      uniteTarifaire: data.uniteTarifaire.present
          ? data.uniteTarifaire.value
          : this.uniteTarifaire,
      actif: data.actif.present ? data.actif.value : this.actif,
      necessiteCahierCharges: data.necessiteCahierCharges.present
          ? data.necessiteCahierCharges.value
          : this.necessiteCahierCharges,
      questionsQualificationJson: data.questionsQualificationJson.present
          ? data.questionsQualificationJson.value
          : this.questionsQualificationJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Service(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('categorie: $categorie, ')
          ..write('uniteTarifaire: $uniteTarifaire, ')
          ..write('actif: $actif, ')
          ..write('necessiteCahierCharges: $necessiteCahierCharges, ')
          ..write('questionsQualificationJson: $questionsQualificationJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      code,
      nom,
      description,
      categorie,
      uniteTarifaire,
      actif,
      necessiteCahierCharges,
      questionsQualificationJson,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Service &&
          other.id == this.id &&
          other.code == this.code &&
          other.nom == this.nom &&
          other.description == this.description &&
          other.categorie == this.categorie &&
          other.uniteTarifaire == this.uniteTarifaire &&
          other.actif == this.actif &&
          other.necessiteCahierCharges == this.necessiteCahierCharges &&
          other.questionsQualificationJson == this.questionsQualificationJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class ServicesCompanion extends UpdateCompanion<Service> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> nom;
  final Value<String?> description;
  final Value<String> categorie;
  final Value<String> uniteTarifaire;
  final Value<bool> actif;
  final Value<bool> necessiteCahierCharges;
  final Value<String> questionsQualificationJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const ServicesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.nom = const Value.absent(),
    this.description = const Value.absent(),
    this.categorie = const Value.absent(),
    this.uniteTarifaire = const Value.absent(),
    this.actif = const Value.absent(),
    this.necessiteCahierCharges = const Value.absent(),
    this.questionsQualificationJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServicesCompanion.insert({
    required String id,
    required String code,
    required String nom,
    this.description = const Value.absent(),
    required String categorie,
    required String uniteTarifaire,
    this.actif = const Value.absent(),
    this.necessiteCahierCharges = const Value.absent(),
    this.questionsQualificationJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        nom = Value(nom),
        categorie = Value(categorie),
        uniteTarifaire = Value(uniteTarifaire),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Service> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? nom,
    Expression<String>? description,
    Expression<String>? categorie,
    Expression<String>? uniteTarifaire,
    Expression<bool>? actif,
    Expression<bool>? necessiteCahierCharges,
    Expression<String>? questionsQualificationJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (categorie != null) 'categorie': categorie,
      if (uniteTarifaire != null) 'unite_tarifaire': uniteTarifaire,
      if (actif != null) 'actif': actif,
      if (necessiteCahierCharges != null)
        'necessite_cahier_charges': necessiteCahierCharges,
      if (questionsQualificationJson != null)
        'questions_qualification_json': questionsQualificationJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? nom,
      Value<String?>? description,
      Value<String>? categorie,
      Value<String>? uniteTarifaire,
      Value<bool>? actif,
      Value<bool>? necessiteCahierCharges,
      Value<String>? questionsQualificationJson,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return ServicesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
      uniteTarifaire: uniteTarifaire ?? this.uniteTarifaire,
      actif: actif ?? this.actif,
      necessiteCahierCharges:
          necessiteCahierCharges ?? this.necessiteCahierCharges,
      questionsQualificationJson:
          questionsQualificationJson ?? this.questionsQualificationJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (uniteTarifaire.present) {
      map['unite_tarifaire'] = Variable<String>(uniteTarifaire.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (necessiteCahierCharges.present) {
      map['necessite_cahier_charges'] =
          Variable<bool>(necessiteCahierCharges.value);
    }
    if (questionsQualificationJson.present) {
      map['questions_qualification_json'] =
          Variable<String>(questionsQualificationJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('categorie: $categorie, ')
          ..write('uniteTarifaire: $uniteTarifaire, ')
          ..write('actif: $actif, ')
          ..write('necessiteCahierCharges: $necessiteCahierCharges, ')
          ..write('questionsQualificationJson: $questionsQualificationJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TarifsTable extends Tarifs with TableInfo<$TarifsTable, Tarif> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarifsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prixUnitaireMeta =
      const VerificationMeta('prixUnitaire');
  @override
  late final GeneratedColumn<int> prixUnitaire = GeneratedColumn<int>(
      'prix_unitaire', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _dateDebutValiditeMeta =
      const VerificationMeta('dateDebutValidite');
  @override
  late final GeneratedColumn<String> dateDebutValidite =
      GeneratedColumn<String>('date_debut_validite', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateFinValiditeMeta =
      const VerificationMeta('dateFinValidite');
  @override
  late final GeneratedColumn<String> dateFinValidite = GeneratedColumn<String>(
      'date_fin_validite', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
      'actif', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actif" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serviceId,
        prixUnitaire,
        devise,
        dateDebutValidite,
        dateFinValidite,
        actif,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarifs';
  @override
  VerificationContext validateIntegrity(Insertable<Tarif> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('prix_unitaire')) {
      context.handle(
          _prixUnitaireMeta,
          prixUnitaire.isAcceptableOrUnknown(
              data['prix_unitaire']!, _prixUnitaireMeta));
    } else if (isInserting) {
      context.missing(_prixUnitaireMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('date_debut_validite')) {
      context.handle(
          _dateDebutValiditeMeta,
          dateDebutValidite.isAcceptableOrUnknown(
              data['date_debut_validite']!, _dateDebutValiditeMeta));
    } else if (isInserting) {
      context.missing(_dateDebutValiditeMeta);
    }
    if (data.containsKey('date_fin_validite')) {
      context.handle(
          _dateFinValiditeMeta,
          dateFinValidite.isAcceptableOrUnknown(
              data['date_fin_validite']!, _dateFinValiditeMeta));
    }
    if (data.containsKey('actif')) {
      context.handle(
          _actifMeta, actif.isAcceptableOrUnknown(data['actif']!, _actifMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tarif map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tarif(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_id'])!,
      prixUnitaire: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prix_unitaire'])!,
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      dateDebutValidite: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_debut_validite'])!,
      dateFinValidite: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_fin_validite']),
      actif: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actif'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TarifsTable createAlias(String alias) {
    return $TarifsTable(attachedDatabase, alias);
  }
}

class Tarif extends DataClass implements Insertable<Tarif> {
  final String id;
  final String serviceId;
  final int prixUnitaire;
  final String devise;
  final String dateDebutValidite;
  final String? dateFinValidite;
  final bool actif;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Tarif(
      {required this.id,
      required this.serviceId,
      required this.prixUnitaire,
      required this.devise,
      required this.dateDebutValidite,
      this.dateFinValidite,
      required this.actif,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['prix_unitaire'] = Variable<int>(prixUnitaire);
    map['devise'] = Variable<String>(devise);
    map['date_debut_validite'] = Variable<String>(dateDebutValidite);
    if (!nullToAbsent || dateFinValidite != null) {
      map['date_fin_validite'] = Variable<String>(dateFinValidite);
    }
    map['actif'] = Variable<bool>(actif);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  TarifsCompanion toCompanion(bool nullToAbsent) {
    return TarifsCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      prixUnitaire: Value(prixUnitaire),
      devise: Value(devise),
      dateDebutValidite: Value(dateDebutValidite),
      dateFinValidite: dateFinValidite == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFinValidite),
      actif: Value(actif),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Tarif.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tarif(
      id: serializer.fromJson<String>(json['id']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      prixUnitaire: serializer.fromJson<int>(json['prixUnitaire']),
      devise: serializer.fromJson<String>(json['devise']),
      dateDebutValidite: serializer.fromJson<String>(json['dateDebutValidite']),
      dateFinValidite: serializer.fromJson<String?>(json['dateFinValidite']),
      actif: serializer.fromJson<bool>(json['actif']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceId': serializer.toJson<String>(serviceId),
      'prixUnitaire': serializer.toJson<int>(prixUnitaire),
      'devise': serializer.toJson<String>(devise),
      'dateDebutValidite': serializer.toJson<String>(dateDebutValidite),
      'dateFinValidite': serializer.toJson<String?>(dateFinValidite),
      'actif': serializer.toJson<bool>(actif),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Tarif copyWith(
          {String? id,
          String? serviceId,
          int? prixUnitaire,
          String? devise,
          String? dateDebutValidite,
          Value<String?> dateFinValidite = const Value.absent(),
          bool? actif,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Tarif(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        prixUnitaire: prixUnitaire ?? this.prixUnitaire,
        devise: devise ?? this.devise,
        dateDebutValidite: dateDebutValidite ?? this.dateDebutValidite,
        dateFinValidite: dateFinValidite.present
            ? dateFinValidite.value
            : this.dateFinValidite,
        actif: actif ?? this.actif,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Tarif copyWithCompanion(TarifsCompanion data) {
    return Tarif(
      id: data.id.present ? data.id.value : this.id,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      prixUnitaire: data.prixUnitaire.present
          ? data.prixUnitaire.value
          : this.prixUnitaire,
      devise: data.devise.present ? data.devise.value : this.devise,
      dateDebutValidite: data.dateDebutValidite.present
          ? data.dateDebutValidite.value
          : this.dateDebutValidite,
      dateFinValidite: data.dateFinValidite.present
          ? data.dateFinValidite.value
          : this.dateFinValidite,
      actif: data.actif.present ? data.actif.value : this.actif,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tarif(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('devise: $devise, ')
          ..write('dateDebutValidite: $dateDebutValidite, ')
          ..write('dateFinValidite: $dateFinValidite, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serviceId,
      prixUnitaire,
      devise,
      dateDebutValidite,
      dateFinValidite,
      actif,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tarif &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.prixUnitaire == this.prixUnitaire &&
          other.devise == this.devise &&
          other.dateDebutValidite == this.dateDebutValidite &&
          other.dateFinValidite == this.dateFinValidite &&
          other.actif == this.actif &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class TarifsCompanion extends UpdateCompanion<Tarif> {
  final Value<String> id;
  final Value<String> serviceId;
  final Value<int> prixUnitaire;
  final Value<String> devise;
  final Value<String> dateDebutValidite;
  final Value<String?> dateFinValidite;
  final Value<bool> actif;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const TarifsCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.prixUnitaire = const Value.absent(),
    this.devise = const Value.absent(),
    this.dateDebutValidite = const Value.absent(),
    this.dateFinValidite = const Value.absent(),
    this.actif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TarifsCompanion.insert({
    required String id,
    required String serviceId,
    required int prixUnitaire,
    this.devise = const Value.absent(),
    required String dateDebutValidite,
    this.dateFinValidite = const Value.absent(),
    this.actif = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        serviceId = Value(serviceId),
        prixUnitaire = Value(prixUnitaire),
        dateDebutValidite = Value(dateDebutValidite),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Tarif> custom({
    Expression<String>? id,
    Expression<String>? serviceId,
    Expression<int>? prixUnitaire,
    Expression<String>? devise,
    Expression<String>? dateDebutValidite,
    Expression<String>? dateFinValidite,
    Expression<bool>? actif,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (devise != null) 'devise': devise,
      if (dateDebutValidite != null) 'date_debut_validite': dateDebutValidite,
      if (dateFinValidite != null) 'date_fin_validite': dateFinValidite,
      if (actif != null) 'actif': actif,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TarifsCompanion copyWith(
      {Value<String>? id,
      Value<String>? serviceId,
      Value<int>? prixUnitaire,
      Value<String>? devise,
      Value<String>? dateDebutValidite,
      Value<String?>? dateFinValidite,
      Value<bool>? actif,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return TarifsCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      devise: devise ?? this.devise,
      dateDebutValidite: dateDebutValidite ?? this.dateDebutValidite,
      dateFinValidite: dateFinValidite ?? this.dateFinValidite,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (prixUnitaire.present) {
      map['prix_unitaire'] = Variable<int>(prixUnitaire.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (dateDebutValidite.present) {
      map['date_debut_validite'] = Variable<String>(dateDebutValidite.value);
    }
    if (dateFinValidite.present) {
      map['date_fin_validite'] = Variable<String>(dateFinValidite.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarifsCompanion(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('devise: $devise, ')
          ..write('dateDebutValidite: $dateDebutValidite, ')
          ..write('dateFinValidite: $dateFinValidite, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DemandesTable extends Demandes with TableInfo<$DemandesTable, Demande> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DemandesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
      'contact_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _canalOrigineMeta =
      const VerificationMeta('canalOrigine');
  @override
  late final GeneratedColumn<String> canalOrigine = GeneratedColumn<String>(
      'canal_origine', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageInitialMeta =
      const VerificationMeta('messageInitial');
  @override
  late final GeneratedColumn<String> messageInitial = GeneratedColumn<String>(
      'message_initial', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _besoinResumeMeta =
      const VerificationMeta('besoinResume');
  @override
  late final GeneratedColumn<String> besoinResume = GeneratedColumn<String>(
      'besoin_resume', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('a_qualifier'));
  static const VerificationMeta _dateLimiteSouhaiteeMeta =
      const VerificationMeta('dateLimiteSouhaitee');
  @override
  late final GeneratedColumn<String> dateLimiteSouhaitee =
      GeneratedColumn<String>('date_limite_souhaitee', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _budgetIndicatifMeta =
      const VerificationMeta('budgetIndicatif');
  @override
  late final GeneratedColumn<int> budgetIndicatif = GeneratedColumn<int>(
      'budget_indicatif', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deviseBudgetMeta =
      const VerificationMeta('deviseBudget');
  @override
  late final GeneratedColumn<String> deviseBudget = GeneratedColumn<String>(
      'devise_budget', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _motifPerteMeta =
      const VerificationMeta('motifPerte');
  @override
  late final GeneratedColumn<String> motifPerte = GeneratedColumn<String>(
      'motif_perte', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientId,
        contactId,
        canalOrigine,
        messageInitial,
        besoinResume,
        statut,
        dateLimiteSouhaitee,
        budgetIndicatif,
        deviseBudget,
        motifPerte,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'demandes';
  @override
  VerificationContext validateIntegrity(Insertable<Demande> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    }
    if (data.containsKey('canal_origine')) {
      context.handle(
          _canalOrigineMeta,
          canalOrigine.isAcceptableOrUnknown(
              data['canal_origine']!, _canalOrigineMeta));
    } else if (isInserting) {
      context.missing(_canalOrigineMeta);
    }
    if (data.containsKey('message_initial')) {
      context.handle(
          _messageInitialMeta,
          messageInitial.isAcceptableOrUnknown(
              data['message_initial']!, _messageInitialMeta));
    } else if (isInserting) {
      context.missing(_messageInitialMeta);
    }
    if (data.containsKey('besoin_resume')) {
      context.handle(
          _besoinResumeMeta,
          besoinResume.isAcceptableOrUnknown(
              data['besoin_resume']!, _besoinResumeMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('date_limite_souhaitee')) {
      context.handle(
          _dateLimiteSouhaiteeMeta,
          dateLimiteSouhaitee.isAcceptableOrUnknown(
              data['date_limite_souhaitee']!, _dateLimiteSouhaiteeMeta));
    }
    if (data.containsKey('budget_indicatif')) {
      context.handle(
          _budgetIndicatifMeta,
          budgetIndicatif.isAcceptableOrUnknown(
              data['budget_indicatif']!, _budgetIndicatifMeta));
    }
    if (data.containsKey('devise_budget')) {
      context.handle(
          _deviseBudgetMeta,
          deviseBudget.isAcceptableOrUnknown(
              data['devise_budget']!, _deviseBudgetMeta));
    }
    if (data.containsKey('motif_perte')) {
      context.handle(
          _motifPerteMeta,
          motifPerte.isAcceptableOrUnknown(
              data['motif_perte']!, _motifPerteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Demande map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Demande(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_id']),
      canalOrigine: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canal_origine'])!,
      messageInitial: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}message_initial'])!,
      besoinResume: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}besoin_resume']),
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      dateLimiteSouhaitee: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_limite_souhaitee']),
      budgetIndicatif: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}budget_indicatif']),
      deviseBudget: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise_budget'])!,
      motifPerte: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motif_perte']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DemandesTable createAlias(String alias) {
    return $DemandesTable(attachedDatabase, alias);
  }
}

class Demande extends DataClass implements Insertable<Demande> {
  final String id;
  final String clientId;
  final String? contactId;
  final String canalOrigine;
  final String messageInitial;
  final String? besoinResume;
  final String statut;
  final String? dateLimiteSouhaitee;
  final int? budgetIndicatif;
  final String deviseBudget;
  final String? motifPerte;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Demande(
      {required this.id,
      required this.clientId,
      this.contactId,
      required this.canalOrigine,
      required this.messageInitial,
      this.besoinResume,
      required this.statut,
      this.dateLimiteSouhaitee,
      this.budgetIndicatif,
      required this.deviseBudget,
      this.motifPerte,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<String>(contactId);
    }
    map['canal_origine'] = Variable<String>(canalOrigine);
    map['message_initial'] = Variable<String>(messageInitial);
    if (!nullToAbsent || besoinResume != null) {
      map['besoin_resume'] = Variable<String>(besoinResume);
    }
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || dateLimiteSouhaitee != null) {
      map['date_limite_souhaitee'] = Variable<String>(dateLimiteSouhaitee);
    }
    if (!nullToAbsent || budgetIndicatif != null) {
      map['budget_indicatif'] = Variable<int>(budgetIndicatif);
    }
    map['devise_budget'] = Variable<String>(deviseBudget);
    if (!nullToAbsent || motifPerte != null) {
      map['motif_perte'] = Variable<String>(motifPerte);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  DemandesCompanion toCompanion(bool nullToAbsent) {
    return DemandesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      canalOrigine: Value(canalOrigine),
      messageInitial: Value(messageInitial),
      besoinResume: besoinResume == null && nullToAbsent
          ? const Value.absent()
          : Value(besoinResume),
      statut: Value(statut),
      dateLimiteSouhaitee: dateLimiteSouhaitee == null && nullToAbsent
          ? const Value.absent()
          : Value(dateLimiteSouhaitee),
      budgetIndicatif: budgetIndicatif == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetIndicatif),
      deviseBudget: Value(deviseBudget),
      motifPerte: motifPerte == null && nullToAbsent
          ? const Value.absent()
          : Value(motifPerte),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Demande.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Demande(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      contactId: serializer.fromJson<String?>(json['contactId']),
      canalOrigine: serializer.fromJson<String>(json['canalOrigine']),
      messageInitial: serializer.fromJson<String>(json['messageInitial']),
      besoinResume: serializer.fromJson<String?>(json['besoinResume']),
      statut: serializer.fromJson<String>(json['statut']),
      dateLimiteSouhaitee:
          serializer.fromJson<String?>(json['dateLimiteSouhaitee']),
      budgetIndicatif: serializer.fromJson<int?>(json['budgetIndicatif']),
      deviseBudget: serializer.fromJson<String>(json['deviseBudget']),
      motifPerte: serializer.fromJson<String?>(json['motifPerte']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'contactId': serializer.toJson<String?>(contactId),
      'canalOrigine': serializer.toJson<String>(canalOrigine),
      'messageInitial': serializer.toJson<String>(messageInitial),
      'besoinResume': serializer.toJson<String?>(besoinResume),
      'statut': serializer.toJson<String>(statut),
      'dateLimiteSouhaitee': serializer.toJson<String?>(dateLimiteSouhaitee),
      'budgetIndicatif': serializer.toJson<int?>(budgetIndicatif),
      'deviseBudget': serializer.toJson<String>(deviseBudget),
      'motifPerte': serializer.toJson<String?>(motifPerte),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Demande copyWith(
          {String? id,
          String? clientId,
          Value<String?> contactId = const Value.absent(),
          String? canalOrigine,
          String? messageInitial,
          Value<String?> besoinResume = const Value.absent(),
          String? statut,
          Value<String?> dateLimiteSouhaitee = const Value.absent(),
          Value<int?> budgetIndicatif = const Value.absent(),
          String? deviseBudget,
          Value<String?> motifPerte = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Demande(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        contactId: contactId.present ? contactId.value : this.contactId,
        canalOrigine: canalOrigine ?? this.canalOrigine,
        messageInitial: messageInitial ?? this.messageInitial,
        besoinResume:
            besoinResume.present ? besoinResume.value : this.besoinResume,
        statut: statut ?? this.statut,
        dateLimiteSouhaitee: dateLimiteSouhaitee.present
            ? dateLimiteSouhaitee.value
            : this.dateLimiteSouhaitee,
        budgetIndicatif: budgetIndicatif.present
            ? budgetIndicatif.value
            : this.budgetIndicatif,
        deviseBudget: deviseBudget ?? this.deviseBudget,
        motifPerte: motifPerte.present ? motifPerte.value : this.motifPerte,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Demande copyWithCompanion(DemandesCompanion data) {
    return Demande(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      canalOrigine: data.canalOrigine.present
          ? data.canalOrigine.value
          : this.canalOrigine,
      messageInitial: data.messageInitial.present
          ? data.messageInitial.value
          : this.messageInitial,
      besoinResume: data.besoinResume.present
          ? data.besoinResume.value
          : this.besoinResume,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateLimiteSouhaitee: data.dateLimiteSouhaitee.present
          ? data.dateLimiteSouhaitee.value
          : this.dateLimiteSouhaitee,
      budgetIndicatif: data.budgetIndicatif.present
          ? data.budgetIndicatif.value
          : this.budgetIndicatif,
      deviseBudget: data.deviseBudget.present
          ? data.deviseBudget.value
          : this.deviseBudget,
      motifPerte:
          data.motifPerte.present ? data.motifPerte.value : this.motifPerte,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Demande(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('contactId: $contactId, ')
          ..write('canalOrigine: $canalOrigine, ')
          ..write('messageInitial: $messageInitial, ')
          ..write('besoinResume: $besoinResume, ')
          ..write('statut: $statut, ')
          ..write('dateLimiteSouhaitee: $dateLimiteSouhaitee, ')
          ..write('budgetIndicatif: $budgetIndicatif, ')
          ..write('deviseBudget: $deviseBudget, ')
          ..write('motifPerte: $motifPerte, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      clientId,
      contactId,
      canalOrigine,
      messageInitial,
      besoinResume,
      statut,
      dateLimiteSouhaitee,
      budgetIndicatif,
      deviseBudget,
      motifPerte,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Demande &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.contactId == this.contactId &&
          other.canalOrigine == this.canalOrigine &&
          other.messageInitial == this.messageInitial &&
          other.besoinResume == this.besoinResume &&
          other.statut == this.statut &&
          other.dateLimiteSouhaitee == this.dateLimiteSouhaitee &&
          other.budgetIndicatif == this.budgetIndicatif &&
          other.deviseBudget == this.deviseBudget &&
          other.motifPerte == this.motifPerte &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class DemandesCompanion extends UpdateCompanion<Demande> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> contactId;
  final Value<String> canalOrigine;
  final Value<String> messageInitial;
  final Value<String?> besoinResume;
  final Value<String> statut;
  final Value<String?> dateLimiteSouhaitee;
  final Value<int?> budgetIndicatif;
  final Value<String> deviseBudget;
  final Value<String?> motifPerte;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const DemandesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.canalOrigine = const Value.absent(),
    this.messageInitial = const Value.absent(),
    this.besoinResume = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateLimiteSouhaitee = const Value.absent(),
    this.budgetIndicatif = const Value.absent(),
    this.deviseBudget = const Value.absent(),
    this.motifPerte = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DemandesCompanion.insert({
    required String id,
    required String clientId,
    this.contactId = const Value.absent(),
    required String canalOrigine,
    required String messageInitial,
    this.besoinResume = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateLimiteSouhaitee = const Value.absent(),
    this.budgetIndicatif = const Value.absent(),
    this.deviseBudget = const Value.absent(),
    this.motifPerte = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientId = Value(clientId),
        canalOrigine = Value(canalOrigine),
        messageInitial = Value(messageInitial),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Demande> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? contactId,
    Expression<String>? canalOrigine,
    Expression<String>? messageInitial,
    Expression<String>? besoinResume,
    Expression<String>? statut,
    Expression<String>? dateLimiteSouhaitee,
    Expression<int>? budgetIndicatif,
    Expression<String>? deviseBudget,
    Expression<String>? motifPerte,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (contactId != null) 'contact_id': contactId,
      if (canalOrigine != null) 'canal_origine': canalOrigine,
      if (messageInitial != null) 'message_initial': messageInitial,
      if (besoinResume != null) 'besoin_resume': besoinResume,
      if (statut != null) 'statut': statut,
      if (dateLimiteSouhaitee != null)
        'date_limite_souhaitee': dateLimiteSouhaitee,
      if (budgetIndicatif != null) 'budget_indicatif': budgetIndicatif,
      if (deviseBudget != null) 'devise_budget': deviseBudget,
      if (motifPerte != null) 'motif_perte': motifPerte,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DemandesCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientId,
      Value<String?>? contactId,
      Value<String>? canalOrigine,
      Value<String>? messageInitial,
      Value<String?>? besoinResume,
      Value<String>? statut,
      Value<String?>? dateLimiteSouhaitee,
      Value<int?>? budgetIndicatif,
      Value<String>? deviseBudget,
      Value<String?>? motifPerte,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return DemandesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      contactId: contactId ?? this.contactId,
      canalOrigine: canalOrigine ?? this.canalOrigine,
      messageInitial: messageInitial ?? this.messageInitial,
      besoinResume: besoinResume ?? this.besoinResume,
      statut: statut ?? this.statut,
      dateLimiteSouhaitee: dateLimiteSouhaitee ?? this.dateLimiteSouhaitee,
      budgetIndicatif: budgetIndicatif ?? this.budgetIndicatif,
      deviseBudget: deviseBudget ?? this.deviseBudget,
      motifPerte: motifPerte ?? this.motifPerte,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (canalOrigine.present) {
      map['canal_origine'] = Variable<String>(canalOrigine.value);
    }
    if (messageInitial.present) {
      map['message_initial'] = Variable<String>(messageInitial.value);
    }
    if (besoinResume.present) {
      map['besoin_resume'] = Variable<String>(besoinResume.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (dateLimiteSouhaitee.present) {
      map['date_limite_souhaitee'] =
          Variable<String>(dateLimiteSouhaitee.value);
    }
    if (budgetIndicatif.present) {
      map['budget_indicatif'] = Variable<int>(budgetIndicatif.value);
    }
    if (deviseBudget.present) {
      map['devise_budget'] = Variable<String>(deviseBudget.value);
    }
    if (motifPerte.present) {
      map['motif_perte'] = Variable<String>(motifPerte.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DemandesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('contactId: $contactId, ')
          ..write('canalOrigine: $canalOrigine, ')
          ..write('messageInitial: $messageInitial, ')
          ..write('besoinResume: $besoinResume, ')
          ..write('statut: $statut, ')
          ..write('dateLimiteSouhaitee: $dateLimiteSouhaitee, ')
          ..write('budgetIndicatif: $budgetIndicatif, ')
          ..write('deviseBudget: $deviseBudget, ')
          ..write('motifPerte: $motifPerte, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DemandePrestationsTable extends DemandePrestations
    with TableInfo<$DemandePrestationsTable, DemandePrestation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DemandePrestationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _demandeIdMeta =
      const VerificationMeta('demandeId');
  @override
  late final GeneratedColumn<String> demandeId = GeneratedColumn<String>(
      'demande_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<String> quantite = GeneratedColumn<String>(
      'quantite', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1'));
  static const VerificationMeta _uniteSnapshotMeta =
      const VerificationMeta('uniteSnapshot');
  @override
  late final GeneratedColumn<String> uniteSnapshot = GeneratedColumn<String>(
      'unite_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prixIndicatifUnitaireMeta =
      const VerificationMeta('prixIndicatifUnitaire');
  @override
  late final GeneratedColumn<int> prixIndicatifUnitaire = GeneratedColumn<int>(
      'prix_indicatif_unitaire', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _detailsJsonMeta =
      const VerificationMeta('detailsJson');
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
      'details_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        demandeId,
        serviceId,
        quantite,
        uniteSnapshot,
        prixIndicatifUnitaire,
        devise,
        detailsJson,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'demande_prestations';
  @override
  VerificationContext validateIntegrity(Insertable<DemandePrestation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('demande_id')) {
      context.handle(_demandeIdMeta,
          demandeId.isAcceptableOrUnknown(data['demande_id']!, _demandeIdMeta));
    } else if (isInserting) {
      context.missing(_demandeIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    }
    if (data.containsKey('unite_snapshot')) {
      context.handle(
          _uniteSnapshotMeta,
          uniteSnapshot.isAcceptableOrUnknown(
              data['unite_snapshot']!, _uniteSnapshotMeta));
    } else if (isInserting) {
      context.missing(_uniteSnapshotMeta);
    }
    if (data.containsKey('prix_indicatif_unitaire')) {
      context.handle(
          _prixIndicatifUnitaireMeta,
          prixIndicatifUnitaire.isAcceptableOrUnknown(
              data['prix_indicatif_unitaire']!, _prixIndicatifUnitaireMeta));
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('details_json')) {
      context.handle(
          _detailsJsonMeta,
          detailsJson.isAcceptableOrUnknown(
              data['details_json']!, _detailsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {demandeId, serviceId},
      ];
  @override
  DemandePrestation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DemandePrestation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      demandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}demande_id'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_id'])!,
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantite'])!,
      uniteSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unite_snapshot'])!,
      prixIndicatifUnitaire: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}prix_indicatif_unitaire']),
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      detailsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DemandePrestationsTable createAlias(String alias) {
    return $DemandePrestationsTable(attachedDatabase, alias);
  }
}

class DemandePrestation extends DataClass
    implements Insertable<DemandePrestation> {
  final String id;
  final String demandeId;
  final String serviceId;
  final String quantite;
  final String uniteSnapshot;
  final int? prixIndicatifUnitaire;
  final String devise;
  final String detailsJson;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const DemandePrestation(
      {required this.id,
      required this.demandeId,
      required this.serviceId,
      required this.quantite,
      required this.uniteSnapshot,
      this.prixIndicatifUnitaire,
      required this.devise,
      required this.detailsJson,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['demande_id'] = Variable<String>(demandeId);
    map['service_id'] = Variable<String>(serviceId);
    map['quantite'] = Variable<String>(quantite);
    map['unite_snapshot'] = Variable<String>(uniteSnapshot);
    if (!nullToAbsent || prixIndicatifUnitaire != null) {
      map['prix_indicatif_unitaire'] = Variable<int>(prixIndicatifUnitaire);
    }
    map['devise'] = Variable<String>(devise);
    map['details_json'] = Variable<String>(detailsJson);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  DemandePrestationsCompanion toCompanion(bool nullToAbsent) {
    return DemandePrestationsCompanion(
      id: Value(id),
      demandeId: Value(demandeId),
      serviceId: Value(serviceId),
      quantite: Value(quantite),
      uniteSnapshot: Value(uniteSnapshot),
      prixIndicatifUnitaire: prixIndicatifUnitaire == null && nullToAbsent
          ? const Value.absent()
          : Value(prixIndicatifUnitaire),
      devise: Value(devise),
      detailsJson: Value(detailsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DemandePrestation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DemandePrestation(
      id: serializer.fromJson<String>(json['id']),
      demandeId: serializer.fromJson<String>(json['demandeId']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      quantite: serializer.fromJson<String>(json['quantite']),
      uniteSnapshot: serializer.fromJson<String>(json['uniteSnapshot']),
      prixIndicatifUnitaire:
          serializer.fromJson<int?>(json['prixIndicatifUnitaire']),
      devise: serializer.fromJson<String>(json['devise']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'demandeId': serializer.toJson<String>(demandeId),
      'serviceId': serializer.toJson<String>(serviceId),
      'quantite': serializer.toJson<String>(quantite),
      'uniteSnapshot': serializer.toJson<String>(uniteSnapshot),
      'prixIndicatifUnitaire': serializer.toJson<int?>(prixIndicatifUnitaire),
      'devise': serializer.toJson<String>(devise),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  DemandePrestation copyWith(
          {String? id,
          String? demandeId,
          String? serviceId,
          String? quantite,
          String? uniteSnapshot,
          Value<int?> prixIndicatifUnitaire = const Value.absent(),
          String? devise,
          String? detailsJson,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      DemandePrestation(
        id: id ?? this.id,
        demandeId: demandeId ?? this.demandeId,
        serviceId: serviceId ?? this.serviceId,
        quantite: quantite ?? this.quantite,
        uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
        prixIndicatifUnitaire: prixIndicatifUnitaire.present
            ? prixIndicatifUnitaire.value
            : this.prixIndicatifUnitaire,
        devise: devise ?? this.devise,
        detailsJson: detailsJson ?? this.detailsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  DemandePrestation copyWithCompanion(DemandePrestationsCompanion data) {
    return DemandePrestation(
      id: data.id.present ? data.id.value : this.id,
      demandeId: data.demandeId.present ? data.demandeId.value : this.demandeId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteSnapshot: data.uniteSnapshot.present
          ? data.uniteSnapshot.value
          : this.uniteSnapshot,
      prixIndicatifUnitaire: data.prixIndicatifUnitaire.present
          ? data.prixIndicatifUnitaire.value
          : this.prixIndicatifUnitaire,
      devise: data.devise.present ? data.devise.value : this.devise,
      detailsJson:
          data.detailsJson.present ? data.detailsJson.value : this.detailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DemandePrestation(')
          ..write('id: $id, ')
          ..write('demandeId: $demandeId, ')
          ..write('serviceId: $serviceId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixIndicatifUnitaire: $prixIndicatifUnitaire, ')
          ..write('devise: $devise, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      demandeId,
      serviceId,
      quantite,
      uniteSnapshot,
      prixIndicatifUnitaire,
      devise,
      detailsJson,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DemandePrestation &&
          other.id == this.id &&
          other.demandeId == this.demandeId &&
          other.serviceId == this.serviceId &&
          other.quantite == this.quantite &&
          other.uniteSnapshot == this.uniteSnapshot &&
          other.prixIndicatifUnitaire == this.prixIndicatifUnitaire &&
          other.devise == this.devise &&
          other.detailsJson == this.detailsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class DemandePrestationsCompanion extends UpdateCompanion<DemandePrestation> {
  final Value<String> id;
  final Value<String> demandeId;
  final Value<String> serviceId;
  final Value<String> quantite;
  final Value<String> uniteSnapshot;
  final Value<int?> prixIndicatifUnitaire;
  final Value<String> devise;
  final Value<String> detailsJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const DemandePrestationsCompanion({
    this.id = const Value.absent(),
    this.demandeId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteSnapshot = const Value.absent(),
    this.prixIndicatifUnitaire = const Value.absent(),
    this.devise = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DemandePrestationsCompanion.insert({
    required String id,
    required String demandeId,
    required String serviceId,
    this.quantite = const Value.absent(),
    required String uniteSnapshot,
    this.prixIndicatifUnitaire = const Value.absent(),
    this.devise = const Value.absent(),
    this.detailsJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        demandeId = Value(demandeId),
        serviceId = Value(serviceId),
        uniteSnapshot = Value(uniteSnapshot),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DemandePrestation> custom({
    Expression<String>? id,
    Expression<String>? demandeId,
    Expression<String>? serviceId,
    Expression<String>? quantite,
    Expression<String>? uniteSnapshot,
    Expression<int>? prixIndicatifUnitaire,
    Expression<String>? devise,
    Expression<String>? detailsJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (demandeId != null) 'demande_id': demandeId,
      if (serviceId != null) 'service_id': serviceId,
      if (quantite != null) 'quantite': quantite,
      if (uniteSnapshot != null) 'unite_snapshot': uniteSnapshot,
      if (prixIndicatifUnitaire != null)
        'prix_indicatif_unitaire': prixIndicatifUnitaire,
      if (devise != null) 'devise': devise,
      if (detailsJson != null) 'details_json': detailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DemandePrestationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? demandeId,
      Value<String>? serviceId,
      Value<String>? quantite,
      Value<String>? uniteSnapshot,
      Value<int?>? prixIndicatifUnitaire,
      Value<String>? devise,
      Value<String>? detailsJson,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return DemandePrestationsCompanion(
      id: id ?? this.id,
      demandeId: demandeId ?? this.demandeId,
      serviceId: serviceId ?? this.serviceId,
      quantite: quantite ?? this.quantite,
      uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
      prixIndicatifUnitaire:
          prixIndicatifUnitaire ?? this.prixIndicatifUnitaire,
      devise: devise ?? this.devise,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (demandeId.present) {
      map['demande_id'] = Variable<String>(demandeId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<String>(quantite.value);
    }
    if (uniteSnapshot.present) {
      map['unite_snapshot'] = Variable<String>(uniteSnapshot.value);
    }
    if (prixIndicatifUnitaire.present) {
      map['prix_indicatif_unitaire'] =
          Variable<int>(prixIndicatifUnitaire.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DemandePrestationsCompanion(')
          ..write('id: $id, ')
          ..write('demandeId: $demandeId, ')
          ..write('serviceId: $serviceId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixIndicatifUnitaire: $prixIndicatifUnitaire, ')
          ..write('devise: $devise, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommandesTable extends Commandes
    with TableInfo<$CommandesTable, Commande> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<String> numero = GeneratedColumn<String>(
      'numero', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _demandeIdMeta =
      const VerificationMeta('demandeId');
  @override
  late final GeneratedColumn<String> demandeId = GeneratedColumn<String>(
      'demande_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_preparation'));
  static const VerificationMeta _dateConfirmationMeta =
      const VerificationMeta('dateConfirmation');
  @override
  late final GeneratedColumn<String> dateConfirmation = GeneratedColumn<String>(
      'date_confirmation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateDebutPrevueMeta =
      const VerificationMeta('dateDebutPrevue');
  @override
  late final GeneratedColumn<String> dateDebutPrevue = GeneratedColumn<String>(
      'date_debut_prevue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateLimiteConfirmeeMeta =
      const VerificationMeta('dateLimiteConfirmee');
  @override
  late final GeneratedColumn<String> dateLimiteConfirmee =
      GeneratedColumn<String>('date_limite_confirmee', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _motifAnnulationMeta =
      const VerificationMeta('motifAnnulation');
  @override
  late final GeneratedColumn<String> motifAnnulation = GeneratedColumn<String>(
      'motif_annulation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        numero,
        demandeId,
        statut,
        dateConfirmation,
        dateDebutPrevue,
        dateLimiteConfirmee,
        instructions,
        motifAnnulation,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commandes';
  @override
  VerificationContext validateIntegrity(Insertable<Commande> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(_numeroMeta,
          numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta));
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('demande_id')) {
      context.handle(_demandeIdMeta,
          demandeId.isAcceptableOrUnknown(data['demande_id']!, _demandeIdMeta));
    } else if (isInserting) {
      context.missing(_demandeIdMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('date_confirmation')) {
      context.handle(
          _dateConfirmationMeta,
          dateConfirmation.isAcceptableOrUnknown(
              data['date_confirmation']!, _dateConfirmationMeta));
    }
    if (data.containsKey('date_debut_prevue')) {
      context.handle(
          _dateDebutPrevueMeta,
          dateDebutPrevue.isAcceptableOrUnknown(
              data['date_debut_prevue']!, _dateDebutPrevueMeta));
    }
    if (data.containsKey('date_limite_confirmee')) {
      context.handle(
          _dateLimiteConfirmeeMeta,
          dateLimiteConfirmee.isAcceptableOrUnknown(
              data['date_limite_confirmee']!, _dateLimiteConfirmeeMeta));
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    }
    if (data.containsKey('motif_annulation')) {
      context.handle(
          _motifAnnulationMeta,
          motifAnnulation.isAcceptableOrUnknown(
              data['motif_annulation']!, _motifAnnulationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Commande map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commande(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      numero: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numero'])!,
      demandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}demande_id'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      dateConfirmation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_confirmation']),
      dateDebutPrevue: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_debut_prevue']),
      dateLimiteConfirmee: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_limite_confirmee']),
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions']),
      motifAnnulation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}motif_annulation']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CommandesTable createAlias(String alias) {
    return $CommandesTable(attachedDatabase, alias);
  }
}

class Commande extends DataClass implements Insertable<Commande> {
  final String id;
  final String numero;
  final String demandeId;
  final String statut;
  final String? dateConfirmation;
  final String? dateDebutPrevue;
  final String? dateLimiteConfirmee;
  final String? instructions;
  final String? motifAnnulation;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Commande(
      {required this.id,
      required this.numero,
      required this.demandeId,
      required this.statut,
      this.dateConfirmation,
      this.dateDebutPrevue,
      this.dateLimiteConfirmee,
      this.instructions,
      this.motifAnnulation,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['numero'] = Variable<String>(numero);
    map['demande_id'] = Variable<String>(demandeId);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || dateConfirmation != null) {
      map['date_confirmation'] = Variable<String>(dateConfirmation);
    }
    if (!nullToAbsent || dateDebutPrevue != null) {
      map['date_debut_prevue'] = Variable<String>(dateDebutPrevue);
    }
    if (!nullToAbsent || dateLimiteConfirmee != null) {
      map['date_limite_confirmee'] = Variable<String>(dateLimiteConfirmee);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    if (!nullToAbsent || motifAnnulation != null) {
      map['motif_annulation'] = Variable<String>(motifAnnulation);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  CommandesCompanion toCompanion(bool nullToAbsent) {
    return CommandesCompanion(
      id: Value(id),
      numero: Value(numero),
      demandeId: Value(demandeId),
      statut: Value(statut),
      dateConfirmation: dateConfirmation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateConfirmation),
      dateDebutPrevue: dateDebutPrevue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDebutPrevue),
      dateLimiteConfirmee: dateLimiteConfirmee == null && nullToAbsent
          ? const Value.absent()
          : Value(dateLimiteConfirmee),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      motifAnnulation: motifAnnulation == null && nullToAbsent
          ? const Value.absent()
          : Value(motifAnnulation),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Commande.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commande(
      id: serializer.fromJson<String>(json['id']),
      numero: serializer.fromJson<String>(json['numero']),
      demandeId: serializer.fromJson<String>(json['demandeId']),
      statut: serializer.fromJson<String>(json['statut']),
      dateConfirmation: serializer.fromJson<String?>(json['dateConfirmation']),
      dateDebutPrevue: serializer.fromJson<String?>(json['dateDebutPrevue']),
      dateLimiteConfirmee:
          serializer.fromJson<String?>(json['dateLimiteConfirmee']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      motifAnnulation: serializer.fromJson<String?>(json['motifAnnulation']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'numero': serializer.toJson<String>(numero),
      'demandeId': serializer.toJson<String>(demandeId),
      'statut': serializer.toJson<String>(statut),
      'dateConfirmation': serializer.toJson<String?>(dateConfirmation),
      'dateDebutPrevue': serializer.toJson<String?>(dateDebutPrevue),
      'dateLimiteConfirmee': serializer.toJson<String?>(dateLimiteConfirmee),
      'instructions': serializer.toJson<String?>(instructions),
      'motifAnnulation': serializer.toJson<String?>(motifAnnulation),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Commande copyWith(
          {String? id,
          String? numero,
          String? demandeId,
          String? statut,
          Value<String?> dateConfirmation = const Value.absent(),
          Value<String?> dateDebutPrevue = const Value.absent(),
          Value<String?> dateLimiteConfirmee = const Value.absent(),
          Value<String?> instructions = const Value.absent(),
          Value<String?> motifAnnulation = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Commande(
        id: id ?? this.id,
        numero: numero ?? this.numero,
        demandeId: demandeId ?? this.demandeId,
        statut: statut ?? this.statut,
        dateConfirmation: dateConfirmation.present
            ? dateConfirmation.value
            : this.dateConfirmation,
        dateDebutPrevue: dateDebutPrevue.present
            ? dateDebutPrevue.value
            : this.dateDebutPrevue,
        dateLimiteConfirmee: dateLimiteConfirmee.present
            ? dateLimiteConfirmee.value
            : this.dateLimiteConfirmee,
        instructions:
            instructions.present ? instructions.value : this.instructions,
        motifAnnulation: motifAnnulation.present
            ? motifAnnulation.value
            : this.motifAnnulation,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Commande copyWithCompanion(CommandesCompanion data) {
    return Commande(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      demandeId: data.demandeId.present ? data.demandeId.value : this.demandeId,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateConfirmation: data.dateConfirmation.present
          ? data.dateConfirmation.value
          : this.dateConfirmation,
      dateDebutPrevue: data.dateDebutPrevue.present
          ? data.dateDebutPrevue.value
          : this.dateDebutPrevue,
      dateLimiteConfirmee: data.dateLimiteConfirmee.present
          ? data.dateLimiteConfirmee.value
          : this.dateLimiteConfirmee,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      motifAnnulation: data.motifAnnulation.present
          ? data.motifAnnulation.value
          : this.motifAnnulation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commande(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('demandeId: $demandeId, ')
          ..write('statut: $statut, ')
          ..write('dateConfirmation: $dateConfirmation, ')
          ..write('dateDebutPrevue: $dateDebutPrevue, ')
          ..write('dateLimiteConfirmee: $dateLimiteConfirmee, ')
          ..write('instructions: $instructions, ')
          ..write('motifAnnulation: $motifAnnulation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      numero,
      demandeId,
      statut,
      dateConfirmation,
      dateDebutPrevue,
      dateLimiteConfirmee,
      instructions,
      motifAnnulation,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commande &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.demandeId == this.demandeId &&
          other.statut == this.statut &&
          other.dateConfirmation == this.dateConfirmation &&
          other.dateDebutPrevue == this.dateDebutPrevue &&
          other.dateLimiteConfirmee == this.dateLimiteConfirmee &&
          other.instructions == this.instructions &&
          other.motifAnnulation == this.motifAnnulation &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class CommandesCompanion extends UpdateCompanion<Commande> {
  final Value<String> id;
  final Value<String> numero;
  final Value<String> demandeId;
  final Value<String> statut;
  final Value<String?> dateConfirmation;
  final Value<String?> dateDebutPrevue;
  final Value<String?> dateLimiteConfirmee;
  final Value<String?> instructions;
  final Value<String?> motifAnnulation;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const CommandesCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.demandeId = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateConfirmation = const Value.absent(),
    this.dateDebutPrevue = const Value.absent(),
    this.dateLimiteConfirmee = const Value.absent(),
    this.instructions = const Value.absent(),
    this.motifAnnulation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommandesCompanion.insert({
    required String id,
    required String numero,
    required String demandeId,
    this.statut = const Value.absent(),
    this.dateConfirmation = const Value.absent(),
    this.dateDebutPrevue = const Value.absent(),
    this.dateLimiteConfirmee = const Value.absent(),
    this.instructions = const Value.absent(),
    this.motifAnnulation = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        numero = Value(numero),
        demandeId = Value(demandeId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Commande> custom({
    Expression<String>? id,
    Expression<String>? numero,
    Expression<String>? demandeId,
    Expression<String>? statut,
    Expression<String>? dateConfirmation,
    Expression<String>? dateDebutPrevue,
    Expression<String>? dateLimiteConfirmee,
    Expression<String>? instructions,
    Expression<String>? motifAnnulation,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (demandeId != null) 'demande_id': demandeId,
      if (statut != null) 'statut': statut,
      if (dateConfirmation != null) 'date_confirmation': dateConfirmation,
      if (dateDebutPrevue != null) 'date_debut_prevue': dateDebutPrevue,
      if (dateLimiteConfirmee != null)
        'date_limite_confirmee': dateLimiteConfirmee,
      if (instructions != null) 'instructions': instructions,
      if (motifAnnulation != null) 'motif_annulation': motifAnnulation,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommandesCompanion copyWith(
      {Value<String>? id,
      Value<String>? numero,
      Value<String>? demandeId,
      Value<String>? statut,
      Value<String?>? dateConfirmation,
      Value<String?>? dateDebutPrevue,
      Value<String?>? dateLimiteConfirmee,
      Value<String?>? instructions,
      Value<String?>? motifAnnulation,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return CommandesCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      demandeId: demandeId ?? this.demandeId,
      statut: statut ?? this.statut,
      dateConfirmation: dateConfirmation ?? this.dateConfirmation,
      dateDebutPrevue: dateDebutPrevue ?? this.dateDebutPrevue,
      dateLimiteConfirmee: dateLimiteConfirmee ?? this.dateLimiteConfirmee,
      instructions: instructions ?? this.instructions,
      motifAnnulation: motifAnnulation ?? this.motifAnnulation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (demandeId.present) {
      map['demande_id'] = Variable<String>(demandeId.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (dateConfirmation.present) {
      map['date_confirmation'] = Variable<String>(dateConfirmation.value);
    }
    if (dateDebutPrevue.present) {
      map['date_debut_prevue'] = Variable<String>(dateDebutPrevue.value);
    }
    if (dateLimiteConfirmee.present) {
      map['date_limite_confirmee'] =
          Variable<String>(dateLimiteConfirmee.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (motifAnnulation.present) {
      map['motif_annulation'] = Variable<String>(motifAnnulation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandesCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('demandeId: $demandeId, ')
          ..write('statut: $statut, ')
          ..write('dateConfirmation: $dateConfirmation, ')
          ..write('dateDebutPrevue: $dateDebutPrevue, ')
          ..write('dateLimiteConfirmee: $dateLimiteConfirmee, ')
          ..write('instructions: $instructions, ')
          ..write('motifAnnulation: $motifAnnulation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LignesCommandeTable extends LignesCommande
    with TableInfo<$LignesCommandeTable, LignesCommandeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignesCommandeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<String> quantite = GeneratedColumn<String>(
      'quantite', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uniteSnapshotMeta =
      const VerificationMeta('uniteSnapshot');
  @override
  late final GeneratedColumn<String> uniteSnapshot = GeneratedColumn<String>(
      'unite_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prixUnitaireMeta =
      const VerificationMeta('prixUnitaire');
  @override
  late final GeneratedColumn<int> prixUnitaire = GeneratedColumn<int>(
      'prix_unitaire', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        commandeId,
        serviceId,
        description,
        quantite,
        uniteSnapshot,
        prixUnitaire,
        devise,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lignes_commande';
  @override
  VerificationContext validateIntegrity(Insertable<LignesCommandeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    } else if (isInserting) {
      context.missing(_commandeIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('unite_snapshot')) {
      context.handle(
          _uniteSnapshotMeta,
          uniteSnapshot.isAcceptableOrUnknown(
              data['unite_snapshot']!, _uniteSnapshotMeta));
    } else if (isInserting) {
      context.missing(_uniteSnapshotMeta);
    }
    if (data.containsKey('prix_unitaire')) {
      context.handle(
          _prixUnitaireMeta,
          prixUnitaire.isAcceptableOrUnknown(
              data['prix_unitaire']!, _prixUnitaireMeta));
    } else if (isInserting) {
      context.missing(_prixUnitaireMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LignesCommandeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LignesCommandeData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantite'])!,
      uniteSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unite_snapshot'])!,
      prixUnitaire: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prix_unitaire'])!,
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $LignesCommandeTable createAlias(String alias) {
    return $LignesCommandeTable(attachedDatabase, alias);
  }
}

class LignesCommandeData extends DataClass
    implements Insertable<LignesCommandeData> {
  final String id;
  final String commandeId;
  final String? serviceId;
  final String description;
  final String quantite;
  final String uniteSnapshot;
  final int prixUnitaire;
  final String devise;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const LignesCommandeData(
      {required this.id,
      required this.commandeId,
      this.serviceId,
      required this.description,
      required this.quantite,
      required this.uniteSnapshot,
      required this.prixUnitaire,
      required this.devise,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['commande_id'] = Variable<String>(commandeId);
    if (!nullToAbsent || serviceId != null) {
      map['service_id'] = Variable<String>(serviceId);
    }
    map['description'] = Variable<String>(description);
    map['quantite'] = Variable<String>(quantite);
    map['unite_snapshot'] = Variable<String>(uniteSnapshot);
    map['prix_unitaire'] = Variable<int>(prixUnitaire);
    map['devise'] = Variable<String>(devise);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  LignesCommandeCompanion toCompanion(bool nullToAbsent) {
    return LignesCommandeCompanion(
      id: Value(id),
      commandeId: Value(commandeId),
      serviceId: serviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceId),
      description: Value(description),
      quantite: Value(quantite),
      uniteSnapshot: Value(uniteSnapshot),
      prixUnitaire: Value(prixUnitaire),
      devise: Value(devise),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LignesCommandeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LignesCommandeData(
      id: serializer.fromJson<String>(json['id']),
      commandeId: serializer.fromJson<String>(json['commandeId']),
      serviceId: serializer.fromJson<String?>(json['serviceId']),
      description: serializer.fromJson<String>(json['description']),
      quantite: serializer.fromJson<String>(json['quantite']),
      uniteSnapshot: serializer.fromJson<String>(json['uniteSnapshot']),
      prixUnitaire: serializer.fromJson<int>(json['prixUnitaire']),
      devise: serializer.fromJson<String>(json['devise']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commandeId': serializer.toJson<String>(commandeId),
      'serviceId': serializer.toJson<String?>(serviceId),
      'description': serializer.toJson<String>(description),
      'quantite': serializer.toJson<String>(quantite),
      'uniteSnapshot': serializer.toJson<String>(uniteSnapshot),
      'prixUnitaire': serializer.toJson<int>(prixUnitaire),
      'devise': serializer.toJson<String>(devise),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  LignesCommandeData copyWith(
          {String? id,
          String? commandeId,
          Value<String?> serviceId = const Value.absent(),
          String? description,
          String? quantite,
          String? uniteSnapshot,
          int? prixUnitaire,
          String? devise,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      LignesCommandeData(
        id: id ?? this.id,
        commandeId: commandeId ?? this.commandeId,
        serviceId: serviceId.present ? serviceId.value : this.serviceId,
        description: description ?? this.description,
        quantite: quantite ?? this.quantite,
        uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
        prixUnitaire: prixUnitaire ?? this.prixUnitaire,
        devise: devise ?? this.devise,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  LignesCommandeData copyWithCompanion(LignesCommandeCompanion data) {
    return LignesCommandeData(
      id: data.id.present ? data.id.value : this.id,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      description:
          data.description.present ? data.description.value : this.description,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteSnapshot: data.uniteSnapshot.present
          ? data.uniteSnapshot.value
          : this.uniteSnapshot,
      prixUnitaire: data.prixUnitaire.present
          ? data.prixUnitaire.value
          : this.prixUnitaire,
      devise: data.devise.present ? data.devise.value : this.devise,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LignesCommandeData(')
          ..write('id: $id, ')
          ..write('commandeId: $commandeId, ')
          ..write('serviceId: $serviceId, ')
          ..write('description: $description, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('devise: $devise, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      commandeId,
      serviceId,
      description,
      quantite,
      uniteSnapshot,
      prixUnitaire,
      devise,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LignesCommandeData &&
          other.id == this.id &&
          other.commandeId == this.commandeId &&
          other.serviceId == this.serviceId &&
          other.description == this.description &&
          other.quantite == this.quantite &&
          other.uniteSnapshot == this.uniteSnapshot &&
          other.prixUnitaire == this.prixUnitaire &&
          other.devise == this.devise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class LignesCommandeCompanion extends UpdateCompanion<LignesCommandeData> {
  final Value<String> id;
  final Value<String> commandeId;
  final Value<String?> serviceId;
  final Value<String> description;
  final Value<String> quantite;
  final Value<String> uniteSnapshot;
  final Value<int> prixUnitaire;
  final Value<String> devise;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const LignesCommandeCompanion({
    this.id = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteSnapshot = const Value.absent(),
    this.prixUnitaire = const Value.absent(),
    this.devise = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LignesCommandeCompanion.insert({
    required String id,
    required String commandeId,
    this.serviceId = const Value.absent(),
    required String description,
    required String quantite,
    required String uniteSnapshot,
    required int prixUnitaire,
    this.devise = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        commandeId = Value(commandeId),
        description = Value(description),
        quantite = Value(quantite),
        uniteSnapshot = Value(uniteSnapshot),
        prixUnitaire = Value(prixUnitaire),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LignesCommandeData> custom({
    Expression<String>? id,
    Expression<String>? commandeId,
    Expression<String>? serviceId,
    Expression<String>? description,
    Expression<String>? quantite,
    Expression<String>? uniteSnapshot,
    Expression<int>? prixUnitaire,
    Expression<String>? devise,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commandeId != null) 'commande_id': commandeId,
      if (serviceId != null) 'service_id': serviceId,
      if (description != null) 'description': description,
      if (quantite != null) 'quantite': quantite,
      if (uniteSnapshot != null) 'unite_snapshot': uniteSnapshot,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (devise != null) 'devise': devise,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LignesCommandeCompanion copyWith(
      {Value<String>? id,
      Value<String>? commandeId,
      Value<String?>? serviceId,
      Value<String>? description,
      Value<String>? quantite,
      Value<String>? uniteSnapshot,
      Value<int>? prixUnitaire,
      Value<String>? devise,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return LignesCommandeCompanion(
      id: id ?? this.id,
      commandeId: commandeId ?? this.commandeId,
      serviceId: serviceId ?? this.serviceId,
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      devise: devise ?? this.devise,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<String>(quantite.value);
    }
    if (uniteSnapshot.present) {
      map['unite_snapshot'] = Variable<String>(uniteSnapshot.value);
    }
    if (prixUnitaire.present) {
      map['prix_unitaire'] = Variable<int>(prixUnitaire.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignesCommandeCompanion(')
          ..write('id: $id, ')
          ..write('commandeId: $commandeId, ')
          ..write('serviceId: $serviceId, ')
          ..write('description: $description, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('devise: $devise, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjetsTable extends Projets with TableInfo<$ProjetsTable, Projet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_preparation'));
  static const VerificationMeta _dateLimiteMeta =
      const VerificationMeta('dateLimite');
  @override
  late final GeneratedColumn<String> dateLimite = GeneratedColumn<String>(
      'date_limite', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        commandeId,
        nom,
        description,
        statut,
        dateLimite,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projets';
  @override
  VerificationContext validateIntegrity(Insertable<Projet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    } else if (isInserting) {
      context.missing(_commandeIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('date_limite')) {
      context.handle(
          _dateLimiteMeta,
          dateLimite.isAcceptableOrUnknown(
              data['date_limite']!, _dateLimiteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Projet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Projet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      dateLimite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_limite']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ProjetsTable createAlias(String alias) {
    return $ProjetsTable(attachedDatabase, alias);
  }
}

class Projet extends DataClass implements Insertable<Projet> {
  final String id;
  final String commandeId;
  final String nom;
  final String? description;
  final String statut;
  final String? dateLimite;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Projet(
      {required this.id,
      required this.commandeId,
      required this.nom,
      this.description,
      required this.statut,
      this.dateLimite,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['commande_id'] = Variable<String>(commandeId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || dateLimite != null) {
      map['date_limite'] = Variable<String>(dateLimite);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  ProjetsCompanion toCompanion(bool nullToAbsent) {
    return ProjetsCompanion(
      id: Value(id),
      commandeId: Value(commandeId),
      nom: Value(nom),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      statut: Value(statut),
      dateLimite: dateLimite == null && nullToAbsent
          ? const Value.absent()
          : Value(dateLimite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Projet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Projet(
      id: serializer.fromJson<String>(json['id']),
      commandeId: serializer.fromJson<String>(json['commandeId']),
      nom: serializer.fromJson<String>(json['nom']),
      description: serializer.fromJson<String?>(json['description']),
      statut: serializer.fromJson<String>(json['statut']),
      dateLimite: serializer.fromJson<String?>(json['dateLimite']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commandeId': serializer.toJson<String>(commandeId),
      'nom': serializer.toJson<String>(nom),
      'description': serializer.toJson<String?>(description),
      'statut': serializer.toJson<String>(statut),
      'dateLimite': serializer.toJson<String?>(dateLimite),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Projet copyWith(
          {String? id,
          String? commandeId,
          String? nom,
          Value<String?> description = const Value.absent(),
          String? statut,
          Value<String?> dateLimite = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Projet(
        id: id ?? this.id,
        commandeId: commandeId ?? this.commandeId,
        nom: nom ?? this.nom,
        description: description.present ? description.value : this.description,
        statut: statut ?? this.statut,
        dateLimite: dateLimite.present ? dateLimite.value : this.dateLimite,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Projet copyWithCompanion(ProjetsCompanion data) {
    return Projet(
      id: data.id.present ? data.id.value : this.id,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      nom: data.nom.present ? data.nom.value : this.nom,
      description:
          data.description.present ? data.description.value : this.description,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateLimite:
          data.dateLimite.present ? data.dateLimite.value : this.dateLimite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Projet(')
          ..write('id: $id, ')
          ..write('commandeId: $commandeId, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('statut: $statut, ')
          ..write('dateLimite: $dateLimite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, commandeId, nom, description, statut,
      dateLimite, createdAt, updatedAt, version, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Projet &&
          other.id == this.id &&
          other.commandeId == this.commandeId &&
          other.nom == this.nom &&
          other.description == this.description &&
          other.statut == this.statut &&
          other.dateLimite == this.dateLimite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class ProjetsCompanion extends UpdateCompanion<Projet> {
  final Value<String> id;
  final Value<String> commandeId;
  final Value<String> nom;
  final Value<String?> description;
  final Value<String> statut;
  final Value<String?> dateLimite;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const ProjetsCompanion({
    this.id = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.nom = const Value.absent(),
    this.description = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateLimite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjetsCompanion.insert({
    required String id,
    required String commandeId,
    required String nom,
    this.description = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateLimite = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        commandeId = Value(commandeId),
        nom = Value(nom),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Projet> custom({
    Expression<String>? id,
    Expression<String>? commandeId,
    Expression<String>? nom,
    Expression<String>? description,
    Expression<String>? statut,
    Expression<String>? dateLimite,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commandeId != null) 'commande_id': commandeId,
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (statut != null) 'statut': statut,
      if (dateLimite != null) 'date_limite': dateLimite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? commandeId,
      Value<String>? nom,
      Value<String?>? description,
      Value<String>? statut,
      Value<String?>? dateLimite,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return ProjetsCompanion(
      id: id ?? this.id,
      commandeId: commandeId ?? this.commandeId,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      dateLimite: dateLimite ?? this.dateLimite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (dateLimite.present) {
      map['date_limite'] = Variable<String>(dateLimite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjetsCompanion(')
          ..write('id: $id, ')
          ..write('commandeId: $commandeId, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('statut: $statut, ')
          ..write('dateLimite: $dateLimite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CahiersChargesTable extends CahiersCharges
    with TableInfo<$CahiersChargesTable, CahiersCharge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CahiersChargesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projetIdMeta =
      const VerificationMeta('projetId');
  @override
  late final GeneratedColumn<String> projetId = GeneratedColumn<String>(
      'projet_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionDocumentMeta =
      const VerificationMeta('versionDocument');
  @override
  late final GeneratedColumn<int> versionDocument = GeneratedColumn<int>(
      'version_document', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _contenuJsonMeta =
      const VerificationMeta('contenuJson');
  @override
  late final GeneratedColumn<String> contenuJson = GeneratedColumn<String>(
      'contenu_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('brouillon'));
  static const VerificationMeta _dateValidationMeta =
      const VerificationMeta('dateValidation');
  @override
  late final GeneratedColumn<String> dateValidation = GeneratedColumn<String>(
      'date_validation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projetId,
        versionDocument,
        contenuJson,
        statut,
        dateValidation,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cahiers_charges';
  @override
  VerificationContext validateIntegrity(Insertable<CahiersCharge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('projet_id')) {
      context.handle(_projetIdMeta,
          projetId.isAcceptableOrUnknown(data['projet_id']!, _projetIdMeta));
    } else if (isInserting) {
      context.missing(_projetIdMeta);
    }
    if (data.containsKey('version_document')) {
      context.handle(
          _versionDocumentMeta,
          versionDocument.isAcceptableOrUnknown(
              data['version_document']!, _versionDocumentMeta));
    }
    if (data.containsKey('contenu_json')) {
      context.handle(
          _contenuJsonMeta,
          contenuJson.isAcceptableOrUnknown(
              data['contenu_json']!, _contenuJsonMeta));
    } else if (isInserting) {
      context.missing(_contenuJsonMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('date_validation')) {
      context.handle(
          _dateValidationMeta,
          dateValidation.isAcceptableOrUnknown(
              data['date_validation']!, _dateValidationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {projetId, versionDocument},
      ];
  @override
  CahiersCharge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CahiersCharge(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projet_id'])!,
      versionDocument: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version_document'])!,
      contenuJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contenu_json'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      dateValidation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_validation']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CahiersChargesTable createAlias(String alias) {
    return $CahiersChargesTable(attachedDatabase, alias);
  }
}

class CahiersCharge extends DataClass implements Insertable<CahiersCharge> {
  final String id;
  final String projetId;
  final int versionDocument;
  final String contenuJson;
  final String statut;
  final String? dateValidation;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const CahiersCharge(
      {required this.id,
      required this.projetId,
      required this.versionDocument,
      required this.contenuJson,
      required this.statut,
      this.dateValidation,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['projet_id'] = Variable<String>(projetId);
    map['version_document'] = Variable<int>(versionDocument);
    map['contenu_json'] = Variable<String>(contenuJson);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || dateValidation != null) {
      map['date_validation'] = Variable<String>(dateValidation);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  CahiersChargesCompanion toCompanion(bool nullToAbsent) {
    return CahiersChargesCompanion(
      id: Value(id),
      projetId: Value(projetId),
      versionDocument: Value(versionDocument),
      contenuJson: Value(contenuJson),
      statut: Value(statut),
      dateValidation: dateValidation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateValidation),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CahiersCharge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CahiersCharge(
      id: serializer.fromJson<String>(json['id']),
      projetId: serializer.fromJson<String>(json['projetId']),
      versionDocument: serializer.fromJson<int>(json['versionDocument']),
      contenuJson: serializer.fromJson<String>(json['contenuJson']),
      statut: serializer.fromJson<String>(json['statut']),
      dateValidation: serializer.fromJson<String?>(json['dateValidation']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projetId': serializer.toJson<String>(projetId),
      'versionDocument': serializer.toJson<int>(versionDocument),
      'contenuJson': serializer.toJson<String>(contenuJson),
      'statut': serializer.toJson<String>(statut),
      'dateValidation': serializer.toJson<String?>(dateValidation),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  CahiersCharge copyWith(
          {String? id,
          String? projetId,
          int? versionDocument,
          String? contenuJson,
          String? statut,
          Value<String?> dateValidation = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      CahiersCharge(
        id: id ?? this.id,
        projetId: projetId ?? this.projetId,
        versionDocument: versionDocument ?? this.versionDocument,
        contenuJson: contenuJson ?? this.contenuJson,
        statut: statut ?? this.statut,
        dateValidation:
            dateValidation.present ? dateValidation.value : this.dateValidation,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  CahiersCharge copyWithCompanion(CahiersChargesCompanion data) {
    return CahiersCharge(
      id: data.id.present ? data.id.value : this.id,
      projetId: data.projetId.present ? data.projetId.value : this.projetId,
      versionDocument: data.versionDocument.present
          ? data.versionDocument.value
          : this.versionDocument,
      contenuJson:
          data.contenuJson.present ? data.contenuJson.value : this.contenuJson,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateValidation: data.dateValidation.present
          ? data.dateValidation.value
          : this.dateValidation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CahiersCharge(')
          ..write('id: $id, ')
          ..write('projetId: $projetId, ')
          ..write('versionDocument: $versionDocument, ')
          ..write('contenuJson: $contenuJson, ')
          ..write('statut: $statut, ')
          ..write('dateValidation: $dateValidation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projetId, versionDocument, contenuJson,
      statut, dateValidation, createdAt, updatedAt, version, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CahiersCharge &&
          other.id == this.id &&
          other.projetId == this.projetId &&
          other.versionDocument == this.versionDocument &&
          other.contenuJson == this.contenuJson &&
          other.statut == this.statut &&
          other.dateValidation == this.dateValidation &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class CahiersChargesCompanion extends UpdateCompanion<CahiersCharge> {
  final Value<String> id;
  final Value<String> projetId;
  final Value<int> versionDocument;
  final Value<String> contenuJson;
  final Value<String> statut;
  final Value<String?> dateValidation;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const CahiersChargesCompanion({
    this.id = const Value.absent(),
    this.projetId = const Value.absent(),
    this.versionDocument = const Value.absent(),
    this.contenuJson = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateValidation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CahiersChargesCompanion.insert({
    required String id,
    required String projetId,
    this.versionDocument = const Value.absent(),
    required String contenuJson,
    this.statut = const Value.absent(),
    this.dateValidation = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projetId = Value(projetId),
        contenuJson = Value(contenuJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CahiersCharge> custom({
    Expression<String>? id,
    Expression<String>? projetId,
    Expression<int>? versionDocument,
    Expression<String>? contenuJson,
    Expression<String>? statut,
    Expression<String>? dateValidation,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projetId != null) 'projet_id': projetId,
      if (versionDocument != null) 'version_document': versionDocument,
      if (contenuJson != null) 'contenu_json': contenuJson,
      if (statut != null) 'statut': statut,
      if (dateValidation != null) 'date_validation': dateValidation,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CahiersChargesCompanion copyWith(
      {Value<String>? id,
      Value<String>? projetId,
      Value<int>? versionDocument,
      Value<String>? contenuJson,
      Value<String>? statut,
      Value<String?>? dateValidation,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return CahiersChargesCompanion(
      id: id ?? this.id,
      projetId: projetId ?? this.projetId,
      versionDocument: versionDocument ?? this.versionDocument,
      contenuJson: contenuJson ?? this.contenuJson,
      statut: statut ?? this.statut,
      dateValidation: dateValidation ?? this.dateValidation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projetId.present) {
      map['projet_id'] = Variable<String>(projetId.value);
    }
    if (versionDocument.present) {
      map['version_document'] = Variable<int>(versionDocument.value);
    }
    if (contenuJson.present) {
      map['contenu_json'] = Variable<String>(contenuJson.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (dateValidation.present) {
      map['date_validation'] = Variable<String>(dateValidation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CahiersChargesCompanion(')
          ..write('id: $id, ')
          ..write('projetId: $projetId, ')
          ..write('versionDocument: $versionDocument, ')
          ..write('contenuJson: $contenuJson, ')
          ..write('statut: $statut, ')
          ..write('dateValidation: $dateValidation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TachesTable extends Taches with TableInfo<$TachesTable, Tache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projetIdMeta =
      const VerificationMeta('projetId');
  @override
  late final GeneratedColumn<String> projetId = GeneratedColumn<String>(
      'projet_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titreMeta = const VerificationMeta('titre');
  @override
  late final GeneratedColumn<String> titre = GeneratedColumn<String>(
      'titre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('a_faire'));
  static const VerificationMeta _prioriteMeta =
      const VerificationMeta('priorite');
  @override
  late final GeneratedColumn<String> priorite = GeneratedColumn<String>(
      'priorite', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normale'));
  static const VerificationMeta _echeanceMeta =
      const VerificationMeta('echeance');
  @override
  late final GeneratedColumn<String> echeance = GeneratedColumn<String>(
      'echeance', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _termineeAtMeta =
      const VerificationMeta('termineeAt');
  @override
  late final GeneratedColumn<String> termineeAt = GeneratedColumn<String>(
      'terminee_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        commandeId,
        projetId,
        titre,
        description,
        statut,
        priorite,
        echeance,
        termineeAt,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taches';
  @override
  VerificationContext validateIntegrity(Insertable<Tache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    } else if (isInserting) {
      context.missing(_commandeIdMeta);
    }
    if (data.containsKey('projet_id')) {
      context.handle(_projetIdMeta,
          projetId.isAcceptableOrUnknown(data['projet_id']!, _projetIdMeta));
    }
    if (data.containsKey('titre')) {
      context.handle(
          _titreMeta, titre.isAcceptableOrUnknown(data['titre']!, _titreMeta));
    } else if (isInserting) {
      context.missing(_titreMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('priorite')) {
      context.handle(_prioriteMeta,
          priorite.isAcceptableOrUnknown(data['priorite']!, _prioriteMeta));
    }
    if (data.containsKey('echeance')) {
      context.handle(_echeanceMeta,
          echeance.isAcceptableOrUnknown(data['echeance']!, _echeanceMeta));
    }
    if (data.containsKey('terminee_at')) {
      context.handle(
          _termineeAtMeta,
          termineeAt.isAcceptableOrUnknown(
              data['terminee_at']!, _termineeAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tache(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id'])!,
      projetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projet_id']),
      titre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titre'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      priorite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priorite'])!,
      echeance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}echeance']),
      termineeAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}terminee_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TachesTable createAlias(String alias) {
    return $TachesTable(attachedDatabase, alias);
  }
}

class Tache extends DataClass implements Insertable<Tache> {
  final String id;
  final String commandeId;
  final String? projetId;
  final String titre;
  final String? description;
  final String statut;
  final String priorite;
  final String? echeance;
  final String? termineeAt;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Tache(
      {required this.id,
      required this.commandeId,
      this.projetId,
      required this.titre,
      this.description,
      required this.statut,
      required this.priorite,
      this.echeance,
      this.termineeAt,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['commande_id'] = Variable<String>(commandeId);
    if (!nullToAbsent || projetId != null) {
      map['projet_id'] = Variable<String>(projetId);
    }
    map['titre'] = Variable<String>(titre);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['statut'] = Variable<String>(statut);
    map['priorite'] = Variable<String>(priorite);
    if (!nullToAbsent || echeance != null) {
      map['echeance'] = Variable<String>(echeance);
    }
    if (!nullToAbsent || termineeAt != null) {
      map['terminee_at'] = Variable<String>(termineeAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  TachesCompanion toCompanion(bool nullToAbsent) {
    return TachesCompanion(
      id: Value(id),
      commandeId: Value(commandeId),
      projetId: projetId == null && nullToAbsent
          ? const Value.absent()
          : Value(projetId),
      titre: Value(titre),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      statut: Value(statut),
      priorite: Value(priorite),
      echeance: echeance == null && nullToAbsent
          ? const Value.absent()
          : Value(echeance),
      termineeAt: termineeAt == null && nullToAbsent
          ? const Value.absent()
          : Value(termineeAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Tache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tache(
      id: serializer.fromJson<String>(json['id']),
      commandeId: serializer.fromJson<String>(json['commandeId']),
      projetId: serializer.fromJson<String?>(json['projetId']),
      titre: serializer.fromJson<String>(json['titre']),
      description: serializer.fromJson<String?>(json['description']),
      statut: serializer.fromJson<String>(json['statut']),
      priorite: serializer.fromJson<String>(json['priorite']),
      echeance: serializer.fromJson<String?>(json['echeance']),
      termineeAt: serializer.fromJson<String?>(json['termineeAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commandeId': serializer.toJson<String>(commandeId),
      'projetId': serializer.toJson<String?>(projetId),
      'titre': serializer.toJson<String>(titre),
      'description': serializer.toJson<String?>(description),
      'statut': serializer.toJson<String>(statut),
      'priorite': serializer.toJson<String>(priorite),
      'echeance': serializer.toJson<String?>(echeance),
      'termineeAt': serializer.toJson<String?>(termineeAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Tache copyWith(
          {String? id,
          String? commandeId,
          Value<String?> projetId = const Value.absent(),
          String? titre,
          Value<String?> description = const Value.absent(),
          String? statut,
          String? priorite,
          Value<String?> echeance = const Value.absent(),
          Value<String?> termineeAt = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Tache(
        id: id ?? this.id,
        commandeId: commandeId ?? this.commandeId,
        projetId: projetId.present ? projetId.value : this.projetId,
        titre: titre ?? this.titre,
        description: description.present ? description.value : this.description,
        statut: statut ?? this.statut,
        priorite: priorite ?? this.priorite,
        echeance: echeance.present ? echeance.value : this.echeance,
        termineeAt: termineeAt.present ? termineeAt.value : this.termineeAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Tache copyWithCompanion(TachesCompanion data) {
    return Tache(
      id: data.id.present ? data.id.value : this.id,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      projetId: data.projetId.present ? data.projetId.value : this.projetId,
      titre: data.titre.present ? data.titre.value : this.titre,
      description:
          data.description.present ? data.description.value : this.description,
      statut: data.statut.present ? data.statut.value : this.statut,
      priorite: data.priorite.present ? data.priorite.value : this.priorite,
      echeance: data.echeance.present ? data.echeance.value : this.echeance,
      termineeAt:
          data.termineeAt.present ? data.termineeAt.value : this.termineeAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tache(')
          ..write('id: $id, ')
          ..write('commandeId: $commandeId, ')
          ..write('projetId: $projetId, ')
          ..write('titre: $titre, ')
          ..write('description: $description, ')
          ..write('statut: $statut, ')
          ..write('priorite: $priorite, ')
          ..write('echeance: $echeance, ')
          ..write('termineeAt: $termineeAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      commandeId,
      projetId,
      titre,
      description,
      statut,
      priorite,
      echeance,
      termineeAt,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tache &&
          other.id == this.id &&
          other.commandeId == this.commandeId &&
          other.projetId == this.projetId &&
          other.titre == this.titre &&
          other.description == this.description &&
          other.statut == this.statut &&
          other.priorite == this.priorite &&
          other.echeance == this.echeance &&
          other.termineeAt == this.termineeAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class TachesCompanion extends UpdateCompanion<Tache> {
  final Value<String> id;
  final Value<String> commandeId;
  final Value<String?> projetId;
  final Value<String> titre;
  final Value<String?> description;
  final Value<String> statut;
  final Value<String> priorite;
  final Value<String?> echeance;
  final Value<String?> termineeAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const TachesCompanion({
    this.id = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.projetId = const Value.absent(),
    this.titre = const Value.absent(),
    this.description = const Value.absent(),
    this.statut = const Value.absent(),
    this.priorite = const Value.absent(),
    this.echeance = const Value.absent(),
    this.termineeAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TachesCompanion.insert({
    required String id,
    required String commandeId,
    this.projetId = const Value.absent(),
    required String titre,
    this.description = const Value.absent(),
    this.statut = const Value.absent(),
    this.priorite = const Value.absent(),
    this.echeance = const Value.absent(),
    this.termineeAt = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        commandeId = Value(commandeId),
        titre = Value(titre),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Tache> custom({
    Expression<String>? id,
    Expression<String>? commandeId,
    Expression<String>? projetId,
    Expression<String>? titre,
    Expression<String>? description,
    Expression<String>? statut,
    Expression<String>? priorite,
    Expression<String>? echeance,
    Expression<String>? termineeAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commandeId != null) 'commande_id': commandeId,
      if (projetId != null) 'projet_id': projetId,
      if (titre != null) 'titre': titre,
      if (description != null) 'description': description,
      if (statut != null) 'statut': statut,
      if (priorite != null) 'priorite': priorite,
      if (echeance != null) 'echeance': echeance,
      if (termineeAt != null) 'terminee_at': termineeAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TachesCompanion copyWith(
      {Value<String>? id,
      Value<String>? commandeId,
      Value<String?>? projetId,
      Value<String>? titre,
      Value<String?>? description,
      Value<String>? statut,
      Value<String>? priorite,
      Value<String?>? echeance,
      Value<String?>? termineeAt,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return TachesCompanion(
      id: id ?? this.id,
      commandeId: commandeId ?? this.commandeId,
      projetId: projetId ?? this.projetId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      priorite: priorite ?? this.priorite,
      echeance: echeance ?? this.echeance,
      termineeAt: termineeAt ?? this.termineeAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (projetId.present) {
      map['projet_id'] = Variable<String>(projetId.value);
    }
    if (titre.present) {
      map['titre'] = Variable<String>(titre.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (priorite.present) {
      map['priorite'] = Variable<String>(priorite.value);
    }
    if (echeance.present) {
      map['echeance'] = Variable<String>(echeance.value);
    }
    if (termineeAt.present) {
      map['terminee_at'] = Variable<String>(termineeAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TachesCompanion(')
          ..write('id: $id, ')
          ..write('commandeId: $commandeId, ')
          ..write('projetId: $projetId, ')
          ..write('titre: $titre, ')
          ..write('description: $description, ')
          ..write('statut: $statut, ')
          ..write('priorite: $priorite, ')
          ..write('echeance: $echeance, ')
          ..write('termineeAt: $termineeAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelesMessagesTable extends ModelesMessages
    with TableInfo<$ModelesMessagesTable, ModelesMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelesMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _objectifMeta =
      const VerificationMeta('objectif');
  @override
  late final GeneratedColumn<String> objectif = GeneratedColumn<String>(
      'objectif', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canalMeta = const VerificationMeta('canal');
  @override
  late final GeneratedColumn<String> canal = GeneratedColumn<String>(
      'canal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _corpsTemplateMeta =
      const VerificationMeta('corpsTemplate');
  @override
  late final GeneratedColumn<String> corpsTemplate = GeneratedColumn<String>(
      'corps_template', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variablesJsonMeta =
      const VerificationMeta('variablesJson');
  @override
  late final GeneratedColumn<String> variablesJson = GeneratedColumn<String>(
      'variables_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
      'actif', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actif" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        nom,
        objectif,
        canal,
        corpsTemplate,
        variablesJson,
        actif,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modeles_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ModelesMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('objectif')) {
      context.handle(_objectifMeta,
          objectif.isAcceptableOrUnknown(data['objectif']!, _objectifMeta));
    } else if (isInserting) {
      context.missing(_objectifMeta);
    }
    if (data.containsKey('canal')) {
      context.handle(
          _canalMeta, canal.isAcceptableOrUnknown(data['canal']!, _canalMeta));
    } else if (isInserting) {
      context.missing(_canalMeta);
    }
    if (data.containsKey('corps_template')) {
      context.handle(
          _corpsTemplateMeta,
          corpsTemplate.isAcceptableOrUnknown(
              data['corps_template']!, _corpsTemplateMeta));
    } else if (isInserting) {
      context.missing(_corpsTemplateMeta);
    }
    if (data.containsKey('variables_json')) {
      context.handle(
          _variablesJsonMeta,
          variablesJson.isAcceptableOrUnknown(
              data['variables_json']!, _variablesJsonMeta));
    }
    if (data.containsKey('actif')) {
      context.handle(
          _actifMeta, actif.isAcceptableOrUnknown(data['actif']!, _actifMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelesMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelesMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      objectif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objectif'])!,
      canal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canal'])!,
      corpsTemplate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}corps_template'])!,
      variablesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variables_json'])!,
      actif: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actif'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ModelesMessagesTable createAlias(String alias) {
    return $ModelesMessagesTable(attachedDatabase, alias);
  }
}

class ModelesMessage extends DataClass implements Insertable<ModelesMessage> {
  final String id;
  final String code;
  final String nom;
  final String objectif;
  final String canal;
  final String corpsTemplate;
  final String variablesJson;
  final bool actif;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const ModelesMessage(
      {required this.id,
      required this.code,
      required this.nom,
      required this.objectif,
      required this.canal,
      required this.corpsTemplate,
      required this.variablesJson,
      required this.actif,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['nom'] = Variable<String>(nom);
    map['objectif'] = Variable<String>(objectif);
    map['canal'] = Variable<String>(canal);
    map['corps_template'] = Variable<String>(corpsTemplate);
    map['variables_json'] = Variable<String>(variablesJson);
    map['actif'] = Variable<bool>(actif);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  ModelesMessagesCompanion toCompanion(bool nullToAbsent) {
    return ModelesMessagesCompanion(
      id: Value(id),
      code: Value(code),
      nom: Value(nom),
      objectif: Value(objectif),
      canal: Value(canal),
      corpsTemplate: Value(corpsTemplate),
      variablesJson: Value(variablesJson),
      actif: Value(actif),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ModelesMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelesMessage(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      nom: serializer.fromJson<String>(json['nom']),
      objectif: serializer.fromJson<String>(json['objectif']),
      canal: serializer.fromJson<String>(json['canal']),
      corpsTemplate: serializer.fromJson<String>(json['corpsTemplate']),
      variablesJson: serializer.fromJson<String>(json['variablesJson']),
      actif: serializer.fromJson<bool>(json['actif']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'nom': serializer.toJson<String>(nom),
      'objectif': serializer.toJson<String>(objectif),
      'canal': serializer.toJson<String>(canal),
      'corpsTemplate': serializer.toJson<String>(corpsTemplate),
      'variablesJson': serializer.toJson<String>(variablesJson),
      'actif': serializer.toJson<bool>(actif),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  ModelesMessage copyWith(
          {String? id,
          String? code,
          String? nom,
          String? objectif,
          String? canal,
          String? corpsTemplate,
          String? variablesJson,
          bool? actif,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      ModelesMessage(
        id: id ?? this.id,
        code: code ?? this.code,
        nom: nom ?? this.nom,
        objectif: objectif ?? this.objectif,
        canal: canal ?? this.canal,
        corpsTemplate: corpsTemplate ?? this.corpsTemplate,
        variablesJson: variablesJson ?? this.variablesJson,
        actif: actif ?? this.actif,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  ModelesMessage copyWithCompanion(ModelesMessagesCompanion data) {
    return ModelesMessage(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      nom: data.nom.present ? data.nom.value : this.nom,
      objectif: data.objectif.present ? data.objectif.value : this.objectif,
      canal: data.canal.present ? data.canal.value : this.canal,
      corpsTemplate: data.corpsTemplate.present
          ? data.corpsTemplate.value
          : this.corpsTemplate,
      variablesJson: data.variablesJson.present
          ? data.variablesJson.value
          : this.variablesJson,
      actif: data.actif.present ? data.actif.value : this.actif,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelesMessage(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nom: $nom, ')
          ..write('objectif: $objectif, ')
          ..write('canal: $canal, ')
          ..write('corpsTemplate: $corpsTemplate, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, nom, objectif, canal, corpsTemplate,
      variablesJson, actif, createdAt, updatedAt, version, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelesMessage &&
          other.id == this.id &&
          other.code == this.code &&
          other.nom == this.nom &&
          other.objectif == this.objectif &&
          other.canal == this.canal &&
          other.corpsTemplate == this.corpsTemplate &&
          other.variablesJson == this.variablesJson &&
          other.actif == this.actif &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class ModelesMessagesCompanion extends UpdateCompanion<ModelesMessage> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> nom;
  final Value<String> objectif;
  final Value<String> canal;
  final Value<String> corpsTemplate;
  final Value<String> variablesJson;
  final Value<bool> actif;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const ModelesMessagesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.nom = const Value.absent(),
    this.objectif = const Value.absent(),
    this.canal = const Value.absent(),
    this.corpsTemplate = const Value.absent(),
    this.variablesJson = const Value.absent(),
    this.actif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelesMessagesCompanion.insert({
    required String id,
    required String code,
    required String nom,
    required String objectif,
    required String canal,
    required String corpsTemplate,
    this.variablesJson = const Value.absent(),
    this.actif = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        nom = Value(nom),
        objectif = Value(objectif),
        canal = Value(canal),
        corpsTemplate = Value(corpsTemplate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ModelesMessage> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? nom,
    Expression<String>? objectif,
    Expression<String>? canal,
    Expression<String>? corpsTemplate,
    Expression<String>? variablesJson,
    Expression<bool>? actif,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (nom != null) 'nom': nom,
      if (objectif != null) 'objectif': objectif,
      if (canal != null) 'canal': canal,
      if (corpsTemplate != null) 'corps_template': corpsTemplate,
      if (variablesJson != null) 'variables_json': variablesJson,
      if (actif != null) 'actif': actif,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelesMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? nom,
      Value<String>? objectif,
      Value<String>? canal,
      Value<String>? corpsTemplate,
      Value<String>? variablesJson,
      Value<bool>? actif,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return ModelesMessagesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      objectif: objectif ?? this.objectif,
      canal: canal ?? this.canal,
      corpsTemplate: corpsTemplate ?? this.corpsTemplate,
      variablesJson: variablesJson ?? this.variablesJson,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (objectif.present) {
      map['objectif'] = Variable<String>(objectif.value);
    }
    if (canal.present) {
      map['canal'] = Variable<String>(canal.value);
    }
    if (corpsTemplate.present) {
      map['corps_template'] = Variable<String>(corpsTemplate.value);
    }
    if (variablesJson.present) {
      map['variables_json'] = Variable<String>(variablesJson.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelesMessagesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nom: $nom, ')
          ..write('objectif: $objectif, ')
          ..write('canal: $canal, ')
          ..write('corpsTemplate: $corpsTemplate, ')
          ..write('variablesJson: $variablesJson, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EchangesTable extends Echanges with TableInfo<$EchangesTable, Echange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EchangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _demandeIdMeta =
      const VerificationMeta('demandeId');
  @override
  late final GeneratedColumn<String> demandeId = GeneratedColumn<String>(
      'demande_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modeleIdMeta =
      const VerificationMeta('modeleId');
  @override
  late final GeneratedColumn<String> modeleId = GeneratedColumn<String>(
      'modele_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _canalMeta = const VerificationMeta('canal');
  @override
  late final GeneratedColumn<String> canal = GeneratedColumn<String>(
      'canal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contenuMeta =
      const VerificationMeta('contenu');
  @override
  late final GeneratedColumn<String> contenu = GeneratedColumn<String>(
      'contenu', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statutEnvoiMeta =
      const VerificationMeta('statutEnvoi');
  @override
  late final GeneratedColumn<String> statutEnvoi = GeneratedColumn<String>(
      'statut_envoi', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('brouillon'));
  static const VerificationMeta _datePreparationMeta =
      const VerificationMeta('datePreparation');
  @override
  late final GeneratedColumn<String> datePreparation = GeneratedColumn<String>(
      'date_preparation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateCopieMeta =
      const VerificationMeta('dateCopie');
  @override
  late final GeneratedColumn<String> dateCopie = GeneratedColumn<String>(
      'date_copie', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateEnvoiConfirmeMeta =
      const VerificationMeta('dateEnvoiConfirme');
  @override
  late final GeneratedColumn<String> dateEnvoiConfirme =
      GeneratedColumn<String>('date_envoi_confirme', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalReferenceMeta =
      const VerificationMeta('externalReference');
  @override
  late final GeneratedColumn<String> externalReference =
      GeneratedColumn<String>('external_reference', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientId,
        demandeId,
        commandeId,
        modeleId,
        canal,
        direction,
        contenu,
        statutEnvoi,
        datePreparation,
        dateCopie,
        dateEnvoiConfirme,
        externalReference,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'echanges';
  @override
  VerificationContext validateIntegrity(Insertable<Echange> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('demande_id')) {
      context.handle(_demandeIdMeta,
          demandeId.isAcceptableOrUnknown(data['demande_id']!, _demandeIdMeta));
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    }
    if (data.containsKey('modele_id')) {
      context.handle(_modeleIdMeta,
          modeleId.isAcceptableOrUnknown(data['modele_id']!, _modeleIdMeta));
    }
    if (data.containsKey('canal')) {
      context.handle(
          _canalMeta, canal.isAcceptableOrUnknown(data['canal']!, _canalMeta));
    } else if (isInserting) {
      context.missing(_canalMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('contenu')) {
      context.handle(_contenuMeta,
          contenu.isAcceptableOrUnknown(data['contenu']!, _contenuMeta));
    } else if (isInserting) {
      context.missing(_contenuMeta);
    }
    if (data.containsKey('statut_envoi')) {
      context.handle(
          _statutEnvoiMeta,
          statutEnvoi.isAcceptableOrUnknown(
              data['statut_envoi']!, _statutEnvoiMeta));
    }
    if (data.containsKey('date_preparation')) {
      context.handle(
          _datePreparationMeta,
          datePreparation.isAcceptableOrUnknown(
              data['date_preparation']!, _datePreparationMeta));
    }
    if (data.containsKey('date_copie')) {
      context.handle(_dateCopieMeta,
          dateCopie.isAcceptableOrUnknown(data['date_copie']!, _dateCopieMeta));
    }
    if (data.containsKey('date_envoi_confirme')) {
      context.handle(
          _dateEnvoiConfirmeMeta,
          dateEnvoiConfirme.isAcceptableOrUnknown(
              data['date_envoi_confirme']!, _dateEnvoiConfirmeMeta));
    }
    if (data.containsKey('external_reference')) {
      context.handle(
          _externalReferenceMeta,
          externalReference.isAcceptableOrUnknown(
              data['external_reference']!, _externalReferenceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Echange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Echange(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      demandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}demande_id']),
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id']),
      modeleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modele_id']),
      canal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canal'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      contenu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contenu'])!,
      statutEnvoi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut_envoi'])!,
      datePreparation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_preparation']),
      dateCopie: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_copie']),
      dateEnvoiConfirme: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}date_envoi_confirme']),
      externalReference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_reference']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $EchangesTable createAlias(String alias) {
    return $EchangesTable(attachedDatabase, alias);
  }
}

class Echange extends DataClass implements Insertable<Echange> {
  final String id;
  final String clientId;
  final String? demandeId;
  final String? commandeId;
  final String? modeleId;
  final String canal;
  final String direction;
  final String contenu;
  final String statutEnvoi;
  final String? datePreparation;
  final String? dateCopie;
  final String? dateEnvoiConfirme;
  final String? externalReference;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Echange(
      {required this.id,
      required this.clientId,
      this.demandeId,
      this.commandeId,
      this.modeleId,
      required this.canal,
      required this.direction,
      required this.contenu,
      required this.statutEnvoi,
      this.datePreparation,
      this.dateCopie,
      this.dateEnvoiConfirme,
      this.externalReference,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || demandeId != null) {
      map['demande_id'] = Variable<String>(demandeId);
    }
    if (!nullToAbsent || commandeId != null) {
      map['commande_id'] = Variable<String>(commandeId);
    }
    if (!nullToAbsent || modeleId != null) {
      map['modele_id'] = Variable<String>(modeleId);
    }
    map['canal'] = Variable<String>(canal);
    map['direction'] = Variable<String>(direction);
    map['contenu'] = Variable<String>(contenu);
    map['statut_envoi'] = Variable<String>(statutEnvoi);
    if (!nullToAbsent || datePreparation != null) {
      map['date_preparation'] = Variable<String>(datePreparation);
    }
    if (!nullToAbsent || dateCopie != null) {
      map['date_copie'] = Variable<String>(dateCopie);
    }
    if (!nullToAbsent || dateEnvoiConfirme != null) {
      map['date_envoi_confirme'] = Variable<String>(dateEnvoiConfirme);
    }
    if (!nullToAbsent || externalReference != null) {
      map['external_reference'] = Variable<String>(externalReference);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  EchangesCompanion toCompanion(bool nullToAbsent) {
    return EchangesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      demandeId: demandeId == null && nullToAbsent
          ? const Value.absent()
          : Value(demandeId),
      commandeId: commandeId == null && nullToAbsent
          ? const Value.absent()
          : Value(commandeId),
      modeleId: modeleId == null && nullToAbsent
          ? const Value.absent()
          : Value(modeleId),
      canal: Value(canal),
      direction: Value(direction),
      contenu: Value(contenu),
      statutEnvoi: Value(statutEnvoi),
      datePreparation: datePreparation == null && nullToAbsent
          ? const Value.absent()
          : Value(datePreparation),
      dateCopie: dateCopie == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCopie),
      dateEnvoiConfirme: dateEnvoiConfirme == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEnvoiConfirme),
      externalReference: externalReference == null && nullToAbsent
          ? const Value.absent()
          : Value(externalReference),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Echange.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Echange(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      demandeId: serializer.fromJson<String?>(json['demandeId']),
      commandeId: serializer.fromJson<String?>(json['commandeId']),
      modeleId: serializer.fromJson<String?>(json['modeleId']),
      canal: serializer.fromJson<String>(json['canal']),
      direction: serializer.fromJson<String>(json['direction']),
      contenu: serializer.fromJson<String>(json['contenu']),
      statutEnvoi: serializer.fromJson<String>(json['statutEnvoi']),
      datePreparation: serializer.fromJson<String?>(json['datePreparation']),
      dateCopie: serializer.fromJson<String?>(json['dateCopie']),
      dateEnvoiConfirme:
          serializer.fromJson<String?>(json['dateEnvoiConfirme']),
      externalReference:
          serializer.fromJson<String?>(json['externalReference']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'demandeId': serializer.toJson<String?>(demandeId),
      'commandeId': serializer.toJson<String?>(commandeId),
      'modeleId': serializer.toJson<String?>(modeleId),
      'canal': serializer.toJson<String>(canal),
      'direction': serializer.toJson<String>(direction),
      'contenu': serializer.toJson<String>(contenu),
      'statutEnvoi': serializer.toJson<String>(statutEnvoi),
      'datePreparation': serializer.toJson<String?>(datePreparation),
      'dateCopie': serializer.toJson<String?>(dateCopie),
      'dateEnvoiConfirme': serializer.toJson<String?>(dateEnvoiConfirme),
      'externalReference': serializer.toJson<String?>(externalReference),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Echange copyWith(
          {String? id,
          String? clientId,
          Value<String?> demandeId = const Value.absent(),
          Value<String?> commandeId = const Value.absent(),
          Value<String?> modeleId = const Value.absent(),
          String? canal,
          String? direction,
          String? contenu,
          String? statutEnvoi,
          Value<String?> datePreparation = const Value.absent(),
          Value<String?> dateCopie = const Value.absent(),
          Value<String?> dateEnvoiConfirme = const Value.absent(),
          Value<String?> externalReference = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Echange(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        demandeId: demandeId.present ? demandeId.value : this.demandeId,
        commandeId: commandeId.present ? commandeId.value : this.commandeId,
        modeleId: modeleId.present ? modeleId.value : this.modeleId,
        canal: canal ?? this.canal,
        direction: direction ?? this.direction,
        contenu: contenu ?? this.contenu,
        statutEnvoi: statutEnvoi ?? this.statutEnvoi,
        datePreparation: datePreparation.present
            ? datePreparation.value
            : this.datePreparation,
        dateCopie: dateCopie.present ? dateCopie.value : this.dateCopie,
        dateEnvoiConfirme: dateEnvoiConfirme.present
            ? dateEnvoiConfirme.value
            : this.dateEnvoiConfirme,
        externalReference: externalReference.present
            ? externalReference.value
            : this.externalReference,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Echange copyWithCompanion(EchangesCompanion data) {
    return Echange(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      demandeId: data.demandeId.present ? data.demandeId.value : this.demandeId,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      modeleId: data.modeleId.present ? data.modeleId.value : this.modeleId,
      canal: data.canal.present ? data.canal.value : this.canal,
      direction: data.direction.present ? data.direction.value : this.direction,
      contenu: data.contenu.present ? data.contenu.value : this.contenu,
      statutEnvoi:
          data.statutEnvoi.present ? data.statutEnvoi.value : this.statutEnvoi,
      datePreparation: data.datePreparation.present
          ? data.datePreparation.value
          : this.datePreparation,
      dateCopie: data.dateCopie.present ? data.dateCopie.value : this.dateCopie,
      dateEnvoiConfirme: data.dateEnvoiConfirme.present
          ? data.dateEnvoiConfirme.value
          : this.dateEnvoiConfirme,
      externalReference: data.externalReference.present
          ? data.externalReference.value
          : this.externalReference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Echange(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('demandeId: $demandeId, ')
          ..write('commandeId: $commandeId, ')
          ..write('modeleId: $modeleId, ')
          ..write('canal: $canal, ')
          ..write('direction: $direction, ')
          ..write('contenu: $contenu, ')
          ..write('statutEnvoi: $statutEnvoi, ')
          ..write('datePreparation: $datePreparation, ')
          ..write('dateCopie: $dateCopie, ')
          ..write('dateEnvoiConfirme: $dateEnvoiConfirme, ')
          ..write('externalReference: $externalReference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      clientId,
      demandeId,
      commandeId,
      modeleId,
      canal,
      direction,
      contenu,
      statutEnvoi,
      datePreparation,
      dateCopie,
      dateEnvoiConfirme,
      externalReference,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Echange &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.demandeId == this.demandeId &&
          other.commandeId == this.commandeId &&
          other.modeleId == this.modeleId &&
          other.canal == this.canal &&
          other.direction == this.direction &&
          other.contenu == this.contenu &&
          other.statutEnvoi == this.statutEnvoi &&
          other.datePreparation == this.datePreparation &&
          other.dateCopie == this.dateCopie &&
          other.dateEnvoiConfirme == this.dateEnvoiConfirme &&
          other.externalReference == this.externalReference &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class EchangesCompanion extends UpdateCompanion<Echange> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> demandeId;
  final Value<String?> commandeId;
  final Value<String?> modeleId;
  final Value<String> canal;
  final Value<String> direction;
  final Value<String> contenu;
  final Value<String> statutEnvoi;
  final Value<String?> datePreparation;
  final Value<String?> dateCopie;
  final Value<String?> dateEnvoiConfirme;
  final Value<String?> externalReference;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const EchangesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.demandeId = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.modeleId = const Value.absent(),
    this.canal = const Value.absent(),
    this.direction = const Value.absent(),
    this.contenu = const Value.absent(),
    this.statutEnvoi = const Value.absent(),
    this.datePreparation = const Value.absent(),
    this.dateCopie = const Value.absent(),
    this.dateEnvoiConfirme = const Value.absent(),
    this.externalReference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EchangesCompanion.insert({
    required String id,
    required String clientId,
    this.demandeId = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.modeleId = const Value.absent(),
    required String canal,
    required String direction,
    required String contenu,
    this.statutEnvoi = const Value.absent(),
    this.datePreparation = const Value.absent(),
    this.dateCopie = const Value.absent(),
    this.dateEnvoiConfirme = const Value.absent(),
    this.externalReference = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientId = Value(clientId),
        canal = Value(canal),
        direction = Value(direction),
        contenu = Value(contenu),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Echange> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? demandeId,
    Expression<String>? commandeId,
    Expression<String>? modeleId,
    Expression<String>? canal,
    Expression<String>? direction,
    Expression<String>? contenu,
    Expression<String>? statutEnvoi,
    Expression<String>? datePreparation,
    Expression<String>? dateCopie,
    Expression<String>? dateEnvoiConfirme,
    Expression<String>? externalReference,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (demandeId != null) 'demande_id': demandeId,
      if (commandeId != null) 'commande_id': commandeId,
      if (modeleId != null) 'modele_id': modeleId,
      if (canal != null) 'canal': canal,
      if (direction != null) 'direction': direction,
      if (contenu != null) 'contenu': contenu,
      if (statutEnvoi != null) 'statut_envoi': statutEnvoi,
      if (datePreparation != null) 'date_preparation': datePreparation,
      if (dateCopie != null) 'date_copie': dateCopie,
      if (dateEnvoiConfirme != null) 'date_envoi_confirme': dateEnvoiConfirme,
      if (externalReference != null) 'external_reference': externalReference,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EchangesCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientId,
      Value<String?>? demandeId,
      Value<String?>? commandeId,
      Value<String?>? modeleId,
      Value<String>? canal,
      Value<String>? direction,
      Value<String>? contenu,
      Value<String>? statutEnvoi,
      Value<String?>? datePreparation,
      Value<String?>? dateCopie,
      Value<String?>? dateEnvoiConfirme,
      Value<String?>? externalReference,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return EchangesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      demandeId: demandeId ?? this.demandeId,
      commandeId: commandeId ?? this.commandeId,
      modeleId: modeleId ?? this.modeleId,
      canal: canal ?? this.canal,
      direction: direction ?? this.direction,
      contenu: contenu ?? this.contenu,
      statutEnvoi: statutEnvoi ?? this.statutEnvoi,
      datePreparation: datePreparation ?? this.datePreparation,
      dateCopie: dateCopie ?? this.dateCopie,
      dateEnvoiConfirme: dateEnvoiConfirme ?? this.dateEnvoiConfirme,
      externalReference: externalReference ?? this.externalReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (demandeId.present) {
      map['demande_id'] = Variable<String>(demandeId.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (modeleId.present) {
      map['modele_id'] = Variable<String>(modeleId.value);
    }
    if (canal.present) {
      map['canal'] = Variable<String>(canal.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (contenu.present) {
      map['contenu'] = Variable<String>(contenu.value);
    }
    if (statutEnvoi.present) {
      map['statut_envoi'] = Variable<String>(statutEnvoi.value);
    }
    if (datePreparation.present) {
      map['date_preparation'] = Variable<String>(datePreparation.value);
    }
    if (dateCopie.present) {
      map['date_copie'] = Variable<String>(dateCopie.value);
    }
    if (dateEnvoiConfirme.present) {
      map['date_envoi_confirme'] = Variable<String>(dateEnvoiConfirme.value);
    }
    if (externalReference.present) {
      map['external_reference'] = Variable<String>(externalReference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EchangesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('demandeId: $demandeId, ')
          ..write('commandeId: $commandeId, ')
          ..write('modeleId: $modeleId, ')
          ..write('canal: $canal, ')
          ..write('direction: $direction, ')
          ..write('contenu: $contenu, ')
          ..write('statutEnvoi: $statutEnvoi, ')
          ..write('datePreparation: $datePreparation, ')
          ..write('dateCopie: $dateCopie, ')
          ..write('dateEnvoiConfirme: $dateEnvoiConfirme, ')
          ..write('externalReference: $externalReference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevisTableTable extends DevisTable
    with TableInfo<$DevisTableTable, Devis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevisTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<String> numero = GeneratedColumn<String>(
      'numero', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _demandeIdMeta =
      const VerificationMeta('demandeId');
  @override
  late final GeneratedColumn<String> demandeId = GeneratedColumn<String>(
      'demande_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
      'revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('brouillon'));
  static const VerificationMeta _dateEmissionMeta =
      const VerificationMeta('dateEmission');
  @override
  late final GeneratedColumn<String> dateEmission = GeneratedColumn<String>(
      'date_emission', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateValiditeMeta =
      const VerificationMeta('dateValidite');
  @override
  late final GeneratedColumn<String> dateValidite = GeneratedColumn<String>(
      'date_validite', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conditionsMeta =
      const VerificationMeta('conditions');
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
      'conditions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalHtMeta =
      const VerificationMeta('totalHt');
  @override
  late final GeneratedColumn<int> totalHt = GeneratedColumn<int>(
      'total_ht', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _accepteAtMeta =
      const VerificationMeta('accepteAt');
  @override
  late final GeneratedColumn<String> accepteAt = GeneratedColumn<String>(
      'accepte_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        numero,
        demandeId,
        commandeId,
        revision,
        statut,
        dateEmission,
        dateValidite,
        conditions,
        totalHt,
        devise,
        accepteAt,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devis';
  @override
  VerificationContext validateIntegrity(Insertable<Devis> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(_numeroMeta,
          numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta));
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('demande_id')) {
      context.handle(_demandeIdMeta,
          demandeId.isAcceptableOrUnknown(data['demande_id']!, _demandeIdMeta));
    } else if (isInserting) {
      context.missing(_demandeIdMeta);
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('date_emission')) {
      context.handle(
          _dateEmissionMeta,
          dateEmission.isAcceptableOrUnknown(
              data['date_emission']!, _dateEmissionMeta));
    }
    if (data.containsKey('date_validite')) {
      context.handle(
          _dateValiditeMeta,
          dateValidite.isAcceptableOrUnknown(
              data['date_validite']!, _dateValiditeMeta));
    }
    if (data.containsKey('conditions')) {
      context.handle(
          _conditionsMeta,
          conditions.isAcceptableOrUnknown(
              data['conditions']!, _conditionsMeta));
    }
    if (data.containsKey('total_ht')) {
      context.handle(_totalHtMeta,
          totalHt.isAcceptableOrUnknown(data['total_ht']!, _totalHtMeta));
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('accepte_at')) {
      context.handle(_accepteAtMeta,
          accepteAt.isAcceptableOrUnknown(data['accepte_at']!, _accepteAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {demandeId, revision},
      ];
  @override
  Devis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Devis(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      numero: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numero'])!,
      demandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}demande_id'])!,
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id']),
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      dateEmission: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_emission']),
      dateValidite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_validite']),
      conditions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conditions']),
      totalHt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_ht'])!,
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      accepteAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accepte_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DevisTableTable createAlias(String alias) {
    return $DevisTableTable(attachedDatabase, alias);
  }
}

class Devis extends DataClass implements Insertable<Devis> {
  final String id;
  final String numero;
  final String demandeId;
  final String? commandeId;
  final int revision;
  final String statut;
  final String? dateEmission;
  final String? dateValidite;
  final String? conditions;
  final int totalHt;
  final String devise;
  final String? accepteAt;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Devis(
      {required this.id,
      required this.numero,
      required this.demandeId,
      this.commandeId,
      required this.revision,
      required this.statut,
      this.dateEmission,
      this.dateValidite,
      this.conditions,
      required this.totalHt,
      required this.devise,
      this.accepteAt,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['numero'] = Variable<String>(numero);
    map['demande_id'] = Variable<String>(demandeId);
    if (!nullToAbsent || commandeId != null) {
      map['commande_id'] = Variable<String>(commandeId);
    }
    map['revision'] = Variable<int>(revision);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || dateEmission != null) {
      map['date_emission'] = Variable<String>(dateEmission);
    }
    if (!nullToAbsent || dateValidite != null) {
      map['date_validite'] = Variable<String>(dateValidite);
    }
    if (!nullToAbsent || conditions != null) {
      map['conditions'] = Variable<String>(conditions);
    }
    map['total_ht'] = Variable<int>(totalHt);
    map['devise'] = Variable<String>(devise);
    if (!nullToAbsent || accepteAt != null) {
      map['accepte_at'] = Variable<String>(accepteAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  DevisTableCompanion toCompanion(bool nullToAbsent) {
    return DevisTableCompanion(
      id: Value(id),
      numero: Value(numero),
      demandeId: Value(demandeId),
      commandeId: commandeId == null && nullToAbsent
          ? const Value.absent()
          : Value(commandeId),
      revision: Value(revision),
      statut: Value(statut),
      dateEmission: dateEmission == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEmission),
      dateValidite: dateValidite == null && nullToAbsent
          ? const Value.absent()
          : Value(dateValidite),
      conditions: conditions == null && nullToAbsent
          ? const Value.absent()
          : Value(conditions),
      totalHt: Value(totalHt),
      devise: Value(devise),
      accepteAt: accepteAt == null && nullToAbsent
          ? const Value.absent()
          : Value(accepteAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Devis.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Devis(
      id: serializer.fromJson<String>(json['id']),
      numero: serializer.fromJson<String>(json['numero']),
      demandeId: serializer.fromJson<String>(json['demandeId']),
      commandeId: serializer.fromJson<String?>(json['commandeId']),
      revision: serializer.fromJson<int>(json['revision']),
      statut: serializer.fromJson<String>(json['statut']),
      dateEmission: serializer.fromJson<String?>(json['dateEmission']),
      dateValidite: serializer.fromJson<String?>(json['dateValidite']),
      conditions: serializer.fromJson<String?>(json['conditions']),
      totalHt: serializer.fromJson<int>(json['totalHt']),
      devise: serializer.fromJson<String>(json['devise']),
      accepteAt: serializer.fromJson<String?>(json['accepteAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'numero': serializer.toJson<String>(numero),
      'demandeId': serializer.toJson<String>(demandeId),
      'commandeId': serializer.toJson<String?>(commandeId),
      'revision': serializer.toJson<int>(revision),
      'statut': serializer.toJson<String>(statut),
      'dateEmission': serializer.toJson<String?>(dateEmission),
      'dateValidite': serializer.toJson<String?>(dateValidite),
      'conditions': serializer.toJson<String?>(conditions),
      'totalHt': serializer.toJson<int>(totalHt),
      'devise': serializer.toJson<String>(devise),
      'accepteAt': serializer.toJson<String?>(accepteAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Devis copyWith(
          {String? id,
          String? numero,
          String? demandeId,
          Value<String?> commandeId = const Value.absent(),
          int? revision,
          String? statut,
          Value<String?> dateEmission = const Value.absent(),
          Value<String?> dateValidite = const Value.absent(),
          Value<String?> conditions = const Value.absent(),
          int? totalHt,
          String? devise,
          Value<String?> accepteAt = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Devis(
        id: id ?? this.id,
        numero: numero ?? this.numero,
        demandeId: demandeId ?? this.demandeId,
        commandeId: commandeId.present ? commandeId.value : this.commandeId,
        revision: revision ?? this.revision,
        statut: statut ?? this.statut,
        dateEmission:
            dateEmission.present ? dateEmission.value : this.dateEmission,
        dateValidite:
            dateValidite.present ? dateValidite.value : this.dateValidite,
        conditions: conditions.present ? conditions.value : this.conditions,
        totalHt: totalHt ?? this.totalHt,
        devise: devise ?? this.devise,
        accepteAt: accepteAt.present ? accepteAt.value : this.accepteAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Devis copyWithCompanion(DevisTableCompanion data) {
    return Devis(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      demandeId: data.demandeId.present ? data.demandeId.value : this.demandeId,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      revision: data.revision.present ? data.revision.value : this.revision,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateEmission: data.dateEmission.present
          ? data.dateEmission.value
          : this.dateEmission,
      dateValidite: data.dateValidite.present
          ? data.dateValidite.value
          : this.dateValidite,
      conditions:
          data.conditions.present ? data.conditions.value : this.conditions,
      totalHt: data.totalHt.present ? data.totalHt.value : this.totalHt,
      devise: data.devise.present ? data.devise.value : this.devise,
      accepteAt: data.accepteAt.present ? data.accepteAt.value : this.accepteAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Devis(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('demandeId: $demandeId, ')
          ..write('commandeId: $commandeId, ')
          ..write('revision: $revision, ')
          ..write('statut: $statut, ')
          ..write('dateEmission: $dateEmission, ')
          ..write('dateValidite: $dateValidite, ')
          ..write('conditions: $conditions, ')
          ..write('totalHt: $totalHt, ')
          ..write('devise: $devise, ')
          ..write('accepteAt: $accepteAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      numero,
      demandeId,
      commandeId,
      revision,
      statut,
      dateEmission,
      dateValidite,
      conditions,
      totalHt,
      devise,
      accepteAt,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Devis &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.demandeId == this.demandeId &&
          other.commandeId == this.commandeId &&
          other.revision == this.revision &&
          other.statut == this.statut &&
          other.dateEmission == this.dateEmission &&
          other.dateValidite == this.dateValidite &&
          other.conditions == this.conditions &&
          other.totalHt == this.totalHt &&
          other.devise == this.devise &&
          other.accepteAt == this.accepteAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class DevisTableCompanion extends UpdateCompanion<Devis> {
  final Value<String> id;
  final Value<String> numero;
  final Value<String> demandeId;
  final Value<String?> commandeId;
  final Value<int> revision;
  final Value<String> statut;
  final Value<String?> dateEmission;
  final Value<String?> dateValidite;
  final Value<String?> conditions;
  final Value<int> totalHt;
  final Value<String> devise;
  final Value<String?> accepteAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const DevisTableCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.demandeId = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.revision = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateEmission = const Value.absent(),
    this.dateValidite = const Value.absent(),
    this.conditions = const Value.absent(),
    this.totalHt = const Value.absent(),
    this.devise = const Value.absent(),
    this.accepteAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevisTableCompanion.insert({
    required String id,
    required String numero,
    required String demandeId,
    this.commandeId = const Value.absent(),
    this.revision = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateEmission = const Value.absent(),
    this.dateValidite = const Value.absent(),
    this.conditions = const Value.absent(),
    this.totalHt = const Value.absent(),
    this.devise = const Value.absent(),
    this.accepteAt = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        numero = Value(numero),
        demandeId = Value(demandeId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Devis> custom({
    Expression<String>? id,
    Expression<String>? numero,
    Expression<String>? demandeId,
    Expression<String>? commandeId,
    Expression<int>? revision,
    Expression<String>? statut,
    Expression<String>? dateEmission,
    Expression<String>? dateValidite,
    Expression<String>? conditions,
    Expression<int>? totalHt,
    Expression<String>? devise,
    Expression<String>? accepteAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (demandeId != null) 'demande_id': demandeId,
      if (commandeId != null) 'commande_id': commandeId,
      if (revision != null) 'revision': revision,
      if (statut != null) 'statut': statut,
      if (dateEmission != null) 'date_emission': dateEmission,
      if (dateValidite != null) 'date_validite': dateValidite,
      if (conditions != null) 'conditions': conditions,
      if (totalHt != null) 'total_ht': totalHt,
      if (devise != null) 'devise': devise,
      if (accepteAt != null) 'accepte_at': accepteAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevisTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? numero,
      Value<String>? demandeId,
      Value<String?>? commandeId,
      Value<int>? revision,
      Value<String>? statut,
      Value<String?>? dateEmission,
      Value<String?>? dateValidite,
      Value<String?>? conditions,
      Value<int>? totalHt,
      Value<String>? devise,
      Value<String?>? accepteAt,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return DevisTableCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      demandeId: demandeId ?? this.demandeId,
      commandeId: commandeId ?? this.commandeId,
      revision: revision ?? this.revision,
      statut: statut ?? this.statut,
      dateEmission: dateEmission ?? this.dateEmission,
      dateValidite: dateValidite ?? this.dateValidite,
      conditions: conditions ?? this.conditions,
      totalHt: totalHt ?? this.totalHt,
      devise: devise ?? this.devise,
      accepteAt: accepteAt ?? this.accepteAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (demandeId.present) {
      map['demande_id'] = Variable<String>(demandeId.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (dateEmission.present) {
      map['date_emission'] = Variable<String>(dateEmission.value);
    }
    if (dateValidite.present) {
      map['date_validite'] = Variable<String>(dateValidite.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (totalHt.present) {
      map['total_ht'] = Variable<int>(totalHt.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (accepteAt.present) {
      map['accepte_at'] = Variable<String>(accepteAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevisTableCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('demandeId: $demandeId, ')
          ..write('commandeId: $commandeId, ')
          ..write('revision: $revision, ')
          ..write('statut: $statut, ')
          ..write('dateEmission: $dateEmission, ')
          ..write('dateValidite: $dateValidite, ')
          ..write('conditions: $conditions, ')
          ..write('totalHt: $totalHt, ')
          ..write('devise: $devise, ')
          ..write('accepteAt: $accepteAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LignesDevisTableTable extends LignesDevisTable
    with TableInfo<$LignesDevisTableTable, LignesDevis> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignesDevisTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _devisIdMeta =
      const VerificationMeta('devisId');
  @override
  late final GeneratedColumn<String> devisId = GeneratedColumn<String>(
      'devis_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<String> quantite = GeneratedColumn<String>(
      'quantite', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uniteSnapshotMeta =
      const VerificationMeta('uniteSnapshot');
  @override
  late final GeneratedColumn<String> uniteSnapshot = GeneratedColumn<String>(
      'unite_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prixUnitaireMeta =
      const VerificationMeta('prixUnitaire');
  @override
  late final GeneratedColumn<int> prixUnitaire = GeneratedColumn<int>(
      'prix_unitaire', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _montantLigneMeta =
      const VerificationMeta('montantLigne');
  @override
  late final GeneratedColumn<int> montantLigne = GeneratedColumn<int>(
      'montant_ligne', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        devisId,
        serviceId,
        description,
        quantite,
        uniteSnapshot,
        prixUnitaire,
        montantLigne,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lignes_devis';
  @override
  VerificationContext validateIntegrity(Insertable<LignesDevis> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('devis_id')) {
      context.handle(_devisIdMeta,
          devisId.isAcceptableOrUnknown(data['devis_id']!, _devisIdMeta));
    } else if (isInserting) {
      context.missing(_devisIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('unite_snapshot')) {
      context.handle(
          _uniteSnapshotMeta,
          uniteSnapshot.isAcceptableOrUnknown(
              data['unite_snapshot']!, _uniteSnapshotMeta));
    } else if (isInserting) {
      context.missing(_uniteSnapshotMeta);
    }
    if (data.containsKey('prix_unitaire')) {
      context.handle(
          _prixUnitaireMeta,
          prixUnitaire.isAcceptableOrUnknown(
              data['prix_unitaire']!, _prixUnitaireMeta));
    } else if (isInserting) {
      context.missing(_prixUnitaireMeta);
    }
    if (data.containsKey('montant_ligne')) {
      context.handle(
          _montantLigneMeta,
          montantLigne.isAcceptableOrUnknown(
              data['montant_ligne']!, _montantLigneMeta));
    } else if (isInserting) {
      context.missing(_montantLigneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LignesDevis map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LignesDevis(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      devisId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devis_id'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantite'])!,
      uniteSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unite_snapshot'])!,
      prixUnitaire: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prix_unitaire'])!,
      montantLigne: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}montant_ligne'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $LignesDevisTableTable createAlias(String alias) {
    return $LignesDevisTableTable(attachedDatabase, alias);
  }
}

class LignesDevis extends DataClass implements Insertable<LignesDevis> {
  final String id;
  final String devisId;
  final String? serviceId;
  final String description;
  final String quantite;
  final String uniteSnapshot;
  final int prixUnitaire;
  final int montantLigne;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const LignesDevis(
      {required this.id,
      required this.devisId,
      this.serviceId,
      required this.description,
      required this.quantite,
      required this.uniteSnapshot,
      required this.prixUnitaire,
      required this.montantLigne,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['devis_id'] = Variable<String>(devisId);
    if (!nullToAbsent || serviceId != null) {
      map['service_id'] = Variable<String>(serviceId);
    }
    map['description'] = Variable<String>(description);
    map['quantite'] = Variable<String>(quantite);
    map['unite_snapshot'] = Variable<String>(uniteSnapshot);
    map['prix_unitaire'] = Variable<int>(prixUnitaire);
    map['montant_ligne'] = Variable<int>(montantLigne);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  LignesDevisTableCompanion toCompanion(bool nullToAbsent) {
    return LignesDevisTableCompanion(
      id: Value(id),
      devisId: Value(devisId),
      serviceId: serviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceId),
      description: Value(description),
      quantite: Value(quantite),
      uniteSnapshot: Value(uniteSnapshot),
      prixUnitaire: Value(prixUnitaire),
      montantLigne: Value(montantLigne),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LignesDevis.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LignesDevis(
      id: serializer.fromJson<String>(json['id']),
      devisId: serializer.fromJson<String>(json['devisId']),
      serviceId: serializer.fromJson<String?>(json['serviceId']),
      description: serializer.fromJson<String>(json['description']),
      quantite: serializer.fromJson<String>(json['quantite']),
      uniteSnapshot: serializer.fromJson<String>(json['uniteSnapshot']),
      prixUnitaire: serializer.fromJson<int>(json['prixUnitaire']),
      montantLigne: serializer.fromJson<int>(json['montantLigne']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'devisId': serializer.toJson<String>(devisId),
      'serviceId': serializer.toJson<String?>(serviceId),
      'description': serializer.toJson<String>(description),
      'quantite': serializer.toJson<String>(quantite),
      'uniteSnapshot': serializer.toJson<String>(uniteSnapshot),
      'prixUnitaire': serializer.toJson<int>(prixUnitaire),
      'montantLigne': serializer.toJson<int>(montantLigne),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  LignesDevis copyWith(
          {String? id,
          String? devisId,
          Value<String?> serviceId = const Value.absent(),
          String? description,
          String? quantite,
          String? uniteSnapshot,
          int? prixUnitaire,
          int? montantLigne,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      LignesDevis(
        id: id ?? this.id,
        devisId: devisId ?? this.devisId,
        serviceId: serviceId.present ? serviceId.value : this.serviceId,
        description: description ?? this.description,
        quantite: quantite ?? this.quantite,
        uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
        prixUnitaire: prixUnitaire ?? this.prixUnitaire,
        montantLigne: montantLigne ?? this.montantLigne,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  LignesDevis copyWithCompanion(LignesDevisTableCompanion data) {
    return LignesDevis(
      id: data.id.present ? data.id.value : this.id,
      devisId: data.devisId.present ? data.devisId.value : this.devisId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      description:
          data.description.present ? data.description.value : this.description,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteSnapshot: data.uniteSnapshot.present
          ? data.uniteSnapshot.value
          : this.uniteSnapshot,
      prixUnitaire: data.prixUnitaire.present
          ? data.prixUnitaire.value
          : this.prixUnitaire,
      montantLigne: data.montantLigne.present
          ? data.montantLigne.value
          : this.montantLigne,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LignesDevis(')
          ..write('id: $id, ')
          ..write('devisId: $devisId, ')
          ..write('serviceId: $serviceId, ')
          ..write('description: $description, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('montantLigne: $montantLigne, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      devisId,
      serviceId,
      description,
      quantite,
      uniteSnapshot,
      prixUnitaire,
      montantLigne,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LignesDevis &&
          other.id == this.id &&
          other.devisId == this.devisId &&
          other.serviceId == this.serviceId &&
          other.description == this.description &&
          other.quantite == this.quantite &&
          other.uniteSnapshot == this.uniteSnapshot &&
          other.prixUnitaire == this.prixUnitaire &&
          other.montantLigne == this.montantLigne &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class LignesDevisTableCompanion extends UpdateCompanion<LignesDevis> {
  final Value<String> id;
  final Value<String> devisId;
  final Value<String?> serviceId;
  final Value<String> description;
  final Value<String> quantite;
  final Value<String> uniteSnapshot;
  final Value<int> prixUnitaire;
  final Value<int> montantLigne;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const LignesDevisTableCompanion({
    this.id = const Value.absent(),
    this.devisId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteSnapshot = const Value.absent(),
    this.prixUnitaire = const Value.absent(),
    this.montantLigne = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LignesDevisTableCompanion.insert({
    required String id,
    required String devisId,
    this.serviceId = const Value.absent(),
    required String description,
    required String quantite,
    required String uniteSnapshot,
    required int prixUnitaire,
    required int montantLigne,
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        devisId = Value(devisId),
        description = Value(description),
        quantite = Value(quantite),
        uniteSnapshot = Value(uniteSnapshot),
        prixUnitaire = Value(prixUnitaire),
        montantLigne = Value(montantLigne),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LignesDevis> custom({
    Expression<String>? id,
    Expression<String>? devisId,
    Expression<String>? serviceId,
    Expression<String>? description,
    Expression<String>? quantite,
    Expression<String>? uniteSnapshot,
    Expression<int>? prixUnitaire,
    Expression<int>? montantLigne,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (devisId != null) 'devis_id': devisId,
      if (serviceId != null) 'service_id': serviceId,
      if (description != null) 'description': description,
      if (quantite != null) 'quantite': quantite,
      if (uniteSnapshot != null) 'unite_snapshot': uniteSnapshot,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (montantLigne != null) 'montant_ligne': montantLigne,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LignesDevisTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? devisId,
      Value<String?>? serviceId,
      Value<String>? description,
      Value<String>? quantite,
      Value<String>? uniteSnapshot,
      Value<int>? prixUnitaire,
      Value<int>? montantLigne,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return LignesDevisTableCompanion(
      id: id ?? this.id,
      devisId: devisId ?? this.devisId,
      serviceId: serviceId ?? this.serviceId,
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      montantLigne: montantLigne ?? this.montantLigne,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (devisId.present) {
      map['devis_id'] = Variable<String>(devisId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<String>(quantite.value);
    }
    if (uniteSnapshot.present) {
      map['unite_snapshot'] = Variable<String>(uniteSnapshot.value);
    }
    if (prixUnitaire.present) {
      map['prix_unitaire'] = Variable<int>(prixUnitaire.value);
    }
    if (montantLigne.present) {
      map['montant_ligne'] = Variable<int>(montantLigne.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignesDevisTableCompanion(')
          ..write('id: $id, ')
          ..write('devisId: $devisId, ')
          ..write('serviceId: $serviceId, ')
          ..write('description: $description, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('montantLigne: $montantLigne, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacturesTable extends Factures with TableInfo<$FacturesTable, Facture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<String> numero = GeneratedColumn<String>(
      'numero', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('brouillon'));
  static const VerificationMeta _dateEmissionMeta =
      const VerificationMeta('dateEmission');
  @override
  late final GeneratedColumn<String> dateEmission = GeneratedColumn<String>(
      'date_emission', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateEcheanceMeta =
      const VerificationMeta('dateEcheance');
  @override
  late final GeneratedColumn<String> dateEcheance = GeneratedColumn<String>(
      'date_echeance', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _conditionsMeta =
      const VerificationMeta('conditions');
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
      'conditions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        numero,
        commandeId,
        statut,
        dateEmission,
        dateEcheance,
        total,
        devise,
        conditions,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'factures';
  @override
  VerificationContext validateIntegrity(Insertable<Facture> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(_numeroMeta,
          numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta));
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    } else if (isInserting) {
      context.missing(_commandeIdMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('date_emission')) {
      context.handle(
          _dateEmissionMeta,
          dateEmission.isAcceptableOrUnknown(
              data['date_emission']!, _dateEmissionMeta));
    }
    if (data.containsKey('date_echeance')) {
      context.handle(
          _dateEcheanceMeta,
          dateEcheance.isAcceptableOrUnknown(
              data['date_echeance']!, _dateEcheanceMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('conditions')) {
      context.handle(
          _conditionsMeta,
          conditions.isAcceptableOrUnknown(
              data['conditions']!, _conditionsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Facture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Facture(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      numero: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numero'])!,
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      dateEmission: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_emission']),
      dateEcheance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_echeance']),
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      conditions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conditions']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $FacturesTable createAlias(String alias) {
    return $FacturesTable(attachedDatabase, alias);
  }
}

class Facture extends DataClass implements Insertable<Facture> {
  final String id;
  final String numero;
  final String commandeId;
  final String statut;
  final String? dateEmission;
  final String? dateEcheance;
  final int total;
  final String devise;
  final String? conditions;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Facture(
      {required this.id,
      required this.numero,
      required this.commandeId,
      required this.statut,
      this.dateEmission,
      this.dateEcheance,
      required this.total,
      required this.devise,
      this.conditions,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['numero'] = Variable<String>(numero);
    map['commande_id'] = Variable<String>(commandeId);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || dateEmission != null) {
      map['date_emission'] = Variable<String>(dateEmission);
    }
    if (!nullToAbsent || dateEcheance != null) {
      map['date_echeance'] = Variable<String>(dateEcheance);
    }
    map['total'] = Variable<int>(total);
    map['devise'] = Variable<String>(devise);
    if (!nullToAbsent || conditions != null) {
      map['conditions'] = Variable<String>(conditions);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  FacturesCompanion toCompanion(bool nullToAbsent) {
    return FacturesCompanion(
      id: Value(id),
      numero: Value(numero),
      commandeId: Value(commandeId),
      statut: Value(statut),
      dateEmission: dateEmission == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEmission),
      dateEcheance: dateEcheance == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEcheance),
      total: Value(total),
      devise: Value(devise),
      conditions: conditions == null && nullToAbsent
          ? const Value.absent()
          : Value(conditions),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Facture.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Facture(
      id: serializer.fromJson<String>(json['id']),
      numero: serializer.fromJson<String>(json['numero']),
      commandeId: serializer.fromJson<String>(json['commandeId']),
      statut: serializer.fromJson<String>(json['statut']),
      dateEmission: serializer.fromJson<String?>(json['dateEmission']),
      dateEcheance: serializer.fromJson<String?>(json['dateEcheance']),
      total: serializer.fromJson<int>(json['total']),
      devise: serializer.fromJson<String>(json['devise']),
      conditions: serializer.fromJson<String?>(json['conditions']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'numero': serializer.toJson<String>(numero),
      'commandeId': serializer.toJson<String>(commandeId),
      'statut': serializer.toJson<String>(statut),
      'dateEmission': serializer.toJson<String?>(dateEmission),
      'dateEcheance': serializer.toJson<String?>(dateEcheance),
      'total': serializer.toJson<int>(total),
      'devise': serializer.toJson<String>(devise),
      'conditions': serializer.toJson<String?>(conditions),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Facture copyWith(
          {String? id,
          String? numero,
          String? commandeId,
          String? statut,
          Value<String?> dateEmission = const Value.absent(),
          Value<String?> dateEcheance = const Value.absent(),
          int? total,
          String? devise,
          Value<String?> conditions = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Facture(
        id: id ?? this.id,
        numero: numero ?? this.numero,
        commandeId: commandeId ?? this.commandeId,
        statut: statut ?? this.statut,
        dateEmission:
            dateEmission.present ? dateEmission.value : this.dateEmission,
        dateEcheance:
            dateEcheance.present ? dateEcheance.value : this.dateEcheance,
        total: total ?? this.total,
        devise: devise ?? this.devise,
        conditions: conditions.present ? conditions.value : this.conditions,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Facture copyWithCompanion(FacturesCompanion data) {
    return Facture(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateEmission: data.dateEmission.present
          ? data.dateEmission.value
          : this.dateEmission,
      dateEcheance: data.dateEcheance.present
          ? data.dateEcheance.value
          : this.dateEcheance,
      total: data.total.present ? data.total.value : this.total,
      devise: data.devise.present ? data.devise.value : this.devise,
      conditions:
          data.conditions.present ? data.conditions.value : this.conditions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Facture(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('commandeId: $commandeId, ')
          ..write('statut: $statut, ')
          ..write('dateEmission: $dateEmission, ')
          ..write('dateEcheance: $dateEcheance, ')
          ..write('total: $total, ')
          ..write('devise: $devise, ')
          ..write('conditions: $conditions, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      numero,
      commandeId,
      statut,
      dateEmission,
      dateEcheance,
      total,
      devise,
      conditions,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Facture &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.commandeId == this.commandeId &&
          other.statut == this.statut &&
          other.dateEmission == this.dateEmission &&
          other.dateEcheance == this.dateEcheance &&
          other.total == this.total &&
          other.devise == this.devise &&
          other.conditions == this.conditions &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class FacturesCompanion extends UpdateCompanion<Facture> {
  final Value<String> id;
  final Value<String> numero;
  final Value<String> commandeId;
  final Value<String> statut;
  final Value<String?> dateEmission;
  final Value<String?> dateEcheance;
  final Value<int> total;
  final Value<String> devise;
  final Value<String?> conditions;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const FacturesCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateEmission = const Value.absent(),
    this.dateEcheance = const Value.absent(),
    this.total = const Value.absent(),
    this.devise = const Value.absent(),
    this.conditions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacturesCompanion.insert({
    required String id,
    required String numero,
    required String commandeId,
    this.statut = const Value.absent(),
    this.dateEmission = const Value.absent(),
    this.dateEcheance = const Value.absent(),
    this.total = const Value.absent(),
    this.devise = const Value.absent(),
    this.conditions = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        numero = Value(numero),
        commandeId = Value(commandeId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Facture> custom({
    Expression<String>? id,
    Expression<String>? numero,
    Expression<String>? commandeId,
    Expression<String>? statut,
    Expression<String>? dateEmission,
    Expression<String>? dateEcheance,
    Expression<int>? total,
    Expression<String>? devise,
    Expression<String>? conditions,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (commandeId != null) 'commande_id': commandeId,
      if (statut != null) 'statut': statut,
      if (dateEmission != null) 'date_emission': dateEmission,
      if (dateEcheance != null) 'date_echeance': dateEcheance,
      if (total != null) 'total': total,
      if (devise != null) 'devise': devise,
      if (conditions != null) 'conditions': conditions,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacturesCompanion copyWith(
      {Value<String>? id,
      Value<String>? numero,
      Value<String>? commandeId,
      Value<String>? statut,
      Value<String?>? dateEmission,
      Value<String?>? dateEcheance,
      Value<int>? total,
      Value<String>? devise,
      Value<String?>? conditions,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return FacturesCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      commandeId: commandeId ?? this.commandeId,
      statut: statut ?? this.statut,
      dateEmission: dateEmission ?? this.dateEmission,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      total: total ?? this.total,
      devise: devise ?? this.devise,
      conditions: conditions ?? this.conditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (dateEmission.present) {
      map['date_emission'] = Variable<String>(dateEmission.value);
    }
    if (dateEcheance.present) {
      map['date_echeance'] = Variable<String>(dateEcheance.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacturesCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('commandeId: $commandeId, ')
          ..write('statut: $statut, ')
          ..write('dateEmission: $dateEmission, ')
          ..write('dateEcheance: $dateEcheance, ')
          ..write('total: $total, ')
          ..write('devise: $devise, ')
          ..write('conditions: $conditions, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LignesFactureTable extends LignesFacture
    with TableInfo<$LignesFactureTable, LignesFactureData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LignesFactureTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _factureIdMeta =
      const VerificationMeta('factureId');
  @override
  late final GeneratedColumn<String> factureId = GeneratedColumn<String>(
      'facture_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantiteMeta =
      const VerificationMeta('quantite');
  @override
  late final GeneratedColumn<String> quantite = GeneratedColumn<String>(
      'quantite', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _uniteSnapshotMeta =
      const VerificationMeta('uniteSnapshot');
  @override
  late final GeneratedColumn<String> uniteSnapshot = GeneratedColumn<String>(
      'unite_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prixUnitaireMeta =
      const VerificationMeta('prixUnitaire');
  @override
  late final GeneratedColumn<int> prixUnitaire = GeneratedColumn<int>(
      'prix_unitaire', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _montantLigneMeta =
      const VerificationMeta('montantLigne');
  @override
  late final GeneratedColumn<int> montantLigne = GeneratedColumn<int>(
      'montant_ligne', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        factureId,
        description,
        quantite,
        uniteSnapshot,
        prixUnitaire,
        montantLigne,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lignes_facture';
  @override
  VerificationContext validateIntegrity(Insertable<LignesFactureData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facture_id')) {
      context.handle(_factureIdMeta,
          factureId.isAcceptableOrUnknown(data['facture_id']!, _factureIdMeta));
    } else if (isInserting) {
      context.missing(_factureIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(_quantiteMeta,
          quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta));
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('unite_snapshot')) {
      context.handle(
          _uniteSnapshotMeta,
          uniteSnapshot.isAcceptableOrUnknown(
              data['unite_snapshot']!, _uniteSnapshotMeta));
    } else if (isInserting) {
      context.missing(_uniteSnapshotMeta);
    }
    if (data.containsKey('prix_unitaire')) {
      context.handle(
          _prixUnitaireMeta,
          prixUnitaire.isAcceptableOrUnknown(
              data['prix_unitaire']!, _prixUnitaireMeta));
    } else if (isInserting) {
      context.missing(_prixUnitaireMeta);
    }
    if (data.containsKey('montant_ligne')) {
      context.handle(
          _montantLigneMeta,
          montantLigne.isAcceptableOrUnknown(
              data['montant_ligne']!, _montantLigneMeta));
    } else if (isInserting) {
      context.missing(_montantLigneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LignesFactureData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LignesFactureData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      factureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facture_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      quantite: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantite'])!,
      uniteSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unite_snapshot'])!,
      prixUnitaire: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prix_unitaire'])!,
      montantLigne: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}montant_ligne'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $LignesFactureTable createAlias(String alias) {
    return $LignesFactureTable(attachedDatabase, alias);
  }
}

class LignesFactureData extends DataClass
    implements Insertable<LignesFactureData> {
  final String id;
  final String factureId;
  final String description;
  final String quantite;
  final String uniteSnapshot;
  final int prixUnitaire;
  final int montantLigne;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const LignesFactureData(
      {required this.id,
      required this.factureId,
      required this.description,
      required this.quantite,
      required this.uniteSnapshot,
      required this.prixUnitaire,
      required this.montantLigne,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facture_id'] = Variable<String>(factureId);
    map['description'] = Variable<String>(description);
    map['quantite'] = Variable<String>(quantite);
    map['unite_snapshot'] = Variable<String>(uniteSnapshot);
    map['prix_unitaire'] = Variable<int>(prixUnitaire);
    map['montant_ligne'] = Variable<int>(montantLigne);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  LignesFactureCompanion toCompanion(bool nullToAbsent) {
    return LignesFactureCompanion(
      id: Value(id),
      factureId: Value(factureId),
      description: Value(description),
      quantite: Value(quantite),
      uniteSnapshot: Value(uniteSnapshot),
      prixUnitaire: Value(prixUnitaire),
      montantLigne: Value(montantLigne),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LignesFactureData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LignesFactureData(
      id: serializer.fromJson<String>(json['id']),
      factureId: serializer.fromJson<String>(json['factureId']),
      description: serializer.fromJson<String>(json['description']),
      quantite: serializer.fromJson<String>(json['quantite']),
      uniteSnapshot: serializer.fromJson<String>(json['uniteSnapshot']),
      prixUnitaire: serializer.fromJson<int>(json['prixUnitaire']),
      montantLigne: serializer.fromJson<int>(json['montantLigne']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'factureId': serializer.toJson<String>(factureId),
      'description': serializer.toJson<String>(description),
      'quantite': serializer.toJson<String>(quantite),
      'uniteSnapshot': serializer.toJson<String>(uniteSnapshot),
      'prixUnitaire': serializer.toJson<int>(prixUnitaire),
      'montantLigne': serializer.toJson<int>(montantLigne),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  LignesFactureData copyWith(
          {String? id,
          String? factureId,
          String? description,
          String? quantite,
          String? uniteSnapshot,
          int? prixUnitaire,
          int? montantLigne,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      LignesFactureData(
        id: id ?? this.id,
        factureId: factureId ?? this.factureId,
        description: description ?? this.description,
        quantite: quantite ?? this.quantite,
        uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
        prixUnitaire: prixUnitaire ?? this.prixUnitaire,
        montantLigne: montantLigne ?? this.montantLigne,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  LignesFactureData copyWithCompanion(LignesFactureCompanion data) {
    return LignesFactureData(
      id: data.id.present ? data.id.value : this.id,
      factureId: data.factureId.present ? data.factureId.value : this.factureId,
      description:
          data.description.present ? data.description.value : this.description,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteSnapshot: data.uniteSnapshot.present
          ? data.uniteSnapshot.value
          : this.uniteSnapshot,
      prixUnitaire: data.prixUnitaire.present
          ? data.prixUnitaire.value
          : this.prixUnitaire,
      montantLigne: data.montantLigne.present
          ? data.montantLigne.value
          : this.montantLigne,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LignesFactureData(')
          ..write('id: $id, ')
          ..write('factureId: $factureId, ')
          ..write('description: $description, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('montantLigne: $montantLigne, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      factureId,
      description,
      quantite,
      uniteSnapshot,
      prixUnitaire,
      montantLigne,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LignesFactureData &&
          other.id == this.id &&
          other.factureId == this.factureId &&
          other.description == this.description &&
          other.quantite == this.quantite &&
          other.uniteSnapshot == this.uniteSnapshot &&
          other.prixUnitaire == this.prixUnitaire &&
          other.montantLigne == this.montantLigne &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class LignesFactureCompanion extends UpdateCompanion<LignesFactureData> {
  final Value<String> id;
  final Value<String> factureId;
  final Value<String> description;
  final Value<String> quantite;
  final Value<String> uniteSnapshot;
  final Value<int> prixUnitaire;
  final Value<int> montantLigne;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const LignesFactureCompanion({
    this.id = const Value.absent(),
    this.factureId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteSnapshot = const Value.absent(),
    this.prixUnitaire = const Value.absent(),
    this.montantLigne = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LignesFactureCompanion.insert({
    required String id,
    required String factureId,
    required String description,
    required String quantite,
    required String uniteSnapshot,
    required int prixUnitaire,
    required int montantLigne,
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        factureId = Value(factureId),
        description = Value(description),
        quantite = Value(quantite),
        uniteSnapshot = Value(uniteSnapshot),
        prixUnitaire = Value(prixUnitaire),
        montantLigne = Value(montantLigne),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LignesFactureData> custom({
    Expression<String>? id,
    Expression<String>? factureId,
    Expression<String>? description,
    Expression<String>? quantite,
    Expression<String>? uniteSnapshot,
    Expression<int>? prixUnitaire,
    Expression<int>? montantLigne,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factureId != null) 'facture_id': factureId,
      if (description != null) 'description': description,
      if (quantite != null) 'quantite': quantite,
      if (uniteSnapshot != null) 'unite_snapshot': uniteSnapshot,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (montantLigne != null) 'montant_ligne': montantLigne,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LignesFactureCompanion copyWith(
      {Value<String>? id,
      Value<String>? factureId,
      Value<String>? description,
      Value<String>? quantite,
      Value<String>? uniteSnapshot,
      Value<int>? prixUnitaire,
      Value<int>? montantLigne,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return LignesFactureCompanion(
      id: id ?? this.id,
      factureId: factureId ?? this.factureId,
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      uniteSnapshot: uniteSnapshot ?? this.uniteSnapshot,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      montantLigne: montantLigne ?? this.montantLigne,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (factureId.present) {
      map['facture_id'] = Variable<String>(factureId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<String>(quantite.value);
    }
    if (uniteSnapshot.present) {
      map['unite_snapshot'] = Variable<String>(uniteSnapshot.value);
    }
    if (prixUnitaire.present) {
      map['prix_unitaire'] = Variable<int>(prixUnitaire.value);
    }
    if (montantLigne.present) {
      map['montant_ligne'] = Variable<int>(montantLigne.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LignesFactureCompanion(')
          ..write('id: $id, ')
          ..write('factureId: $factureId, ')
          ..write('description: $description, ')
          ..write('quantite: $quantite, ')
          ..write('uniteSnapshot: $uniteSnapshot, ')
          ..write('prixUnitaire: $prixUnitaire, ')
          ..write('montantLigne: $montantLigne, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaiementsTable extends Paiements
    with TableInfo<$PaiementsTable, Paiement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaiementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _factureIdMeta =
      const VerificationMeta('factureId');
  @override
  late final GeneratedColumn<String> factureId = GeneratedColumn<String>(
      'facture_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _montantMeta =
      const VerificationMeta('montant');
  @override
  late final GeneratedColumn<int> montant = GeneratedColumn<int>(
      'montant', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _datePaiementMeta =
      const VerificationMeta('datePaiement');
  @override
  late final GeneratedColumn<String> datePaiement = GeneratedColumn<String>(
      'date_paiement', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moyenMeta = const VerificationMeta('moyen');
  @override
  late final GeneratedColumn<String> moyen = GeneratedColumn<String>(
      'moyen', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('confirme'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        factureId,
        montant,
        devise,
        datePaiement,
        moyen,
        reference,
        statut,
        notes,
        idempotencyKey,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paiements';
  @override
  VerificationContext validateIntegrity(Insertable<Paiement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facture_id')) {
      context.handle(_factureIdMeta,
          factureId.isAcceptableOrUnknown(data['facture_id']!, _factureIdMeta));
    } else if (isInserting) {
      context.missing(_factureIdMeta);
    }
    if (data.containsKey('montant')) {
      context.handle(_montantMeta,
          montant.isAcceptableOrUnknown(data['montant']!, _montantMeta));
    } else if (isInserting) {
      context.missing(_montantMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('date_paiement')) {
      context.handle(
          _datePaiementMeta,
          datePaiement.isAcceptableOrUnknown(
              data['date_paiement']!, _datePaiementMeta));
    } else if (isInserting) {
      context.missing(_datePaiementMeta);
    }
    if (data.containsKey('moyen')) {
      context.handle(
          _moyenMeta, moyen.isAcceptableOrUnknown(data['moyen']!, _moyenMeta));
    } else if (isInserting) {
      context.missing(_moyenMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Paiement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Paiement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      factureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facture_id'])!,
      montant: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}montant'])!,
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      datePaiement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_paiement'])!,
      moyen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}moyen'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      idempotencyKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idempotency_key']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PaiementsTable createAlias(String alias) {
    return $PaiementsTable(attachedDatabase, alias);
  }
}

class Paiement extends DataClass implements Insertable<Paiement> {
  final String id;
  final String factureId;
  final int montant;
  final String devise;
  final String datePaiement;
  final String moyen;
  final String? reference;
  final String statut;
  final String? notes;
  final String? idempotencyKey;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Paiement(
      {required this.id,
      required this.factureId,
      required this.montant,
      required this.devise,
      required this.datePaiement,
      required this.moyen,
      this.reference,
      required this.statut,
      this.notes,
      this.idempotencyKey,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facture_id'] = Variable<String>(factureId);
    map['montant'] = Variable<int>(montant);
    map['devise'] = Variable<String>(devise);
    map['date_paiement'] = Variable<String>(datePaiement);
    map['moyen'] = Variable<String>(moyen);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  PaiementsCompanion toCompanion(bool nullToAbsent) {
    return PaiementsCompanion(
      id: Value(id),
      factureId: Value(factureId),
      montant: Value(montant),
      devise: Value(devise),
      datePaiement: Value(datePaiement),
      moyen: Value(moyen),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      statut: Value(statut),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Paiement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Paiement(
      id: serializer.fromJson<String>(json['id']),
      factureId: serializer.fromJson<String>(json['factureId']),
      montant: serializer.fromJson<int>(json['montant']),
      devise: serializer.fromJson<String>(json['devise']),
      datePaiement: serializer.fromJson<String>(json['datePaiement']),
      moyen: serializer.fromJson<String>(json['moyen']),
      reference: serializer.fromJson<String?>(json['reference']),
      statut: serializer.fromJson<String>(json['statut']),
      notes: serializer.fromJson<String?>(json['notes']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'factureId': serializer.toJson<String>(factureId),
      'montant': serializer.toJson<int>(montant),
      'devise': serializer.toJson<String>(devise),
      'datePaiement': serializer.toJson<String>(datePaiement),
      'moyen': serializer.toJson<String>(moyen),
      'reference': serializer.toJson<String?>(reference),
      'statut': serializer.toJson<String>(statut),
      'notes': serializer.toJson<String?>(notes),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Paiement copyWith(
          {String? id,
          String? factureId,
          int? montant,
          String? devise,
          String? datePaiement,
          String? moyen,
          Value<String?> reference = const Value.absent(),
          String? statut,
          Value<String?> notes = const Value.absent(),
          Value<String?> idempotencyKey = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Paiement(
        id: id ?? this.id,
        factureId: factureId ?? this.factureId,
        montant: montant ?? this.montant,
        devise: devise ?? this.devise,
        datePaiement: datePaiement ?? this.datePaiement,
        moyen: moyen ?? this.moyen,
        reference: reference.present ? reference.value : this.reference,
        statut: statut ?? this.statut,
        notes: notes.present ? notes.value : this.notes,
        idempotencyKey:
            idempotencyKey.present ? idempotencyKey.value : this.idempotencyKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Paiement copyWithCompanion(PaiementsCompanion data) {
    return Paiement(
      id: data.id.present ? data.id.value : this.id,
      factureId: data.factureId.present ? data.factureId.value : this.factureId,
      montant: data.montant.present ? data.montant.value : this.montant,
      devise: data.devise.present ? data.devise.value : this.devise,
      datePaiement: data.datePaiement.present
          ? data.datePaiement.value
          : this.datePaiement,
      moyen: data.moyen.present ? data.moyen.value : this.moyen,
      reference: data.reference.present ? data.reference.value : this.reference,
      statut: data.statut.present ? data.statut.value : this.statut,
      notes: data.notes.present ? data.notes.value : this.notes,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Paiement(')
          ..write('id: $id, ')
          ..write('factureId: $factureId, ')
          ..write('montant: $montant, ')
          ..write('devise: $devise, ')
          ..write('datePaiement: $datePaiement, ')
          ..write('moyen: $moyen, ')
          ..write('reference: $reference, ')
          ..write('statut: $statut, ')
          ..write('notes: $notes, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      factureId,
      montant,
      devise,
      datePaiement,
      moyen,
      reference,
      statut,
      notes,
      idempotencyKey,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Paiement &&
          other.id == this.id &&
          other.factureId == this.factureId &&
          other.montant == this.montant &&
          other.devise == this.devise &&
          other.datePaiement == this.datePaiement &&
          other.moyen == this.moyen &&
          other.reference == this.reference &&
          other.statut == this.statut &&
          other.notes == this.notes &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class PaiementsCompanion extends UpdateCompanion<Paiement> {
  final Value<String> id;
  final Value<String> factureId;
  final Value<int> montant;
  final Value<String> devise;
  final Value<String> datePaiement;
  final Value<String> moyen;
  final Value<String?> reference;
  final Value<String> statut;
  final Value<String?> notes;
  final Value<String?> idempotencyKey;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const PaiementsCompanion({
    this.id = const Value.absent(),
    this.factureId = const Value.absent(),
    this.montant = const Value.absent(),
    this.devise = const Value.absent(),
    this.datePaiement = const Value.absent(),
    this.moyen = const Value.absent(),
    this.reference = const Value.absent(),
    this.statut = const Value.absent(),
    this.notes = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaiementsCompanion.insert({
    required String id,
    required String factureId,
    required int montant,
    this.devise = const Value.absent(),
    required String datePaiement,
    required String moyen,
    this.reference = const Value.absent(),
    this.statut = const Value.absent(),
    this.notes = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        factureId = Value(factureId),
        montant = Value(montant),
        datePaiement = Value(datePaiement),
        moyen = Value(moyen),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Paiement> custom({
    Expression<String>? id,
    Expression<String>? factureId,
    Expression<int>? montant,
    Expression<String>? devise,
    Expression<String>? datePaiement,
    Expression<String>? moyen,
    Expression<String>? reference,
    Expression<String>? statut,
    Expression<String>? notes,
    Expression<String>? idempotencyKey,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (factureId != null) 'facture_id': factureId,
      if (montant != null) 'montant': montant,
      if (devise != null) 'devise': devise,
      if (datePaiement != null) 'date_paiement': datePaiement,
      if (moyen != null) 'moyen': moyen,
      if (reference != null) 'reference': reference,
      if (statut != null) 'statut': statut,
      if (notes != null) 'notes': notes,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaiementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? factureId,
      Value<int>? montant,
      Value<String>? devise,
      Value<String>? datePaiement,
      Value<String>? moyen,
      Value<String?>? reference,
      Value<String>? statut,
      Value<String?>? notes,
      Value<String?>? idempotencyKey,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return PaiementsCompanion(
      id: id ?? this.id,
      factureId: factureId ?? this.factureId,
      montant: montant ?? this.montant,
      devise: devise ?? this.devise,
      datePaiement: datePaiement ?? this.datePaiement,
      moyen: moyen ?? this.moyen,
      reference: reference ?? this.reference,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (factureId.present) {
      map['facture_id'] = Variable<String>(factureId.value);
    }
    if (montant.present) {
      map['montant'] = Variable<int>(montant.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (datePaiement.present) {
      map['date_paiement'] = Variable<String>(datePaiement.value);
    }
    if (moyen.present) {
      map['moyen'] = Variable<String>(moyen.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaiementsCompanion(')
          ..write('id: $id, ')
          ..write('factureId: $factureId, ')
          ..write('montant: $montant, ')
          ..write('devise: $devise, ')
          ..write('datePaiement: $datePaiement, ')
          ..write('moyen: $moyen, ')
          ..write('reference: $reference, ')
          ..write('statut: $statut, ')
          ..write('notes: $notes, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DepensesTable extends Depenses with TableInfo<$DepensesTable, Depense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateDepenseMeta =
      const VerificationMeta('dateDepense');
  @override
  late final GeneratedColumn<String> dateDepense = GeneratedColumn<String>(
      'date_depense', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categorieMeta =
      const VerificationMeta('categorie');
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
      'categorie', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _montantMeta =
      const VerificationMeta('montant');
  @override
  late final GeneratedColumn<int> montant = GeneratedColumn<int>(
      'montant', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviseMeta = const VerificationMeta('devise');
  @override
  late final GeneratedColumn<String> devise = GeneratedColumn<String>(
      'devise', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MGA'));
  static const VerificationMeta _moyenMeta = const VerificationMeta('moyen');
  @override
  late final GeneratedColumn<String> moyen = GeneratedColumn<String>(
      'moyen', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dateDepense,
        categorie,
        description,
        montant,
        devise,
        moyen,
        reference,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'depenses';
  @override
  VerificationContext validateIntegrity(Insertable<Depense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_depense')) {
      context.handle(
          _dateDepenseMeta,
          dateDepense.isAcceptableOrUnknown(
              data['date_depense']!, _dateDepenseMeta));
    } else if (isInserting) {
      context.missing(_dateDepenseMeta);
    }
    if (data.containsKey('categorie')) {
      context.handle(_categorieMeta,
          categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta));
    } else if (isInserting) {
      context.missing(_categorieMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('montant')) {
      context.handle(_montantMeta,
          montant.isAcceptableOrUnknown(data['montant']!, _montantMeta));
    } else if (isInserting) {
      context.missing(_montantMeta);
    }
    if (data.containsKey('devise')) {
      context.handle(_deviseMeta,
          devise.isAcceptableOrUnknown(data['devise']!, _deviseMeta));
    }
    if (data.containsKey('moyen')) {
      context.handle(
          _moyenMeta, moyen.isAcceptableOrUnknown(data['moyen']!, _moyenMeta));
    } else if (isInserting) {
      context.missing(_moyenMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Depense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Depense(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateDepense: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_depense'])!,
      categorie: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categorie'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      montant: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}montant'])!,
      devise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}devise'])!,
      moyen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}moyen'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $DepensesTable createAlias(String alias) {
    return $DepensesTable(attachedDatabase, alias);
  }
}

class Depense extends DataClass implements Insertable<Depense> {
  final String id;
  final String dateDepense;
  final String categorie;
  final String description;
  final int montant;
  final String devise;
  final String moyen;
  final String? reference;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const Depense(
      {required this.id,
      required this.dateDepense,
      required this.categorie,
      required this.description,
      required this.montant,
      required this.devise,
      required this.moyen,
      this.reference,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_depense'] = Variable<String>(dateDepense);
    map['categorie'] = Variable<String>(categorie);
    map['description'] = Variable<String>(description);
    map['montant'] = Variable<int>(montant);
    map['devise'] = Variable<String>(devise);
    map['moyen'] = Variable<String>(moyen);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  DepensesCompanion toCompanion(bool nullToAbsent) {
    return DepensesCompanion(
      id: Value(id),
      dateDepense: Value(dateDepense),
      categorie: Value(categorie),
      description: Value(description),
      montant: Value(montant),
      devise: Value(devise),
      moyen: Value(moyen),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Depense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Depense(
      id: serializer.fromJson<String>(json['id']),
      dateDepense: serializer.fromJson<String>(json['dateDepense']),
      categorie: serializer.fromJson<String>(json['categorie']),
      description: serializer.fromJson<String>(json['description']),
      montant: serializer.fromJson<int>(json['montant']),
      devise: serializer.fromJson<String>(json['devise']),
      moyen: serializer.fromJson<String>(json['moyen']),
      reference: serializer.fromJson<String?>(json['reference']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateDepense': serializer.toJson<String>(dateDepense),
      'categorie': serializer.toJson<String>(categorie),
      'description': serializer.toJson<String>(description),
      'montant': serializer.toJson<int>(montant),
      'devise': serializer.toJson<String>(devise),
      'moyen': serializer.toJson<String>(moyen),
      'reference': serializer.toJson<String?>(reference),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  Depense copyWith(
          {String? id,
          String? dateDepense,
          String? categorie,
          String? description,
          int? montant,
          String? devise,
          String? moyen,
          Value<String?> reference = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      Depense(
        id: id ?? this.id,
        dateDepense: dateDepense ?? this.dateDepense,
        categorie: categorie ?? this.categorie,
        description: description ?? this.description,
        montant: montant ?? this.montant,
        devise: devise ?? this.devise,
        moyen: moyen ?? this.moyen,
        reference: reference.present ? reference.value : this.reference,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Depense copyWithCompanion(DepensesCompanion data) {
    return Depense(
      id: data.id.present ? data.id.value : this.id,
      dateDepense:
          data.dateDepense.present ? data.dateDepense.value : this.dateDepense,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      description:
          data.description.present ? data.description.value : this.description,
      montant: data.montant.present ? data.montant.value : this.montant,
      devise: data.devise.present ? data.devise.value : this.devise,
      moyen: data.moyen.present ? data.moyen.value : this.moyen,
      reference: data.reference.present ? data.reference.value : this.reference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Depense(')
          ..write('id: $id, ')
          ..write('dateDepense: $dateDepense, ')
          ..write('categorie: $categorie, ')
          ..write('description: $description, ')
          ..write('montant: $montant, ')
          ..write('devise: $devise, ')
          ..write('moyen: $moyen, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dateDepense,
      categorie,
      description,
      montant,
      devise,
      moyen,
      reference,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Depense &&
          other.id == this.id &&
          other.dateDepense == this.dateDepense &&
          other.categorie == this.categorie &&
          other.description == this.description &&
          other.montant == this.montant &&
          other.devise == this.devise &&
          other.moyen == this.moyen &&
          other.reference == this.reference &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class DepensesCompanion extends UpdateCompanion<Depense> {
  final Value<String> id;
  final Value<String> dateDepense;
  final Value<String> categorie;
  final Value<String> description;
  final Value<int> montant;
  final Value<String> devise;
  final Value<String> moyen;
  final Value<String?> reference;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const DepensesCompanion({
    this.id = const Value.absent(),
    this.dateDepense = const Value.absent(),
    this.categorie = const Value.absent(),
    this.description = const Value.absent(),
    this.montant = const Value.absent(),
    this.devise = const Value.absent(),
    this.moyen = const Value.absent(),
    this.reference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DepensesCompanion.insert({
    required String id,
    required String dateDepense,
    required String categorie,
    required String description,
    required int montant,
    this.devise = const Value.absent(),
    required String moyen,
    this.reference = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dateDepense = Value(dateDepense),
        categorie = Value(categorie),
        description = Value(description),
        montant = Value(montant),
        moyen = Value(moyen),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Depense> custom({
    Expression<String>? id,
    Expression<String>? dateDepense,
    Expression<String>? categorie,
    Expression<String>? description,
    Expression<int>? montant,
    Expression<String>? devise,
    Expression<String>? moyen,
    Expression<String>? reference,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateDepense != null) 'date_depense': dateDepense,
      if (categorie != null) 'categorie': categorie,
      if (description != null) 'description': description,
      if (montant != null) 'montant': montant,
      if (devise != null) 'devise': devise,
      if (moyen != null) 'moyen': moyen,
      if (reference != null) 'reference': reference,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DepensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? dateDepense,
      Value<String>? categorie,
      Value<String>? description,
      Value<int>? montant,
      Value<String>? devise,
      Value<String>? moyen,
      Value<String?>? reference,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return DepensesCompanion(
      id: id ?? this.id,
      dateDepense: dateDepense ?? this.dateDepense,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      montant: montant ?? this.montant,
      devise: devise ?? this.devise,
      moyen: moyen ?? this.moyen,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateDepense.present) {
      map['date_depense'] = Variable<String>(dateDepense.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (montant.present) {
      map['montant'] = Variable<int>(montant.value);
    }
    if (devise.present) {
      map['devise'] = Variable<String>(devise.value);
    }
    if (moyen.present) {
      map['moyen'] = Variable<String>(moyen.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepensesCompanion(')
          ..write('id: $id, ')
          ..write('dateDepense: $dateDepense, ')
          ..write('categorie: $categorie, ')
          ..write('description: $description, ')
          ..write('montant: $montant, ')
          ..write('devise: $devise, ')
          ..write('moyen: $moyen, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PiecesJointesTable extends PiecesJointes
    with TableInfo<$PiecesJointesTable, PiecesJointe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PiecesJointesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _demandeIdMeta =
      const VerificationMeta('demandeId');
  @override
  late final GeneratedColumn<String> demandeId = GeneratedColumn<String>(
      'demande_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commandeIdMeta =
      const VerificationMeta('commandeId');
  @override
  late final GeneratedColumn<String> commandeId = GeneratedColumn<String>(
      'commande_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _projetIdMeta =
      const VerificationMeta('projetId');
  @override
  late final GeneratedColumn<String> projetId = GeneratedColumn<String>(
      'projet_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nomFichierMeta =
      const VerificationMeta('nomFichier');
  @override
  late final GeneratedColumn<String> nomFichier = GeneratedColumn<String>(
      'nom_fichier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tailleOctetsMeta =
      const VerificationMeta('tailleOctets');
  @override
  late final GeneratedColumn<int> tailleOctets = GeneratedColumn<int>(
      'taille_octets', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
      'sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cheminLocalMeta =
      const VerificationMeta('cheminLocal');
  @override
  late final GeneratedColumn<String> cheminLocal = GeneratedColumn<String>(
      'chemin_local', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cleStockageDistantMeta =
      const VerificationMeta('cleStockageDistant');
  @override
  late final GeneratedColumn<String> cleStockageDistant =
      GeneratedColumn<String>('cle_stockage_distant', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statutTransfertMeta =
      const VerificationMeta('statutTransfert');
  @override
  late final GeneratedColumn<String> statutTransfert = GeneratedColumn<String>(
      'statut_transfert', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientId,
        demandeId,
        commandeId,
        projetId,
        nomFichier,
        mimeType,
        tailleOctets,
        sha256,
        cheminLocal,
        cleStockageDistant,
        statutTransfert,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pieces_jointes';
  @override
  VerificationContext validateIntegrity(Insertable<PiecesJointe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('demande_id')) {
      context.handle(_demandeIdMeta,
          demandeId.isAcceptableOrUnknown(data['demande_id']!, _demandeIdMeta));
    }
    if (data.containsKey('commande_id')) {
      context.handle(
          _commandeIdMeta,
          commandeId.isAcceptableOrUnknown(
              data['commande_id']!, _commandeIdMeta));
    }
    if (data.containsKey('projet_id')) {
      context.handle(_projetIdMeta,
          projetId.isAcceptableOrUnknown(data['projet_id']!, _projetIdMeta));
    }
    if (data.containsKey('nom_fichier')) {
      context.handle(
          _nomFichierMeta,
          nomFichier.isAcceptableOrUnknown(
              data['nom_fichier']!, _nomFichierMeta));
    } else if (isInserting) {
      context.missing(_nomFichierMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('taille_octets')) {
      context.handle(
          _tailleOctetsMeta,
          tailleOctets.isAcceptableOrUnknown(
              data['taille_octets']!, _tailleOctetsMeta));
    } else if (isInserting) {
      context.missing(_tailleOctetsMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(_sha256Meta,
          sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta));
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('chemin_local')) {
      context.handle(
          _cheminLocalMeta,
          cheminLocal.isAcceptableOrUnknown(
              data['chemin_local']!, _cheminLocalMeta));
    }
    if (data.containsKey('cle_stockage_distant')) {
      context.handle(
          _cleStockageDistantMeta,
          cleStockageDistant.isAcceptableOrUnknown(
              data['cle_stockage_distant']!, _cleStockageDistantMeta));
    }
    if (data.containsKey('statut_transfert')) {
      context.handle(
          _statutTransfertMeta,
          statutTransfert.isAcceptableOrUnknown(
              data['statut_transfert']!, _statutTransfertMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PiecesJointe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PiecesJointe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      demandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}demande_id']),
      commandeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commande_id']),
      projetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projet_id']),
      nomFichier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom_fichier'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      tailleOctets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}taille_octets'])!,
      sha256: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256'])!,
      cheminLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chemin_local']),
      cleStockageDistant: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cle_stockage_distant']),
      statutTransfert: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}statut_transfert'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PiecesJointesTable createAlias(String alias) {
    return $PiecesJointesTable(attachedDatabase, alias);
  }
}

class PiecesJointe extends DataClass implements Insertable<PiecesJointe> {
  final String id;
  final String? clientId;
  final String? demandeId;
  final String? commandeId;
  final String? projetId;
  final String nomFichier;
  final String mimeType;
  final int tailleOctets;
  final String sha256;
  final String? cheminLocal;
  final String? cleStockageDistant;
  final String statutTransfert;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const PiecesJointe(
      {required this.id,
      this.clientId,
      this.demandeId,
      this.commandeId,
      this.projetId,
      required this.nomFichier,
      required this.mimeType,
      required this.tailleOctets,
      required this.sha256,
      this.cheminLocal,
      this.cleStockageDistant,
      required this.statutTransfert,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    if (!nullToAbsent || demandeId != null) {
      map['demande_id'] = Variable<String>(demandeId);
    }
    if (!nullToAbsent || commandeId != null) {
      map['commande_id'] = Variable<String>(commandeId);
    }
    if (!nullToAbsent || projetId != null) {
      map['projet_id'] = Variable<String>(projetId);
    }
    map['nom_fichier'] = Variable<String>(nomFichier);
    map['mime_type'] = Variable<String>(mimeType);
    map['taille_octets'] = Variable<int>(tailleOctets);
    map['sha256'] = Variable<String>(sha256);
    if (!nullToAbsent || cheminLocal != null) {
      map['chemin_local'] = Variable<String>(cheminLocal);
    }
    if (!nullToAbsent || cleStockageDistant != null) {
      map['cle_stockage_distant'] = Variable<String>(cleStockageDistant);
    }
    map['statut_transfert'] = Variable<String>(statutTransfert);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  PiecesJointesCompanion toCompanion(bool nullToAbsent) {
    return PiecesJointesCompanion(
      id: Value(id),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      demandeId: demandeId == null && nullToAbsent
          ? const Value.absent()
          : Value(demandeId),
      commandeId: commandeId == null && nullToAbsent
          ? const Value.absent()
          : Value(commandeId),
      projetId: projetId == null && nullToAbsent
          ? const Value.absent()
          : Value(projetId),
      nomFichier: Value(nomFichier),
      mimeType: Value(mimeType),
      tailleOctets: Value(tailleOctets),
      sha256: Value(sha256),
      cheminLocal: cheminLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(cheminLocal),
      cleStockageDistant: cleStockageDistant == null && nullToAbsent
          ? const Value.absent()
          : Value(cleStockageDistant),
      statutTransfert: Value(statutTransfert),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PiecesJointe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PiecesJointe(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      demandeId: serializer.fromJson<String?>(json['demandeId']),
      commandeId: serializer.fromJson<String?>(json['commandeId']),
      projetId: serializer.fromJson<String?>(json['projetId']),
      nomFichier: serializer.fromJson<String>(json['nomFichier']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      tailleOctets: serializer.fromJson<int>(json['tailleOctets']),
      sha256: serializer.fromJson<String>(json['sha256']),
      cheminLocal: serializer.fromJson<String?>(json['cheminLocal']),
      cleStockageDistant:
          serializer.fromJson<String?>(json['cleStockageDistant']),
      statutTransfert: serializer.fromJson<String>(json['statutTransfert']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String?>(clientId),
      'demandeId': serializer.toJson<String?>(demandeId),
      'commandeId': serializer.toJson<String?>(commandeId),
      'projetId': serializer.toJson<String?>(projetId),
      'nomFichier': serializer.toJson<String>(nomFichier),
      'mimeType': serializer.toJson<String>(mimeType),
      'tailleOctets': serializer.toJson<int>(tailleOctets),
      'sha256': serializer.toJson<String>(sha256),
      'cheminLocal': serializer.toJson<String?>(cheminLocal),
      'cleStockageDistant': serializer.toJson<String?>(cleStockageDistant),
      'statutTransfert': serializer.toJson<String>(statutTransfert),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  PiecesJointe copyWith(
          {String? id,
          Value<String?> clientId = const Value.absent(),
          Value<String?> demandeId = const Value.absent(),
          Value<String?> commandeId = const Value.absent(),
          Value<String?> projetId = const Value.absent(),
          String? nomFichier,
          String? mimeType,
          int? tailleOctets,
          String? sha256,
          Value<String?> cheminLocal = const Value.absent(),
          Value<String?> cleStockageDistant = const Value.absent(),
          String? statutTransfert,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      PiecesJointe(
        id: id ?? this.id,
        clientId: clientId.present ? clientId.value : this.clientId,
        demandeId: demandeId.present ? demandeId.value : this.demandeId,
        commandeId: commandeId.present ? commandeId.value : this.commandeId,
        projetId: projetId.present ? projetId.value : this.projetId,
        nomFichier: nomFichier ?? this.nomFichier,
        mimeType: mimeType ?? this.mimeType,
        tailleOctets: tailleOctets ?? this.tailleOctets,
        sha256: sha256 ?? this.sha256,
        cheminLocal: cheminLocal.present ? cheminLocal.value : this.cheminLocal,
        cleStockageDistant: cleStockageDistant.present
            ? cleStockageDistant.value
            : this.cleStockageDistant,
        statutTransfert: statutTransfert ?? this.statutTransfert,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  PiecesJointe copyWithCompanion(PiecesJointesCompanion data) {
    return PiecesJointe(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      demandeId: data.demandeId.present ? data.demandeId.value : this.demandeId,
      commandeId:
          data.commandeId.present ? data.commandeId.value : this.commandeId,
      projetId: data.projetId.present ? data.projetId.value : this.projetId,
      nomFichier:
          data.nomFichier.present ? data.nomFichier.value : this.nomFichier,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      tailleOctets: data.tailleOctets.present
          ? data.tailleOctets.value
          : this.tailleOctets,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      cheminLocal:
          data.cheminLocal.present ? data.cheminLocal.value : this.cheminLocal,
      cleStockageDistant: data.cleStockageDistant.present
          ? data.cleStockageDistant.value
          : this.cleStockageDistant,
      statutTransfert: data.statutTransfert.present
          ? data.statutTransfert.value
          : this.statutTransfert,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PiecesJointe(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('demandeId: $demandeId, ')
          ..write('commandeId: $commandeId, ')
          ..write('projetId: $projetId, ')
          ..write('nomFichier: $nomFichier, ')
          ..write('mimeType: $mimeType, ')
          ..write('tailleOctets: $tailleOctets, ')
          ..write('sha256: $sha256, ')
          ..write('cheminLocal: $cheminLocal, ')
          ..write('cleStockageDistant: $cleStockageDistant, ')
          ..write('statutTransfert: $statutTransfert, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      clientId,
      demandeId,
      commandeId,
      projetId,
      nomFichier,
      mimeType,
      tailleOctets,
      sha256,
      cheminLocal,
      cleStockageDistant,
      statutTransfert,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PiecesJointe &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.demandeId == this.demandeId &&
          other.commandeId == this.commandeId &&
          other.projetId == this.projetId &&
          other.nomFichier == this.nomFichier &&
          other.mimeType == this.mimeType &&
          other.tailleOctets == this.tailleOctets &&
          other.sha256 == this.sha256 &&
          other.cheminLocal == this.cheminLocal &&
          other.cleStockageDistant == this.cleStockageDistant &&
          other.statutTransfert == this.statutTransfert &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class PiecesJointesCompanion extends UpdateCompanion<PiecesJointe> {
  final Value<String> id;
  final Value<String?> clientId;
  final Value<String?> demandeId;
  final Value<String?> commandeId;
  final Value<String?> projetId;
  final Value<String> nomFichier;
  final Value<String> mimeType;
  final Value<int> tailleOctets;
  final Value<String> sha256;
  final Value<String?> cheminLocal;
  final Value<String?> cleStockageDistant;
  final Value<String> statutTransfert;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const PiecesJointesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.demandeId = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.projetId = const Value.absent(),
    this.nomFichier = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.tailleOctets = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.cheminLocal = const Value.absent(),
    this.cleStockageDistant = const Value.absent(),
    this.statutTransfert = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PiecesJointesCompanion.insert({
    required String id,
    this.clientId = const Value.absent(),
    this.demandeId = const Value.absent(),
    this.commandeId = const Value.absent(),
    this.projetId = const Value.absent(),
    required String nomFichier,
    required String mimeType,
    required int tailleOctets,
    required String sha256,
    this.cheminLocal = const Value.absent(),
    this.cleStockageDistant = const Value.absent(),
    this.statutTransfert = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nomFichier = Value(nomFichier),
        mimeType = Value(mimeType),
        tailleOctets = Value(tailleOctets),
        sha256 = Value(sha256),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PiecesJointe> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? demandeId,
    Expression<String>? commandeId,
    Expression<String>? projetId,
    Expression<String>? nomFichier,
    Expression<String>? mimeType,
    Expression<int>? tailleOctets,
    Expression<String>? sha256,
    Expression<String>? cheminLocal,
    Expression<String>? cleStockageDistant,
    Expression<String>? statutTransfert,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (demandeId != null) 'demande_id': demandeId,
      if (commandeId != null) 'commande_id': commandeId,
      if (projetId != null) 'projet_id': projetId,
      if (nomFichier != null) 'nom_fichier': nomFichier,
      if (mimeType != null) 'mime_type': mimeType,
      if (tailleOctets != null) 'taille_octets': tailleOctets,
      if (sha256 != null) 'sha256': sha256,
      if (cheminLocal != null) 'chemin_local': cheminLocal,
      if (cleStockageDistant != null)
        'cle_stockage_distant': cleStockageDistant,
      if (statutTransfert != null) 'statut_transfert': statutTransfert,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PiecesJointesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? clientId,
      Value<String?>? demandeId,
      Value<String?>? commandeId,
      Value<String?>? projetId,
      Value<String>? nomFichier,
      Value<String>? mimeType,
      Value<int>? tailleOctets,
      Value<String>? sha256,
      Value<String?>? cheminLocal,
      Value<String?>? cleStockageDistant,
      Value<String>? statutTransfert,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return PiecesJointesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      demandeId: demandeId ?? this.demandeId,
      commandeId: commandeId ?? this.commandeId,
      projetId: projetId ?? this.projetId,
      nomFichier: nomFichier ?? this.nomFichier,
      mimeType: mimeType ?? this.mimeType,
      tailleOctets: tailleOctets ?? this.tailleOctets,
      sha256: sha256 ?? this.sha256,
      cheminLocal: cheminLocal ?? this.cheminLocal,
      cleStockageDistant: cleStockageDistant ?? this.cleStockageDistant,
      statutTransfert: statutTransfert ?? this.statutTransfert,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (demandeId.present) {
      map['demande_id'] = Variable<String>(demandeId.value);
    }
    if (commandeId.present) {
      map['commande_id'] = Variable<String>(commandeId.value);
    }
    if (projetId.present) {
      map['projet_id'] = Variable<String>(projetId.value);
    }
    if (nomFichier.present) {
      map['nom_fichier'] = Variable<String>(nomFichier.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (tailleOctets.present) {
      map['taille_octets'] = Variable<int>(tailleOctets.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (cheminLocal.present) {
      map['chemin_local'] = Variable<String>(cheminLocal.value);
    }
    if (cleStockageDistant.present) {
      map['cle_stockage_distant'] = Variable<String>(cleStockageDistant.value);
    }
    if (statutTransfert.present) {
      map['statut_transfert'] = Variable<String>(statutTransfert.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PiecesJointesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('demandeId: $demandeId, ')
          ..write('commandeId: $commandeId, ')
          ..write('projetId: $projetId, ')
          ..write('nomFichier: $nomFichier, ')
          ..write('mimeType: $mimeType, ')
          ..write('tailleOctets: $tailleOctets, ')
          ..write('sha256: $sha256, ')
          ..write('cheminLocal: $cheminLocal, ')
          ..write('cleStockageDistant: $cleStockageDistant, ')
          ..write('statutTransfert: $statutTransfert, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalActionsTable extends JournalActions
    with TableInfo<$JournalActionsTable, JournalAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entiteTypeMeta =
      const VerificationMeta('entiteType');
  @override
  late final GeneratedColumn<String> entiteType = GeneratedColumn<String>(
      'entite_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entiteIdMeta =
      const VerificationMeta('entiteId');
  @override
  late final GeneratedColumn<String> entiteId = GeneratedColumn<String>(
      'entite_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avantJsonMeta =
      const VerificationMeta('avantJson');
  @override
  late final GeneratedColumn<String> avantJson = GeneratedColumn<String>(
      'avant_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _apresJsonMeta =
      const VerificationMeta('apresJson');
  @override
  late final GeneratedColumn<String> apresJson = GeneratedColumn<String>(
      'apres_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _motifMeta = const VerificationMeta('motif');
  @override
  late final GeneratedColumn<String> motif = GeneratedColumn<String>(
      'motif', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _appareilIdMeta =
      const VerificationMeta('appareilId');
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
      'appareil_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acteurIdMeta =
      const VerificationMeta('acteurId');
  @override
  late final GeneratedColumn<String> acteurId = GeneratedColumn<String>(
      'acteur_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateActionMeta =
      const VerificationMeta('dateAction');
  @override
  late final GeneratedColumn<String> dateAction = GeneratedColumn<String>(
      'date_action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entiteType,
        entiteId,
        action,
        avantJson,
        apresJson,
        motif,
        appareilId,
        acteurId,
        dateAction,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_actions';
  @override
  VerificationContext validateIntegrity(Insertable<JournalAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entite_type')) {
      context.handle(
          _entiteTypeMeta,
          entiteType.isAcceptableOrUnknown(
              data['entite_type']!, _entiteTypeMeta));
    } else if (isInserting) {
      context.missing(_entiteTypeMeta);
    }
    if (data.containsKey('entite_id')) {
      context.handle(_entiteIdMeta,
          entiteId.isAcceptableOrUnknown(data['entite_id']!, _entiteIdMeta));
    } else if (isInserting) {
      context.missing(_entiteIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('avant_json')) {
      context.handle(_avantJsonMeta,
          avantJson.isAcceptableOrUnknown(data['avant_json']!, _avantJsonMeta));
    }
    if (data.containsKey('apres_json')) {
      context.handle(_apresJsonMeta,
          apresJson.isAcceptableOrUnknown(data['apres_json']!, _apresJsonMeta));
    }
    if (data.containsKey('motif')) {
      context.handle(
          _motifMeta, motif.isAcceptableOrUnknown(data['motif']!, _motifMeta));
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
          _appareilIdMeta,
          appareilId.isAcceptableOrUnknown(
              data['appareil_id']!, _appareilIdMeta));
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('acteur_id')) {
      context.handle(_acteurIdMeta,
          acteurId.isAcceptableOrUnknown(data['acteur_id']!, _acteurIdMeta));
    }
    if (data.containsKey('date_action')) {
      context.handle(
          _dateActionMeta,
          dateAction.isAcceptableOrUnknown(
              data['date_action']!, _dateActionMeta));
    } else if (isInserting) {
      context.missing(_dateActionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entiteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entite_type'])!,
      entiteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entite_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      avantJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avant_json']),
      apresJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}apres_json']),
      motif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motif']),
      appareilId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appareil_id'])!,
      acteurId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}acteur_id']),
      dateAction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_action'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $JournalActionsTable createAlias(String alias) {
    return $JournalActionsTable(attachedDatabase, alias);
  }
}

class JournalAction extends DataClass implements Insertable<JournalAction> {
  final String id;
  final String entiteType;
  final String entiteId;
  final String action;
  final String? avantJson;
  final String? apresJson;
  final String? motif;
  final String appareilId;
  final String? acteurId;
  final String dateAction;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const JournalAction(
      {required this.id,
      required this.entiteType,
      required this.entiteId,
      required this.action,
      this.avantJson,
      this.apresJson,
      this.motif,
      required this.appareilId,
      this.acteurId,
      required this.dateAction,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entite_type'] = Variable<String>(entiteType);
    map['entite_id'] = Variable<String>(entiteId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || avantJson != null) {
      map['avant_json'] = Variable<String>(avantJson);
    }
    if (!nullToAbsent || apresJson != null) {
      map['apres_json'] = Variable<String>(apresJson);
    }
    if (!nullToAbsent || motif != null) {
      map['motif'] = Variable<String>(motif);
    }
    map['appareil_id'] = Variable<String>(appareilId);
    if (!nullToAbsent || acteurId != null) {
      map['acteur_id'] = Variable<String>(acteurId);
    }
    map['date_action'] = Variable<String>(dateAction);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  JournalActionsCompanion toCompanion(bool nullToAbsent) {
    return JournalActionsCompanion(
      id: Value(id),
      entiteType: Value(entiteType),
      entiteId: Value(entiteId),
      action: Value(action),
      avantJson: avantJson == null && nullToAbsent
          ? const Value.absent()
          : Value(avantJson),
      apresJson: apresJson == null && nullToAbsent
          ? const Value.absent()
          : Value(apresJson),
      motif:
          motif == null && nullToAbsent ? const Value.absent() : Value(motif),
      appareilId: Value(appareilId),
      acteurId: acteurId == null && nullToAbsent
          ? const Value.absent()
          : Value(acteurId),
      dateAction: Value(dateAction),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory JournalAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalAction(
      id: serializer.fromJson<String>(json['id']),
      entiteType: serializer.fromJson<String>(json['entiteType']),
      entiteId: serializer.fromJson<String>(json['entiteId']),
      action: serializer.fromJson<String>(json['action']),
      avantJson: serializer.fromJson<String?>(json['avantJson']),
      apresJson: serializer.fromJson<String?>(json['apresJson']),
      motif: serializer.fromJson<String?>(json['motif']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      acteurId: serializer.fromJson<String?>(json['acteurId']),
      dateAction: serializer.fromJson<String>(json['dateAction']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entiteType': serializer.toJson<String>(entiteType),
      'entiteId': serializer.toJson<String>(entiteId),
      'action': serializer.toJson<String>(action),
      'avantJson': serializer.toJson<String?>(avantJson),
      'apresJson': serializer.toJson<String?>(apresJson),
      'motif': serializer.toJson<String?>(motif),
      'appareilId': serializer.toJson<String>(appareilId),
      'acteurId': serializer.toJson<String?>(acteurId),
      'dateAction': serializer.toJson<String>(dateAction),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  JournalAction copyWith(
          {String? id,
          String? entiteType,
          String? entiteId,
          String? action,
          Value<String?> avantJson = const Value.absent(),
          Value<String?> apresJson = const Value.absent(),
          Value<String?> motif = const Value.absent(),
          String? appareilId,
          Value<String?> acteurId = const Value.absent(),
          String? dateAction,
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      JournalAction(
        id: id ?? this.id,
        entiteType: entiteType ?? this.entiteType,
        entiteId: entiteId ?? this.entiteId,
        action: action ?? this.action,
        avantJson: avantJson.present ? avantJson.value : this.avantJson,
        apresJson: apresJson.present ? apresJson.value : this.apresJson,
        motif: motif.present ? motif.value : this.motif,
        appareilId: appareilId ?? this.appareilId,
        acteurId: acteurId.present ? acteurId.value : this.acteurId,
        dateAction: dateAction ?? this.dateAction,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  JournalAction copyWithCompanion(JournalActionsCompanion data) {
    return JournalAction(
      id: data.id.present ? data.id.value : this.id,
      entiteType:
          data.entiteType.present ? data.entiteType.value : this.entiteType,
      entiteId: data.entiteId.present ? data.entiteId.value : this.entiteId,
      action: data.action.present ? data.action.value : this.action,
      avantJson: data.avantJson.present ? data.avantJson.value : this.avantJson,
      apresJson: data.apresJson.present ? data.apresJson.value : this.apresJson,
      motif: data.motif.present ? data.motif.value : this.motif,
      appareilId:
          data.appareilId.present ? data.appareilId.value : this.appareilId,
      acteurId: data.acteurId.present ? data.acteurId.value : this.acteurId,
      dateAction:
          data.dateAction.present ? data.dateAction.value : this.dateAction,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalAction(')
          ..write('id: $id, ')
          ..write('entiteType: $entiteType, ')
          ..write('entiteId: $entiteId, ')
          ..write('action: $action, ')
          ..write('avantJson: $avantJson, ')
          ..write('apresJson: $apresJson, ')
          ..write('motif: $motif, ')
          ..write('appareilId: $appareilId, ')
          ..write('acteurId: $acteurId, ')
          ..write('dateAction: $dateAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entiteType,
      entiteId,
      action,
      avantJson,
      apresJson,
      motif,
      appareilId,
      acteurId,
      dateAction,
      createdAt,
      updatedAt,
      version,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalAction &&
          other.id == this.id &&
          other.entiteType == this.entiteType &&
          other.entiteId == this.entiteId &&
          other.action == this.action &&
          other.avantJson == this.avantJson &&
          other.apresJson == this.apresJson &&
          other.motif == this.motif &&
          other.appareilId == this.appareilId &&
          other.acteurId == this.acteurId &&
          other.dateAction == this.dateAction &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class JournalActionsCompanion extends UpdateCompanion<JournalAction> {
  final Value<String> id;
  final Value<String> entiteType;
  final Value<String> entiteId;
  final Value<String> action;
  final Value<String?> avantJson;
  final Value<String?> apresJson;
  final Value<String?> motif;
  final Value<String> appareilId;
  final Value<String?> acteurId;
  final Value<String> dateAction;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const JournalActionsCompanion({
    this.id = const Value.absent(),
    this.entiteType = const Value.absent(),
    this.entiteId = const Value.absent(),
    this.action = const Value.absent(),
    this.avantJson = const Value.absent(),
    this.apresJson = const Value.absent(),
    this.motif = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.acteurId = const Value.absent(),
    this.dateAction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalActionsCompanion.insert({
    required String id,
    required String entiteType,
    required String entiteId,
    required String action,
    this.avantJson = const Value.absent(),
    this.apresJson = const Value.absent(),
    this.motif = const Value.absent(),
    required String appareilId,
    this.acteurId = const Value.absent(),
    required String dateAction,
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entiteType = Value(entiteType),
        entiteId = Value(entiteId),
        action = Value(action),
        appareilId = Value(appareilId),
        dateAction = Value(dateAction),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<JournalAction> custom({
    Expression<String>? id,
    Expression<String>? entiteType,
    Expression<String>? entiteId,
    Expression<String>? action,
    Expression<String>? avantJson,
    Expression<String>? apresJson,
    Expression<String>? motif,
    Expression<String>? appareilId,
    Expression<String>? acteurId,
    Expression<String>? dateAction,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entiteType != null) 'entite_type': entiteType,
      if (entiteId != null) 'entite_id': entiteId,
      if (action != null) 'action': action,
      if (avantJson != null) 'avant_json': avantJson,
      if (apresJson != null) 'apres_json': apresJson,
      if (motif != null) 'motif': motif,
      if (appareilId != null) 'appareil_id': appareilId,
      if (acteurId != null) 'acteur_id': acteurId,
      if (dateAction != null) 'date_action': dateAction,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalActionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entiteType,
      Value<String>? entiteId,
      Value<String>? action,
      Value<String?>? avantJson,
      Value<String?>? apresJson,
      Value<String?>? motif,
      Value<String>? appareilId,
      Value<String?>? acteurId,
      Value<String>? dateAction,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return JournalActionsCompanion(
      id: id ?? this.id,
      entiteType: entiteType ?? this.entiteType,
      entiteId: entiteId ?? this.entiteId,
      action: action ?? this.action,
      avantJson: avantJson ?? this.avantJson,
      apresJson: apresJson ?? this.apresJson,
      motif: motif ?? this.motif,
      appareilId: appareilId ?? this.appareilId,
      acteurId: acteurId ?? this.acteurId,
      dateAction: dateAction ?? this.dateAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entiteType.present) {
      map['entite_type'] = Variable<String>(entiteType.value);
    }
    if (entiteId.present) {
      map['entite_id'] = Variable<String>(entiteId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (avantJson.present) {
      map['avant_json'] = Variable<String>(avantJson.value);
    }
    if (apresJson.present) {
      map['apres_json'] = Variable<String>(apresJson.value);
    }
    if (motif.present) {
      map['motif'] = Variable<String>(motif.value);
    }
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (acteurId.present) {
      map['acteur_id'] = Variable<String>(acteurId.value);
    }
    if (dateAction.present) {
      map['date_action'] = Variable<String>(dateAction.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalActionsCompanion(')
          ..write('id: $id, ')
          ..write('entiteType: $entiteType, ')
          ..write('entiteId: $entiteId, ')
          ..write('action: $action, ')
          ..write('avantJson: $avantJson, ')
          ..write('apresJson: $apresJson, ')
          ..write('motif: $motif, ')
          ..write('appareilId: $appareilId, ')
          ..write('acteurId: $acteurId, ')
          ..write('dateAction: $dateAction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppareilsTable extends Appareils
    with TableInfo<$AppareilsTable, Appareil> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppareilsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plateformeMeta =
      const VerificationMeta('plateforme');
  @override
  late final GeneratedColumn<String> plateforme = GeneratedColumn<String>(
      'plateforme', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dernierSyncAtMeta =
      const VerificationMeta('dernierSyncAt');
  @override
  late final GeneratedColumn<String> dernierSyncAt = GeneratedColumn<String>(
      'dernier_sync_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actifMeta = const VerificationMeta('actif');
  @override
  late final GeneratedColumn<bool> actif = GeneratedColumn<bool>(
      'actif', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("actif" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, nom, plateforme, dernierSyncAt, actif, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appareils';
  @override
  VerificationContext validateIntegrity(Insertable<Appareil> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('plateforme')) {
      context.handle(
          _plateformeMeta,
          plateforme.isAcceptableOrUnknown(
              data['plateforme']!, _plateformeMeta));
    } else if (isInserting) {
      context.missing(_plateformeMeta);
    }
    if (data.containsKey('dernier_sync_at')) {
      context.handle(
          _dernierSyncAtMeta,
          dernierSyncAt.isAcceptableOrUnknown(
              data['dernier_sync_at']!, _dernierSyncAtMeta));
    }
    if (data.containsKey('actif')) {
      context.handle(
          _actifMeta, actif.isAcceptableOrUnknown(data['actif']!, _actifMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appareil map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appareil(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      plateforme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plateforme'])!,
      dernierSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dernier_sync_at']),
      actif: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}actif'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppareilsTable createAlias(String alias) {
    return $AppareilsTable(attachedDatabase, alias);
  }
}

class Appareil extends DataClass implements Insertable<Appareil> {
  final String id;
  final String nom;
  final String plateforme;
  final String? dernierSyncAt;
  final bool actif;
  final String createdAt;
  final String updatedAt;
  const Appareil(
      {required this.id,
      required this.nom,
      required this.plateforme,
      this.dernierSyncAt,
      required this.actif,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nom'] = Variable<String>(nom);
    map['plateforme'] = Variable<String>(plateforme);
    if (!nullToAbsent || dernierSyncAt != null) {
      map['dernier_sync_at'] = Variable<String>(dernierSyncAt);
    }
    map['actif'] = Variable<bool>(actif);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AppareilsCompanion toCompanion(bool nullToAbsent) {
    return AppareilsCompanion(
      id: Value(id),
      nom: Value(nom),
      plateforme: Value(plateforme),
      dernierSyncAt: dernierSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dernierSyncAt),
      actif: Value(actif),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Appareil.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appareil(
      id: serializer.fromJson<String>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      plateforme: serializer.fromJson<String>(json['plateforme']),
      dernierSyncAt: serializer.fromJson<String?>(json['dernierSyncAt']),
      actif: serializer.fromJson<bool>(json['actif']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nom': serializer.toJson<String>(nom),
      'plateforme': serializer.toJson<String>(plateforme),
      'dernierSyncAt': serializer.toJson<String?>(dernierSyncAt),
      'actif': serializer.toJson<bool>(actif),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Appareil copyWith(
          {String? id,
          String? nom,
          String? plateforme,
          Value<String?> dernierSyncAt = const Value.absent(),
          bool? actif,
          String? createdAt,
          String? updatedAt}) =>
      Appareil(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        plateforme: plateforme ?? this.plateforme,
        dernierSyncAt:
            dernierSyncAt.present ? dernierSyncAt.value : this.dernierSyncAt,
        actif: actif ?? this.actif,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Appareil copyWithCompanion(AppareilsCompanion data) {
    return Appareil(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      plateforme:
          data.plateforme.present ? data.plateforme.value : this.plateforme,
      dernierSyncAt: data.dernierSyncAt.present
          ? data.dernierSyncAt.value
          : this.dernierSyncAt,
      actif: data.actif.present ? data.actif.value : this.actif,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appareil(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('plateforme: $plateforme, ')
          ..write('dernierSyncAt: $dernierSyncAt, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, nom, plateforme, dernierSyncAt, actif, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appareil &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.plateforme == this.plateforme &&
          other.dernierSyncAt == this.dernierSyncAt &&
          other.actif == this.actif &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppareilsCompanion extends UpdateCompanion<Appareil> {
  final Value<String> id;
  final Value<String> nom;
  final Value<String> plateforme;
  final Value<String?> dernierSyncAt;
  final Value<bool> actif;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AppareilsCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.plateforme = const Value.absent(),
    this.dernierSyncAt = const Value.absent(),
    this.actif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppareilsCompanion.insert({
    required String id,
    required String nom,
    required String plateforme,
    this.dernierSyncAt = const Value.absent(),
    this.actif = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nom = Value(nom),
        plateforme = Value(plateforme),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Appareil> custom({
    Expression<String>? id,
    Expression<String>? nom,
    Expression<String>? plateforme,
    Expression<String>? dernierSyncAt,
    Expression<bool>? actif,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (plateforme != null) 'plateforme': plateforme,
      if (dernierSyncAt != null) 'dernier_sync_at': dernierSyncAt,
      if (actif != null) 'actif': actif,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppareilsCompanion copyWith(
      {Value<String>? id,
      Value<String>? nom,
      Value<String>? plateforme,
      Value<String?>? dernierSyncAt,
      Value<bool>? actif,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return AppareilsCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      plateforme: plateforme ?? this.plateforme,
      dernierSyncAt: dernierSyncAt ?? this.dernierSyncAt,
      actif: actif ?? this.actif,
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
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (plateforme.present) {
      map['plateforme'] = Variable<String>(plateforme.value);
    }
    if (dernierSyncAt.present) {
      map['dernier_sync_at'] = Variable<String>(dernierSyncAt.value);
    }
    if (actif.present) {
      map['actif'] = Variable<bool>(actif.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppareilsCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('plateforme: $plateforme, ')
          ..write('dernierSyncAt: $dernierSyncAt, ')
          ..write('actif: $actif, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PublicationsFacebookTable extends PublicationsFacebook
    with TableInfo<$PublicationsFacebookTable, PublicationsFacebookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PublicationsFacebookTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titreMeta = const VerificationMeta('titre');
  @override
  late final GeneratedColumn<String> titre = GeneratedColumn<String>(
      'titre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contenuMeta =
      const VerificationMeta('contenu');
  @override
  late final GeneratedColumn<String> contenu = GeneratedColumn<String>(
      'contenu', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _datePlanifieeMeta =
      const VerificationMeta('datePlanifiee');
  @override
  late final GeneratedColumn<String> datePlanifiee = GeneratedColumn<String>(
      'date_planifiee', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('planifie'));
  static const VerificationMeta _canalMeta = const VerificationMeta('canal');
  @override
  late final GeneratedColumn<String> canal = GeneratedColumn<String>(
      'canal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('facebook'));
  static const VerificationMeta _publieAtMeta =
      const VerificationMeta('publieAt');
  @override
  late final GeneratedColumn<String> publieAt = GeneratedColumn<String>(
      'publie_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientId,
        titre,
        contenu,
        datePlanifiee,
        statut,
        canal,
        publieAt,
        notes,
        createdAt,
        updatedAt,
        version,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'publications_facebook';
  @override
  VerificationContext validateIntegrity(
      Insertable<PublicationsFacebookData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('titre')) {
      context.handle(
          _titreMeta, titre.isAcceptableOrUnknown(data['titre']!, _titreMeta));
    } else if (isInserting) {
      context.missing(_titreMeta);
    }
    if (data.containsKey('contenu')) {
      context.handle(_contenuMeta,
          contenu.isAcceptableOrUnknown(data['contenu']!, _contenuMeta));
    } else if (isInserting) {
      context.missing(_contenuMeta);
    }
    if (data.containsKey('date_planifiee')) {
      context.handle(
          _datePlanifieeMeta,
          datePlanifiee.isAcceptableOrUnknown(
              data['date_planifiee']!, _datePlanifieeMeta));
    } else if (isInserting) {
      context.missing(_datePlanifieeMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('canal')) {
      context.handle(
          _canalMeta, canal.isAcceptableOrUnknown(data['canal']!, _canalMeta));
    }
    if (data.containsKey('publie_at')) {
      context.handle(_publieAtMeta,
          publieAt.isAcceptableOrUnknown(data['publie_at']!, _publieAtMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PublicationsFacebookData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PublicationsFacebookData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id']),
      titre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titre'])!,
      contenu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contenu'])!,
      datePlanifiee: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_planifiee'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      canal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canal'])!,
      publieAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publie_at']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PublicationsFacebookTable createAlias(String alias) {
    return $PublicationsFacebookTable(attachedDatabase, alias);
  }
}

class PublicationsFacebookData extends DataClass
    implements Insertable<PublicationsFacebookData> {
  final String id;
  final String? clientId;
  final String titre;
  final String contenu;
  final String datePlanifiee;
  final String statut;
  final String canal;
  final String? publieAt;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String? deletedAt;
  const PublicationsFacebookData(
      {required this.id,
      this.clientId,
      required this.titre,
      required this.contenu,
      required this.datePlanifiee,
      required this.statut,
      required this.canal,
      this.publieAt,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['titre'] = Variable<String>(titre);
    map['contenu'] = Variable<String>(contenu);
    map['date_planifiee'] = Variable<String>(datePlanifiee);
    map['statut'] = Variable<String>(statut);
    map['canal'] = Variable<String>(canal);
    if (!nullToAbsent || publieAt != null) {
      map['publie_at'] = Variable<String>(publieAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  PublicationsFacebookCompanion toCompanion(bool nullToAbsent) {
    return PublicationsFacebookCompanion(
      id: Value(id),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      titre: Value(titre),
      contenu: Value(contenu),
      datePlanifiee: Value(datePlanifiee),
      statut: Value(statut),
      canal: Value(canal),
      publieAt: publieAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publieAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PublicationsFacebookData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PublicationsFacebookData(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      titre: serializer.fromJson<String>(json['titre']),
      contenu: serializer.fromJson<String>(json['contenu']),
      datePlanifiee: serializer.fromJson<String>(json['datePlanifiee']),
      statut: serializer.fromJson<String>(json['statut']),
      canal: serializer.fromJson<String>(json['canal']),
      publieAt: serializer.fromJson<String?>(json['publieAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String?>(clientId),
      'titre': serializer.toJson<String>(titre),
      'contenu': serializer.toJson<String>(contenu),
      'datePlanifiee': serializer.toJson<String>(datePlanifiee),
      'statut': serializer.toJson<String>(statut),
      'canal': serializer.toJson<String>(canal),
      'publieAt': serializer.toJson<String?>(publieAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'version': serializer.toJson<int>(version),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  PublicationsFacebookData copyWith(
          {String? id,
          Value<String?> clientId = const Value.absent(),
          String? titre,
          String? contenu,
          String? datePlanifiee,
          String? statut,
          String? canal,
          Value<String?> publieAt = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          int? version,
          Value<String?> deletedAt = const Value.absent()}) =>
      PublicationsFacebookData(
        id: id ?? this.id,
        clientId: clientId.present ? clientId.value : this.clientId,
        titre: titre ?? this.titre,
        contenu: contenu ?? this.contenu,
        datePlanifiee: datePlanifiee ?? this.datePlanifiee,
        statut: statut ?? this.statut,
        canal: canal ?? this.canal,
        publieAt: publieAt.present ? publieAt.value : this.publieAt,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  PublicationsFacebookData copyWithCompanion(
      PublicationsFacebookCompanion data) {
    return PublicationsFacebookData(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      titre: data.titre.present ? data.titre.value : this.titre,
      contenu: data.contenu.present ? data.contenu.value : this.contenu,
      datePlanifiee: data.datePlanifiee.present
          ? data.datePlanifiee.value
          : this.datePlanifiee,
      statut: data.statut.present ? data.statut.value : this.statut,
      canal: data.canal.present ? data.canal.value : this.canal,
      publieAt: data.publieAt.present ? data.publieAt.value : this.publieAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PublicationsFacebookData(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('titre: $titre, ')
          ..write('contenu: $contenu, ')
          ..write('datePlanifiee: $datePlanifiee, ')
          ..write('statut: $statut, ')
          ..write('canal: $canal, ')
          ..write('publieAt: $publieAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clientId, titre, contenu, datePlanifiee,
      statut, canal, publieAt, notes, createdAt, updatedAt, version, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PublicationsFacebookData &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.titre == this.titre &&
          other.contenu == this.contenu &&
          other.datePlanifiee == this.datePlanifiee &&
          other.statut == this.statut &&
          other.canal == this.canal &&
          other.publieAt == this.publieAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.deletedAt == this.deletedAt);
}

class PublicationsFacebookCompanion
    extends UpdateCompanion<PublicationsFacebookData> {
  final Value<String> id;
  final Value<String?> clientId;
  final Value<String> titre;
  final Value<String> contenu;
  final Value<String> datePlanifiee;
  final Value<String> statut;
  final Value<String> canal;
  final Value<String?> publieAt;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> version;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const PublicationsFacebookCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.titre = const Value.absent(),
    this.contenu = const Value.absent(),
    this.datePlanifiee = const Value.absent(),
    this.statut = const Value.absent(),
    this.canal = const Value.absent(),
    this.publieAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PublicationsFacebookCompanion.insert({
    required String id,
    this.clientId = const Value.absent(),
    required String titre,
    required String contenu,
    required String datePlanifiee,
    this.statut = const Value.absent(),
    this.canal = const Value.absent(),
    this.publieAt = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.version = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        titre = Value(titre),
        contenu = Value(contenu),
        datePlanifiee = Value(datePlanifiee),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PublicationsFacebookData> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? titre,
    Expression<String>? contenu,
    Expression<String>? datePlanifiee,
    Expression<String>? statut,
    Expression<String>? canal,
    Expression<String>? publieAt,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? version,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (titre != null) 'titre': titre,
      if (contenu != null) 'contenu': contenu,
      if (datePlanifiee != null) 'date_planifiee': datePlanifiee,
      if (statut != null) 'statut': statut,
      if (canal != null) 'canal': canal,
      if (publieAt != null) 'publie_at': publieAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PublicationsFacebookCompanion copyWith(
      {Value<String>? id,
      Value<String?>? clientId,
      Value<String>? titre,
      Value<String>? contenu,
      Value<String>? datePlanifiee,
      Value<String>? statut,
      Value<String>? canal,
      Value<String?>? publieAt,
      Value<String?>? notes,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? version,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return PublicationsFacebookCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      datePlanifiee: datePlanifiee ?? this.datePlanifiee,
      statut: statut ?? this.statut,
      canal: canal ?? this.canal,
      publieAt: publieAt ?? this.publieAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (titre.present) {
      map['titre'] = Variable<String>(titre.value);
    }
    if (contenu.present) {
      map['contenu'] = Variable<String>(contenu.value);
    }
    if (datePlanifiee.present) {
      map['date_planifiee'] = Variable<String>(datePlanifiee.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (canal.present) {
      map['canal'] = Variable<String>(canal.value);
    }
    if (publieAt.present) {
      map['publie_at'] = Variable<String>(publieAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PublicationsFacebookCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('titre: $titre, ')
          ..write('contenu: $contenu, ')
          ..write('datePlanifiee: $datePlanifiee, ')
          ..write('statut: $statut, ')
          ..write('canal: $canal, ')
          ..write('publieAt: $publieAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appareilIdMeta =
      const VerificationMeta('appareilId');
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
      'appareil_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entiteTypeMeta =
      const VerificationMeta('entiteType');
  @override
  late final GeneratedColumn<String> entiteType = GeneratedColumn<String>(
      'entite_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entiteIdMeta =
      const VerificationMeta('entiteId');
  @override
  late final GeneratedColumn<String> entiteId = GeneratedColumn<String>(
      'entite_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseVersionMeta =
      const VerificationMeta('baseVersion');
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
      'base_version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _tentativesMeta =
      const VerificationMeta('tentatives');
  @override
  late final GeneratedColumn<int> tentatives = GeneratedColumn<int>(
      'tentatives', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _prochaineTentativeAtMeta =
      const VerificationMeta('prochaineTentativeAt');
  @override
  late final GeneratedColumn<String> prochaineTentativeAt =
      GeneratedColumn<String>('prochaine_tentative_at', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _derniereErreurMeta =
      const VerificationMeta('derniereErreur');
  @override
  late final GeneratedColumn<String> derniereErreur = GeneratedColumn<String>(
      'derniere_erreur', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        appareilId,
        entiteType,
        entiteId,
        operation,
        payloadJson,
        baseVersion,
        idempotencyKey,
        statut,
        tentatives,
        prochaineTentativeAt,
        derniereErreur,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
          _appareilIdMeta,
          appareilId.isAcceptableOrUnknown(
              data['appareil_id']!, _appareilIdMeta));
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('entite_type')) {
      context.handle(
          _entiteTypeMeta,
          entiteType.isAcceptableOrUnknown(
              data['entite_type']!, _entiteTypeMeta));
    } else if (isInserting) {
      context.missing(_entiteTypeMeta);
    }
    if (data.containsKey('entite_id')) {
      context.handle(_entiteIdMeta,
          entiteId.isAcceptableOrUnknown(data['entite_id']!, _entiteIdMeta));
    } else if (isInserting) {
      context.missing(_entiteIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
          _baseVersionMeta,
          baseVersion.isAcceptableOrUnknown(
              data['base_version']!, _baseVersionMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('tentatives')) {
      context.handle(
          _tentativesMeta,
          tentatives.isAcceptableOrUnknown(
              data['tentatives']!, _tentativesMeta));
    }
    if (data.containsKey('prochaine_tentative_at')) {
      context.handle(
          _prochaineTentativeAtMeta,
          prochaineTentativeAt.isAcceptableOrUnknown(
              data['prochaine_tentative_at']!, _prochaineTentativeAtMeta));
    }
    if (data.containsKey('derniere_erreur')) {
      context.handle(
          _derniereErreurMeta,
          derniereErreur.isAcceptableOrUnknown(
              data['derniere_erreur']!, _derniereErreurMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      appareilId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appareil_id'])!,
      entiteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entite_type'])!,
      entiteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entite_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      baseVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}base_version']),
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      tentatives: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tentatives'])!,
      prochaineTentativeAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prochaine_tentative_at']),
      derniereErreur: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}derniere_erreur']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String appareilId;
  final String entiteType;
  final String entiteId;
  final String operation;
  final String payloadJson;
  final int? baseVersion;
  final String idempotencyKey;
  final String statut;
  final int tentatives;
  final String? prochaineTentativeAt;
  final String? derniereErreur;
  final String createdAt;
  final String updatedAt;
  const SyncOutboxData(
      {required this.id,
      required this.appareilId,
      required this.entiteType,
      required this.entiteId,
      required this.operation,
      required this.payloadJson,
      this.baseVersion,
      required this.idempotencyKey,
      required this.statut,
      required this.tentatives,
      this.prochaineTentativeAt,
      this.derniereErreur,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['appareil_id'] = Variable<String>(appareilId);
    map['entite_type'] = Variable<String>(entiteType);
    map['entite_id'] = Variable<String>(entiteId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['statut'] = Variable<String>(statut);
    map['tentatives'] = Variable<int>(tentatives);
    if (!nullToAbsent || prochaineTentativeAt != null) {
      map['prochaine_tentative_at'] = Variable<String>(prochaineTentativeAt);
    }
    if (!nullToAbsent || derniereErreur != null) {
      map['derniere_erreur'] = Variable<String>(derniereErreur);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      appareilId: Value(appareilId),
      entiteType: Value(entiteType),
      entiteId: Value(entiteId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      idempotencyKey: Value(idempotencyKey),
      statut: Value(statut),
      tentatives: Value(tentatives),
      prochaineTentativeAt: prochaineTentativeAt == null && nullToAbsent
          ? const Value.absent()
          : Value(prochaineTentativeAt),
      derniereErreur: derniereErreur == null && nullToAbsent
          ? const Value.absent()
          : Value(derniereErreur),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncOutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      entiteType: serializer.fromJson<String>(json['entiteType']),
      entiteId: serializer.fromJson<String>(json['entiteId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      statut: serializer.fromJson<String>(json['statut']),
      tentatives: serializer.fromJson<int>(json['tentatives']),
      prochaineTentativeAt:
          serializer.fromJson<String?>(json['prochaineTentativeAt']),
      derniereErreur: serializer.fromJson<String?>(json['derniereErreur']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'appareilId': serializer.toJson<String>(appareilId),
      'entiteType': serializer.toJson<String>(entiteType),
      'entiteId': serializer.toJson<String>(entiteId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'statut': serializer.toJson<String>(statut),
      'tentatives': serializer.toJson<int>(tentatives),
      'prochaineTentativeAt': serializer.toJson<String?>(prochaineTentativeAt),
      'derniereErreur': serializer.toJson<String?>(derniereErreur),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SyncOutboxData copyWith(
          {String? id,
          String? appareilId,
          String? entiteType,
          String? entiteId,
          String? operation,
          String? payloadJson,
          Value<int?> baseVersion = const Value.absent(),
          String? idempotencyKey,
          String? statut,
          int? tentatives,
          Value<String?> prochaineTentativeAt = const Value.absent(),
          Value<String?> derniereErreur = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      SyncOutboxData(
        id: id ?? this.id,
        appareilId: appareilId ?? this.appareilId,
        entiteType: entiteType ?? this.entiteType,
        entiteId: entiteId ?? this.entiteId,
        operation: operation ?? this.operation,
        payloadJson: payloadJson ?? this.payloadJson,
        baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        statut: statut ?? this.statut,
        tentatives: tentatives ?? this.tentatives,
        prochaineTentativeAt: prochaineTentativeAt.present
            ? prochaineTentativeAt.value
            : this.prochaineTentativeAt,
        derniereErreur:
            derniereErreur.present ? derniereErreur.value : this.derniereErreur,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      appareilId:
          data.appareilId.present ? data.appareilId.value : this.appareilId,
      entiteType:
          data.entiteType.present ? data.entiteType.value : this.entiteType,
      entiteId: data.entiteId.present ? data.entiteId.value : this.entiteId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      baseVersion:
          data.baseVersion.present ? data.baseVersion.value : this.baseVersion,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      statut: data.statut.present ? data.statut.value : this.statut,
      tentatives:
          data.tentatives.present ? data.tentatives.value : this.tentatives,
      prochaineTentativeAt: data.prochaineTentativeAt.present
          ? data.prochaineTentativeAt.value
          : this.prochaineTentativeAt,
      derniereErreur: data.derniereErreur.present
          ? data.derniereErreur.value
          : this.derniereErreur,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('appareilId: $appareilId, ')
          ..write('entiteType: $entiteType, ')
          ..write('entiteId: $entiteId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('statut: $statut, ')
          ..write('tentatives: $tentatives, ')
          ..write('prochaineTentativeAt: $prochaineTentativeAt, ')
          ..write('derniereErreur: $derniereErreur, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      appareilId,
      entiteType,
      entiteId,
      operation,
      payloadJson,
      baseVersion,
      idempotencyKey,
      statut,
      tentatives,
      prochaineTentativeAt,
      derniereErreur,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.appareilId == this.appareilId &&
          other.entiteType == this.entiteType &&
          other.entiteId == this.entiteId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.baseVersion == this.baseVersion &&
          other.idempotencyKey == this.idempotencyKey &&
          other.statut == this.statut &&
          other.tentatives == this.tentatives &&
          other.prochaineTentativeAt == this.prochaineTentativeAt &&
          other.derniereErreur == this.derniereErreur &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> appareilId;
  final Value<String> entiteType;
  final Value<String> entiteId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int?> baseVersion;
  final Value<String> idempotencyKey;
  final Value<String> statut;
  final Value<int> tentatives;
  final Value<String?> prochaineTentativeAt;
  final Value<String?> derniereErreur;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.entiteType = const Value.absent(),
    this.entiteId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.statut = const Value.absent(),
    this.tentatives = const Value.absent(),
    this.prochaineTentativeAt = const Value.absent(),
    this.derniereErreur = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String appareilId,
    required String entiteType,
    required String entiteId,
    required String operation,
    required String payloadJson,
    this.baseVersion = const Value.absent(),
    required String idempotencyKey,
    this.statut = const Value.absent(),
    this.tentatives = const Value.absent(),
    this.prochaineTentativeAt = const Value.absent(),
    this.derniereErreur = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        appareilId = Value(appareilId),
        entiteType = Value(entiteType),
        entiteId = Value(entiteId),
        operation = Value(operation),
        payloadJson = Value(payloadJson),
        idempotencyKey = Value(idempotencyKey),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? appareilId,
    Expression<String>? entiteType,
    Expression<String>? entiteId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? baseVersion,
    Expression<String>? idempotencyKey,
    Expression<String>? statut,
    Expression<int>? tentatives,
    Expression<String>? prochaineTentativeAt,
    Expression<String>? derniereErreur,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appareilId != null) 'appareil_id': appareilId,
      if (entiteType != null) 'entite_type': entiteType,
      if (entiteId != null) 'entite_id': entiteId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (baseVersion != null) 'base_version': baseVersion,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (statut != null) 'statut': statut,
      if (tentatives != null) 'tentatives': tentatives,
      if (prochaineTentativeAt != null)
        'prochaine_tentative_at': prochaineTentativeAt,
      if (derniereErreur != null) 'derniere_erreur': derniereErreur,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<String>? id,
      Value<String>? appareilId,
      Value<String>? entiteType,
      Value<String>? entiteId,
      Value<String>? operation,
      Value<String>? payloadJson,
      Value<int?>? baseVersion,
      Value<String>? idempotencyKey,
      Value<String>? statut,
      Value<int>? tentatives,
      Value<String?>? prochaineTentativeAt,
      Value<String?>? derniereErreur,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      appareilId: appareilId ?? this.appareilId,
      entiteType: entiteType ?? this.entiteType,
      entiteId: entiteId ?? this.entiteId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      baseVersion: baseVersion ?? this.baseVersion,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      statut: statut ?? this.statut,
      tentatives: tentatives ?? this.tentatives,
      prochaineTentativeAt: prochaineTentativeAt ?? this.prochaineTentativeAt,
      derniereErreur: derniereErreur ?? this.derniereErreur,
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
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (entiteType.present) {
      map['entite_type'] = Variable<String>(entiteType.value);
    }
    if (entiteId.present) {
      map['entite_id'] = Variable<String>(entiteId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (tentatives.present) {
      map['tentatives'] = Variable<int>(tentatives.value);
    }
    if (prochaineTentativeAt.present) {
      map['prochaine_tentative_at'] =
          Variable<String>(prochaineTentativeAt.value);
    }
    if (derniereErreur.present) {
      map['derniere_erreur'] = Variable<String>(derniereErreur.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('appareilId: $appareilId, ')
          ..write('entiteType: $entiteType, ')
          ..write('entiteId: $entiteId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('statut: $statut, ')
          ..write('tentatives: $tentatives, ')
          ..write('prochaineTentativeAt: $prochaineTentativeAt, ')
          ..write('derniereErreur: $derniereErreur, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _appareilIdMeta =
      const VerificationMeta('appareilId');
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
      'appareil_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dernierCurseurMeta =
      const VerificationMeta('dernierCurseur');
  @override
  late final GeneratedColumn<String> dernierCurseur = GeneratedColumn<String>(
      'dernier_curseur', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('0'));
  static const VerificationMeta _dernierSyncReussiAtMeta =
      const VerificationMeta('dernierSyncReussiAt');
  @override
  late final GeneratedColumn<String> dernierSyncReussiAt =
      GeneratedColumn<String>('dernier_sync_reussi_at', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _derniereErreurMeta =
      const VerificationMeta('derniereErreur');
  @override
  late final GeneratedColumn<String> derniereErreur = GeneratedColumn<String>(
      'derniere_erreur', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        appareilId,
        dernierCurseur,
        dernierSyncReussiAt,
        derniereErreur,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('appareil_id')) {
      context.handle(
          _appareilIdMeta,
          appareilId.isAcceptableOrUnknown(
              data['appareil_id']!, _appareilIdMeta));
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('dernier_curseur')) {
      context.handle(
          _dernierCurseurMeta,
          dernierCurseur.isAcceptableOrUnknown(
              data['dernier_curseur']!, _dernierCurseurMeta));
    }
    if (data.containsKey('dernier_sync_reussi_at')) {
      context.handle(
          _dernierSyncReussiAtMeta,
          dernierSyncReussiAt.isAcceptableOrUnknown(
              data['dernier_sync_reussi_at']!, _dernierSyncReussiAtMeta));
    }
    if (data.containsKey('derniere_erreur')) {
      context.handle(
          _derniereErreurMeta,
          derniereErreur.isAcceptableOrUnknown(
              data['derniere_erreur']!, _derniereErreurMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {appareilId};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      appareilId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appareil_id'])!,
      dernierCurseur: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dernier_curseur'])!,
      dernierSyncReussiAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}dernier_sync_reussi_at']),
      derniereErreur: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}derniere_erreur']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String appareilId;
  final String dernierCurseur;
  final String? dernierSyncReussiAt;
  final String? derniereErreur;
  final String updatedAt;
  const SyncStateData(
      {required this.appareilId,
      required this.dernierCurseur,
      this.dernierSyncReussiAt,
      this.derniereErreur,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['appareil_id'] = Variable<String>(appareilId);
    map['dernier_curseur'] = Variable<String>(dernierCurseur);
    if (!nullToAbsent || dernierSyncReussiAt != null) {
      map['dernier_sync_reussi_at'] = Variable<String>(dernierSyncReussiAt);
    }
    if (!nullToAbsent || derniereErreur != null) {
      map['derniere_erreur'] = Variable<String>(derniereErreur);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      appareilId: Value(appareilId),
      dernierCurseur: Value(dernierCurseur),
      dernierSyncReussiAt: dernierSyncReussiAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dernierSyncReussiAt),
      derniereErreur: derniereErreur == null && nullToAbsent
          ? const Value.absent()
          : Value(derniereErreur),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      appareilId: serializer.fromJson<String>(json['appareilId']),
      dernierCurseur: serializer.fromJson<String>(json['dernierCurseur']),
      dernierSyncReussiAt:
          serializer.fromJson<String?>(json['dernierSyncReussiAt']),
      derniereErreur: serializer.fromJson<String?>(json['derniereErreur']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'appareilId': serializer.toJson<String>(appareilId),
      'dernierCurseur': serializer.toJson<String>(dernierCurseur),
      'dernierSyncReussiAt': serializer.toJson<String?>(dernierSyncReussiAt),
      'derniereErreur': serializer.toJson<String?>(derniereErreur),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SyncStateData copyWith(
          {String? appareilId,
          String? dernierCurseur,
          Value<String?> dernierSyncReussiAt = const Value.absent(),
          Value<String?> derniereErreur = const Value.absent(),
          String? updatedAt}) =>
      SyncStateData(
        appareilId: appareilId ?? this.appareilId,
        dernierCurseur: dernierCurseur ?? this.dernierCurseur,
        dernierSyncReussiAt: dernierSyncReussiAt.present
            ? dernierSyncReussiAt.value
            : this.dernierSyncReussiAt,
        derniereErreur:
            derniereErreur.present ? derniereErreur.value : this.derniereErreur,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      appareilId:
          data.appareilId.present ? data.appareilId.value : this.appareilId,
      dernierCurseur: data.dernierCurseur.present
          ? data.dernierCurseur.value
          : this.dernierCurseur,
      dernierSyncReussiAt: data.dernierSyncReussiAt.present
          ? data.dernierSyncReussiAt.value
          : this.dernierSyncReussiAt,
      derniereErreur: data.derniereErreur.present
          ? data.derniereErreur.value
          : this.derniereErreur,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('appareilId: $appareilId, ')
          ..write('dernierCurseur: $dernierCurseur, ')
          ..write('dernierSyncReussiAt: $dernierSyncReussiAt, ')
          ..write('derniereErreur: $derniereErreur, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(appareilId, dernierCurseur,
      dernierSyncReussiAt, derniereErreur, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.appareilId == this.appareilId &&
          other.dernierCurseur == this.dernierCurseur &&
          other.dernierSyncReussiAt == this.dernierSyncReussiAt &&
          other.derniereErreur == this.derniereErreur &&
          other.updatedAt == this.updatedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> appareilId;
  final Value<String> dernierCurseur;
  final Value<String?> dernierSyncReussiAt;
  final Value<String?> derniereErreur;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.appareilId = const Value.absent(),
    this.dernierCurseur = const Value.absent(),
    this.dernierSyncReussiAt = const Value.absent(),
    this.derniereErreur = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String appareilId,
    this.dernierCurseur = const Value.absent(),
    this.dernierSyncReussiAt = const Value.absent(),
    this.derniereErreur = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : appareilId = Value(appareilId),
        updatedAt = Value(updatedAt);
  static Insertable<SyncStateData> custom({
    Expression<String>? appareilId,
    Expression<String>? dernierCurseur,
    Expression<String>? dernierSyncReussiAt,
    Expression<String>? derniereErreur,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (appareilId != null) 'appareil_id': appareilId,
      if (dernierCurseur != null) 'dernier_curseur': dernierCurseur,
      if (dernierSyncReussiAt != null)
        'dernier_sync_reussi_at': dernierSyncReussiAt,
      if (derniereErreur != null) 'derniere_erreur': derniereErreur,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith(
      {Value<String>? appareilId,
      Value<String>? dernierCurseur,
      Value<String?>? dernierSyncReussiAt,
      Value<String?>? derniereErreur,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return SyncStateCompanion(
      appareilId: appareilId ?? this.appareilId,
      dernierCurseur: dernierCurseur ?? this.dernierCurseur,
      dernierSyncReussiAt: dernierSyncReussiAt ?? this.dernierSyncReussiAt,
      derniereErreur: derniereErreur ?? this.derniereErreur,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (dernierCurseur.present) {
      map['dernier_curseur'] = Variable<String>(dernierCurseur.value);
    }
    if (dernierSyncReussiAt.present) {
      map['dernier_sync_reussi_at'] =
          Variable<String>(dernierSyncReussiAt.value);
    }
    if (derniereErreur.present) {
      map['derniere_erreur'] = Variable<String>(derniereErreur.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('appareilId: $appareilId, ')
          ..write('dernierCurseur: $dernierCurseur, ')
          ..write('dernierSyncReussiAt: $dernierSyncReussiAt, ')
          ..write('derniereErreur: $derniereErreur, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appareilIdMeta =
      const VerificationMeta('appareilId');
  @override
  late final GeneratedColumn<String> appareilId = GeneratedColumn<String>(
      'appareil_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entiteTypeMeta =
      const VerificationMeta('entiteType');
  @override
  late final GeneratedColumn<String> entiteType = GeneratedColumn<String>(
      'entite_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entiteIdMeta =
      const VerificationMeta('entiteId');
  @override
  late final GeneratedColumn<String> entiteId = GeneratedColumn<String>(
      'entite_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionLocaleMeta =
      const VerificationMeta('versionLocale');
  @override
  late final GeneratedColumn<int> versionLocale = GeneratedColumn<int>(
      'version_locale', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _versionServeurMeta =
      const VerificationMeta('versionServeur');
  @override
  late final GeneratedColumn<int> versionServeur = GeneratedColumn<int>(
      'version_serveur', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localJsonMeta =
      const VerificationMeta('localJson');
  @override
  late final GeneratedColumn<String> localJson = GeneratedColumn<String>(
      'local_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serveurJsonMeta =
      const VerificationMeta('serveurJson');
  @override
  late final GeneratedColumn<String> serveurJson = GeneratedColumn<String>(
      'serveur_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('a_resoudre'));
  static const VerificationMeta _resolutionJsonMeta =
      const VerificationMeta('resolutionJson');
  @override
  late final GeneratedColumn<String> resolutionJson = GeneratedColumn<String>(
      'resolution_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        appareilId,
        entiteType,
        entiteId,
        versionLocale,
        versionServeur,
        localJson,
        serveurJson,
        statut,
        resolutionJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(Insertable<SyncConflict> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('appareil_id')) {
      context.handle(
          _appareilIdMeta,
          appareilId.isAcceptableOrUnknown(
              data['appareil_id']!, _appareilIdMeta));
    } else if (isInserting) {
      context.missing(_appareilIdMeta);
    }
    if (data.containsKey('entite_type')) {
      context.handle(
          _entiteTypeMeta,
          entiteType.isAcceptableOrUnknown(
              data['entite_type']!, _entiteTypeMeta));
    } else if (isInserting) {
      context.missing(_entiteTypeMeta);
    }
    if (data.containsKey('entite_id')) {
      context.handle(_entiteIdMeta,
          entiteId.isAcceptableOrUnknown(data['entite_id']!, _entiteIdMeta));
    } else if (isInserting) {
      context.missing(_entiteIdMeta);
    }
    if (data.containsKey('version_locale')) {
      context.handle(
          _versionLocaleMeta,
          versionLocale.isAcceptableOrUnknown(
              data['version_locale']!, _versionLocaleMeta));
    } else if (isInserting) {
      context.missing(_versionLocaleMeta);
    }
    if (data.containsKey('version_serveur')) {
      context.handle(
          _versionServeurMeta,
          versionServeur.isAcceptableOrUnknown(
              data['version_serveur']!, _versionServeurMeta));
    } else if (isInserting) {
      context.missing(_versionServeurMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(_localJsonMeta,
          localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta));
    } else if (isInserting) {
      context.missing(_localJsonMeta);
    }
    if (data.containsKey('serveur_json')) {
      context.handle(
          _serveurJsonMeta,
          serveurJson.isAcceptableOrUnknown(
              data['serveur_json']!, _serveurJsonMeta));
    } else if (isInserting) {
      context.missing(_serveurJsonMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('resolution_json')) {
      context.handle(
          _resolutionJsonMeta,
          resolutionJson.isAcceptableOrUnknown(
              data['resolution_json']!, _resolutionJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      appareilId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}appareil_id'])!,
      entiteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entite_type'])!,
      entiteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entite_id'])!,
      versionLocale: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version_locale'])!,
      versionServeur: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version_serveur'])!,
      localJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_json'])!,
      serveurJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serveur_json'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      resolutionJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resolution_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String appareilId;
  final String entiteType;
  final String entiteId;
  final int versionLocale;
  final int versionServeur;
  final String localJson;
  final String serveurJson;
  final String statut;
  final String? resolutionJson;
  final String createdAt;
  final String updatedAt;
  const SyncConflict(
      {required this.id,
      required this.appareilId,
      required this.entiteType,
      required this.entiteId,
      required this.versionLocale,
      required this.versionServeur,
      required this.localJson,
      required this.serveurJson,
      required this.statut,
      this.resolutionJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['appareil_id'] = Variable<String>(appareilId);
    map['entite_type'] = Variable<String>(entiteType);
    map['entite_id'] = Variable<String>(entiteId);
    map['version_locale'] = Variable<int>(versionLocale);
    map['version_serveur'] = Variable<int>(versionServeur);
    map['local_json'] = Variable<String>(localJson);
    map['serveur_json'] = Variable<String>(serveurJson);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || resolutionJson != null) {
      map['resolution_json'] = Variable<String>(resolutionJson);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      appareilId: Value(appareilId),
      entiteType: Value(entiteType),
      entiteId: Value(entiteId),
      versionLocale: Value(versionLocale),
      versionServeur: Value(versionServeur),
      localJson: Value(localJson),
      serveurJson: Value(serveurJson),
      statut: Value(statut),
      resolutionJson: resolutionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncConflict.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      appareilId: serializer.fromJson<String>(json['appareilId']),
      entiteType: serializer.fromJson<String>(json['entiteType']),
      entiteId: serializer.fromJson<String>(json['entiteId']),
      versionLocale: serializer.fromJson<int>(json['versionLocale']),
      versionServeur: serializer.fromJson<int>(json['versionServeur']),
      localJson: serializer.fromJson<String>(json['localJson']),
      serveurJson: serializer.fromJson<String>(json['serveurJson']),
      statut: serializer.fromJson<String>(json['statut']),
      resolutionJson: serializer.fromJson<String?>(json['resolutionJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'appareilId': serializer.toJson<String>(appareilId),
      'entiteType': serializer.toJson<String>(entiteType),
      'entiteId': serializer.toJson<String>(entiteId),
      'versionLocale': serializer.toJson<int>(versionLocale),
      'versionServeur': serializer.toJson<int>(versionServeur),
      'localJson': serializer.toJson<String>(localJson),
      'serveurJson': serializer.toJson<String>(serveurJson),
      'statut': serializer.toJson<String>(statut),
      'resolutionJson': serializer.toJson<String?>(resolutionJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SyncConflict copyWith(
          {String? id,
          String? appareilId,
          String? entiteType,
          String? entiteId,
          int? versionLocale,
          int? versionServeur,
          String? localJson,
          String? serveurJson,
          String? statut,
          Value<String?> resolutionJson = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      SyncConflict(
        id: id ?? this.id,
        appareilId: appareilId ?? this.appareilId,
        entiteType: entiteType ?? this.entiteType,
        entiteId: entiteId ?? this.entiteId,
        versionLocale: versionLocale ?? this.versionLocale,
        versionServeur: versionServeur ?? this.versionServeur,
        localJson: localJson ?? this.localJson,
        serveurJson: serveurJson ?? this.serveurJson,
        statut: statut ?? this.statut,
        resolutionJson:
            resolutionJson.present ? resolutionJson.value : this.resolutionJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      appareilId:
          data.appareilId.present ? data.appareilId.value : this.appareilId,
      entiteType:
          data.entiteType.present ? data.entiteType.value : this.entiteType,
      entiteId: data.entiteId.present ? data.entiteId.value : this.entiteId,
      versionLocale: data.versionLocale.present
          ? data.versionLocale.value
          : this.versionLocale,
      versionServeur: data.versionServeur.present
          ? data.versionServeur.value
          : this.versionServeur,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      serveurJson:
          data.serveurJson.present ? data.serveurJson.value : this.serveurJson,
      statut: data.statut.present ? data.statut.value : this.statut,
      resolutionJson: data.resolutionJson.present
          ? data.resolutionJson.value
          : this.resolutionJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('appareilId: $appareilId, ')
          ..write('entiteType: $entiteType, ')
          ..write('entiteId: $entiteId, ')
          ..write('versionLocale: $versionLocale, ')
          ..write('versionServeur: $versionServeur, ')
          ..write('localJson: $localJson, ')
          ..write('serveurJson: $serveurJson, ')
          ..write('statut: $statut, ')
          ..write('resolutionJson: $resolutionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      appareilId,
      entiteType,
      entiteId,
      versionLocale,
      versionServeur,
      localJson,
      serveurJson,
      statut,
      resolutionJson,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.appareilId == this.appareilId &&
          other.entiteType == this.entiteType &&
          other.entiteId == this.entiteId &&
          other.versionLocale == this.versionLocale &&
          other.versionServeur == this.versionServeur &&
          other.localJson == this.localJson &&
          other.serveurJson == this.serveurJson &&
          other.statut == this.statut &&
          other.resolutionJson == this.resolutionJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> appareilId;
  final Value<String> entiteType;
  final Value<String> entiteId;
  final Value<int> versionLocale;
  final Value<int> versionServeur;
  final Value<String> localJson;
  final Value<String> serveurJson;
  final Value<String> statut;
  final Value<String?> resolutionJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.appareilId = const Value.absent(),
    this.entiteType = const Value.absent(),
    this.entiteId = const Value.absent(),
    this.versionLocale = const Value.absent(),
    this.versionServeur = const Value.absent(),
    this.localJson = const Value.absent(),
    this.serveurJson = const Value.absent(),
    this.statut = const Value.absent(),
    this.resolutionJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String appareilId,
    required String entiteType,
    required String entiteId,
    required int versionLocale,
    required int versionServeur,
    required String localJson,
    required String serveurJson,
    this.statut = const Value.absent(),
    this.resolutionJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        appareilId = Value(appareilId),
        entiteType = Value(entiteType),
        entiteId = Value(entiteId),
        versionLocale = Value(versionLocale),
        versionServeur = Value(versionServeur),
        localJson = Value(localJson),
        serveurJson = Value(serveurJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? appareilId,
    Expression<String>? entiteType,
    Expression<String>? entiteId,
    Expression<int>? versionLocale,
    Expression<int>? versionServeur,
    Expression<String>? localJson,
    Expression<String>? serveurJson,
    Expression<String>? statut,
    Expression<String>? resolutionJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appareilId != null) 'appareil_id': appareilId,
      if (entiteType != null) 'entite_type': entiteType,
      if (entiteId != null) 'entite_id': entiteId,
      if (versionLocale != null) 'version_locale': versionLocale,
      if (versionServeur != null) 'version_serveur': versionServeur,
      if (localJson != null) 'local_json': localJson,
      if (serveurJson != null) 'serveur_json': serveurJson,
      if (statut != null) 'statut': statut,
      if (resolutionJson != null) 'resolution_json': resolutionJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith(
      {Value<String>? id,
      Value<String>? appareilId,
      Value<String>? entiteType,
      Value<String>? entiteId,
      Value<int>? versionLocale,
      Value<int>? versionServeur,
      Value<String>? localJson,
      Value<String>? serveurJson,
      Value<String>? statut,
      Value<String?>? resolutionJson,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      appareilId: appareilId ?? this.appareilId,
      entiteType: entiteType ?? this.entiteType,
      entiteId: entiteId ?? this.entiteId,
      versionLocale: versionLocale ?? this.versionLocale,
      versionServeur: versionServeur ?? this.versionServeur,
      localJson: localJson ?? this.localJson,
      serveurJson: serveurJson ?? this.serveurJson,
      statut: statut ?? this.statut,
      resolutionJson: resolutionJson ?? this.resolutionJson,
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
    if (appareilId.present) {
      map['appareil_id'] = Variable<String>(appareilId.value);
    }
    if (entiteType.present) {
      map['entite_type'] = Variable<String>(entiteType.value);
    }
    if (entiteId.present) {
      map['entite_id'] = Variable<String>(entiteId.value);
    }
    if (versionLocale.present) {
      map['version_locale'] = Variable<int>(versionLocale.value);
    }
    if (versionServeur.present) {
      map['version_serveur'] = Variable<int>(versionServeur.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (serveurJson.present) {
      map['serveur_json'] = Variable<String>(serveurJson.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (resolutionJson.present) {
      map['resolution_json'] = Variable<String>(resolutionJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('appareilId: $appareilId, ')
          ..write('entiteType: $entiteType, ')
          ..write('entiteId: $entiteId, ')
          ..write('versionLocale: $versionLocale, ')
          ..write('versionServeur: $versionServeur, ')
          ..write('localJson: $localJson, ')
          ..write('serveurJson: $serveurJson, ')
          ..write('statut: $statut, ')
          ..write('resolutionJson: $resolutionJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MsnDatabase extends GeneratedDatabase {
  _$MsnDatabase(QueryExecutor e) : super(e);
  $MsnDatabaseManager get managers => $MsnDatabaseManager(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final $TarifsTable tarifs = $TarifsTable(this);
  late final $DemandesTable demandes = $DemandesTable(this);
  late final $DemandePrestationsTable demandePrestations =
      $DemandePrestationsTable(this);
  late final $CommandesTable commandes = $CommandesTable(this);
  late final $LignesCommandeTable lignesCommande = $LignesCommandeTable(this);
  late final $ProjetsTable projets = $ProjetsTable(this);
  late final $CahiersChargesTable cahiersCharges = $CahiersChargesTable(this);
  late final $TachesTable taches = $TachesTable(this);
  late final $ModelesMessagesTable modelesMessages =
      $ModelesMessagesTable(this);
  late final $EchangesTable echanges = $EchangesTable(this);
  late final $DevisTableTable devisTable = $DevisTableTable(this);
  late final $LignesDevisTableTable lignesDevisTable =
      $LignesDevisTableTable(this);
  late final $FacturesTable factures = $FacturesTable(this);
  late final $LignesFactureTable lignesFacture = $LignesFactureTable(this);
  late final $PaiementsTable paiements = $PaiementsTable(this);
  late final $DepensesTable depenses = $DepensesTable(this);
  late final $PiecesJointesTable piecesJointes = $PiecesJointesTable(this);
  late final $JournalActionsTable journalActions = $JournalActionsTable(this);
  late final $AppareilsTable appareils = $AppareilsTable(this);
  late final $PublicationsFacebookTable publicationsFacebook =
      $PublicationsFacebookTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        appMeta,
        clients,
        contacts,
        services,
        tarifs,
        demandes,
        demandePrestations,
        commandes,
        lignesCommande,
        projets,
        cahiersCharges,
        taches,
        modelesMessages,
        echanges,
        devisTable,
        lignesDevisTable,
        factures,
        lignesFacture,
        paiements,
        depenses,
        piecesJointes,
        journalActions,
        appareils,
        publicationsFacebook,
        syncOutbox,
        syncState,
        syncConflicts
      ];
}

typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$MsnDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$MsnDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$MsnDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $AppMetaTable,
    AppMetaData,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaData, BaseReferences<_$MsnDatabase, $AppMetaTable, AppMetaData>),
    AppMetaData,
    PrefetchHooks Function()> {
  $$AppMetaTableTableManager(_$MsnDatabase db, $AppMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $AppMetaTable,
    AppMetaData,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaData, BaseReferences<_$MsnDatabase, $AppMetaTable, AppMetaData>),
    AppMetaData,
    PrefetchHooks Function()>;
typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  required String id,
  required String typeClient,
  required String nomAffiche,
  Value<String?> nomLegal,
  Value<String?> telephonePrincipal,
  Value<String?> emailPrincipal,
  Value<String?> adresse,
  Value<String?> notes,
  Value<bool> actif,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<String> id,
  Value<String> typeClient,
  Value<String> nomAffiche,
  Value<String?> nomLegal,
  Value<String?> telephonePrincipal,
  Value<String?> emailPrincipal,
  Value<String?> adresse,
  Value<String?> notes,
  Value<bool> actif,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$ClientsTableFilterComposer
    extends Composer<_$MsnDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeClient => $composableBuilder(
      column: $table.typeClient, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nomAffiche => $composableBuilder(
      column: $table.nomAffiche, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nomLegal => $composableBuilder(
      column: $table.nomLegal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telephonePrincipal => $composableBuilder(
      column: $table.telephonePrincipal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailPrincipal => $composableBuilder(
      column: $table.emailPrincipal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adresse => $composableBuilder(
      column: $table.adresse, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ClientsTableOrderingComposer
    extends Composer<_$MsnDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeClient => $composableBuilder(
      column: $table.typeClient, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nomAffiche => $composableBuilder(
      column: $table.nomAffiche, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nomLegal => $composableBuilder(
      column: $table.nomLegal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telephonePrincipal => $composableBuilder(
      column: $table.telephonePrincipal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailPrincipal => $composableBuilder(
      column: $table.emailPrincipal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adresse => $composableBuilder(
      column: $table.adresse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeClient => $composableBuilder(
      column: $table.typeClient, builder: (column) => column);

  GeneratedColumn<String> get nomAffiche => $composableBuilder(
      column: $table.nomAffiche, builder: (column) => column);

  GeneratedColumn<String> get nomLegal =>
      $composableBuilder(column: $table.nomLegal, builder: (column) => column);

  GeneratedColumn<String> get telephonePrincipal => $composableBuilder(
      column: $table.telephonePrincipal, builder: (column) => column);

  GeneratedColumn<String> get emailPrincipal => $composableBuilder(
      column: $table.emailPrincipal, builder: (column) => column);

  GeneratedColumn<String> get adresse =>
      $composableBuilder(column: $table.adresse, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ClientsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, BaseReferences<_$MsnDatabase, $ClientsTable, Client>),
    Client,
    PrefetchHooks Function()> {
  $$ClientsTableTableManager(_$MsnDatabase db, $ClientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> typeClient = const Value.absent(),
            Value<String> nomAffiche = const Value.absent(),
            Value<String?> nomLegal = const Value.absent(),
            Value<String?> telephonePrincipal = const Value.absent(),
            Value<String?> emailPrincipal = const Value.absent(),
            Value<String?> adresse = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsCompanion(
            id: id,
            typeClient: typeClient,
            nomAffiche: nomAffiche,
            nomLegal: nomLegal,
            telephonePrincipal: telephonePrincipal,
            emailPrincipal: emailPrincipal,
            adresse: adresse,
            notes: notes,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String typeClient,
            required String nomAffiche,
            Value<String?> nomLegal = const Value.absent(),
            Value<String?> telephonePrincipal = const Value.absent(),
            Value<String?> emailPrincipal = const Value.absent(),
            Value<String?> adresse = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsCompanion.insert(
            id: id,
            typeClient: typeClient,
            nomAffiche: nomAffiche,
            nomLegal: nomLegal,
            telephonePrincipal: telephonePrincipal,
            emailPrincipal: emailPrincipal,
            adresse: adresse,
            notes: notes,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClientsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, BaseReferences<_$MsnDatabase, $ClientsTable, Client>),
    Client,
    PrefetchHooks Function()>;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String id,
  required String clientId,
  required String nom,
  Value<String?> role,
  Value<String?> telephone,
  Value<String?> email,
  Value<String?> canalPrefere,
  Value<bool> principal,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> id,
  Value<String> clientId,
  Value<String> nom,
  Value<String?> role,
  Value<String?> telephone,
  Value<String?> email,
  Value<String?> canalPrefere,
  Value<bool> principal,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$ContactsTableFilterComposer
    extends Composer<_$MsnDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canalPrefere => $composableBuilder(
      column: $table.canalPrefere, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get principal => $composableBuilder(
      column: $table.principal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ContactsTableOrderingComposer
    extends Composer<_$MsnDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canalPrefere => $composableBuilder(
      column: $table.canalPrefere,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get principal => $composableBuilder(
      column: $table.principal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get canalPrefere => $composableBuilder(
      column: $table.canalPrefere, builder: (column) => column);

  GeneratedColumn<bool> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ContactsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, BaseReferences<_$MsnDatabase, $ContactsTable, Contact>),
    Contact,
    PrefetchHooks Function()> {
  $$ContactsTableTableManager(_$MsnDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String?> telephone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> canalPrefere = const Value.absent(),
            Value<bool> principal = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion(
            id: id,
            clientId: clientId,
            nom: nom,
            role: role,
            telephone: telephone,
            email: email,
            canalPrefere: canalPrefere,
            principal: principal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientId,
            required String nom,
            Value<String?> role = const Value.absent(),
            Value<String?> telephone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> canalPrefere = const Value.absent(),
            Value<bool> principal = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            id: id,
            clientId: clientId,
            nom: nom,
            role: role,
            telephone: telephone,
            email: email,
            canalPrefere: canalPrefere,
            principal: principal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContactsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, BaseReferences<_$MsnDatabase, $ContactsTable, Contact>),
    Contact,
    PrefetchHooks Function()>;
typedef $$ServicesTableCreateCompanionBuilder = ServicesCompanion Function({
  required String id,
  required String code,
  required String nom,
  Value<String?> description,
  required String categorie,
  required String uniteTarifaire,
  Value<bool> actif,
  Value<bool> necessiteCahierCharges,
  Value<String> questionsQualificationJson,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$ServicesTableUpdateCompanionBuilder = ServicesCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> nom,
  Value<String?> description,
  Value<String> categorie,
  Value<String> uniteTarifaire,
  Value<bool> actif,
  Value<bool> necessiteCahierCharges,
  Value<String> questionsQualificationJson,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$ServicesTableFilterComposer
    extends Composer<_$MsnDatabase, $ServicesTable> {
  $$ServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uniteTarifaire => $composableBuilder(
      column: $table.uniteTarifaire,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get necessiteCahierCharges => $composableBuilder(
      column: $table.necessiteCahierCharges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionsQualificationJson => $composableBuilder(
      column: $table.questionsQualificationJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ServicesTableOrderingComposer
    extends Composer<_$MsnDatabase, $ServicesTable> {
  $$ServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uniteTarifaire => $composableBuilder(
      column: $table.uniteTarifaire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get necessiteCahierCharges => $composableBuilder(
      column: $table.necessiteCahierCharges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionsQualificationJson => $composableBuilder(
      column: $table.questionsQualificationJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get uniteTarifaire => $composableBuilder(
      column: $table.uniteTarifaire, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<bool> get necessiteCahierCharges => $composableBuilder(
      column: $table.necessiteCahierCharges, builder: (column) => column);

  GeneratedColumn<String> get questionsQualificationJson => $composableBuilder(
      column: $table.questionsQualificationJson, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ServicesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, BaseReferences<_$MsnDatabase, $ServicesTable, Service>),
    Service,
    PrefetchHooks Function()> {
  $$ServicesTableTableManager(_$MsnDatabase db, $ServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> categorie = const Value.absent(),
            Value<String> uniteTarifaire = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            Value<bool> necessiteCahierCharges = const Value.absent(),
            Value<String> questionsQualificationJson = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServicesCompanion(
            id: id,
            code: code,
            nom: nom,
            description: description,
            categorie: categorie,
            uniteTarifaire: uniteTarifaire,
            actif: actif,
            necessiteCahierCharges: necessiteCahierCharges,
            questionsQualificationJson: questionsQualificationJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String nom,
            Value<String?> description = const Value.absent(),
            required String categorie,
            required String uniteTarifaire,
            Value<bool> actif = const Value.absent(),
            Value<bool> necessiteCahierCharges = const Value.absent(),
            Value<String> questionsQualificationJson = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServicesCompanion.insert(
            id: id,
            code: code,
            nom: nom,
            description: description,
            categorie: categorie,
            uniteTarifaire: uniteTarifaire,
            actif: actif,
            necessiteCahierCharges: necessiteCahierCharges,
            questionsQualificationJson: questionsQualificationJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServicesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, BaseReferences<_$MsnDatabase, $ServicesTable, Service>),
    Service,
    PrefetchHooks Function()>;
typedef $$TarifsTableCreateCompanionBuilder = TarifsCompanion Function({
  required String id,
  required String serviceId,
  required int prixUnitaire,
  Value<String> devise,
  required String dateDebutValidite,
  Value<String?> dateFinValidite,
  Value<bool> actif,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$TarifsTableUpdateCompanionBuilder = TarifsCompanion Function({
  Value<String> id,
  Value<String> serviceId,
  Value<int> prixUnitaire,
  Value<String> devise,
  Value<String> dateDebutValidite,
  Value<String?> dateFinValidite,
  Value<bool> actif,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$TarifsTableFilterComposer
    extends Composer<_$MsnDatabase, $TarifsTable> {
  $$TarifsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateDebutValidite => $composableBuilder(
      column: $table.dateDebutValidite,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateFinValidite => $composableBuilder(
      column: $table.dateFinValidite,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TarifsTableOrderingComposer
    extends Composer<_$MsnDatabase, $TarifsTable> {
  $$TarifsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateDebutValidite => $composableBuilder(
      column: $table.dateDebutValidite,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateFinValidite => $composableBuilder(
      column: $table.dateFinValidite,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TarifsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $TarifsTable> {
  $$TarifsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get dateDebutValidite => $composableBuilder(
      column: $table.dateDebutValidite, builder: (column) => column);

  GeneratedColumn<String> get dateFinValidite => $composableBuilder(
      column: $table.dateFinValidite, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TarifsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $TarifsTable,
    Tarif,
    $$TarifsTableFilterComposer,
    $$TarifsTableOrderingComposer,
    $$TarifsTableAnnotationComposer,
    $$TarifsTableCreateCompanionBuilder,
    $$TarifsTableUpdateCompanionBuilder,
    (Tarif, BaseReferences<_$MsnDatabase, $TarifsTable, Tarif>),
    Tarif,
    PrefetchHooks Function()> {
  $$TarifsTableTableManager(_$MsnDatabase db, $TarifsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarifsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarifsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TarifsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> serviceId = const Value.absent(),
            Value<int> prixUnitaire = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String> dateDebutValidite = const Value.absent(),
            Value<String?> dateFinValidite = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TarifsCompanion(
            id: id,
            serviceId: serviceId,
            prixUnitaire: prixUnitaire,
            devise: devise,
            dateDebutValidite: dateDebutValidite,
            dateFinValidite: dateFinValidite,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String serviceId,
            required int prixUnitaire,
            Value<String> devise = const Value.absent(),
            required String dateDebutValidite,
            Value<String?> dateFinValidite = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TarifsCompanion.insert(
            id: id,
            serviceId: serviceId,
            prixUnitaire: prixUnitaire,
            devise: devise,
            dateDebutValidite: dateDebutValidite,
            dateFinValidite: dateFinValidite,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TarifsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $TarifsTable,
    Tarif,
    $$TarifsTableFilterComposer,
    $$TarifsTableOrderingComposer,
    $$TarifsTableAnnotationComposer,
    $$TarifsTableCreateCompanionBuilder,
    $$TarifsTableUpdateCompanionBuilder,
    (Tarif, BaseReferences<_$MsnDatabase, $TarifsTable, Tarif>),
    Tarif,
    PrefetchHooks Function()>;
typedef $$DemandesTableCreateCompanionBuilder = DemandesCompanion Function({
  required String id,
  required String clientId,
  Value<String?> contactId,
  required String canalOrigine,
  required String messageInitial,
  Value<String?> besoinResume,
  Value<String> statut,
  Value<String?> dateLimiteSouhaitee,
  Value<int?> budgetIndicatif,
  Value<String> deviseBudget,
  Value<String?> motifPerte,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$DemandesTableUpdateCompanionBuilder = DemandesCompanion Function({
  Value<String> id,
  Value<String> clientId,
  Value<String?> contactId,
  Value<String> canalOrigine,
  Value<String> messageInitial,
  Value<String?> besoinResume,
  Value<String> statut,
  Value<String?> dateLimiteSouhaitee,
  Value<int?> budgetIndicatif,
  Value<String> deviseBudget,
  Value<String?> motifPerte,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$DemandesTableFilterComposer
    extends Composer<_$MsnDatabase, $DemandesTable> {
  $$DemandesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactId => $composableBuilder(
      column: $table.contactId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canalOrigine => $composableBuilder(
      column: $table.canalOrigine, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageInitial => $composableBuilder(
      column: $table.messageInitial,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get besoinResume => $composableBuilder(
      column: $table.besoinResume, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateLimiteSouhaitee => $composableBuilder(
      column: $table.dateLimiteSouhaitee,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get budgetIndicatif => $composableBuilder(
      column: $table.budgetIndicatif,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviseBudget => $composableBuilder(
      column: $table.deviseBudget, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motifPerte => $composableBuilder(
      column: $table.motifPerte, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DemandesTableOrderingComposer
    extends Composer<_$MsnDatabase, $DemandesTable> {
  $$DemandesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactId => $composableBuilder(
      column: $table.contactId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canalOrigine => $composableBuilder(
      column: $table.canalOrigine,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageInitial => $composableBuilder(
      column: $table.messageInitial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get besoinResume => $composableBuilder(
      column: $table.besoinResume,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateLimiteSouhaitee => $composableBuilder(
      column: $table.dateLimiteSouhaitee,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get budgetIndicatif => $composableBuilder(
      column: $table.budgetIndicatif,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviseBudget => $composableBuilder(
      column: $table.deviseBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motifPerte => $composableBuilder(
      column: $table.motifPerte, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DemandesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $DemandesTable> {
  $$DemandesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get canalOrigine => $composableBuilder(
      column: $table.canalOrigine, builder: (column) => column);

  GeneratedColumn<String> get messageInitial => $composableBuilder(
      column: $table.messageInitial, builder: (column) => column);

  GeneratedColumn<String> get besoinResume => $composableBuilder(
      column: $table.besoinResume, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get dateLimiteSouhaitee => $composableBuilder(
      column: $table.dateLimiteSouhaitee, builder: (column) => column);

  GeneratedColumn<int> get budgetIndicatif => $composableBuilder(
      column: $table.budgetIndicatif, builder: (column) => column);

  GeneratedColumn<String> get deviseBudget => $composableBuilder(
      column: $table.deviseBudget, builder: (column) => column);

  GeneratedColumn<String> get motifPerte => $composableBuilder(
      column: $table.motifPerte, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DemandesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $DemandesTable,
    Demande,
    $$DemandesTableFilterComposer,
    $$DemandesTableOrderingComposer,
    $$DemandesTableAnnotationComposer,
    $$DemandesTableCreateCompanionBuilder,
    $$DemandesTableUpdateCompanionBuilder,
    (Demande, BaseReferences<_$MsnDatabase, $DemandesTable, Demande>),
    Demande,
    PrefetchHooks Function()> {
  $$DemandesTableTableManager(_$MsnDatabase db, $DemandesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DemandesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DemandesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DemandesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<String?> contactId = const Value.absent(),
            Value<String> canalOrigine = const Value.absent(),
            Value<String> messageInitial = const Value.absent(),
            Value<String?> besoinResume = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateLimiteSouhaitee = const Value.absent(),
            Value<int?> budgetIndicatif = const Value.absent(),
            Value<String> deviseBudget = const Value.absent(),
            Value<String?> motifPerte = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DemandesCompanion(
            id: id,
            clientId: clientId,
            contactId: contactId,
            canalOrigine: canalOrigine,
            messageInitial: messageInitial,
            besoinResume: besoinResume,
            statut: statut,
            dateLimiteSouhaitee: dateLimiteSouhaitee,
            budgetIndicatif: budgetIndicatif,
            deviseBudget: deviseBudget,
            motifPerte: motifPerte,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientId,
            Value<String?> contactId = const Value.absent(),
            required String canalOrigine,
            required String messageInitial,
            Value<String?> besoinResume = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateLimiteSouhaitee = const Value.absent(),
            Value<int?> budgetIndicatif = const Value.absent(),
            Value<String> deviseBudget = const Value.absent(),
            Value<String?> motifPerte = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DemandesCompanion.insert(
            id: id,
            clientId: clientId,
            contactId: contactId,
            canalOrigine: canalOrigine,
            messageInitial: messageInitial,
            besoinResume: besoinResume,
            statut: statut,
            dateLimiteSouhaitee: dateLimiteSouhaitee,
            budgetIndicatif: budgetIndicatif,
            deviseBudget: deviseBudget,
            motifPerte: motifPerte,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DemandesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $DemandesTable,
    Demande,
    $$DemandesTableFilterComposer,
    $$DemandesTableOrderingComposer,
    $$DemandesTableAnnotationComposer,
    $$DemandesTableCreateCompanionBuilder,
    $$DemandesTableUpdateCompanionBuilder,
    (Demande, BaseReferences<_$MsnDatabase, $DemandesTable, Demande>),
    Demande,
    PrefetchHooks Function()>;
typedef $$DemandePrestationsTableCreateCompanionBuilder
    = DemandePrestationsCompanion Function({
  required String id,
  required String demandeId,
  required String serviceId,
  Value<String> quantite,
  required String uniteSnapshot,
  Value<int?> prixIndicatifUnitaire,
  Value<String> devise,
  Value<String> detailsJson,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$DemandePrestationsTableUpdateCompanionBuilder
    = DemandePrestationsCompanion Function({
  Value<String> id,
  Value<String> demandeId,
  Value<String> serviceId,
  Value<String> quantite,
  Value<String> uniteSnapshot,
  Value<int?> prixIndicatifUnitaire,
  Value<String> devise,
  Value<String> detailsJson,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$DemandePrestationsTableFilterComposer
    extends Composer<_$MsnDatabase, $DemandePrestationsTable> {
  $$DemandePrestationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prixIndicatifUnitaire => $composableBuilder(
      column: $table.prixIndicatifUnitaire,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DemandePrestationsTableOrderingComposer
    extends Composer<_$MsnDatabase, $DemandePrestationsTable> {
  $$DemandePrestationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prixIndicatifUnitaire => $composableBuilder(
      column: $table.prixIndicatifUnitaire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DemandePrestationsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $DemandePrestationsTable> {
  $$DemandePrestationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get demandeId =>
      $composableBuilder(column: $table.demandeId, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<String> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => column);

  GeneratedColumn<int> get prixIndicatifUnitaire => $composableBuilder(
      column: $table.prixIndicatifUnitaire, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DemandePrestationsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $DemandePrestationsTable,
    DemandePrestation,
    $$DemandePrestationsTableFilterComposer,
    $$DemandePrestationsTableOrderingComposer,
    $$DemandePrestationsTableAnnotationComposer,
    $$DemandePrestationsTableCreateCompanionBuilder,
    $$DemandePrestationsTableUpdateCompanionBuilder,
    (
      DemandePrestation,
      BaseReferences<_$MsnDatabase, $DemandePrestationsTable, DemandePrestation>
    ),
    DemandePrestation,
    PrefetchHooks Function()> {
  $$DemandePrestationsTableTableManager(
      _$MsnDatabase db, $DemandePrestationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DemandePrestationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DemandePrestationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DemandePrestationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> demandeId = const Value.absent(),
            Value<String> serviceId = const Value.absent(),
            Value<String> quantite = const Value.absent(),
            Value<String> uniteSnapshot = const Value.absent(),
            Value<int?> prixIndicatifUnitaire = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String> detailsJson = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DemandePrestationsCompanion(
            id: id,
            demandeId: demandeId,
            serviceId: serviceId,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixIndicatifUnitaire: prixIndicatifUnitaire,
            devise: devise,
            detailsJson: detailsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String demandeId,
            required String serviceId,
            Value<String> quantite = const Value.absent(),
            required String uniteSnapshot,
            Value<int?> prixIndicatifUnitaire = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String> detailsJson = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DemandePrestationsCompanion.insert(
            id: id,
            demandeId: demandeId,
            serviceId: serviceId,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixIndicatifUnitaire: prixIndicatifUnitaire,
            devise: devise,
            detailsJson: detailsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DemandePrestationsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $DemandePrestationsTable,
    DemandePrestation,
    $$DemandePrestationsTableFilterComposer,
    $$DemandePrestationsTableOrderingComposer,
    $$DemandePrestationsTableAnnotationComposer,
    $$DemandePrestationsTableCreateCompanionBuilder,
    $$DemandePrestationsTableUpdateCompanionBuilder,
    (
      DemandePrestation,
      BaseReferences<_$MsnDatabase, $DemandePrestationsTable, DemandePrestation>
    ),
    DemandePrestation,
    PrefetchHooks Function()>;
typedef $$CommandesTableCreateCompanionBuilder = CommandesCompanion Function({
  required String id,
  required String numero,
  required String demandeId,
  Value<String> statut,
  Value<String?> dateConfirmation,
  Value<String?> dateDebutPrevue,
  Value<String?> dateLimiteConfirmee,
  Value<String?> instructions,
  Value<String?> motifAnnulation,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$CommandesTableUpdateCompanionBuilder = CommandesCompanion Function({
  Value<String> id,
  Value<String> numero,
  Value<String> demandeId,
  Value<String> statut,
  Value<String?> dateConfirmation,
  Value<String?> dateDebutPrevue,
  Value<String?> dateLimiteConfirmee,
  Value<String?> instructions,
  Value<String?> motifAnnulation,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$CommandesTableFilterComposer
    extends Composer<_$MsnDatabase, $CommandesTable> {
  $$CommandesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateConfirmation => $composableBuilder(
      column: $table.dateConfirmation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateDebutPrevue => $composableBuilder(
      column: $table.dateDebutPrevue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateLimiteConfirmee => $composableBuilder(
      column: $table.dateLimiteConfirmee,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motifAnnulation => $composableBuilder(
      column: $table.motifAnnulation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$CommandesTableOrderingComposer
    extends Composer<_$MsnDatabase, $CommandesTable> {
  $$CommandesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateConfirmation => $composableBuilder(
      column: $table.dateConfirmation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateDebutPrevue => $composableBuilder(
      column: $table.dateDebutPrevue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateLimiteConfirmee => $composableBuilder(
      column: $table.dateLimiteConfirmee,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructions => $composableBuilder(
      column: $table.instructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motifAnnulation => $composableBuilder(
      column: $table.motifAnnulation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$CommandesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $CommandesTable> {
  $$CommandesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get demandeId =>
      $composableBuilder(column: $table.demandeId, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get dateConfirmation => $composableBuilder(
      column: $table.dateConfirmation, builder: (column) => column);

  GeneratedColumn<String> get dateDebutPrevue => $composableBuilder(
      column: $table.dateDebutPrevue, builder: (column) => column);

  GeneratedColumn<String> get dateLimiteConfirmee => $composableBuilder(
      column: $table.dateLimiteConfirmee, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => column);

  GeneratedColumn<String> get motifAnnulation => $composableBuilder(
      column: $table.motifAnnulation, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CommandesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $CommandesTable,
    Commande,
    $$CommandesTableFilterComposer,
    $$CommandesTableOrderingComposer,
    $$CommandesTableAnnotationComposer,
    $$CommandesTableCreateCompanionBuilder,
    $$CommandesTableUpdateCompanionBuilder,
    (Commande, BaseReferences<_$MsnDatabase, $CommandesTable, Commande>),
    Commande,
    PrefetchHooks Function()> {
  $$CommandesTableTableManager(_$MsnDatabase db, $CommandesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommandesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommandesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> numero = const Value.absent(),
            Value<String> demandeId = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateConfirmation = const Value.absent(),
            Value<String?> dateDebutPrevue = const Value.absent(),
            Value<String?> dateLimiteConfirmee = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
            Value<String?> motifAnnulation = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommandesCompanion(
            id: id,
            numero: numero,
            demandeId: demandeId,
            statut: statut,
            dateConfirmation: dateConfirmation,
            dateDebutPrevue: dateDebutPrevue,
            dateLimiteConfirmee: dateLimiteConfirmee,
            instructions: instructions,
            motifAnnulation: motifAnnulation,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String numero,
            required String demandeId,
            Value<String> statut = const Value.absent(),
            Value<String?> dateConfirmation = const Value.absent(),
            Value<String?> dateDebutPrevue = const Value.absent(),
            Value<String?> dateLimiteConfirmee = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
            Value<String?> motifAnnulation = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommandesCompanion.insert(
            id: id,
            numero: numero,
            demandeId: demandeId,
            statut: statut,
            dateConfirmation: dateConfirmation,
            dateDebutPrevue: dateDebutPrevue,
            dateLimiteConfirmee: dateLimiteConfirmee,
            instructions: instructions,
            motifAnnulation: motifAnnulation,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CommandesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $CommandesTable,
    Commande,
    $$CommandesTableFilterComposer,
    $$CommandesTableOrderingComposer,
    $$CommandesTableAnnotationComposer,
    $$CommandesTableCreateCompanionBuilder,
    $$CommandesTableUpdateCompanionBuilder,
    (Commande, BaseReferences<_$MsnDatabase, $CommandesTable, Commande>),
    Commande,
    PrefetchHooks Function()>;
typedef $$LignesCommandeTableCreateCompanionBuilder = LignesCommandeCompanion
    Function({
  required String id,
  required String commandeId,
  Value<String?> serviceId,
  required String description,
  required String quantite,
  required String uniteSnapshot,
  required int prixUnitaire,
  Value<String> devise,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$LignesCommandeTableUpdateCompanionBuilder = LignesCommandeCompanion
    Function({
  Value<String> id,
  Value<String> commandeId,
  Value<String?> serviceId,
  Value<String> description,
  Value<String> quantite,
  Value<String> uniteSnapshot,
  Value<int> prixUnitaire,
  Value<String> devise,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$LignesCommandeTableFilterComposer
    extends Composer<_$MsnDatabase, $LignesCommandeTable> {
  $$LignesCommandeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LignesCommandeTableOrderingComposer
    extends Composer<_$MsnDatabase, $LignesCommandeTable> {
  $$LignesCommandeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LignesCommandeTableAnnotationComposer
    extends Composer<_$MsnDatabase, $LignesCommandeTable> {
  $$LignesCommandeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => column);

  GeneratedColumn<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LignesCommandeTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $LignesCommandeTable,
    LignesCommandeData,
    $$LignesCommandeTableFilterComposer,
    $$LignesCommandeTableOrderingComposer,
    $$LignesCommandeTableAnnotationComposer,
    $$LignesCommandeTableCreateCompanionBuilder,
    $$LignesCommandeTableUpdateCompanionBuilder,
    (
      LignesCommandeData,
      BaseReferences<_$MsnDatabase, $LignesCommandeTable, LignesCommandeData>
    ),
    LignesCommandeData,
    PrefetchHooks Function()> {
  $$LignesCommandeTableTableManager(
      _$MsnDatabase db, $LignesCommandeTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignesCommandeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignesCommandeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignesCommandeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> commandeId = const Value.absent(),
            Value<String?> serviceId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> quantite = const Value.absent(),
            Value<String> uniteSnapshot = const Value.absent(),
            Value<int> prixUnitaire = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LignesCommandeCompanion(
            id: id,
            commandeId: commandeId,
            serviceId: serviceId,
            description: description,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixUnitaire: prixUnitaire,
            devise: devise,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String commandeId,
            Value<String?> serviceId = const Value.absent(),
            required String description,
            required String quantite,
            required String uniteSnapshot,
            required int prixUnitaire,
            Value<String> devise = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LignesCommandeCompanion.insert(
            id: id,
            commandeId: commandeId,
            serviceId: serviceId,
            description: description,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixUnitaire: prixUnitaire,
            devise: devise,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LignesCommandeTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $LignesCommandeTable,
    LignesCommandeData,
    $$LignesCommandeTableFilterComposer,
    $$LignesCommandeTableOrderingComposer,
    $$LignesCommandeTableAnnotationComposer,
    $$LignesCommandeTableCreateCompanionBuilder,
    $$LignesCommandeTableUpdateCompanionBuilder,
    (
      LignesCommandeData,
      BaseReferences<_$MsnDatabase, $LignesCommandeTable, LignesCommandeData>
    ),
    LignesCommandeData,
    PrefetchHooks Function()>;
typedef $$ProjetsTableCreateCompanionBuilder = ProjetsCompanion Function({
  required String id,
  required String commandeId,
  required String nom,
  Value<String?> description,
  Value<String> statut,
  Value<String?> dateLimite,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$ProjetsTableUpdateCompanionBuilder = ProjetsCompanion Function({
  Value<String> id,
  Value<String> commandeId,
  Value<String> nom,
  Value<String?> description,
  Value<String> statut,
  Value<String?> dateLimite,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$ProjetsTableFilterComposer
    extends Composer<_$MsnDatabase, $ProjetsTable> {
  $$ProjetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateLimite => $composableBuilder(
      column: $table.dateLimite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ProjetsTableOrderingComposer
    extends Composer<_$MsnDatabase, $ProjetsTable> {
  $$ProjetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateLimite => $composableBuilder(
      column: $table.dateLimite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProjetsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $ProjetsTable> {
  $$ProjetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get dateLimite => $composableBuilder(
      column: $table.dateLimite, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ProjetsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $ProjetsTable,
    Projet,
    $$ProjetsTableFilterComposer,
    $$ProjetsTableOrderingComposer,
    $$ProjetsTableAnnotationComposer,
    $$ProjetsTableCreateCompanionBuilder,
    $$ProjetsTableUpdateCompanionBuilder,
    (Projet, BaseReferences<_$MsnDatabase, $ProjetsTable, Projet>),
    Projet,
    PrefetchHooks Function()> {
  $$ProjetsTableTableManager(_$MsnDatabase db, $ProjetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> commandeId = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateLimite = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjetsCompanion(
            id: id,
            commandeId: commandeId,
            nom: nom,
            description: description,
            statut: statut,
            dateLimite: dateLimite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String commandeId,
            required String nom,
            Value<String?> description = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateLimite = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjetsCompanion.insert(
            id: id,
            commandeId: commandeId,
            nom: nom,
            description: description,
            statut: statut,
            dateLimite: dateLimite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjetsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $ProjetsTable,
    Projet,
    $$ProjetsTableFilterComposer,
    $$ProjetsTableOrderingComposer,
    $$ProjetsTableAnnotationComposer,
    $$ProjetsTableCreateCompanionBuilder,
    $$ProjetsTableUpdateCompanionBuilder,
    (Projet, BaseReferences<_$MsnDatabase, $ProjetsTable, Projet>),
    Projet,
    PrefetchHooks Function()>;
typedef $$CahiersChargesTableCreateCompanionBuilder = CahiersChargesCompanion
    Function({
  required String id,
  required String projetId,
  Value<int> versionDocument,
  required String contenuJson,
  Value<String> statut,
  Value<String?> dateValidation,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$CahiersChargesTableUpdateCompanionBuilder = CahiersChargesCompanion
    Function({
  Value<String> id,
  Value<String> projetId,
  Value<int> versionDocument,
  Value<String> contenuJson,
  Value<String> statut,
  Value<String?> dateValidation,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$CahiersChargesTableFilterComposer
    extends Composer<_$MsnDatabase, $CahiersChargesTable> {
  $$CahiersChargesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projetId => $composableBuilder(
      column: $table.projetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get versionDocument => $composableBuilder(
      column: $table.versionDocument,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contenuJson => $composableBuilder(
      column: $table.contenuJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateValidation => $composableBuilder(
      column: $table.dateValidation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$CahiersChargesTableOrderingComposer
    extends Composer<_$MsnDatabase, $CahiersChargesTable> {
  $$CahiersChargesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projetId => $composableBuilder(
      column: $table.projetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get versionDocument => $composableBuilder(
      column: $table.versionDocument,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contenuJson => $composableBuilder(
      column: $table.contenuJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateValidation => $composableBuilder(
      column: $table.dateValidation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$CahiersChargesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $CahiersChargesTable> {
  $$CahiersChargesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projetId =>
      $composableBuilder(column: $table.projetId, builder: (column) => column);

  GeneratedColumn<int> get versionDocument => $composableBuilder(
      column: $table.versionDocument, builder: (column) => column);

  GeneratedColumn<String> get contenuJson => $composableBuilder(
      column: $table.contenuJson, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get dateValidation => $composableBuilder(
      column: $table.dateValidation, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CahiersChargesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $CahiersChargesTable,
    CahiersCharge,
    $$CahiersChargesTableFilterComposer,
    $$CahiersChargesTableOrderingComposer,
    $$CahiersChargesTableAnnotationComposer,
    $$CahiersChargesTableCreateCompanionBuilder,
    $$CahiersChargesTableUpdateCompanionBuilder,
    (
      CahiersCharge,
      BaseReferences<_$MsnDatabase, $CahiersChargesTable, CahiersCharge>
    ),
    CahiersCharge,
    PrefetchHooks Function()> {
  $$CahiersChargesTableTableManager(
      _$MsnDatabase db, $CahiersChargesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CahiersChargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CahiersChargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CahiersChargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projetId = const Value.absent(),
            Value<int> versionDocument = const Value.absent(),
            Value<String> contenuJson = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateValidation = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CahiersChargesCompanion(
            id: id,
            projetId: projetId,
            versionDocument: versionDocument,
            contenuJson: contenuJson,
            statut: statut,
            dateValidation: dateValidation,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projetId,
            Value<int> versionDocument = const Value.absent(),
            required String contenuJson,
            Value<String> statut = const Value.absent(),
            Value<String?> dateValidation = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CahiersChargesCompanion.insert(
            id: id,
            projetId: projetId,
            versionDocument: versionDocument,
            contenuJson: contenuJson,
            statut: statut,
            dateValidation: dateValidation,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CahiersChargesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $CahiersChargesTable,
    CahiersCharge,
    $$CahiersChargesTableFilterComposer,
    $$CahiersChargesTableOrderingComposer,
    $$CahiersChargesTableAnnotationComposer,
    $$CahiersChargesTableCreateCompanionBuilder,
    $$CahiersChargesTableUpdateCompanionBuilder,
    (
      CahiersCharge,
      BaseReferences<_$MsnDatabase, $CahiersChargesTable, CahiersCharge>
    ),
    CahiersCharge,
    PrefetchHooks Function()>;
typedef $$TachesTableCreateCompanionBuilder = TachesCompanion Function({
  required String id,
  required String commandeId,
  Value<String?> projetId,
  required String titre,
  Value<String?> description,
  Value<String> statut,
  Value<String> priorite,
  Value<String?> echeance,
  Value<String?> termineeAt,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$TachesTableUpdateCompanionBuilder = TachesCompanion Function({
  Value<String> id,
  Value<String> commandeId,
  Value<String?> projetId,
  Value<String> titre,
  Value<String?> description,
  Value<String> statut,
  Value<String> priorite,
  Value<String?> echeance,
  Value<String?> termineeAt,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$TachesTableFilterComposer
    extends Composer<_$MsnDatabase, $TachesTable> {
  $$TachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projetId => $composableBuilder(
      column: $table.projetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titre => $composableBuilder(
      column: $table.titre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priorite => $composableBuilder(
      column: $table.priorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get echeance => $composableBuilder(
      column: $table.echeance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termineeAt => $composableBuilder(
      column: $table.termineeAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TachesTableOrderingComposer
    extends Composer<_$MsnDatabase, $TachesTable> {
  $$TachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projetId => $composableBuilder(
      column: $table.projetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titre => $composableBuilder(
      column: $table.titre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priorite => $composableBuilder(
      column: $table.priorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get echeance => $composableBuilder(
      column: $table.echeance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termineeAt => $composableBuilder(
      column: $table.termineeAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TachesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $TachesTable> {
  $$TachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<String> get projetId =>
      $composableBuilder(column: $table.projetId, builder: (column) => column);

  GeneratedColumn<String> get titre =>
      $composableBuilder(column: $table.titre, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get priorite =>
      $composableBuilder(column: $table.priorite, builder: (column) => column);

  GeneratedColumn<String> get echeance =>
      $composableBuilder(column: $table.echeance, builder: (column) => column);

  GeneratedColumn<String> get termineeAt => $composableBuilder(
      column: $table.termineeAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TachesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $TachesTable,
    Tache,
    $$TachesTableFilterComposer,
    $$TachesTableOrderingComposer,
    $$TachesTableAnnotationComposer,
    $$TachesTableCreateCompanionBuilder,
    $$TachesTableUpdateCompanionBuilder,
    (Tache, BaseReferences<_$MsnDatabase, $TachesTable, Tache>),
    Tache,
    PrefetchHooks Function()> {
  $$TachesTableTableManager(_$MsnDatabase db, $TachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> commandeId = const Value.absent(),
            Value<String?> projetId = const Value.absent(),
            Value<String> titre = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String> priorite = const Value.absent(),
            Value<String?> echeance = const Value.absent(),
            Value<String?> termineeAt = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TachesCompanion(
            id: id,
            commandeId: commandeId,
            projetId: projetId,
            titre: titre,
            description: description,
            statut: statut,
            priorite: priorite,
            echeance: echeance,
            termineeAt: termineeAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String commandeId,
            Value<String?> projetId = const Value.absent(),
            required String titre,
            Value<String?> description = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String> priorite = const Value.absent(),
            Value<String?> echeance = const Value.absent(),
            Value<String?> termineeAt = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TachesCompanion.insert(
            id: id,
            commandeId: commandeId,
            projetId: projetId,
            titre: titre,
            description: description,
            statut: statut,
            priorite: priorite,
            echeance: echeance,
            termineeAt: termineeAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TachesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $TachesTable,
    Tache,
    $$TachesTableFilterComposer,
    $$TachesTableOrderingComposer,
    $$TachesTableAnnotationComposer,
    $$TachesTableCreateCompanionBuilder,
    $$TachesTableUpdateCompanionBuilder,
    (Tache, BaseReferences<_$MsnDatabase, $TachesTable, Tache>),
    Tache,
    PrefetchHooks Function()>;
typedef $$ModelesMessagesTableCreateCompanionBuilder = ModelesMessagesCompanion
    Function({
  required String id,
  required String code,
  required String nom,
  required String objectif,
  required String canal,
  required String corpsTemplate,
  Value<String> variablesJson,
  Value<bool> actif,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$ModelesMessagesTableUpdateCompanionBuilder = ModelesMessagesCompanion
    Function({
  Value<String> id,
  Value<String> code,
  Value<String> nom,
  Value<String> objectif,
  Value<String> canal,
  Value<String> corpsTemplate,
  Value<String> variablesJson,
  Value<bool> actif,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$ModelesMessagesTableFilterComposer
    extends Composer<_$MsnDatabase, $ModelesMessagesTable> {
  $$ModelesMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectif => $composableBuilder(
      column: $table.objectif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canal => $composableBuilder(
      column: $table.canal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get corpsTemplate => $composableBuilder(
      column: $table.corpsTemplate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variablesJson => $composableBuilder(
      column: $table.variablesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ModelesMessagesTableOrderingComposer
    extends Composer<_$MsnDatabase, $ModelesMessagesTable> {
  $$ModelesMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectif => $composableBuilder(
      column: $table.objectif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canal => $composableBuilder(
      column: $table.canal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get corpsTemplate => $composableBuilder(
      column: $table.corpsTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variablesJson => $composableBuilder(
      column: $table.variablesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ModelesMessagesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $ModelesMessagesTable> {
  $$ModelesMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get objectif =>
      $composableBuilder(column: $table.objectif, builder: (column) => column);

  GeneratedColumn<String> get canal =>
      $composableBuilder(column: $table.canal, builder: (column) => column);

  GeneratedColumn<String> get corpsTemplate => $composableBuilder(
      column: $table.corpsTemplate, builder: (column) => column);

  GeneratedColumn<String> get variablesJson => $composableBuilder(
      column: $table.variablesJson, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ModelesMessagesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $ModelesMessagesTable,
    ModelesMessage,
    $$ModelesMessagesTableFilterComposer,
    $$ModelesMessagesTableOrderingComposer,
    $$ModelesMessagesTableAnnotationComposer,
    $$ModelesMessagesTableCreateCompanionBuilder,
    $$ModelesMessagesTableUpdateCompanionBuilder,
    (
      ModelesMessage,
      BaseReferences<_$MsnDatabase, $ModelesMessagesTable, ModelesMessage>
    ),
    ModelesMessage,
    PrefetchHooks Function()> {
  $$ModelesMessagesTableTableManager(
      _$MsnDatabase db, $ModelesMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelesMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelesMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelesMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String> objectif = const Value.absent(),
            Value<String> canal = const Value.absent(),
            Value<String> corpsTemplate = const Value.absent(),
            Value<String> variablesJson = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelesMessagesCompanion(
            id: id,
            code: code,
            nom: nom,
            objectif: objectif,
            canal: canal,
            corpsTemplate: corpsTemplate,
            variablesJson: variablesJson,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String nom,
            required String objectif,
            required String canal,
            required String corpsTemplate,
            Value<String> variablesJson = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelesMessagesCompanion.insert(
            id: id,
            code: code,
            nom: nom,
            objectif: objectif,
            canal: canal,
            corpsTemplate: corpsTemplate,
            variablesJson: variablesJson,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModelesMessagesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $ModelesMessagesTable,
    ModelesMessage,
    $$ModelesMessagesTableFilterComposer,
    $$ModelesMessagesTableOrderingComposer,
    $$ModelesMessagesTableAnnotationComposer,
    $$ModelesMessagesTableCreateCompanionBuilder,
    $$ModelesMessagesTableUpdateCompanionBuilder,
    (
      ModelesMessage,
      BaseReferences<_$MsnDatabase, $ModelesMessagesTable, ModelesMessage>
    ),
    ModelesMessage,
    PrefetchHooks Function()>;
typedef $$EchangesTableCreateCompanionBuilder = EchangesCompanion Function({
  required String id,
  required String clientId,
  Value<String?> demandeId,
  Value<String?> commandeId,
  Value<String?> modeleId,
  required String canal,
  required String direction,
  required String contenu,
  Value<String> statutEnvoi,
  Value<String?> datePreparation,
  Value<String?> dateCopie,
  Value<String?> dateEnvoiConfirme,
  Value<String?> externalReference,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$EchangesTableUpdateCompanionBuilder = EchangesCompanion Function({
  Value<String> id,
  Value<String> clientId,
  Value<String?> demandeId,
  Value<String?> commandeId,
  Value<String?> modeleId,
  Value<String> canal,
  Value<String> direction,
  Value<String> contenu,
  Value<String> statutEnvoi,
  Value<String?> datePreparation,
  Value<String?> dateCopie,
  Value<String?> dateEnvoiConfirme,
  Value<String?> externalReference,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$EchangesTableFilterComposer
    extends Composer<_$MsnDatabase, $EchangesTable> {
  $$EchangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modeleId => $composableBuilder(
      column: $table.modeleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canal => $composableBuilder(
      column: $table.canal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contenu => $composableBuilder(
      column: $table.contenu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statutEnvoi => $composableBuilder(
      column: $table.statutEnvoi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get datePreparation => $composableBuilder(
      column: $table.datePreparation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateCopie => $composableBuilder(
      column: $table.dateCopie, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateEnvoiConfirme => $composableBuilder(
      column: $table.dateEnvoiConfirme,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalReference => $composableBuilder(
      column: $table.externalReference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$EchangesTableOrderingComposer
    extends Composer<_$MsnDatabase, $EchangesTable> {
  $$EchangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modeleId => $composableBuilder(
      column: $table.modeleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canal => $composableBuilder(
      column: $table.canal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contenu => $composableBuilder(
      column: $table.contenu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statutEnvoi => $composableBuilder(
      column: $table.statutEnvoi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get datePreparation => $composableBuilder(
      column: $table.datePreparation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateCopie => $composableBuilder(
      column: $table.dateCopie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateEnvoiConfirme => $composableBuilder(
      column: $table.dateEnvoiConfirme,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalReference => $composableBuilder(
      column: $table.externalReference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$EchangesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $EchangesTable> {
  $$EchangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get demandeId =>
      $composableBuilder(column: $table.demandeId, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<String> get modeleId =>
      $composableBuilder(column: $table.modeleId, builder: (column) => column);

  GeneratedColumn<String> get canal =>
      $composableBuilder(column: $table.canal, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get contenu =>
      $composableBuilder(column: $table.contenu, builder: (column) => column);

  GeneratedColumn<String> get statutEnvoi => $composableBuilder(
      column: $table.statutEnvoi, builder: (column) => column);

  GeneratedColumn<String> get datePreparation => $composableBuilder(
      column: $table.datePreparation, builder: (column) => column);

  GeneratedColumn<String> get dateCopie =>
      $composableBuilder(column: $table.dateCopie, builder: (column) => column);

  GeneratedColumn<String> get dateEnvoiConfirme => $composableBuilder(
      column: $table.dateEnvoiConfirme, builder: (column) => column);

  GeneratedColumn<String> get externalReference => $composableBuilder(
      column: $table.externalReference, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$EchangesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $EchangesTable,
    Echange,
    $$EchangesTableFilterComposer,
    $$EchangesTableOrderingComposer,
    $$EchangesTableAnnotationComposer,
    $$EchangesTableCreateCompanionBuilder,
    $$EchangesTableUpdateCompanionBuilder,
    (Echange, BaseReferences<_$MsnDatabase, $EchangesTable, Echange>),
    Echange,
    PrefetchHooks Function()> {
  $$EchangesTableTableManager(_$MsnDatabase db, $EchangesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EchangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EchangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EchangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<String?> demandeId = const Value.absent(),
            Value<String?> commandeId = const Value.absent(),
            Value<String?> modeleId = const Value.absent(),
            Value<String> canal = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<String> contenu = const Value.absent(),
            Value<String> statutEnvoi = const Value.absent(),
            Value<String?> datePreparation = const Value.absent(),
            Value<String?> dateCopie = const Value.absent(),
            Value<String?> dateEnvoiConfirme = const Value.absent(),
            Value<String?> externalReference = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EchangesCompanion(
            id: id,
            clientId: clientId,
            demandeId: demandeId,
            commandeId: commandeId,
            modeleId: modeleId,
            canal: canal,
            direction: direction,
            contenu: contenu,
            statutEnvoi: statutEnvoi,
            datePreparation: datePreparation,
            dateCopie: dateCopie,
            dateEnvoiConfirme: dateEnvoiConfirme,
            externalReference: externalReference,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientId,
            Value<String?> demandeId = const Value.absent(),
            Value<String?> commandeId = const Value.absent(),
            Value<String?> modeleId = const Value.absent(),
            required String canal,
            required String direction,
            required String contenu,
            Value<String> statutEnvoi = const Value.absent(),
            Value<String?> datePreparation = const Value.absent(),
            Value<String?> dateCopie = const Value.absent(),
            Value<String?> dateEnvoiConfirme = const Value.absent(),
            Value<String?> externalReference = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EchangesCompanion.insert(
            id: id,
            clientId: clientId,
            demandeId: demandeId,
            commandeId: commandeId,
            modeleId: modeleId,
            canal: canal,
            direction: direction,
            contenu: contenu,
            statutEnvoi: statutEnvoi,
            datePreparation: datePreparation,
            dateCopie: dateCopie,
            dateEnvoiConfirme: dateEnvoiConfirme,
            externalReference: externalReference,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EchangesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $EchangesTable,
    Echange,
    $$EchangesTableFilterComposer,
    $$EchangesTableOrderingComposer,
    $$EchangesTableAnnotationComposer,
    $$EchangesTableCreateCompanionBuilder,
    $$EchangesTableUpdateCompanionBuilder,
    (Echange, BaseReferences<_$MsnDatabase, $EchangesTable, Echange>),
    Echange,
    PrefetchHooks Function()>;
typedef $$DevisTableTableCreateCompanionBuilder = DevisTableCompanion Function({
  required String id,
  required String numero,
  required String demandeId,
  Value<String?> commandeId,
  Value<int> revision,
  Value<String> statut,
  Value<String?> dateEmission,
  Value<String?> dateValidite,
  Value<String?> conditions,
  Value<int> totalHt,
  Value<String> devise,
  Value<String?> accepteAt,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$DevisTableTableUpdateCompanionBuilder = DevisTableCompanion Function({
  Value<String> id,
  Value<String> numero,
  Value<String> demandeId,
  Value<String?> commandeId,
  Value<int> revision,
  Value<String> statut,
  Value<String?> dateEmission,
  Value<String?> dateValidite,
  Value<String?> conditions,
  Value<int> totalHt,
  Value<String> devise,
  Value<String?> accepteAt,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$DevisTableTableFilterComposer
    extends Composer<_$MsnDatabase, $DevisTableTable> {
  $$DevisTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateEmission => $composableBuilder(
      column: $table.dateEmission, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateValidite => $composableBuilder(
      column: $table.dateValidite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalHt => $composableBuilder(
      column: $table.totalHt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accepteAt => $composableBuilder(
      column: $table.accepteAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DevisTableTableOrderingComposer
    extends Composer<_$MsnDatabase, $DevisTableTable> {
  $$DevisTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revision => $composableBuilder(
      column: $table.revision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateEmission => $composableBuilder(
      column: $table.dateEmission,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateValidite => $composableBuilder(
      column: $table.dateValidite,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalHt => $composableBuilder(
      column: $table.totalHt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accepteAt => $composableBuilder(
      column: $table.accepteAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DevisTableTableAnnotationComposer
    extends Composer<_$MsnDatabase, $DevisTableTable> {
  $$DevisTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get demandeId =>
      $composableBuilder(column: $table.demandeId, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get dateEmission => $composableBuilder(
      column: $table.dateEmission, builder: (column) => column);

  GeneratedColumn<String> get dateValidite => $composableBuilder(
      column: $table.dateValidite, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => column);

  GeneratedColumn<int> get totalHt =>
      $composableBuilder(column: $table.totalHt, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get accepteAt =>
      $composableBuilder(column: $table.accepteAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DevisTableTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $DevisTableTable,
    Devis,
    $$DevisTableTableFilterComposer,
    $$DevisTableTableOrderingComposer,
    $$DevisTableTableAnnotationComposer,
    $$DevisTableTableCreateCompanionBuilder,
    $$DevisTableTableUpdateCompanionBuilder,
    (Devis, BaseReferences<_$MsnDatabase, $DevisTableTable, Devis>),
    Devis,
    PrefetchHooks Function()> {
  $$DevisTableTableTableManager(_$MsnDatabase db, $DevisTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevisTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevisTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevisTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> numero = const Value.absent(),
            Value<String> demandeId = const Value.absent(),
            Value<String?> commandeId = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateEmission = const Value.absent(),
            Value<String?> dateValidite = const Value.absent(),
            Value<String?> conditions = const Value.absent(),
            Value<int> totalHt = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String?> accepteAt = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevisTableCompanion(
            id: id,
            numero: numero,
            demandeId: demandeId,
            commandeId: commandeId,
            revision: revision,
            statut: statut,
            dateEmission: dateEmission,
            dateValidite: dateValidite,
            conditions: conditions,
            totalHt: totalHt,
            devise: devise,
            accepteAt: accepteAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String numero,
            required String demandeId,
            Value<String?> commandeId = const Value.absent(),
            Value<int> revision = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateEmission = const Value.absent(),
            Value<String?> dateValidite = const Value.absent(),
            Value<String?> conditions = const Value.absent(),
            Value<int> totalHt = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String?> accepteAt = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevisTableCompanion.insert(
            id: id,
            numero: numero,
            demandeId: demandeId,
            commandeId: commandeId,
            revision: revision,
            statut: statut,
            dateEmission: dateEmission,
            dateValidite: dateValidite,
            conditions: conditions,
            totalHt: totalHt,
            devise: devise,
            accepteAt: accepteAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevisTableTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $DevisTableTable,
    Devis,
    $$DevisTableTableFilterComposer,
    $$DevisTableTableOrderingComposer,
    $$DevisTableTableAnnotationComposer,
    $$DevisTableTableCreateCompanionBuilder,
    $$DevisTableTableUpdateCompanionBuilder,
    (Devis, BaseReferences<_$MsnDatabase, $DevisTableTable, Devis>),
    Devis,
    PrefetchHooks Function()>;
typedef $$LignesDevisTableTableCreateCompanionBuilder
    = LignesDevisTableCompanion Function({
  required String id,
  required String devisId,
  Value<String?> serviceId,
  required String description,
  required String quantite,
  required String uniteSnapshot,
  required int prixUnitaire,
  required int montantLigne,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$LignesDevisTableTableUpdateCompanionBuilder
    = LignesDevisTableCompanion Function({
  Value<String> id,
  Value<String> devisId,
  Value<String?> serviceId,
  Value<String> description,
  Value<String> quantite,
  Value<String> uniteSnapshot,
  Value<int> prixUnitaire,
  Value<int> montantLigne,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$LignesDevisTableTableFilterComposer
    extends Composer<_$MsnDatabase, $LignesDevisTableTable> {
  $$LignesDevisTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devisId => $composableBuilder(
      column: $table.devisId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get montantLigne => $composableBuilder(
      column: $table.montantLigne, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LignesDevisTableTableOrderingComposer
    extends Composer<_$MsnDatabase, $LignesDevisTableTable> {
  $$LignesDevisTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devisId => $composableBuilder(
      column: $table.devisId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceId => $composableBuilder(
      column: $table.serviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get montantLigne => $composableBuilder(
      column: $table.montantLigne,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LignesDevisTableTableAnnotationComposer
    extends Composer<_$MsnDatabase, $LignesDevisTableTable> {
  $$LignesDevisTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get devisId =>
      $composableBuilder(column: $table.devisId, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => column);

  GeneratedColumn<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => column);

  GeneratedColumn<int> get montantLigne => $composableBuilder(
      column: $table.montantLigne, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LignesDevisTableTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $LignesDevisTableTable,
    LignesDevis,
    $$LignesDevisTableTableFilterComposer,
    $$LignesDevisTableTableOrderingComposer,
    $$LignesDevisTableTableAnnotationComposer,
    $$LignesDevisTableTableCreateCompanionBuilder,
    $$LignesDevisTableTableUpdateCompanionBuilder,
    (
      LignesDevis,
      BaseReferences<_$MsnDatabase, $LignesDevisTableTable, LignesDevis>
    ),
    LignesDevis,
    PrefetchHooks Function()> {
  $$LignesDevisTableTableTableManager(
      _$MsnDatabase db, $LignesDevisTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignesDevisTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignesDevisTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignesDevisTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> devisId = const Value.absent(),
            Value<String?> serviceId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> quantite = const Value.absent(),
            Value<String> uniteSnapshot = const Value.absent(),
            Value<int> prixUnitaire = const Value.absent(),
            Value<int> montantLigne = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LignesDevisTableCompanion(
            id: id,
            devisId: devisId,
            serviceId: serviceId,
            description: description,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixUnitaire: prixUnitaire,
            montantLigne: montantLigne,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String devisId,
            Value<String?> serviceId = const Value.absent(),
            required String description,
            required String quantite,
            required String uniteSnapshot,
            required int prixUnitaire,
            required int montantLigne,
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LignesDevisTableCompanion.insert(
            id: id,
            devisId: devisId,
            serviceId: serviceId,
            description: description,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixUnitaire: prixUnitaire,
            montantLigne: montantLigne,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LignesDevisTableTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $LignesDevisTableTable,
    LignesDevis,
    $$LignesDevisTableTableFilterComposer,
    $$LignesDevisTableTableOrderingComposer,
    $$LignesDevisTableTableAnnotationComposer,
    $$LignesDevisTableTableCreateCompanionBuilder,
    $$LignesDevisTableTableUpdateCompanionBuilder,
    (
      LignesDevis,
      BaseReferences<_$MsnDatabase, $LignesDevisTableTable, LignesDevis>
    ),
    LignesDevis,
    PrefetchHooks Function()>;
typedef $$FacturesTableCreateCompanionBuilder = FacturesCompanion Function({
  required String id,
  required String numero,
  required String commandeId,
  Value<String> statut,
  Value<String?> dateEmission,
  Value<String?> dateEcheance,
  Value<int> total,
  Value<String> devise,
  Value<String?> conditions,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$FacturesTableUpdateCompanionBuilder = FacturesCompanion Function({
  Value<String> id,
  Value<String> numero,
  Value<String> commandeId,
  Value<String> statut,
  Value<String?> dateEmission,
  Value<String?> dateEcheance,
  Value<int> total,
  Value<String> devise,
  Value<String?> conditions,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$FacturesTableFilterComposer
    extends Composer<_$MsnDatabase, $FacturesTable> {
  $$FacturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateEmission => $composableBuilder(
      column: $table.dateEmission, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateEcheance => $composableBuilder(
      column: $table.dateEcheance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$FacturesTableOrderingComposer
    extends Composer<_$MsnDatabase, $FacturesTable> {
  $$FacturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateEmission => $composableBuilder(
      column: $table.dateEmission,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateEcheance => $composableBuilder(
      column: $table.dateEcheance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$FacturesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $FacturesTable> {
  $$FacturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get dateEmission => $composableBuilder(
      column: $table.dateEmission, builder: (column) => column);

  GeneratedColumn<String> get dateEcheance => $composableBuilder(
      column: $table.dateEcheance, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
      column: $table.conditions, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$FacturesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $FacturesTable,
    Facture,
    $$FacturesTableFilterComposer,
    $$FacturesTableOrderingComposer,
    $$FacturesTableAnnotationComposer,
    $$FacturesTableCreateCompanionBuilder,
    $$FacturesTableUpdateCompanionBuilder,
    (Facture, BaseReferences<_$MsnDatabase, $FacturesTable, Facture>),
    Facture,
    PrefetchHooks Function()> {
  $$FacturesTableTableManager(_$MsnDatabase db, $FacturesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> numero = const Value.absent(),
            Value<String> commandeId = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> dateEmission = const Value.absent(),
            Value<String?> dateEcheance = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String?> conditions = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FacturesCompanion(
            id: id,
            numero: numero,
            commandeId: commandeId,
            statut: statut,
            dateEmission: dateEmission,
            dateEcheance: dateEcheance,
            total: total,
            devise: devise,
            conditions: conditions,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String numero,
            required String commandeId,
            Value<String> statut = const Value.absent(),
            Value<String?> dateEmission = const Value.absent(),
            Value<String?> dateEcheance = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String?> conditions = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FacturesCompanion.insert(
            id: id,
            numero: numero,
            commandeId: commandeId,
            statut: statut,
            dateEmission: dateEmission,
            dateEcheance: dateEcheance,
            total: total,
            devise: devise,
            conditions: conditions,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FacturesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $FacturesTable,
    Facture,
    $$FacturesTableFilterComposer,
    $$FacturesTableOrderingComposer,
    $$FacturesTableAnnotationComposer,
    $$FacturesTableCreateCompanionBuilder,
    $$FacturesTableUpdateCompanionBuilder,
    (Facture, BaseReferences<_$MsnDatabase, $FacturesTable, Facture>),
    Facture,
    PrefetchHooks Function()>;
typedef $$LignesFactureTableCreateCompanionBuilder = LignesFactureCompanion
    Function({
  required String id,
  required String factureId,
  required String description,
  required String quantite,
  required String uniteSnapshot,
  required int prixUnitaire,
  required int montantLigne,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$LignesFactureTableUpdateCompanionBuilder = LignesFactureCompanion
    Function({
  Value<String> id,
  Value<String> factureId,
  Value<String> description,
  Value<String> quantite,
  Value<String> uniteSnapshot,
  Value<int> prixUnitaire,
  Value<int> montantLigne,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$LignesFactureTableFilterComposer
    extends Composer<_$MsnDatabase, $LignesFactureTable> {
  $$LignesFactureTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factureId => $composableBuilder(
      column: $table.factureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get montantLigne => $composableBuilder(
      column: $table.montantLigne, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LignesFactureTableOrderingComposer
    extends Composer<_$MsnDatabase, $LignesFactureTable> {
  $$LignesFactureTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factureId => $composableBuilder(
      column: $table.factureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantite => $composableBuilder(
      column: $table.quantite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get montantLigne => $composableBuilder(
      column: $table.montantLigne,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LignesFactureTableAnnotationComposer
    extends Composer<_$MsnDatabase, $LignesFactureTable> {
  $$LignesFactureTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get factureId =>
      $composableBuilder(column: $table.factureId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<String> get uniteSnapshot => $composableBuilder(
      column: $table.uniteSnapshot, builder: (column) => column);

  GeneratedColumn<int> get prixUnitaire => $composableBuilder(
      column: $table.prixUnitaire, builder: (column) => column);

  GeneratedColumn<int> get montantLigne => $composableBuilder(
      column: $table.montantLigne, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LignesFactureTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $LignesFactureTable,
    LignesFactureData,
    $$LignesFactureTableFilterComposer,
    $$LignesFactureTableOrderingComposer,
    $$LignesFactureTableAnnotationComposer,
    $$LignesFactureTableCreateCompanionBuilder,
    $$LignesFactureTableUpdateCompanionBuilder,
    (
      LignesFactureData,
      BaseReferences<_$MsnDatabase, $LignesFactureTable, LignesFactureData>
    ),
    LignesFactureData,
    PrefetchHooks Function()> {
  $$LignesFactureTableTableManager(_$MsnDatabase db, $LignesFactureTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LignesFactureTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LignesFactureTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LignesFactureTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> factureId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> quantite = const Value.absent(),
            Value<String> uniteSnapshot = const Value.absent(),
            Value<int> prixUnitaire = const Value.absent(),
            Value<int> montantLigne = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LignesFactureCompanion(
            id: id,
            factureId: factureId,
            description: description,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixUnitaire: prixUnitaire,
            montantLigne: montantLigne,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String factureId,
            required String description,
            required String quantite,
            required String uniteSnapshot,
            required int prixUnitaire,
            required int montantLigne,
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LignesFactureCompanion.insert(
            id: id,
            factureId: factureId,
            description: description,
            quantite: quantite,
            uniteSnapshot: uniteSnapshot,
            prixUnitaire: prixUnitaire,
            montantLigne: montantLigne,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LignesFactureTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $LignesFactureTable,
    LignesFactureData,
    $$LignesFactureTableFilterComposer,
    $$LignesFactureTableOrderingComposer,
    $$LignesFactureTableAnnotationComposer,
    $$LignesFactureTableCreateCompanionBuilder,
    $$LignesFactureTableUpdateCompanionBuilder,
    (
      LignesFactureData,
      BaseReferences<_$MsnDatabase, $LignesFactureTable, LignesFactureData>
    ),
    LignesFactureData,
    PrefetchHooks Function()>;
typedef $$PaiementsTableCreateCompanionBuilder = PaiementsCompanion Function({
  required String id,
  required String factureId,
  required int montant,
  Value<String> devise,
  required String datePaiement,
  required String moyen,
  Value<String?> reference,
  Value<String> statut,
  Value<String?> notes,
  Value<String?> idempotencyKey,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$PaiementsTableUpdateCompanionBuilder = PaiementsCompanion Function({
  Value<String> id,
  Value<String> factureId,
  Value<int> montant,
  Value<String> devise,
  Value<String> datePaiement,
  Value<String> moyen,
  Value<String?> reference,
  Value<String> statut,
  Value<String?> notes,
  Value<String?> idempotencyKey,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$PaiementsTableFilterComposer
    extends Composer<_$MsnDatabase, $PaiementsTable> {
  $$PaiementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factureId => $composableBuilder(
      column: $table.factureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get datePaiement => $composableBuilder(
      column: $table.datePaiement, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moyen => $composableBuilder(
      column: $table.moyen, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PaiementsTableOrderingComposer
    extends Composer<_$MsnDatabase, $PaiementsTable> {
  $$PaiementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factureId => $composableBuilder(
      column: $table.factureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get datePaiement => $composableBuilder(
      column: $table.datePaiement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moyen => $composableBuilder(
      column: $table.moyen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PaiementsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $PaiementsTable> {
  $$PaiementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get factureId =>
      $composableBuilder(column: $table.factureId, builder: (column) => column);

  GeneratedColumn<int> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get datePaiement => $composableBuilder(
      column: $table.datePaiement, builder: (column) => column);

  GeneratedColumn<String> get moyen =>
      $composableBuilder(column: $table.moyen, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PaiementsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $PaiementsTable,
    Paiement,
    $$PaiementsTableFilterComposer,
    $$PaiementsTableOrderingComposer,
    $$PaiementsTableAnnotationComposer,
    $$PaiementsTableCreateCompanionBuilder,
    $$PaiementsTableUpdateCompanionBuilder,
    (Paiement, BaseReferences<_$MsnDatabase, $PaiementsTable, Paiement>),
    Paiement,
    PrefetchHooks Function()> {
  $$PaiementsTableTableManager(_$MsnDatabase db, $PaiementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaiementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaiementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaiementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> factureId = const Value.absent(),
            Value<int> montant = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String> datePaiement = const Value.absent(),
            Value<String> moyen = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> idempotencyKey = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaiementsCompanion(
            id: id,
            factureId: factureId,
            montant: montant,
            devise: devise,
            datePaiement: datePaiement,
            moyen: moyen,
            reference: reference,
            statut: statut,
            notes: notes,
            idempotencyKey: idempotencyKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String factureId,
            required int montant,
            Value<String> devise = const Value.absent(),
            required String datePaiement,
            required String moyen,
            Value<String?> reference = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> idempotencyKey = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaiementsCompanion.insert(
            id: id,
            factureId: factureId,
            montant: montant,
            devise: devise,
            datePaiement: datePaiement,
            moyen: moyen,
            reference: reference,
            statut: statut,
            notes: notes,
            idempotencyKey: idempotencyKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaiementsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $PaiementsTable,
    Paiement,
    $$PaiementsTableFilterComposer,
    $$PaiementsTableOrderingComposer,
    $$PaiementsTableAnnotationComposer,
    $$PaiementsTableCreateCompanionBuilder,
    $$PaiementsTableUpdateCompanionBuilder,
    (Paiement, BaseReferences<_$MsnDatabase, $PaiementsTable, Paiement>),
    Paiement,
    PrefetchHooks Function()>;
typedef $$DepensesTableCreateCompanionBuilder = DepensesCompanion Function({
  required String id,
  required String dateDepense,
  required String categorie,
  required String description,
  required int montant,
  Value<String> devise,
  required String moyen,
  Value<String?> reference,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$DepensesTableUpdateCompanionBuilder = DepensesCompanion Function({
  Value<String> id,
  Value<String> dateDepense,
  Value<String> categorie,
  Value<String> description,
  Value<int> montant,
  Value<String> devise,
  Value<String> moyen,
  Value<String?> reference,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$DepensesTableFilterComposer
    extends Composer<_$MsnDatabase, $DepensesTable> {
  $$DepensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateDepense => $composableBuilder(
      column: $table.dateDepense, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moyen => $composableBuilder(
      column: $table.moyen, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DepensesTableOrderingComposer
    extends Composer<_$MsnDatabase, $DepensesTable> {
  $$DepensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateDepense => $composableBuilder(
      column: $table.dateDepense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get devise => $composableBuilder(
      column: $table.devise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moyen => $composableBuilder(
      column: $table.moyen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DepensesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $DepensesTable> {
  $$DepensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateDepense => $composableBuilder(
      column: $table.dateDepense, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumn<String> get devise =>
      $composableBuilder(column: $table.devise, builder: (column) => column);

  GeneratedColumn<String> get moyen =>
      $composableBuilder(column: $table.moyen, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DepensesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $DepensesTable,
    Depense,
    $$DepensesTableFilterComposer,
    $$DepensesTableOrderingComposer,
    $$DepensesTableAnnotationComposer,
    $$DepensesTableCreateCompanionBuilder,
    $$DepensesTableUpdateCompanionBuilder,
    (Depense, BaseReferences<_$MsnDatabase, $DepensesTable, Depense>),
    Depense,
    PrefetchHooks Function()> {
  $$DepensesTableTableManager(_$MsnDatabase db, $DepensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dateDepense = const Value.absent(),
            Value<String> categorie = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> montant = const Value.absent(),
            Value<String> devise = const Value.absent(),
            Value<String> moyen = const Value.absent(),
            Value<String?> reference = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DepensesCompanion(
            id: id,
            dateDepense: dateDepense,
            categorie: categorie,
            description: description,
            montant: montant,
            devise: devise,
            moyen: moyen,
            reference: reference,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dateDepense,
            required String categorie,
            required String description,
            required int montant,
            Value<String> devise = const Value.absent(),
            required String moyen,
            Value<String?> reference = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DepensesCompanion.insert(
            id: id,
            dateDepense: dateDepense,
            categorie: categorie,
            description: description,
            montant: montant,
            devise: devise,
            moyen: moyen,
            reference: reference,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DepensesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $DepensesTable,
    Depense,
    $$DepensesTableFilterComposer,
    $$DepensesTableOrderingComposer,
    $$DepensesTableAnnotationComposer,
    $$DepensesTableCreateCompanionBuilder,
    $$DepensesTableUpdateCompanionBuilder,
    (Depense, BaseReferences<_$MsnDatabase, $DepensesTable, Depense>),
    Depense,
    PrefetchHooks Function()>;
typedef $$PiecesJointesTableCreateCompanionBuilder = PiecesJointesCompanion
    Function({
  required String id,
  Value<String?> clientId,
  Value<String?> demandeId,
  Value<String?> commandeId,
  Value<String?> projetId,
  required String nomFichier,
  required String mimeType,
  required int tailleOctets,
  required String sha256,
  Value<String?> cheminLocal,
  Value<String?> cleStockageDistant,
  Value<String> statutTransfert,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$PiecesJointesTableUpdateCompanionBuilder = PiecesJointesCompanion
    Function({
  Value<String> id,
  Value<String?> clientId,
  Value<String?> demandeId,
  Value<String?> commandeId,
  Value<String?> projetId,
  Value<String> nomFichier,
  Value<String> mimeType,
  Value<int> tailleOctets,
  Value<String> sha256,
  Value<String?> cheminLocal,
  Value<String?> cleStockageDistant,
  Value<String> statutTransfert,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$PiecesJointesTableFilterComposer
    extends Composer<_$MsnDatabase, $PiecesJointesTable> {
  $$PiecesJointesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projetId => $composableBuilder(
      column: $table.projetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nomFichier => $composableBuilder(
      column: $table.nomFichier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tailleOctets => $composableBuilder(
      column: $table.tailleOctets, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cheminLocal => $composableBuilder(
      column: $table.cheminLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cleStockageDistant => $composableBuilder(
      column: $table.cleStockageDistant,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statutTransfert => $composableBuilder(
      column: $table.statutTransfert,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PiecesJointesTableOrderingComposer
    extends Composer<_$MsnDatabase, $PiecesJointesTable> {
  $$PiecesJointesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get demandeId => $composableBuilder(
      column: $table.demandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projetId => $composableBuilder(
      column: $table.projetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nomFichier => $composableBuilder(
      column: $table.nomFichier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tailleOctets => $composableBuilder(
      column: $table.tailleOctets,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cheminLocal => $composableBuilder(
      column: $table.cheminLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cleStockageDistant => $composableBuilder(
      column: $table.cleStockageDistant,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statutTransfert => $composableBuilder(
      column: $table.statutTransfert,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PiecesJointesTableAnnotationComposer
    extends Composer<_$MsnDatabase, $PiecesJointesTable> {
  $$PiecesJointesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get demandeId =>
      $composableBuilder(column: $table.demandeId, builder: (column) => column);

  GeneratedColumn<String> get commandeId => $composableBuilder(
      column: $table.commandeId, builder: (column) => column);

  GeneratedColumn<String> get projetId =>
      $composableBuilder(column: $table.projetId, builder: (column) => column);

  GeneratedColumn<String> get nomFichier => $composableBuilder(
      column: $table.nomFichier, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get tailleOctets => $composableBuilder(
      column: $table.tailleOctets, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get cheminLocal => $composableBuilder(
      column: $table.cheminLocal, builder: (column) => column);

  GeneratedColumn<String> get cleStockageDistant => $composableBuilder(
      column: $table.cleStockageDistant, builder: (column) => column);

  GeneratedColumn<String> get statutTransfert => $composableBuilder(
      column: $table.statutTransfert, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PiecesJointesTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $PiecesJointesTable,
    PiecesJointe,
    $$PiecesJointesTableFilterComposer,
    $$PiecesJointesTableOrderingComposer,
    $$PiecesJointesTableAnnotationComposer,
    $$PiecesJointesTableCreateCompanionBuilder,
    $$PiecesJointesTableUpdateCompanionBuilder,
    (
      PiecesJointe,
      BaseReferences<_$MsnDatabase, $PiecesJointesTable, PiecesJointe>
    ),
    PiecesJointe,
    PrefetchHooks Function()> {
  $$PiecesJointesTableTableManager(_$MsnDatabase db, $PiecesJointesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PiecesJointesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PiecesJointesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PiecesJointesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String?> demandeId = const Value.absent(),
            Value<String?> commandeId = const Value.absent(),
            Value<String?> projetId = const Value.absent(),
            Value<String> nomFichier = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<int> tailleOctets = const Value.absent(),
            Value<String> sha256 = const Value.absent(),
            Value<String?> cheminLocal = const Value.absent(),
            Value<String?> cleStockageDistant = const Value.absent(),
            Value<String> statutTransfert = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PiecesJointesCompanion(
            id: id,
            clientId: clientId,
            demandeId: demandeId,
            commandeId: commandeId,
            projetId: projetId,
            nomFichier: nomFichier,
            mimeType: mimeType,
            tailleOctets: tailleOctets,
            sha256: sha256,
            cheminLocal: cheminLocal,
            cleStockageDistant: cleStockageDistant,
            statutTransfert: statutTransfert,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> clientId = const Value.absent(),
            Value<String?> demandeId = const Value.absent(),
            Value<String?> commandeId = const Value.absent(),
            Value<String?> projetId = const Value.absent(),
            required String nomFichier,
            required String mimeType,
            required int tailleOctets,
            required String sha256,
            Value<String?> cheminLocal = const Value.absent(),
            Value<String?> cleStockageDistant = const Value.absent(),
            Value<String> statutTransfert = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PiecesJointesCompanion.insert(
            id: id,
            clientId: clientId,
            demandeId: demandeId,
            commandeId: commandeId,
            projetId: projetId,
            nomFichier: nomFichier,
            mimeType: mimeType,
            tailleOctets: tailleOctets,
            sha256: sha256,
            cheminLocal: cheminLocal,
            cleStockageDistant: cleStockageDistant,
            statutTransfert: statutTransfert,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PiecesJointesTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $PiecesJointesTable,
    PiecesJointe,
    $$PiecesJointesTableFilterComposer,
    $$PiecesJointesTableOrderingComposer,
    $$PiecesJointesTableAnnotationComposer,
    $$PiecesJointesTableCreateCompanionBuilder,
    $$PiecesJointesTableUpdateCompanionBuilder,
    (
      PiecesJointe,
      BaseReferences<_$MsnDatabase, $PiecesJointesTable, PiecesJointe>
    ),
    PiecesJointe,
    PrefetchHooks Function()>;
typedef $$JournalActionsTableCreateCompanionBuilder = JournalActionsCompanion
    Function({
  required String id,
  required String entiteType,
  required String entiteId,
  required String action,
  Value<String?> avantJson,
  Value<String?> apresJson,
  Value<String?> motif,
  required String appareilId,
  Value<String?> acteurId,
  required String dateAction,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$JournalActionsTableUpdateCompanionBuilder = JournalActionsCompanion
    Function({
  Value<String> id,
  Value<String> entiteType,
  Value<String> entiteId,
  Value<String> action,
  Value<String?> avantJson,
  Value<String?> apresJson,
  Value<String?> motif,
  Value<String> appareilId,
  Value<String?> acteurId,
  Value<String> dateAction,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$JournalActionsTableFilterComposer
    extends Composer<_$MsnDatabase, $JournalActionsTable> {
  $$JournalActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entiteId => $composableBuilder(
      column: $table.entiteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avantJson => $composableBuilder(
      column: $table.avantJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apresJson => $composableBuilder(
      column: $table.apresJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get acteurId => $composableBuilder(
      column: $table.acteurId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateAction => $composableBuilder(
      column: $table.dateAction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$JournalActionsTableOrderingComposer
    extends Composer<_$MsnDatabase, $JournalActionsTable> {
  $$JournalActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entiteId => $composableBuilder(
      column: $table.entiteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avantJson => $composableBuilder(
      column: $table.avantJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apresJson => $composableBuilder(
      column: $table.apresJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motif => $composableBuilder(
      column: $table.motif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get acteurId => $composableBuilder(
      column: $table.acteurId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateAction => $composableBuilder(
      column: $table.dateAction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$JournalActionsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $JournalActionsTable> {
  $$JournalActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => column);

  GeneratedColumn<String> get entiteId =>
      $composableBuilder(column: $table.entiteId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get avantJson =>
      $composableBuilder(column: $table.avantJson, builder: (column) => column);

  GeneratedColumn<String> get apresJson =>
      $composableBuilder(column: $table.apresJson, builder: (column) => column);

  GeneratedColumn<String> get motif =>
      $composableBuilder(column: $table.motif, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => column);

  GeneratedColumn<String> get acteurId =>
      $composableBuilder(column: $table.acteurId, builder: (column) => column);

  GeneratedColumn<String> get dateAction => $composableBuilder(
      column: $table.dateAction, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$JournalActionsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $JournalActionsTable,
    JournalAction,
    $$JournalActionsTableFilterComposer,
    $$JournalActionsTableOrderingComposer,
    $$JournalActionsTableAnnotationComposer,
    $$JournalActionsTableCreateCompanionBuilder,
    $$JournalActionsTableUpdateCompanionBuilder,
    (
      JournalAction,
      BaseReferences<_$MsnDatabase, $JournalActionsTable, JournalAction>
    ),
    JournalAction,
    PrefetchHooks Function()> {
  $$JournalActionsTableTableManager(
      _$MsnDatabase db, $JournalActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entiteType = const Value.absent(),
            Value<String> entiteId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> avantJson = const Value.absent(),
            Value<String?> apresJson = const Value.absent(),
            Value<String?> motif = const Value.absent(),
            Value<String> appareilId = const Value.absent(),
            Value<String?> acteurId = const Value.absent(),
            Value<String> dateAction = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalActionsCompanion(
            id: id,
            entiteType: entiteType,
            entiteId: entiteId,
            action: action,
            avantJson: avantJson,
            apresJson: apresJson,
            motif: motif,
            appareilId: appareilId,
            acteurId: acteurId,
            dateAction: dateAction,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entiteType,
            required String entiteId,
            required String action,
            Value<String?> avantJson = const Value.absent(),
            Value<String?> apresJson = const Value.absent(),
            Value<String?> motif = const Value.absent(),
            required String appareilId,
            Value<String?> acteurId = const Value.absent(),
            required String dateAction,
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JournalActionsCompanion.insert(
            id: id,
            entiteType: entiteType,
            entiteId: entiteId,
            action: action,
            avantJson: avantJson,
            apresJson: apresJson,
            motif: motif,
            appareilId: appareilId,
            acteurId: acteurId,
            dateAction: dateAction,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalActionsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $JournalActionsTable,
    JournalAction,
    $$JournalActionsTableFilterComposer,
    $$JournalActionsTableOrderingComposer,
    $$JournalActionsTableAnnotationComposer,
    $$JournalActionsTableCreateCompanionBuilder,
    $$JournalActionsTableUpdateCompanionBuilder,
    (
      JournalAction,
      BaseReferences<_$MsnDatabase, $JournalActionsTable, JournalAction>
    ),
    JournalAction,
    PrefetchHooks Function()>;
typedef $$AppareilsTableCreateCompanionBuilder = AppareilsCompanion Function({
  required String id,
  required String nom,
  required String plateforme,
  Value<String?> dernierSyncAt,
  Value<bool> actif,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$AppareilsTableUpdateCompanionBuilder = AppareilsCompanion Function({
  Value<String> id,
  Value<String> nom,
  Value<String> plateforme,
  Value<String?> dernierSyncAt,
  Value<bool> actif,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$AppareilsTableFilterComposer
    extends Composer<_$MsnDatabase, $AppareilsTable> {
  $$AppareilsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plateforme => $composableBuilder(
      column: $table.plateforme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dernierSyncAt => $composableBuilder(
      column: $table.dernierSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppareilsTableOrderingComposer
    extends Composer<_$MsnDatabase, $AppareilsTable> {
  $$AppareilsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plateforme => $composableBuilder(
      column: $table.plateforme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dernierSyncAt => $composableBuilder(
      column: $table.dernierSyncAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get actif => $composableBuilder(
      column: $table.actif, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppareilsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $AppareilsTable> {
  $$AppareilsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get plateforme => $composableBuilder(
      column: $table.plateforme, builder: (column) => column);

  GeneratedColumn<String> get dernierSyncAt => $composableBuilder(
      column: $table.dernierSyncAt, builder: (column) => column);

  GeneratedColumn<bool> get actif =>
      $composableBuilder(column: $table.actif, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppareilsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $AppareilsTable,
    Appareil,
    $$AppareilsTableFilterComposer,
    $$AppareilsTableOrderingComposer,
    $$AppareilsTableAnnotationComposer,
    $$AppareilsTableCreateCompanionBuilder,
    $$AppareilsTableUpdateCompanionBuilder,
    (Appareil, BaseReferences<_$MsnDatabase, $AppareilsTable, Appareil>),
    Appareil,
    PrefetchHooks Function()> {
  $$AppareilsTableTableManager(_$MsnDatabase db, $AppareilsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppareilsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppareilsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppareilsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String> plateforme = const Value.absent(),
            Value<String?> dernierSyncAt = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppareilsCompanion(
            id: id,
            nom: nom,
            plateforme: plateforme,
            dernierSyncAt: dernierSyncAt,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nom,
            required String plateforme,
            Value<String?> dernierSyncAt = const Value.absent(),
            Value<bool> actif = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppareilsCompanion.insert(
            id: id,
            nom: nom,
            plateforme: plateforme,
            dernierSyncAt: dernierSyncAt,
            actif: actif,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppareilsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $AppareilsTable,
    Appareil,
    $$AppareilsTableFilterComposer,
    $$AppareilsTableOrderingComposer,
    $$AppareilsTableAnnotationComposer,
    $$AppareilsTableCreateCompanionBuilder,
    $$AppareilsTableUpdateCompanionBuilder,
    (Appareil, BaseReferences<_$MsnDatabase, $AppareilsTable, Appareil>),
    Appareil,
    PrefetchHooks Function()>;
typedef $$PublicationsFacebookTableCreateCompanionBuilder
    = PublicationsFacebookCompanion Function({
  required String id,
  Value<String?> clientId,
  required String titre,
  required String contenu,
  required String datePlanifiee,
  Value<String> statut,
  Value<String> canal,
  Value<String?> publieAt,
  Value<String?> notes,
  required String createdAt,
  required String updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$PublicationsFacebookTableUpdateCompanionBuilder
    = PublicationsFacebookCompanion Function({
  Value<String> id,
  Value<String?> clientId,
  Value<String> titre,
  Value<String> contenu,
  Value<String> datePlanifiee,
  Value<String> statut,
  Value<String> canal,
  Value<String?> publieAt,
  Value<String?> notes,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> version,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$PublicationsFacebookTableFilterComposer
    extends Composer<_$MsnDatabase, $PublicationsFacebookTable> {
  $$PublicationsFacebookTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titre => $composableBuilder(
      column: $table.titre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contenu => $composableBuilder(
      column: $table.contenu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get datePlanifiee => $composableBuilder(
      column: $table.datePlanifiee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canal => $composableBuilder(
      column: $table.canal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publieAt => $composableBuilder(
      column: $table.publieAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PublicationsFacebookTableOrderingComposer
    extends Composer<_$MsnDatabase, $PublicationsFacebookTable> {
  $$PublicationsFacebookTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titre => $composableBuilder(
      column: $table.titre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contenu => $composableBuilder(
      column: $table.contenu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get datePlanifiee => $composableBuilder(
      column: $table.datePlanifiee,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canal => $composableBuilder(
      column: $table.canal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publieAt => $composableBuilder(
      column: $table.publieAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PublicationsFacebookTableAnnotationComposer
    extends Composer<_$MsnDatabase, $PublicationsFacebookTable> {
  $$PublicationsFacebookTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get titre =>
      $composableBuilder(column: $table.titre, builder: (column) => column);

  GeneratedColumn<String> get contenu =>
      $composableBuilder(column: $table.contenu, builder: (column) => column);

  GeneratedColumn<String> get datePlanifiee => $composableBuilder(
      column: $table.datePlanifiee, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get canal =>
      $composableBuilder(column: $table.canal, builder: (column) => column);

  GeneratedColumn<String> get publieAt =>
      $composableBuilder(column: $table.publieAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PublicationsFacebookTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $PublicationsFacebookTable,
    PublicationsFacebookData,
    $$PublicationsFacebookTableFilterComposer,
    $$PublicationsFacebookTableOrderingComposer,
    $$PublicationsFacebookTableAnnotationComposer,
    $$PublicationsFacebookTableCreateCompanionBuilder,
    $$PublicationsFacebookTableUpdateCompanionBuilder,
    (
      PublicationsFacebookData,
      BaseReferences<_$MsnDatabase, $PublicationsFacebookTable,
          PublicationsFacebookData>
    ),
    PublicationsFacebookData,
    PrefetchHooks Function()> {
  $$PublicationsFacebookTableTableManager(
      _$MsnDatabase db, $PublicationsFacebookTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PublicationsFacebookTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PublicationsFacebookTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PublicationsFacebookTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> clientId = const Value.absent(),
            Value<String> titre = const Value.absent(),
            Value<String> contenu = const Value.absent(),
            Value<String> datePlanifiee = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String> canal = const Value.absent(),
            Value<String?> publieAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PublicationsFacebookCompanion(
            id: id,
            clientId: clientId,
            titre: titre,
            contenu: contenu,
            datePlanifiee: datePlanifiee,
            statut: statut,
            canal: canal,
            publieAt: publieAt,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> clientId = const Value.absent(),
            required String titre,
            required String contenu,
            required String datePlanifiee,
            Value<String> statut = const Value.absent(),
            Value<String> canal = const Value.absent(),
            Value<String?> publieAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> version = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PublicationsFacebookCompanion.insert(
            id: id,
            clientId: clientId,
            titre: titre,
            contenu: contenu,
            datePlanifiee: datePlanifiee,
            statut: statut,
            canal: canal,
            publieAt: publieAt,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            version: version,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PublicationsFacebookTableProcessedTableManager
    = ProcessedTableManager<
        _$MsnDatabase,
        $PublicationsFacebookTable,
        PublicationsFacebookData,
        $$PublicationsFacebookTableFilterComposer,
        $$PublicationsFacebookTableOrderingComposer,
        $$PublicationsFacebookTableAnnotationComposer,
        $$PublicationsFacebookTableCreateCompanionBuilder,
        $$PublicationsFacebookTableUpdateCompanionBuilder,
        (
          PublicationsFacebookData,
          BaseReferences<_$MsnDatabase, $PublicationsFacebookTable,
              PublicationsFacebookData>
        ),
        PublicationsFacebookData,
        PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String id,
  required String appareilId,
  required String entiteType,
  required String entiteId,
  required String operation,
  required String payloadJson,
  Value<int?> baseVersion,
  required String idempotencyKey,
  Value<String> statut,
  Value<int> tentatives,
  Value<String?> prochaineTentativeAt,
  Value<String?> derniereErreur,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> id,
  Value<String> appareilId,
  Value<String> entiteType,
  Value<String> entiteId,
  Value<String> operation,
  Value<String> payloadJson,
  Value<int?> baseVersion,
  Value<String> idempotencyKey,
  Value<String> statut,
  Value<int> tentatives,
  Value<String?> prochaineTentativeAt,
  Value<String?> derniereErreur,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$MsnDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entiteId => $composableBuilder(
      column: $table.entiteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tentatives => $composableBuilder(
      column: $table.tentatives, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prochaineTentativeAt => $composableBuilder(
      column: $table.prochaineTentativeAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get derniereErreur => $composableBuilder(
      column: $table.derniereErreur,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$MsnDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entiteId => $composableBuilder(
      column: $table.entiteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tentatives => $composableBuilder(
      column: $table.tentatives, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prochaineTentativeAt => $composableBuilder(
      column: $table.prochaineTentativeAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get derniereErreur => $composableBuilder(
      column: $table.derniereErreur,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$MsnDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => column);

  GeneratedColumn<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => column);

  GeneratedColumn<String> get entiteId =>
      $composableBuilder(column: $table.entiteId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<int> get tentatives => $composableBuilder(
      column: $table.tentatives, builder: (column) => column);

  GeneratedColumn<String> get prochaineTentativeAt => $composableBuilder(
      column: $table.prochaineTentativeAt, builder: (column) => column);

  GeneratedColumn<String> get derniereErreur => $composableBuilder(
      column: $table.derniereErreur, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxData,
      BaseReferences<_$MsnDatabase, $SyncOutboxTable, SyncOutboxData>
    ),
    SyncOutboxData,
    PrefetchHooks Function()> {
  $$SyncOutboxTableTableManager(_$MsnDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> appareilId = const Value.absent(),
            Value<String> entiteType = const Value.absent(),
            Value<String> entiteId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int?> baseVersion = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<int> tentatives = const Value.absent(),
            Value<String?> prochaineTentativeAt = const Value.absent(),
            Value<String?> derniereErreur = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            id: id,
            appareilId: appareilId,
            entiteType: entiteType,
            entiteId: entiteId,
            operation: operation,
            payloadJson: payloadJson,
            baseVersion: baseVersion,
            idempotencyKey: idempotencyKey,
            statut: statut,
            tentatives: tentatives,
            prochaineTentativeAt: prochaineTentativeAt,
            derniereErreur: derniereErreur,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String appareilId,
            required String entiteType,
            required String entiteId,
            required String operation,
            required String payloadJson,
            Value<int?> baseVersion = const Value.absent(),
            required String idempotencyKey,
            Value<String> statut = const Value.absent(),
            Value<int> tentatives = const Value.absent(),
            Value<String?> prochaineTentativeAt = const Value.absent(),
            Value<String?> derniereErreur = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            id: id,
            appareilId: appareilId,
            entiteType: entiteType,
            entiteId: entiteId,
            operation: operation,
            payloadJson: payloadJson,
            baseVersion: baseVersion,
            idempotencyKey: idempotencyKey,
            statut: statut,
            tentatives: tentatives,
            prochaineTentativeAt: prochaineTentativeAt,
            derniereErreur: derniereErreur,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxData,
      BaseReferences<_$MsnDatabase, $SyncOutboxTable, SyncOutboxData>
    ),
    SyncOutboxData,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String appareilId,
  Value<String> dernierCurseur,
  Value<String?> dernierSyncReussiAt,
  Value<String?> derniereErreur,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> appareilId,
  Value<String> dernierCurseur,
  Value<String?> dernierSyncReussiAt,
  Value<String?> derniereErreur,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$MsnDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dernierCurseur => $composableBuilder(
      column: $table.dernierCurseur,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dernierSyncReussiAt => $composableBuilder(
      column: $table.dernierSyncReussiAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get derniereErreur => $composableBuilder(
      column: $table.derniereErreur,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$MsnDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dernierCurseur => $composableBuilder(
      column: $table.dernierCurseur,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dernierSyncReussiAt => $composableBuilder(
      column: $table.dernierSyncReussiAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get derniereErreur => $composableBuilder(
      column: $table.derniereErreur,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$MsnDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => column);

  GeneratedColumn<String> get dernierCurseur => $composableBuilder(
      column: $table.dernierCurseur, builder: (column) => column);

  GeneratedColumn<String> get dernierSyncReussiAt => $composableBuilder(
      column: $table.dernierSyncReussiAt, builder: (column) => column);

  GeneratedColumn<String> get derniereErreur => $composableBuilder(
      column: $table.derniereErreur, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$MsnDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$MsnDatabase db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> appareilId = const Value.absent(),
            Value<String> dernierCurseur = const Value.absent(),
            Value<String?> dernierSyncReussiAt = const Value.absent(),
            Value<String?> derniereErreur = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion(
            appareilId: appareilId,
            dernierCurseur: dernierCurseur,
            dernierSyncReussiAt: dernierSyncReussiAt,
            derniereErreur: derniereErreur,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String appareilId,
            Value<String> dernierCurseur = const Value.absent(),
            Value<String?> dernierSyncReussiAt = const Value.absent(),
            Value<String?> derniereErreur = const Value.absent(),
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            appareilId: appareilId,
            dernierCurseur: dernierCurseur,
            dernierSyncReussiAt: dernierSyncReussiAt,
            derniereErreur: derniereErreur,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$MsnDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()>;
typedef $$SyncConflictsTableCreateCompanionBuilder = SyncConflictsCompanion
    Function({
  required String id,
  required String appareilId,
  required String entiteType,
  required String entiteId,
  required int versionLocale,
  required int versionServeur,
  required String localJson,
  required String serveurJson,
  Value<String> statut,
  Value<String?> resolutionJson,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$SyncConflictsTableUpdateCompanionBuilder = SyncConflictsCompanion
    Function({
  Value<String> id,
  Value<String> appareilId,
  Value<String> entiteType,
  Value<String> entiteId,
  Value<int> versionLocale,
  Value<int> versionServeur,
  Value<String> localJson,
  Value<String> serveurJson,
  Value<String> statut,
  Value<String?> resolutionJson,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$SyncConflictsTableFilterComposer
    extends Composer<_$MsnDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entiteId => $composableBuilder(
      column: $table.entiteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get versionLocale => $composableBuilder(
      column: $table.versionLocale, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get versionServeur => $composableBuilder(
      column: $table.versionServeur,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localJson => $composableBuilder(
      column: $table.localJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serveurJson => $composableBuilder(
      column: $table.serveurJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionJson => $composableBuilder(
      column: $table.resolutionJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$MsnDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entiteId => $composableBuilder(
      column: $table.entiteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get versionLocale => $composableBuilder(
      column: $table.versionLocale,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get versionServeur => $composableBuilder(
      column: $table.versionServeur,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localJson => $composableBuilder(
      column: $table.localJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serveurJson => $composableBuilder(
      column: $table.serveurJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionJson => $composableBuilder(
      column: $table.resolutionJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$MsnDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appareilId => $composableBuilder(
      column: $table.appareilId, builder: (column) => column);

  GeneratedColumn<String> get entiteType => $composableBuilder(
      column: $table.entiteType, builder: (column) => column);

  GeneratedColumn<String> get entiteId =>
      $composableBuilder(column: $table.entiteId, builder: (column) => column);

  GeneratedColumn<int> get versionLocale => $composableBuilder(
      column: $table.versionLocale, builder: (column) => column);

  GeneratedColumn<int> get versionServeur => $composableBuilder(
      column: $table.versionServeur, builder: (column) => column);

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<String> get serveurJson => $composableBuilder(
      column: $table.serveurJson, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get resolutionJson => $composableBuilder(
      column: $table.resolutionJson, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncConflictsTableTableManager extends RootTableManager<
    _$MsnDatabase,
    $SyncConflictsTable,
    SyncConflict,
    $$SyncConflictsTableFilterComposer,
    $$SyncConflictsTableOrderingComposer,
    $$SyncConflictsTableAnnotationComposer,
    $$SyncConflictsTableCreateCompanionBuilder,
    $$SyncConflictsTableUpdateCompanionBuilder,
    (
      SyncConflict,
      BaseReferences<_$MsnDatabase, $SyncConflictsTable, SyncConflict>
    ),
    SyncConflict,
    PrefetchHooks Function()> {
  $$SyncConflictsTableTableManager(_$MsnDatabase db, $SyncConflictsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> appareilId = const Value.absent(),
            Value<String> entiteType = const Value.absent(),
            Value<String> entiteId = const Value.absent(),
            Value<int> versionLocale = const Value.absent(),
            Value<int> versionServeur = const Value.absent(),
            Value<String> localJson = const Value.absent(),
            Value<String> serveurJson = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<String?> resolutionJson = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConflictsCompanion(
            id: id,
            appareilId: appareilId,
            entiteType: entiteType,
            entiteId: entiteId,
            versionLocale: versionLocale,
            versionServeur: versionServeur,
            localJson: localJson,
            serveurJson: serveurJson,
            statut: statut,
            resolutionJson: resolutionJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String appareilId,
            required String entiteType,
            required String entiteId,
            required int versionLocale,
            required int versionServeur,
            required String localJson,
            required String serveurJson,
            Value<String> statut = const Value.absent(),
            Value<String?> resolutionJson = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConflictsCompanion.insert(
            id: id,
            appareilId: appareilId,
            entiteType: entiteType,
            entiteId: entiteId,
            versionLocale: versionLocale,
            versionServeur: versionServeur,
            localJson: localJson,
            serveurJson: serveurJson,
            statut: statut,
            resolutionJson: resolutionJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncConflictsTableProcessedTableManager = ProcessedTableManager<
    _$MsnDatabase,
    $SyncConflictsTable,
    SyncConflict,
    $$SyncConflictsTableFilterComposer,
    $$SyncConflictsTableOrderingComposer,
    $$SyncConflictsTableAnnotationComposer,
    $$SyncConflictsTableCreateCompanionBuilder,
    $$SyncConflictsTableUpdateCompanionBuilder,
    (
      SyncConflict,
      BaseReferences<_$MsnDatabase, $SyncConflictsTable, SyncConflict>
    ),
    SyncConflict,
    PrefetchHooks Function()>;

class $MsnDatabaseManager {
  final _$MsnDatabase _db;
  $MsnDatabaseManager(this._db);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
  $$TarifsTableTableManager get tarifs =>
      $$TarifsTableTableManager(_db, _db.tarifs);
  $$DemandesTableTableManager get demandes =>
      $$DemandesTableTableManager(_db, _db.demandes);
  $$DemandePrestationsTableTableManager get demandePrestations =>
      $$DemandePrestationsTableTableManager(_db, _db.demandePrestations);
  $$CommandesTableTableManager get commandes =>
      $$CommandesTableTableManager(_db, _db.commandes);
  $$LignesCommandeTableTableManager get lignesCommande =>
      $$LignesCommandeTableTableManager(_db, _db.lignesCommande);
  $$ProjetsTableTableManager get projets =>
      $$ProjetsTableTableManager(_db, _db.projets);
  $$CahiersChargesTableTableManager get cahiersCharges =>
      $$CahiersChargesTableTableManager(_db, _db.cahiersCharges);
  $$TachesTableTableManager get taches =>
      $$TachesTableTableManager(_db, _db.taches);
  $$ModelesMessagesTableTableManager get modelesMessages =>
      $$ModelesMessagesTableTableManager(_db, _db.modelesMessages);
  $$EchangesTableTableManager get echanges =>
      $$EchangesTableTableManager(_db, _db.echanges);
  $$DevisTableTableTableManager get devisTable =>
      $$DevisTableTableTableManager(_db, _db.devisTable);
  $$LignesDevisTableTableTableManager get lignesDevisTable =>
      $$LignesDevisTableTableTableManager(_db, _db.lignesDevisTable);
  $$FacturesTableTableManager get factures =>
      $$FacturesTableTableManager(_db, _db.factures);
  $$LignesFactureTableTableManager get lignesFacture =>
      $$LignesFactureTableTableManager(_db, _db.lignesFacture);
  $$PaiementsTableTableManager get paiements =>
      $$PaiementsTableTableManager(_db, _db.paiements);
  $$DepensesTableTableManager get depenses =>
      $$DepensesTableTableManager(_db, _db.depenses);
  $$PiecesJointesTableTableManager get piecesJointes =>
      $$PiecesJointesTableTableManager(_db, _db.piecesJointes);
  $$JournalActionsTableTableManager get journalActions =>
      $$JournalActionsTableTableManager(_db, _db.journalActions);
  $$AppareilsTableTableManager get appareils =>
      $$AppareilsTableTableManager(_db, _db.appareils);
  $$PublicationsFacebookTableTableManager get publicationsFacebook =>
      $$PublicationsFacebookTableTableManager(_db, _db.publicationsFacebook);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
}
