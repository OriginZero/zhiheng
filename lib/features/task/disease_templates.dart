import '../../core/storage/local_repository.dart';
import '../../shared/domain/domain.dart';

/// 疾病专属任务模板（来源：医学知识库 / 医生方案）。
///
/// 模板只做「依据展示 + 参数预填」，不产生剂量等医学指令；
/// 用户可在创建弹层中调整频率、星期与疗程（§4：不硬编码为医学事实）。
class DiseaseTaskTemplate {
  const DiseaseTaskTemplate({
    required this.id,
    required this.diseaseCode,
    required this.title,
    required this.description,
    required this.type,
    required this.source,
    required this.knowledgeId,
    required this.defaultRecurrence,
    required this.defaultEndAtMonths,
  });

  final String id;

  /// 适用疾病编码（vitiligo / type2_diabetes）。
  final String diseaseCode;
  final String title;
  final String description;
  final TaskType type;
  final TaskSource source;

  /// 知识库条目（展示「依据」）。
  final String knowledgeId;

  /// 默认重复规则（可按指南预填，用户可改）。
  final TaskRecurrence defaultRecurrence;

  /// 默认疗程月数（光疗按指南 6–12 个月，取 6 为默认）。
  final int defaultEndAtMonths;

  /// 为当前患者实例化一份管理计划（PlanDefinition → CarePlan）。
  ///
  /// 计划是「意图」：承载重复规则与疗程，生成任务链；可暂停/完成。
  CarePlan buildCarePlan({
    required String patientId,
    required String diseaseId,
    required DateTime startAt,
    int? endAtMonths,
  }) {
    final endAt = endAtMonths == null
        ? null
        : DateTime(startAt.year, startAt.month + endAtMonths, startAt.day);
    return CarePlan(
      id: newId(),
      patientId: patientId,
      diseaseId: diseaseId,
      title: title,
      description: description,
      status: CarePlanStatus.active,
      startAt: startAt,
      endAt: endAt,
      templateId: id,
    );
  }

  /// 生成计划的首条任务（CarePlan → Task，链的锚点）。
  Task buildFirstTask({
    required String patientId,
    required String diseaseId,
    required String carePlanId,
    required DateTime dueAt,
  }) {
    final recurrence = TaskRecurrence(
      frequency: defaultRecurrence.frequency,
      interval: defaultRecurrence.interval,
      weekdays: defaultRecurrence.weekdays,
      endAt: null, // 由计划生命周期控制，而非任务自身
      anchor: dueAt,
    );
    return Task(
      id: newId(),
      patientId: patientId,
      diseaseId: diseaseId,
      carePlanId: carePlanId,
      title: title,
      description: description,
      type: type,
      source: source,
      priority: TaskPriority.required,
      dueAt: dueAt,
      recurrence: recurrence,
      templateId: id,
    );
  }
}

/// 已收录的疾病任务模板。
abstract final class DiseaseTemplates {
  static const List<DiseaseTaskTemplate> all = [
    // ---- 白癜风：308nm 光疗（加拿大共识 2025：初始每周 2–3 次，疗程 6–12 个月） ----
    DiseaseTaskTemplate(
      id: 'vitiligo.phototherapy',
      diseaseCode: DiseaseCodes.vitiligo,
      title: '308nm 光疗',
      description: '按医生方案执行 308nm 光疗（设备、剂量与时长以医生/'
          '设备说明书为准）。共识（2024 版）建议每周 2～3 次，疗程通常 '
          '6–12 个月；模板按每周一三五排程，两次治疗至少间隔 2 天。'
          '创建后立即从今天开始第一次治疗，之后按实际完成日期自动排程。',
      type: TaskType.treatment,
      source: TaskSource.clinicalRule,
      knowledgeId: 'vitiligo.phototherapy.cn2024',
      defaultRecurrence: TaskRecurrence(
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        weekdays: [1, 3, 5], // 周一 / 三 / 五
      ),
      defaultEndAtMonths: 6,
    ),
    // ---- 2 型糖尿病：HbA1c 定期复查（ADA 2025：未达标每 3 个月，达标稳定每 6 个月） ----
    DiseaseTaskTemplate(
      id: 'diabetes.hba1c',
      diseaseCode: DiseaseCodes.type2Diabetes,
      title: '复查 HbA1c（糖化血红蛋白）',
      description: '按 ADA 标准：血糖未达标或调整方案后至少每 3 个月检测一次；'
          '达标且稳定者可每 6 个月一次。频率以医生建议为准。',
      type: TaskType.measurement,
      source: TaskSource.clinicalRule,
      knowledgeId: 'diabetes.hba1c.monitoring',
      defaultRecurrence: TaskRecurrence(
        frequency: RecurrenceFrequency.monthly,
        interval: 3,
      ),
      defaultEndAtMonths: 0,
    ),
    // ---- 2 型糖尿病：年度综合评估（ADA 2025：每年眼底、肾功、足部等） ----
    DiseaseTaskTemplate(
      id: 'diabetes.annual',
      diseaseCode: DiseaseCodes.type2Diabetes,
      title: '年度糖尿病综合检查',
      description: '每年一次综合评估：血压、血脂、肾功能（尿白蛋白/肌酐比、'
          'eGFR）、眼底、足部检查及并发症筛查。',
      type: TaskType.revisit,
      source: TaskSource.clinicalRule,
      knowledgeId: 'diabetes.annual.evaluation',
      defaultRecurrence: TaskRecurrence(
        frequency: RecurrenceFrequency.monthly,
        interval: 12,
      ),
      defaultEndAtMonths: 0,
    ),
  ];

  /// 某疾病的模板。
  static List<DiseaseTaskTemplate> forDisease(String diseaseCode) =>
      all.where((t) => t.diseaseCode == diseaseCode).toList();
}
