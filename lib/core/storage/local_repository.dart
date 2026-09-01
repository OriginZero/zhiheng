import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../shared/domain/domain.dart';
import 'app_database.dart';

const _uuid = Uuid();

/// 生成统一 id。
String newId() => _uuid.v4();

DateTime _now() => DateTime.now();

// ---- Drift 行 -> 领域模型映射 ----

Patient patientFromRow(PatientRow d) => Patient(
  id: d.id,
  name: d.name,
  gender: Gender.values.byName(d.gender),
  birthDate: d.birthDate,
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
);

Disease diseaseFromRow(DiseaseRow d) => Disease(
  id: d.id,
  patientId: d.patientId,
  code: d.code,
  name: d.name,
  status: DiseaseStatus.values.byName(d.status),
  diagnosedAt: d.diagnosedAt,
  notes: d.notes,
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
);

CarePlan carePlanFromRow(CarePlanRow d) => CarePlan(
  id: d.id,
  patientId: d.patientId,
  diseaseId: d.diseaseId,
  title: d.title,
  description: d.description,
  status: CarePlanStatus.values.byName(d.status),
  startAt: d.startAt,
  endAt: d.endAt,
  templateId: d.templateId,
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
);

Task taskFromRow(TaskRow d) => Task(
  id: d.id,
  patientId: d.patientId,
  diseaseId: d.diseaseId,
  carePlanId: d.carePlanId,
  title: d.title,
  description: d.description,
  type: TaskType.values.byName(d.type),
  source: TaskSource.values.byName(d.source),
  priority: TaskPriority.values.byName(d.priority),
  status: TaskStatus.values.byName(d.status),
  dueAt: d.dueAt,
  completedAt: d.completedAt,
  recurrence: d.recurrenceFrequency == null
      ? TaskRecurrence.none
      : TaskRecurrence(
          frequency: RecurrenceFrequency.values.byName(d.recurrenceFrequency!),
          interval: d.recurrenceInterval ?? 1,
          weekdays: TaskRecurrence.weekdaysFromJson(d.recurrenceWeekdays),
          endAt: d.recurrenceEndAt,
          anchor: d.recurrenceAnchor,
        ),
  templateId: d.templateId,
  notes: d.notes,
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
);

Reminder reminderFromRow(ReminderRow d) => Reminder(
  id: d.id,
  taskId: d.taskId,
  fireAt: d.fireAt,
  status: ReminderStatus.values.byName(d.status),
  createdAt: d.createdAt,
  updatedAt: d.updatedAt,
);

HealthEvent eventFromRow(EventRow d) => HealthEvent(
  id: d.id,
  patientId: d.patientId,
  diseaseId: d.diseaseId,
  type: EventType.values.byName(d.type),
  occurredAt: d.occurredAt,
  createdAt: d.createdAt,
  title: d.title,
  source: EventSource.values.byName(d.source),
  payload: (jsonDecode(d.payload) as Map).cast<String, Object?>(),
  notes: d.notes,
  taskId: d.taskId,
);

/// 仓储：领域层与存储之间唯一通道（开发文档 §19）。
///
/// 上层（UseCase / Notifier）只面向领域模型，不接触 Drift 行类型。
class LocalRepository {
  LocalRepository(this._db);

  final AppDatabase _db;

  AppDatabase get database => _db;

  // ---- Patient ----

  Stream<Patient?> watchPatient(String id) {
    return (_db.select(_db.patients)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((d) => d == null ? null : patientFromRow(d));
  }

  Future<void> savePatient(Patient patient) {
    final now = _now();
    return _db
        .into(_db.patients)
        .insertOnConflictUpdate(
          PatientsCompanion.insert(
            id: patient.id,
            name: patient.name,
            gender: patient.gender.name,
            birthDate: Value(patient.birthDate),
            createdAt: patient.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }

  // ---- Disease ----

  Stream<List<Disease>> watchDiseases(String patientId) {
    return (_db.select(_db.diseases)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(diseaseFromRow).toList());
  }

  Future<void> saveDisease(Disease disease) {
    final now = _now();
    return _db
        .into(_db.diseases)
        .insertOnConflictUpdate(
          DiseasesCompanion.insert(
            id: disease.id,
            patientId: disease.patientId,
            code: disease.code,
            name: disease.name,
            status: disease.status.name,
            diagnosedAt: Value(disease.diagnosedAt),
            notes: Value(disease.notes),
            createdAt: disease.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }

  // ---- CarePlan ----

  /// 读取单个管理计划。
  Future<CarePlan?> getCarePlan(String planId) async {
    final row = await (_db.select(_db.carePlans)
          ..where((t) => t.id.equals(planId)))
        .getSingleOrNull();
    return row == null ? null : carePlanFromRow(row);
  }

  /// 更新计划状态（active / paused / completed / cancelled）。
  Future<void> updateCarePlanStatus(
    String planId,
    CarePlanStatus status,
  ) async {
    await (_db.update(_db.carePlans)..where((t) => t.id.equals(planId))).write(
      CarePlansCompanion(
        status: Value(status.name),
        updatedAt: Value(_now()),
      ),
    );
  }

  Stream<List<CarePlan>> watchCarePlans(String patientId) {
    return (_db.select(_db.carePlans)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(carePlanFromRow).toList());
  }

  Future<void> saveCarePlan(CarePlan plan) {
    final now = _now();
    return _db
        .into(_db.carePlans)
        .insertOnConflictUpdate(
          CarePlansCompanion.insert(
            id: plan.id,
            patientId: plan.patientId,
            diseaseId: Value(plan.diseaseId),
            title: plan.title,
            description: Value(plan.description),
            status: plan.status.name,
            startAt: Value(plan.startAt),
            endAt: Value(plan.endAt),
            templateId: Value(plan.templateId),
            createdAt: plan.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }

  // ---- Task ----

  /// 监听某日到期且未完成的任务（首页 Today）。
  Stream<List<Task>> watchTasksForDay(String patientId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.patientId.equals(patientId) &
                t.dueAt.isBiggerOrEqualValue(start) &
                t.dueAt.isSmallerThanValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.dueAt),
          ]))
        .watch()
        .map((rows) => rows.map(taskFromRow).toList());
  }

  Stream<List<Task>> watchUpcomingTasks(String patientId, {int days = 7}) {
    final start = _now();
    final end = start.add(Duration(days: days));
    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.patientId.equals(patientId) &
                t.status.equals(TaskStatus.pending.name) &
                t.dueAt.isBiggerOrEqualValue(start) &
                t.dueAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
        .watch()
        .map((rows) => rows.map(taskFromRow).toList());
  }

  /// 监听某疾病下所有未完成任务（疾病详情页）。
  Stream<List<Task>> watchDiseaseTasks(String patientId, String diseaseId) {
    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.patientId.equals(patientId) &
                t.diseaseId.equals(diseaseId) &
                t.status.equals(TaskStatus.pending.name),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
        .watch()
        .map((rows) => rows.map(taskFromRow).toList());
  }

  Future<void> saveTask(Task task) {
    final now = _now();
    return _db
        .into(_db.tasks)
        .insertOnConflictUpdate(
          TasksCompanion.insert(
            id: task.id,
            patientId: task.patientId,
            diseaseId: Value(task.diseaseId),
            carePlanId: Value(task.carePlanId),
            title: task.title,
            description: Value(task.description),
            type: task.type.name,
            source: task.source.name,
            priority: task.priority.name,
            status: task.status.name,
            dueAt: task.dueAt,
            completedAt: Value(task.completedAt),
            recurrenceFrequency: Value(
              task.recurrence.isRecurring
                  ? task.recurrence.frequency.name
                  : null,
            ),
            recurrenceInterval: Value(
              task.recurrence.isRecurring ? task.recurrence.interval : null,
            ),
            recurrenceWeekdays: Value(
              task.recurrence.isRecurring ? task.recurrence.weekdaysJson : null,
            ),
            recurrenceEndAt: Value(task.recurrence.endAt),
            recurrenceAnchor: Value(task.recurrence.anchor),
            templateId: Value(task.templateId),
            notes: Value(task.notes),
            createdAt: task.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }

  /// 完成任务：更新任务状态（历史不可变：不改写其他字段）。
  Future<void> completeTask(String taskId, TaskStatus status) async {
    final now = _now();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        status: Value(status.name),
        completedAt: Value(status == TaskStatus.completed ? now : null),
        updatedAt: Value(now),
      ),
    );
  }

  /// 撤销完成：任务恢复待办，清除完成时间与备注。
  Future<void> revertTaskCompletion(String taskId) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        status: Value(TaskStatus.pending.name),
        completedAt: const Value(null),
        notes: const Value(null),
        updatedAt: Value(_now()),
      ),
    );
  }

  /// 删除任务（撤销时清理派生的下一次任务）。
  Future<void> deleteTask(String taskId) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
  }

  /// 删除某任务的完成事件（撤销时清理时间线）。
  Future<void> deleteEventsByTaskId(String taskId) async {
    await (_db.delete(_db.events)..where((t) => t.taskId.equals(taskId))).go();
  }

  /// 补写任务备注。
  Future<void> updateTaskNotes(String taskId, String? notes) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        notes: Value(notes),
        updatedAt: Value(_now()),
      ),
    );
  }

  /// 查找同一计划/模板下未完成的派生任务（周期链的下一次、反应记录等）。
  Future<List<Task>> pendingSpawnedTasks({
    String? carePlanId,
    String? templateId,
  }) async {
    final query = _db.select(_db.tasks)
      ..where((t) {
        var expr = t.status.equals(TaskStatus.pending.name);
        if (carePlanId != null) {
          expr = expr & t.carePlanId.equals(carePlanId);
        }
        if (templateId != null) {
          expr = expr & t.templateId.equals(templateId);
        }
        return expr;
      });
    final rows = await query.get();
    return rows.map(taskFromRow).toList();
  }

  // ---- Reminder ----

  Future<void> saveReminder(Reminder reminder) {
    final now = _now();
    return _db
        .into(_db.reminders)
        .insertOnConflictUpdate(
          RemindersCompanion.insert(
            id: reminder.id,
            taskId: reminder.taskId,
            fireAt: reminder.fireAt,
            status: reminder.status.name,
            createdAt: reminder.createdAt ?? now,
            updatedAt: now,
          ),
        );
  }

  // ---- Event（时间线） ----

  /// 时间线查询（§9）：支持按疾病、事件类型、时间范围过滤。
  Stream<List<HealthEvent>> watchEvents(
    String patientId, {
    String? diseaseId,
    EventType? type,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) {
    final query = _db.select(_db.events)
      ..where((t) {
        var expr = t.patientId.equals(patientId);
        if (diseaseId != null) {
          expr = expr & t.diseaseId.equals(diseaseId);
        }
        if (type != null) {
          expr = expr & t.type.equals(type.name);
        }
        if (from != null) {
          expr = expr & t.occurredAt.isBiggerOrEqualValue(from);
        }
        if (to != null) {
          expr = expr & t.occurredAt.isSmallerThanValue(to);
        }
        return expr;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(eventFromRow).toList());
  }

  /// 新增事件（追加式，不改写历史）。
  Future<void> addEvent(HealthEvent event) {
    return _db
        .into(_db.events)
        .insert(
          EventsCompanion.insert(
            id: event.id,
            patientId: event.patientId,
            diseaseId: Value(event.diseaseId),
            type: event.type.name,
            occurredAt: event.occurredAt,
            createdAt: event.createdAt,
            title: Value(event.title),
            source: event.source.name,
            payload: event.payloadJson,
            notes: Value(event.notes),
            taskId: Value(event.taskId),
          ),
        );
  }

  // ---- Preferences ----

  /// 读取偏好（不存在返回 null）。
  Future<String?> readPreference(String key) async {
    final row = await (_db.select(
      _db.preferences,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// 写入偏好（按键覆盖）。
  Future<void> writePreference(String key, String value) {
    return _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion.insert(
            key: key,
            value: value,
            updatedAt: _now(),
          ),
        );
  }

  Future<void> close() => _db.close();
}
