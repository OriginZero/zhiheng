// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, PatientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    gender,
    birthDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientRow> instance, {
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
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
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
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class PatientRow extends DataClass implements Insertable<PatientRow> {
  final String id;
  final String name;
  final String gender;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PatientRow({
    required this.id,
    required this.name,
    required this.gender,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      name: Value(name),
      gender: Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PatientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
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
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PatientRow copyWith({
    String? id,
    String? name,
    String? gender,
    Value<DateTime?> birthDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PatientRow(
    id: id ?? this.id,
    name: name ?? this.name,
    gender: gender ?? this.gender,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PatientRow copyWithCompanion(PatientsCompanion data) {
    return PatientRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, gender, birthDate, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientsCompanion extends UpdateCompanion<PatientRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> gender;
  final Value<DateTime?> birthDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String name,
    required String gender,
    this.birthDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       gender = Value(gender),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PatientRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? gender,
    Expression<DateTime>? birthDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? gender,
    Value<DateTime?>? birthDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
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
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
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
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiseasesTable extends Diseases
    with TableInfo<$DiseasesTable, DiseaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiseasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosedAtMeta = const VerificationMeta(
    'diagnosedAt',
  );
  @override
  late final GeneratedColumn<DateTime> diagnosedAt = GeneratedColumn<DateTime>(
    'diagnosed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    code,
    name,
    status,
    diagnosedAt,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diseases';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiseaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('diagnosed_at')) {
      context.handle(
        _diagnosedAtMeta,
        diagnosedAt.isAcceptableOrUnknown(
          data['diagnosed_at']!,
          _diagnosedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiseaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiseaseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      diagnosedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diagnosed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $DiseasesTable createAlias(String alias) {
    return $DiseasesTable(attachedDatabase, alias);
  }
}

class DiseaseRow extends DataClass implements Insertable<DiseaseRow> {
  final String id;
  final String patientId;
  final String code;
  final String name;
  final String status;
  final DateTime? diagnosedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DiseaseRow({
    required this.id,
    required this.patientId,
    required this.code,
    required this.name,
    required this.status,
    this.diagnosedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || diagnosedAt != null) {
      map['diagnosed_at'] = Variable<DateTime>(diagnosedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiseasesCompanion toCompanion(bool nullToAbsent) {
    return DiseasesCompanion(
      id: Value(id),
      patientId: Value(patientId),
      code: Value(code),
      name: Value(name),
      status: Value(status),
      diagnosedAt: diagnosedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiseaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiseaseRow(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      diagnosedAt: serializer.fromJson<DateTime?>(json['diagnosedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'diagnosedAt': serializer.toJson<DateTime?>(diagnosedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiseaseRow copyWith({
    String? id,
    String? patientId,
    String? code,
    String? name,
    String? status,
    Value<DateTime?> diagnosedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DiseaseRow(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    code: code ?? this.code,
    name: name ?? this.name,
    status: status ?? this.status,
    diagnosedAt: diagnosedAt.present ? diagnosedAt.value : this.diagnosedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DiseaseRow copyWithCompanion(DiseasesCompanion data) {
    return DiseaseRow(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      diagnosedAt: data.diagnosedAt.present
          ? data.diagnosedAt.value
          : this.diagnosedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiseaseRow(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('diagnosedAt: $diagnosedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    code,
    name,
    status,
    diagnosedAt,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiseaseRow &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.code == this.code &&
          other.name == this.name &&
          other.status == this.status &&
          other.diagnosedAt == this.diagnosedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DiseasesCompanion extends UpdateCompanion<DiseaseRow> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> code;
  final Value<String> name;
  final Value<String> status;
  final Value<DateTime?> diagnosedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DiseasesCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.diagnosedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiseasesCompanion.insert({
    required String id,
    required String patientId,
    required String code,
    required String name,
    required String status,
    this.diagnosedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       code = Value(code),
       name = Value(name),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DiseaseRow> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? status,
    Expression<DateTime>? diagnosedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (diagnosedAt != null) 'diagnosed_at': diagnosedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiseasesCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? code,
    Value<String>? name,
    Value<String>? status,
    Value<DateTime?>? diagnosedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DiseasesCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      code: code ?? this.code,
      name: name ?? this.name,
      status: status ?? this.status,
      diagnosedAt: diagnosedAt ?? this.diagnosedAt,
      notes: notes ?? this.notes,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (diagnosedAt.present) {
      map['diagnosed_at'] = Variable<DateTime>(diagnosedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('DiseasesCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('diagnosedAt: $diagnosedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CarePlansTable extends CarePlans
    with TableInfo<$CarePlansTable, CarePlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarePlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diseaseIdMeta = const VerificationMeta(
    'diseaseId',
  );
  @override
  late final GeneratedColumn<String> diseaseId = GeneratedColumn<String>(
    'disease_id',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    diseaseId,
    title,
    description,
    status,
    startAt,
    endAt,
    templateId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarePlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('disease_id')) {
      context.handle(
        _diseaseIdMeta,
        diseaseId.isAcceptableOrUnknown(data['disease_id']!, _diseaseIdMeta),
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarePlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarePlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      diseaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disease_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      ),
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
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
  $CarePlansTable createAlias(String alias) {
    return $CarePlansTable(attachedDatabase, alias);
  }
}

class CarePlanRow extends DataClass implements Insertable<CarePlanRow> {
  final String id;
  final String patientId;
  final String? diseaseId;
  final String title;
  final String? description;
  final String status;
  final DateTime? startAt;
  final DateTime? endAt;

  /// 实例化该计划的模板 id（PlanDefinition 层，来源可追踪）。
  final String? templateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CarePlanRow({
    required this.id,
    required this.patientId,
    this.diseaseId,
    required this.title,
    this.description,
    required this.status,
    this.startAt,
    this.endAt,
    this.templateId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || diseaseId != null) {
      map['disease_id'] = Variable<String>(diseaseId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startAt != null) {
      map['start_at'] = Variable<DateTime>(startAt);
    }
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CarePlansCompanion toCompanion(bool nullToAbsent) {
    return CarePlansCompanion(
      id: Value(id),
      patientId: Value(patientId),
      diseaseId: diseaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(diseaseId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      startAt: startAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CarePlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarePlanRow(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      diseaseId: serializer.fromJson<String?>(json['diseaseId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      startAt: serializer.fromJson<DateTime?>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'diseaseId': serializer.toJson<String?>(diseaseId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'startAt': serializer.toJson<DateTime?>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'templateId': serializer.toJson<String?>(templateId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CarePlanRow copyWith({
    String? id,
    String? patientId,
    Value<String?> diseaseId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    String? status,
    Value<DateTime?> startAt = const Value.absent(),
    Value<DateTime?> endAt = const Value.absent(),
    Value<String?> templateId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CarePlanRow(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    diseaseId: diseaseId.present ? diseaseId.value : this.diseaseId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    startAt: startAt.present ? startAt.value : this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    templateId: templateId.present ? templateId.value : this.templateId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CarePlanRow copyWithCompanion(CarePlansCompanion data) {
    return CarePlanRow(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      diseaseId: data.diseaseId.present ? data.diseaseId.value : this.diseaseId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarePlanRow(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    diseaseId,
    title,
    description,
    status,
    startAt,
    endAt,
    templateId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarePlanRow &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.diseaseId == this.diseaseId &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.templateId == this.templateId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CarePlansCompanion extends UpdateCompanion<CarePlanRow> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> diseaseId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> status;
  final Value<DateTime?> startAt;
  final Value<DateTime?> endAt;
  final Value<String?> templateId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CarePlansCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.diseaseId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.templateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CarePlansCompanion.insert({
    required String id,
    required String patientId,
    this.diseaseId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String status,
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.templateId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CarePlanRow> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? diseaseId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? templateId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (diseaseId != null) 'disease_id': diseaseId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (templateId != null) 'template_id': templateId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CarePlansCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? diseaseId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? status,
    Value<DateTime?>? startAt,
    Value<DateTime?>? endAt,
    Value<String?>? templateId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CarePlansCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: diseaseId ?? this.diseaseId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      templateId: templateId ?? this.templateId,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (diseaseId.present) {
      map['disease_id'] = Variable<String>(diseaseId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
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
    return (StringBuffer('CarePlansCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diseaseIdMeta = const VerificationMeta(
    'diseaseId',
  );
  @override
  late final GeneratedColumn<String> diseaseId = GeneratedColumn<String>(
    'disease_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carePlanIdMeta = const VerificationMeta(
    'carePlanId',
  );
  @override
  late final GeneratedColumn<String> carePlanId = GeneratedColumn<String>(
    'care_plan_id',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceFrequencyMeta =
      const VerificationMeta('recurrenceFrequency');
  @override
  late final GeneratedColumn<String> recurrenceFrequency =
      GeneratedColumn<String>(
        'recurrence_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
    'recurrence_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceWeekdaysMeta =
      const VerificationMeta('recurrenceWeekdays');
  @override
  late final GeneratedColumn<String> recurrenceWeekdays =
      GeneratedColumn<String>(
        'recurrence_weekdays',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceEndAtMeta = const VerificationMeta(
    'recurrenceEndAt',
  );
  @override
  late final GeneratedColumn<DateTime> recurrenceEndAt =
      GeneratedColumn<DateTime>(
        'recurrence_end_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceAnchorMeta = const VerificationMeta(
    'recurrenceAnchor',
  );
  @override
  late final GeneratedColumn<DateTime> recurrenceAnchor =
      GeneratedColumn<DateTime>(
        'recurrence_anchor',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    diseaseId,
    carePlanId,
    title,
    description,
    type,
    source,
    priority,
    status,
    dueAt,
    completedAt,
    recurrenceFrequency,
    recurrenceInterval,
    recurrenceWeekdays,
    recurrenceEndAt,
    recurrenceAnchor,
    templateId,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('disease_id')) {
      context.handle(
        _diseaseIdMeta,
        diseaseId.isAcceptableOrUnknown(data['disease_id']!, _diseaseIdMeta),
      );
    }
    if (data.containsKey('care_plan_id')) {
      context.handle(
        _carePlanIdMeta,
        carePlanId.isAcceptableOrUnknown(
          data['care_plan_id']!,
          _carePlanIdMeta,
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_frequency')) {
      context.handle(
        _recurrenceFrequencyMeta,
        recurrenceFrequency.isAcceptableOrUnknown(
          data['recurrence_frequency']!,
          _recurrenceFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
        _recurrenceIntervalMeta,
        recurrenceInterval.isAcceptableOrUnknown(
          data['recurrence_interval']!,
          _recurrenceIntervalMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_weekdays')) {
      context.handle(
        _recurrenceWeekdaysMeta,
        recurrenceWeekdays.isAcceptableOrUnknown(
          data['recurrence_weekdays']!,
          _recurrenceWeekdaysMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_end_at')) {
      context.handle(
        _recurrenceEndAtMeta,
        recurrenceEndAt.isAcceptableOrUnknown(
          data['recurrence_end_at']!,
          _recurrenceEndAtMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_anchor')) {
      context.handle(
        _recurrenceAnchorMeta,
        recurrenceAnchor.isAcceptableOrUnknown(
          data['recurrence_anchor']!,
          _recurrenceAnchorMeta,
        ),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      diseaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disease_id'],
      ),
      carePlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}care_plan_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      recurrenceFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_frequency'],
      ),
      recurrenceInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_interval'],
      ),
      recurrenceWeekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_weekdays'],
      ),
      recurrenceEndAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_end_at'],
      ),
      recurrenceAnchor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_anchor'],
      ),
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String patientId;
  final String? diseaseId;
  final String? carePlanId;
  final String title;
  final String? description;
  final String type;
  final String source;
  final String priority;
  final String status;
  final DateTime dueAt;
  final DateTime? completedAt;

  /// none / daily / weekly（null 视为 none）。
  final String? recurrenceFrequency;

  /// 间隔：每 N 天 / 每 N 周。
  final int? recurrenceInterval;

  /// JSON 数组，元素为 DateTime.weekday（1=周一 … 7=周日），仅每周重复使用。
  final String? recurrenceWeekdays;

  /// 重复结束日期（疗程结束，§44 历史不可变由事件体现）。
  final DateTime? recurrenceEndAt;

  /// 周期链的锚点：链中第一次到期日（每 N 周的计数基准）。
  final DateTime? recurrenceAnchor;

  /// 创建该任务的模板 id（来源可追踪，§10）。
  final String? templateId;

  /// 执行备注（完成时填写，如剂量、感受；可事后补充）。
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskRow({
    required this.id,
    required this.patientId,
    this.diseaseId,
    this.carePlanId,
    required this.title,
    this.description,
    required this.type,
    required this.source,
    required this.priority,
    required this.status,
    required this.dueAt,
    this.completedAt,
    this.recurrenceFrequency,
    this.recurrenceInterval,
    this.recurrenceWeekdays,
    this.recurrenceEndAt,
    this.recurrenceAnchor,
    this.templateId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || diseaseId != null) {
      map['disease_id'] = Variable<String>(diseaseId);
    }
    if (!nullToAbsent || carePlanId != null) {
      map['care_plan_id'] = Variable<String>(carePlanId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    map['source'] = Variable<String>(source);
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || recurrenceFrequency != null) {
      map['recurrence_frequency'] = Variable<String>(recurrenceFrequency);
    }
    if (!nullToAbsent || recurrenceInterval != null) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    }
    if (!nullToAbsent || recurrenceWeekdays != null) {
      map['recurrence_weekdays'] = Variable<String>(recurrenceWeekdays);
    }
    if (!nullToAbsent || recurrenceEndAt != null) {
      map['recurrence_end_at'] = Variable<DateTime>(recurrenceEndAt);
    }
    if (!nullToAbsent || recurrenceAnchor != null) {
      map['recurrence_anchor'] = Variable<DateTime>(recurrenceAnchor);
    }
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      patientId: Value(patientId),
      diseaseId: diseaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(diseaseId),
      carePlanId: carePlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(carePlanId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      source: Value(source),
      priority: Value(priority),
      status: Value(status),
      dueAt: Value(dueAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      recurrenceFrequency: recurrenceFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceFrequency),
      recurrenceInterval: recurrenceInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceInterval),
      recurrenceWeekdays: recurrenceWeekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceWeekdays),
      recurrenceEndAt: recurrenceEndAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndAt),
      recurrenceAnchor: recurrenceAnchor == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceAnchor),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      diseaseId: serializer.fromJson<String?>(json['diseaseId']),
      carePlanId: serializer.fromJson<String?>(json['carePlanId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      source: serializer.fromJson<String>(json['source']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      recurrenceFrequency: serializer.fromJson<String?>(
        json['recurrenceFrequency'],
      ),
      recurrenceInterval: serializer.fromJson<int?>(json['recurrenceInterval']),
      recurrenceWeekdays: serializer.fromJson<String?>(
        json['recurrenceWeekdays'],
      ),
      recurrenceEndAt: serializer.fromJson<DateTime?>(json['recurrenceEndAt']),
      recurrenceAnchor: serializer.fromJson<DateTime?>(
        json['recurrenceAnchor'],
      ),
      templateId: serializer.fromJson<String?>(json['templateId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'diseaseId': serializer.toJson<String?>(diseaseId),
      'carePlanId': serializer.toJson<String?>(carePlanId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'source': serializer.toJson<String>(source),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'recurrenceFrequency': serializer.toJson<String?>(recurrenceFrequency),
      'recurrenceInterval': serializer.toJson<int?>(recurrenceInterval),
      'recurrenceWeekdays': serializer.toJson<String?>(recurrenceWeekdays),
      'recurrenceEndAt': serializer.toJson<DateTime?>(recurrenceEndAt),
      'recurrenceAnchor': serializer.toJson<DateTime?>(recurrenceAnchor),
      'templateId': serializer.toJson<String?>(templateId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TaskRow copyWith({
    String? id,
    String? patientId,
    Value<String?> diseaseId = const Value.absent(),
    Value<String?> carePlanId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    String? type,
    String? source,
    String? priority,
    String? status,
    DateTime? dueAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> recurrenceFrequency = const Value.absent(),
    Value<int?> recurrenceInterval = const Value.absent(),
    Value<String?> recurrenceWeekdays = const Value.absent(),
    Value<DateTime?> recurrenceEndAt = const Value.absent(),
    Value<DateTime?> recurrenceAnchor = const Value.absent(),
    Value<String?> templateId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskRow(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    diseaseId: diseaseId.present ? diseaseId.value : this.diseaseId,
    carePlanId: carePlanId.present ? carePlanId.value : this.carePlanId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
    source: source ?? this.source,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    dueAt: dueAt ?? this.dueAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    recurrenceFrequency: recurrenceFrequency.present
        ? recurrenceFrequency.value
        : this.recurrenceFrequency,
    recurrenceInterval: recurrenceInterval.present
        ? recurrenceInterval.value
        : this.recurrenceInterval,
    recurrenceWeekdays: recurrenceWeekdays.present
        ? recurrenceWeekdays.value
        : this.recurrenceWeekdays,
    recurrenceEndAt: recurrenceEndAt.present
        ? recurrenceEndAt.value
        : this.recurrenceEndAt,
    recurrenceAnchor: recurrenceAnchor.present
        ? recurrenceAnchor.value
        : this.recurrenceAnchor,
    templateId: templateId.present ? templateId.value : this.templateId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      diseaseId: data.diseaseId.present ? data.diseaseId.value : this.diseaseId,
      carePlanId: data.carePlanId.present
          ? data.carePlanId.value
          : this.carePlanId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      source: data.source.present ? data.source.value : this.source,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      recurrenceFrequency: data.recurrenceFrequency.present
          ? data.recurrenceFrequency.value
          : this.recurrenceFrequency,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      recurrenceWeekdays: data.recurrenceWeekdays.present
          ? data.recurrenceWeekdays.value
          : this.recurrenceWeekdays,
      recurrenceEndAt: data.recurrenceEndAt.present
          ? data.recurrenceEndAt.value
          : this.recurrenceEndAt,
      recurrenceAnchor: data.recurrenceAnchor.present
          ? data.recurrenceAnchor.value
          : this.recurrenceAnchor,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('carePlanId: $carePlanId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceWeekdays: $recurrenceWeekdays, ')
          ..write('recurrenceEndAt: $recurrenceEndAt, ')
          ..write('recurrenceAnchor: $recurrenceAnchor, ')
          ..write('templateId: $templateId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    patientId,
    diseaseId,
    carePlanId,
    title,
    description,
    type,
    source,
    priority,
    status,
    dueAt,
    completedAt,
    recurrenceFrequency,
    recurrenceInterval,
    recurrenceWeekdays,
    recurrenceEndAt,
    recurrenceAnchor,
    templateId,
    notes,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.diseaseId == this.diseaseId &&
          other.carePlanId == this.carePlanId &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.source == this.source &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.completedAt == this.completedAt &&
          other.recurrenceFrequency == this.recurrenceFrequency &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.recurrenceWeekdays == this.recurrenceWeekdays &&
          other.recurrenceEndAt == this.recurrenceEndAt &&
          other.recurrenceAnchor == this.recurrenceAnchor &&
          other.templateId == this.templateId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> diseaseId;
  final Value<String?> carePlanId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> type;
  final Value<String> source;
  final Value<String> priority;
  final Value<String> status;
  final Value<DateTime> dueAt;
  final Value<DateTime?> completedAt;
  final Value<String?> recurrenceFrequency;
  final Value<int?> recurrenceInterval;
  final Value<String?> recurrenceWeekdays;
  final Value<DateTime?> recurrenceEndAt;
  final Value<DateTime?> recurrenceAnchor;
  final Value<String?> templateId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.diseaseId = const Value.absent(),
    this.carePlanId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.recurrenceFrequency = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceWeekdays = const Value.absent(),
    this.recurrenceEndAt = const Value.absent(),
    this.recurrenceAnchor = const Value.absent(),
    this.templateId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String patientId,
    this.diseaseId = const Value.absent(),
    this.carePlanId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String type,
    required String source,
    required String priority,
    required String status,
    required DateTime dueAt,
    this.completedAt = const Value.absent(),
    this.recurrenceFrequency = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceWeekdays = const Value.absent(),
    this.recurrenceEndAt = const Value.absent(),
    this.recurrenceAnchor = const Value.absent(),
    this.templateId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       title = Value(title),
       type = Value(type),
       source = Value(source),
       priority = Value(priority),
       status = Value(status),
       dueAt = Value(dueAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? diseaseId,
    Expression<String>? carePlanId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? completedAt,
    Expression<String>? recurrenceFrequency,
    Expression<int>? recurrenceInterval,
    Expression<String>? recurrenceWeekdays,
    Expression<DateTime>? recurrenceEndAt,
    Expression<DateTime>? recurrenceAnchor,
    Expression<String>? templateId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (diseaseId != null) 'disease_id': diseaseId,
      if (carePlanId != null) 'care_plan_id': carePlanId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (dueAt != null) 'due_at': dueAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (recurrenceFrequency != null)
        'recurrence_frequency': recurrenceFrequency,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceWeekdays != null) 'recurrence_weekdays': recurrenceWeekdays,
      if (recurrenceEndAt != null) 'recurrence_end_at': recurrenceEndAt,
      if (recurrenceAnchor != null) 'recurrence_anchor': recurrenceAnchor,
      if (templateId != null) 'template_id': templateId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? diseaseId,
    Value<String?>? carePlanId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? type,
    Value<String>? source,
    Value<String>? priority,
    Value<String>? status,
    Value<DateTime>? dueAt,
    Value<DateTime?>? completedAt,
    Value<String?>? recurrenceFrequency,
    Value<int?>? recurrenceInterval,
    Value<String?>? recurrenceWeekdays,
    Value<DateTime?>? recurrenceEndAt,
    Value<DateTime?>? recurrenceAnchor,
    Value<String?>? templateId,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: diseaseId ?? this.diseaseId,
      carePlanId: carePlanId ?? this.carePlanId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      source: source ?? this.source,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceEndAt: recurrenceEndAt ?? this.recurrenceEndAt,
      recurrenceAnchor: recurrenceAnchor ?? this.recurrenceAnchor,
      templateId: templateId ?? this.templateId,
      notes: notes ?? this.notes,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (diseaseId.present) {
      map['disease_id'] = Variable<String>(diseaseId.value);
    }
    if (carePlanId.present) {
      map['care_plan_id'] = Variable<String>(carePlanId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (recurrenceFrequency.present) {
      map['recurrence_frequency'] = Variable<String>(recurrenceFrequency.value);
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (recurrenceWeekdays.present) {
      map['recurrence_weekdays'] = Variable<String>(recurrenceWeekdays.value);
    }
    if (recurrenceEndAt.present) {
      map['recurrence_end_at'] = Variable<DateTime>(recurrenceEndAt.value);
    }
    if (recurrenceAnchor.present) {
      map['recurrence_anchor'] = Variable<DateTime>(recurrenceAnchor.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('carePlanId: $carePlanId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceWeekdays: $recurrenceWeekdays, ')
          ..write('recurrenceEndAt: $recurrenceEndAt, ')
          ..write('recurrenceAnchor: $recurrenceAnchor, ')
          ..write('templateId: $templateId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    fireAt,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
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
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String taskId;
  final DateTime fireAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReminderRow({
    required this.id,
    required this.taskId,
    required this.fireAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      taskId: Value(taskId),
      fireAt: Value(fireAt),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? taskId,
    DateTime? fireAt,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReminderRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    fireAt: fireAt ?? this.fireAt,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('fireAt: $fireAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, fireAt, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.fireAt == this.fireAt &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<DateTime> fireAt;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String taskId,
    required DateTime fireAt,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       fireAt = Value(fireAt),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<DateTime>? fireAt,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (fireAt != null) 'fire_at': fireAt,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<DateTime>? fireAt,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fireAt: fireAt ?? this.fireAt,
      status: status ?? this.status,
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
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('fireAt: $fireAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diseaseIdMeta = const VerificationMeta(
    'diseaseId',
  );
  @override
  late final GeneratedColumn<String> diseaseId = GeneratedColumn<String>(
    'disease_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    diseaseId,
    type,
    occurredAt,
    createdAt,
    title,
    source,
    payload,
    notes,
    taskId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('disease_id')) {
      context.handle(
        _diseaseIdMeta,
        diseaseId.isAcceptableOrUnknown(data['disease_id']!, _diseaseIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      diseaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disease_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String patientId;
  final String? diseaseId;
  final String type;
  final DateTime occurredAt;
  final DateTime createdAt;
  final String? title;
  final String source;

  /// JSON 编码的 [Map<String, Object?>] 负载。
  final String payload;
  final String? notes;

  /// 关联任务 id（任务完成事件；撤销任务时用于清理）。
  final String? taskId;
  const EventRow({
    required this.id,
    required this.patientId,
    this.diseaseId,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    this.title,
    required this.source,
    required this.payload,
    this.notes,
    this.taskId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || diseaseId != null) {
      map['disease_id'] = Variable<String>(diseaseId);
    }
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['source'] = Variable<String>(source);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      diseaseId: diseaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(diseaseId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      createdAt: Value(createdAt),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      source: Value(source),
      payload: Value(payload),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      diseaseId: serializer.fromJson<String?>(json['diseaseId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String?>(json['title']),
      source: serializer.fromJson<String>(json['source']),
      payload: serializer.fromJson<String>(json['payload']),
      notes: serializer.fromJson<String?>(json['notes']),
      taskId: serializer.fromJson<String?>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'diseaseId': serializer.toJson<String?>(diseaseId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String?>(title),
      'source': serializer.toJson<String>(source),
      'payload': serializer.toJson<String>(payload),
      'notes': serializer.toJson<String?>(notes),
      'taskId': serializer.toJson<String?>(taskId),
    };
  }

  EventRow copyWith({
    String? id,
    String? patientId,
    Value<String?> diseaseId = const Value.absent(),
    String? type,
    DateTime? occurredAt,
    DateTime? createdAt,
    Value<String?> title = const Value.absent(),
    String? source,
    String? payload,
    Value<String?> notes = const Value.absent(),
    Value<String?> taskId = const Value.absent(),
  }) => EventRow(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    diseaseId: diseaseId.present ? diseaseId.value : this.diseaseId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    createdAt: createdAt ?? this.createdAt,
    title: title.present ? title.value : this.title,
    source: source ?? this.source,
    payload: payload ?? this.payload,
    notes: notes.present ? notes.value : this.notes,
    taskId: taskId.present ? taskId.value : this.taskId,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      diseaseId: data.diseaseId.present ? data.diseaseId.value : this.diseaseId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      source: data.source.present ? data.source.value : this.source,
      payload: data.payload.present ? data.payload.value : this.payload,
      notes: data.notes.present ? data.notes.value : this.notes,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('payload: $payload, ')
          ..write('notes: $notes, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    diseaseId,
    type,
    occurredAt,
    createdAt,
    title,
    source,
    payload,
    notes,
    taskId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.diseaseId == this.diseaseId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          other.source == this.source &&
          other.payload == this.payload &&
          other.notes == this.notes &&
          other.taskId == this.taskId);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> diseaseId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<DateTime> createdAt;
  final Value<String?> title;
  final Value<String> source;
  final Value<String> payload;
  final Value<String?> notes;
  final Value<String?> taskId;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.diseaseId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.source = const Value.absent(),
    this.payload = const Value.absent(),
    this.notes = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String patientId,
    this.diseaseId = const Value.absent(),
    required String type,
    required DateTime occurredAt,
    required DateTime createdAt,
    this.title = const Value.absent(),
    required String source,
    required String payload,
    this.notes = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       type = Value(type),
       occurredAt = Value(occurredAt),
       createdAt = Value(createdAt),
       source = Value(source),
       payload = Value(payload);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? diseaseId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<String>? source,
    Expression<String>? payload,
    Expression<String>? notes,
    Expression<String>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (diseaseId != null) 'disease_id': diseaseId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (payload != null) 'payload': payload,
      if (notes != null) 'notes': notes,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String?>? diseaseId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<DateTime>? createdAt,
    Value<String?>? title,
    Value<String>? source,
    Value<String>? payload,
    Value<String?>? notes,
    Value<String?>? taskId,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: diseaseId ?? this.diseaseId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      source: source ?? this.source,
      payload: payload ?? this.payload,
      notes: notes ?? this.notes,
      taskId: taskId ?? this.taskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (diseaseId.present) {
      map['disease_id'] = Variable<String>(diseaseId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('payload: $payload, ')
          ..write('notes: $notes, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, PreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  PreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class PreferenceRow extends DataClass implements Insertable<PreferenceRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const PreferenceRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory PreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PreferenceRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      PreferenceRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PreferenceRow copyWithCompanion(PreferencesCompanion data) {
    return PreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class PreferencesCompanion extends UpdateCompanion<PreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<PreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $DiseasesTable diseases = $DiseasesTable(this);
  late final $CarePlansTable carePlans = $CarePlansTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    diseases,
    carePlans,
    tasks,
    reminders,
    events,
    preferences,
  ];
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required String name,
  required String gender,
  Value<DateTime?> birthDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> gender,
  Value<DateTime?> birthDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
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

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
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
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
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

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
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

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
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

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          PatientRow,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (
            PatientRow,
            BaseReferences<_$AppDatabase, $PatientsTable, PatientRow>,
          ),
          PatientRow,
          PrefetchHooks Function()
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                name: name,
                gender: gender,
                birthDate: birthDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String gender,
                Value<DateTime?> birthDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                name: name,
                gender: gender,
                birthDate: birthDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      PatientRow,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (PatientRow, BaseReferences<_$AppDatabase, $PatientsTable, PatientRow>),
      PatientRow,
      PrefetchHooks Function()
    >;
typedef $$DiseasesTableCreateCompanionBuilder = DiseasesCompanion Function({
  required String id,
  required String patientId,
  required String code,
  required String name,
  required String status,
  Value<DateTime?> diagnosedAt,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DiseasesTableUpdateCompanionBuilder = DiseasesCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String> code,
  Value<String> name,
  Value<String> status,
  Value<DateTime?> diagnosedAt,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DiseasesTableFilterComposer
    extends Composer<_$AppDatabase, $DiseasesTable> {
  $$DiseasesTableFilterComposer({
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

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diagnosedAt => $composableBuilder(
    column: $table.diagnosedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$DiseasesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiseasesTable> {
  $$DiseasesTableOrderingComposer({
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

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diagnosedAt => $composableBuilder(
    column: $table.diagnosedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$DiseasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiseasesTable> {
  $$DiseasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get diagnosedAt => $composableBuilder(
    column: $table.diagnosedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DiseasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiseasesTable,
          DiseaseRow,
          $$DiseasesTableFilterComposer,
          $$DiseasesTableOrderingComposer,
          $$DiseasesTableAnnotationComposer,
          $$DiseasesTableCreateCompanionBuilder,
          $$DiseasesTableUpdateCompanionBuilder,
          (
            DiseaseRow,
            BaseReferences<_$AppDatabase, $DiseasesTable, DiseaseRow>,
          ),
          DiseaseRow,
          PrefetchHooks Function()
        > {
  $$DiseasesTableTableManager(_$AppDatabase db, $DiseasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiseasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiseasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiseasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> diagnosedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiseasesCompanion(
                id: id,
                patientId: patientId,
                code: code,
                name: name,
                status: status,
                diagnosedAt: diagnosedAt,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String code,
                required String name,
                required String status,
                Value<DateTime?> diagnosedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DiseasesCompanion.insert(
                id: id,
                patientId: patientId,
                code: code,
                name: name,
                status: status,
                diagnosedAt: diagnosedAt,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiseasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiseasesTable,
      DiseaseRow,
      $$DiseasesTableFilterComposer,
      $$DiseasesTableOrderingComposer,
      $$DiseasesTableAnnotationComposer,
      $$DiseasesTableCreateCompanionBuilder,
      $$DiseasesTableUpdateCompanionBuilder,
      (DiseaseRow, BaseReferences<_$AppDatabase, $DiseasesTable, DiseaseRow>),
      DiseaseRow,
      PrefetchHooks Function()
    >;
typedef $$CarePlansTableCreateCompanionBuilder = CarePlansCompanion Function({
  required String id,
  required String patientId,
  Value<String?> diseaseId,
  required String title,
  Value<String?> description,
  required String status,
  Value<DateTime?> startAt,
  Value<DateTime?> endAt,
  Value<String?> templateId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CarePlansTableUpdateCompanionBuilder = CarePlansCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String?> diseaseId,
  Value<String> title,
  Value<String?> description,
  Value<String> status,
  Value<DateTime?> startAt,
  Value<DateTime?> endAt,
  Value<String?> templateId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CarePlansTableFilterComposer
    extends Composer<_$AppDatabase, $CarePlansTable> {
  $$CarePlansTableFilterComposer({
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

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
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
}

class $$CarePlansTableOrderingComposer
    extends Composer<_$AppDatabase, $CarePlansTable> {
  $$CarePlansTableOrderingComposer({
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

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
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

class $$CarePlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarePlansTable> {
  $$CarePlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get diseaseId =>
      $composableBuilder(column: $table.diseaseId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CarePlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarePlansTable,
          CarePlanRow,
          $$CarePlansTableFilterComposer,
          $$CarePlansTableOrderingComposer,
          $$CarePlansTableAnnotationComposer,
          $$CarePlansTableCreateCompanionBuilder,
          $$CarePlansTableUpdateCompanionBuilder,
          (
            CarePlanRow,
            BaseReferences<_$AppDatabase, $CarePlansTable, CarePlanRow>,
          ),
          CarePlanRow,
          PrefetchHooks Function()
        > {
  $$CarePlansTableTableManager(_$AppDatabase db, $CarePlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarePlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarePlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarePlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> diseaseId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarePlansCompanion(
                id: id,
                patientId: patientId,
                diseaseId: diseaseId,
                title: title,
                description: description,
                status: status,
                startAt: startAt,
                endAt: endAt,
                templateId: templateId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> diseaseId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String status,
                Value<DateTime?> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CarePlansCompanion.insert(
                id: id,
                patientId: patientId,
                diseaseId: diseaseId,
                title: title,
                description: description,
                status: status,
                startAt: startAt,
                endAt: endAt,
                templateId: templateId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CarePlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarePlansTable,
      CarePlanRow,
      $$CarePlansTableFilterComposer,
      $$CarePlansTableOrderingComposer,
      $$CarePlansTableAnnotationComposer,
      $$CarePlansTableCreateCompanionBuilder,
      $$CarePlansTableUpdateCompanionBuilder,
      (
        CarePlanRow,
        BaseReferences<_$AppDatabase, $CarePlansTable, CarePlanRow>,
      ),
      CarePlanRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String patientId,
  Value<String?> diseaseId,
  Value<String?> carePlanId,
  required String title,
  Value<String?> description,
  required String type,
  required String source,
  required String priority,
  required String status,
  required DateTime dueAt,
  Value<DateTime?> completedAt,
  Value<String?> recurrenceFrequency,
  Value<int?> recurrenceInterval,
  Value<String?> recurrenceWeekdays,
  Value<DateTime?> recurrenceEndAt,
  Value<DateTime?> recurrenceAnchor,
  Value<String?> templateId,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String?> diseaseId,
  Value<String?> carePlanId,
  Value<String> title,
  Value<String?> description,
  Value<String> type,
  Value<String> source,
  Value<String> priority,
  Value<String> status,
  Value<DateTime> dueAt,
  Value<DateTime?> completedAt,
  Value<String?> recurrenceFrequency,
  Value<int?> recurrenceInterval,
  Value<String?> recurrenceWeekdays,
  Value<DateTime?> recurrenceEndAt,
  Value<DateTime?> recurrenceAnchor,
  Value<String?> templateId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carePlanId => $composableBuilder(
    column: $table.carePlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceWeekdays => $composableBuilder(
    column: $table.recurrenceWeekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurrenceEndAt => $composableBuilder(
    column: $table.recurrenceEndAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurrenceAnchor => $composableBuilder(
    column: $table.recurrenceAnchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carePlanId => $composableBuilder(
    column: $table.carePlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceWeekdays => $composableBuilder(
    column: $table.recurrenceWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurrenceEndAt => $composableBuilder(
    column: $table.recurrenceEndAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurrenceAnchor => $composableBuilder(
    column: $table.recurrenceAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get diseaseId =>
      $composableBuilder(column: $table.diseaseId, builder: (column) => column);

  GeneratedColumn<String> get carePlanId => $composableBuilder(
    column: $table.carePlanId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceWeekdays => $composableBuilder(
    column: $table.recurrenceWeekdays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurrenceEndAt => $composableBuilder(
    column: $table.recurrenceEndAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurrenceAnchor => $composableBuilder(
    column: $table.recurrenceAnchor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> diseaseId = const Value.absent(),
                Value<String?> carePlanId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> recurrenceFrequency = const Value.absent(),
                Value<int?> recurrenceInterval = const Value.absent(),
                Value<String?> recurrenceWeekdays = const Value.absent(),
                Value<DateTime?> recurrenceEndAt = const Value.absent(),
                Value<DateTime?> recurrenceAnchor = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                patientId: patientId,
                diseaseId: diseaseId,
                carePlanId: carePlanId,
                title: title,
                description: description,
                type: type,
                source: source,
                priority: priority,
                status: status,
                dueAt: dueAt,
                completedAt: completedAt,
                recurrenceFrequency: recurrenceFrequency,
                recurrenceInterval: recurrenceInterval,
                recurrenceWeekdays: recurrenceWeekdays,
                recurrenceEndAt: recurrenceEndAt,
                recurrenceAnchor: recurrenceAnchor,
                templateId: templateId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> diseaseId = const Value.absent(),
                Value<String?> carePlanId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String type,
                required String source,
                required String priority,
                required String status,
                required DateTime dueAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> recurrenceFrequency = const Value.absent(),
                Value<int?> recurrenceInterval = const Value.absent(),
                Value<String?> recurrenceWeekdays = const Value.absent(),
                Value<DateTime?> recurrenceEndAt = const Value.absent(),
                Value<DateTime?> recurrenceAnchor = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                patientId: patientId,
                diseaseId: diseaseId,
                carePlanId: carePlanId,
                title: title,
                description: description,
                type: type,
                source: source,
                priority: priority,
                status: status,
                dueAt: dueAt,
                completedAt: completedAt,
                recurrenceFrequency: recurrenceFrequency,
                recurrenceInterval: recurrenceInterval,
                recurrenceWeekdays: recurrenceWeekdays,
                recurrenceEndAt: recurrenceEndAt,
                recurrenceAnchor: recurrenceAnchor,
                templateId: templateId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String taskId,
  required DateTime fireAt,
  required String status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<DateTime> fireAt,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                taskId: taskId,
                fireAt: fireAt,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required DateTime fireAt,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                taskId: taskId,
                fireAt: fireAt,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String patientId,
  Value<String?> diseaseId,
  required String type,
  required DateTime occurredAt,
  required DateTime createdAt,
  Value<String?> title,
  required String source,
  required String payload,
  Value<String?> notes,
  Value<String?> taskId,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String?> diseaseId,
  Value<String> type,
  Value<DateTime> occurredAt,
  Value<DateTime> createdAt,
  Value<String?> title,
  Value<String> source,
  Value<String> payload,
  Value<String?> notes,
  Value<String?> taskId,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get diseaseId =>
      $composableBuilder(column: $table.diseaseId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String?> diseaseId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                patientId: patientId,
                diseaseId: diseaseId,
                type: type,
                occurredAt: occurredAt,
                createdAt: createdAt,
                title: title,
                source: source,
                payload: payload,
                notes: notes,
                taskId: taskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                Value<String?> diseaseId = const Value.absent(),
                required String type,
                required DateTime occurredAt,
                required DateTime createdAt,
                Value<String?> title = const Value.absent(),
                required String source,
                required String payload,
                Value<String?> notes = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                patientId: patientId,
                diseaseId: diseaseId,
                type: type,
                occurredAt: occurredAt,
                createdAt: createdAt,
                title: title,
                source: source,
                payload: payload,
                notes: notes,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTable,
          PreferenceRow,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            PreferenceRow,
            BaseReferences<_$AppDatabase, $PreferencesTable, PreferenceRow>,
          ),
          PreferenceRow,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTable,
      PreferenceRow,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        PreferenceRow,
        BaseReferences<_$AppDatabase, $PreferencesTable, PreferenceRow>,
      ),
      PreferenceRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$DiseasesTableTableManager get diseases =>
      $$DiseasesTableTableManager(_db, _db.diseases);
  $$CarePlansTableTableManager get carePlans =>
      $$CarePlansTableTableManager(_db, _db.carePlans);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
