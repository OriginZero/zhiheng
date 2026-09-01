/// 跨疾病通用枚举（开发文档 §55：代码与字段使用英文）。
library;

/// 性别。
enum Gender {
  female,
  male,
  other,
  unspecified;

  String get labelZh => switch (this) {
        Gender.female => '女',
        Gender.male => '男',
        Gender.other => '其他',
        Gender.unspecified => '未填写',
      };
}

/// 疾病状态。
enum DiseaseStatus {
  active,
  remission,
  resolved;

  String get labelZh => switch (this) {
        DiseaseStatus.active => '管理中',
        DiseaseStatus.remission => '缓解期',
        DiseaseStatus.resolved => '已痊愈',
      };
}

/// 内置疾病编码（开发文档 §5、§6：疾病模块可扩展）。
abstract final class DiseaseCodes {
  static const String vitiligo = 'vitiligo';
  static const String type2Diabetes = 'type2_diabetes';

  static String displayName(String code) => switch (code) {
        vitiligo => '白癜风',
        type2Diabetes => '2 型糖尿病',
        _ => code,
      };
}

/// 管理计划状态。
enum CarePlanStatus {
  active,
  paused,
  completed,
  cancelled;

  String get labelZh => switch (this) {
        CarePlanStatus.active => '进行中',
        CarePlanStatus.paused => '已暂停',
        CarePlanStatus.completed => '已完成',
        CarePlanStatus.cancelled => '已取消',
      };
}

/// 任务类型。
enum TaskType {
  medication,
  treatment,
  measurement,
  photo,
  exercise,
  revisit,
  record,
  custom;

  String get labelZh => switch (this) {
        TaskType.medication => '用药',
        TaskType.treatment => '治疗',
        TaskType.measurement => '测量',
        TaskType.photo => '拍照记录',
        TaskType.exercise => '运动',
        TaskType.revisit => '复诊',
        TaskType.record => '记录',
        TaskType.custom => '自定义',
      };
}

/// 任务来源（开发文档 §10：来源必须可追踪，不得全部来自 AI）。
enum TaskSource {
  doctorPlan,
  clinicalRule,
  carePlan,
  medicationSchedule,
  monitoringPlan,
  userCreated;

  String get labelZh => switch (this) {
        TaskSource.doctorPlan => '医生方案',
        TaskSource.clinicalRule => '临床规则',
        TaskSource.carePlan => '管理计划',
        TaskSource.medicationSchedule => '用药计划',
        TaskSource.monitoringPlan => '监测计划',
        TaskSource.userCreated => '自建',
      };
}

/// 任务优先级（首页「必须完成 / 建议完成」分组）。
enum TaskPriority {
  required,
  suggested;

  String get labelZh => switch (this) {
        TaskPriority.required => '必须完成',
        TaskPriority.suggested => '建议完成',
      };
}

/// 任务状态。
enum TaskStatus {
  pending,
  completed,
  skipped;
}

/// 事件类型（开发文档 §7：Event First）。
enum EventType {
  diagnosis,
  planAdjustment,
  treatment,
  medication,
  measurement,
  symptom,
  lab,
  photo,
  exercise,
  adverse,
  appointment,
  taskCompleted,
  custom;

  String get labelZh => switch (this) {
        EventType.diagnosis => '诊断',
        EventType.planAdjustment => '方案调整',
        EventType.treatment => '治疗',
        EventType.medication => '用药',
        EventType.measurement => '测量',
        EventType.symptom => '症状',
        EventType.lab => '检验',
        EventType.photo => '照片',
        EventType.exercise => '运动',
        EventType.adverse => '不良反应',
        EventType.appointment => '就诊',
        EventType.taskCompleted => '任务完成',
        EventType.custom => '记录',
      };
}

/// 提醒状态。
enum ReminderStatus {
  pending,
  fired,
  cancelled;
}
