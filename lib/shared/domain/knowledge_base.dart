/// 医学知识库条目（开发文档 §13）。
///
/// 每条知识必须记录来源（指南 / 专家共识），禁止无依据的医学规则。
/// 条目仅用于「展示依据 + 预填模板」，不构成处方或剂量指令。
class KnowledgeEntry {
  const KnowledgeEntry({
    required this.id,
    required this.source,
    required this.title,
    required this.organization,
    required this.publicationDate,
    required this.disease,
    required this.recommendation,
    required this.reference,
  });

  final String id;

  /// 来源类型：guideline（指南）/ consensus（专家共识）。
  final String source;
  final String title;
  final String organization;
  final String publicationDate;

  /// 疾病编码（vitiligo / type2_diabetes）。
  final String disease;

  /// 推荐内容摘要（面向患者的中文转述，保持原意）。
  final String recommendation;

  /// 文献引用（DOI / PMID / PMC）。
  final String reference;
}

/// 已收录的循证条目。
///
/// 新增条目时：必须先在指南 / 共识原文中核实，再补充到此处，
/// 并写明 reference（PMID/DOI/PMC 编号）。
abstract final class KnowledgeBase {
  static const List<KnowledgeEntry> entries = [
    KnowledgeEntry(
      id: 'vitiligo.phototherapy.frequency',
      source: 'consensus',
      title: '加拿大白癜风管理共识（2025）——光疗建议',
      organization: 'Canadian Dermatology Association 等',
      publicationDate: '2025-06',
      disease: 'vitiligo',
      recommendation: '光疗（NB-UVB / 308nm 准分子激光）初始建议每周 2–3 次，'
          '直到充分复色；整个疗程通常需要 6–12 个月；'
          '达到充分复色后可改为维持治疗（每周 1–2 次）。'
          '具体剂量与频率请遵循主治医生方案。',
      reference: 'PMC12092322 / doi:10.1186/s12950-025（Canadian Consensus 2025）',
    ),
    KnowledgeEntry(
      id: 'vitiligo.phototherapy.cn2024',
      source: 'consensus',
      title: '白癜风诊疗共识（2024 版）——光疗建议',
      organization: '中国中西医结合学会皮肤性病专委会色素病学组、中华医学会皮肤性病学分会、中国医师协会皮肤科医师分会色素病专委会',
      publicationDate: '2024-12',
      disease: 'vitiligo',
      recommendation: '308nm 单色准分子光 / 准分子激光：每周治疗 2～3 次，'
          '起始剂量及下次剂量调整参考 NB-UVB 方案（无红斑或红斑持续 <24h 提高 10%～20%；'
          '红斑持续 24～72h 维持原剂量；红斑持续 >72h 或出现水疱，待症状消失后再治疗并降低 20%～50%）；'
          '连续照射超过 20 次可能出现平台期。具体剂量与频率以主治医生方案为准。',
      reference: '中华皮肤科杂志 2024;57(12) / doi:10.35541/cjd.20240260',
    ),
    KnowledgeEntry(
      id: 'diabetes.hba1c.monitoring',
      source: 'guideline',
      title: 'ADA 糖尿病诊疗标准（2025）——HbA1c 监测',
      organization: 'American Diabetes Association',
      publicationDate: '2024-12',
      disease: 'type2_diabetes',
      recommendation: '血糖控制稳定且达标者：至少每 6 个月检测一次 HbA1c；'
          '治疗方案有调整或未达标者：至少每 3 个月检测一次。',
      reference: 'Diabetes Care 2025;48(Suppl 1) Chapter 6 (ADA Standards of Care)',
    ),
    KnowledgeEntry(
      id: 'diabetes.annual.evaluation',
      source: 'guideline',
      title: 'ADA 糖尿病诊疗标准（2025）——年度综合评估',
      organization: 'American Diabetes Association',
      publicationDate: '2024-12',
      disease: 'type2_diabetes',
      recommendation: '每年进行一次综合医学评估：血压、血脂、'
          '肾功能（尿白蛋白/肌酐比、eGFR）、眼底、足部检查等，'
          '以及并发症筛查。',
      reference: 'Diabetes Care 2025;48(Suppl 1) Chapter 4 (ADA Standards of Care)',
    ),
    // ---- 2 型糖尿病：SMBG 监测（《中国糖尿病防治指南（2024版）》） ----
    KnowledgeEntry(
      id: 'diabetes.glucose.monitoring',
      source: 'guideline',
      title: '中国糖尿病防治指南（2024版）——血糖自我监测',
      organization: '中华医学会糖尿病学分会',
      publicationDate: '2024-12',
      disease: 'type2_diabetes',
      recommendation: 'SMBG 频率应根据患者实际病情决定：胰岛素治疗者需常规监测空腹、'
          '餐前、餐后、睡前血糖；非胰岛素治疗者按医生方案进行阶段性监测。'
          '测量时点包括空腹、餐前、餐后2小时、睡前、夜间等。'
          '出现低血糖症状或剧烈运动前后应及时监测。',
      reference: '中华糖尿病杂志 2025;17(1)（中国糖尿病防治指南 2024 版）',
    ),
    // ---- 2 型糖尿病：低血糖识别与处理（《中国糖尿病防治指南（2024版）》） ----
    KnowledgeEntry(
      id: 'diabetes.hypoglycemia',
      source: 'guideline',
      title: '中国糖尿病防治指南（2024版）——低血糖',
      organization: '中华医学会糖尿病学分会',
      publicationDate: '2024-12',
      disease: 'type2_diabetes',
      recommendation: '低血糖分级：1 级 3.0 ≤ 血糖 < 3.9 mmol/L；'
          '2 级血糖 < 3.0 mmol/L；3 级需要他人帮助的严重事件。'
          '发生低血糖后应寻找原因并及时调整治疗方案；'
          '出现未察觉低血糖、严重 3 级低血糖或不明原因 2 级低血糖，'
          '应重新评估血糖目标和治疗方案。',
      reference: '中华糖尿病杂志 2025;17(1)（中国糖尿病防治指南 2024 版）',
    ),
  ];

  /// 某疾病的所有知识条目。
  static List<KnowledgeEntry> forDisease(String diseaseCode) =>
      entries.where((e) => e.disease == diseaseCode).toList();
}
