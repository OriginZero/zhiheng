import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// 患者表（开发文档 §6）。
@DataClassName('PatientRow')
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get gender => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 疾病表。通过 code 支持疾病扩展（§6）。
@DataClassName('DiseaseRow')
class Diseases extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  DateTimeColumn get diagnosedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 管理计划表。
@DataClassName('CarePlanRow')
class CarePlans extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get diseaseId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get endAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 任务表（§10）。
@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get diseaseId => text().nullable()();
  TextColumn get carePlanId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()();
  TextColumn get source => text()();
  TextColumn get priority => text()();
  TextColumn get status => text()();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 提醒表（§11：Reminder 建立在 Task 之上）。
@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  DateTimeColumn get fireAt => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 结构化医疗事件表（§7：统一 Event；高频数据未来可加疾病专用表）。
@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  TextColumn get diseaseId => text().nullable()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get title => text().nullable()();
  TextColumn get source => text()();

  /// JSON 编码的 [Map<String, Object?>] 负载。
  TextColumn get payload => text()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 应用本地数据库。
///
/// 当前为纯本地存储（无后端）；表结构已带 createdAt/updatedAt，
/// 未来接入同步时按 §20 补充 version / syncStatus / deviceId。
@DriftDatabase(tables: [Patients, Diseases, CarePlans, Tasks, Reminders, Events])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
