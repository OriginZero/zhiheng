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
///
/// 周期性字段支持光疗（每周固定几回）、用药（每日多次）等周期任务（§11）。
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

  // ---- 周期性字段 ----
  /// none / daily / weekly（null 视为 none）。
  TextColumn get recurrenceFrequency => text().nullable()();

  /// 间隔：每 N 天 / 每 N 周。
  IntColumn get recurrenceInterval => integer().nullable()();

  /// JSON 数组，元素为 DateTime.weekday（1=周一 … 7=周日），仅每周重复使用。
  TextColumn get recurrenceWeekdays => text().nullable()();

  /// 重复结束日期（疗程结束，§44 历史不可变由事件体现）。
  DateTimeColumn get recurrenceEndAt => dateTime().nullable()();

  /// 周期链的锚点：链中第一次到期日（每 N 周的计数基准）。
  DateTimeColumn get recurrenceAnchor => dateTime().nullable()();

  /// 创建该任务的模板 id（来源可追踪，§10）。
  TextColumn get templateId => text().nullable()();

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

/// 应用偏好（主题模式等本地设置的键值存储）。
@DataClassName('PreferenceRow')
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 应用本地数据库。
///
/// 当前为纯本地存储（无后端）；表结构已带 createdAt/updatedAt，
/// 未来接入同步时按 §20 补充 version / syncStatus / deviceId。
@DriftDatabase(
  tables: [Patients, Diseases, CarePlans, Tasks, Reminders, Events, Preferences],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2：新增偏好表。
          if (from < 2) {
            await m.createTable(preferences);
          }
          // v3：任务周期性字段。
          if (from < 3) {
            await m.addColumn(tasks, tasks.recurrenceFrequency);
            await m.addColumn(tasks, tasks.recurrenceInterval);
            await m.addColumn(tasks, tasks.recurrenceWeekdays);
            await m.addColumn(tasks, tasks.recurrenceEndAt);
            await m.addColumn(tasks, tasks.recurrenceAnchor);
            await m.addColumn(tasks, tasks.templateId);
          }
        },
      );
}
