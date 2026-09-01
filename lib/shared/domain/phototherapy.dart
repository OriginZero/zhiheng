/// 308nm 光疗记录（开发文档 §4）。
///
/// 结构化记录治疗部位、单次剂量、红斑及不良反应。
/// 记录只做数据沉淀，不做剂量建议（剂量由医生方案决定）。
class PhototherapyRecord {
  const PhototherapyRecord({
    required this.id,
    required this.patientId,
    required this.diseaseId,
    required this.occurredAt,
    this.device,
    this.bodyPart,
    this.laterality,
    this.dose,
    this.doseUnit,
    this.erythema = false,
    this.erythemaStart,
    this.erythemaDurationHours,
    this.painLevel,
    this.itchingLevel,
    this.burningLevel,
    this.blister = false,
    this.otherReaction,
    this.doctorNotes,
    this.patientNotes,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String diseaseId;
  final DateTime occurredAt;

  /// 治疗设备（如 308nm 准分子光）。
  final String? device;

  /// 治疗部位（如 手背）。
  final String? bodyPart;

  /// 左右侧。
  final String? laterality;

  /// 单次剂量。
  final double? dose;

  /// 剂量单位（如 J/cm²）。
  final String? doseUnit;

  /// 红斑：有无 / 开始时间 / 持续时间（小时）。
  final bool erythema;
  final DateTime? erythemaStart;
  final int? erythemaDurationHours;

  /// 疼痛 / 瘙痒 / 灼热：0=无 1=轻 2=中 3=重。
  final int? painLevel;
  final int? itchingLevel;
  final int? burningLevel;

  /// 水疱与其他反应。
  final bool blister;
  final String? otherReaction;

  final String? doctorNotes;
  final String? patientNotes;
  final DateTime? createdAt;

  /// 不良反应摘要（用于列表展示）。
  String get reactionSummary {
    final parts = <String>[];
    if (erythema) parts.add('红斑');
    if (blister) parts.add('水疱');
    if ((painLevel ?? 0) > 0) parts.add('疼痛');
    if ((itchingLevel ?? 0) > 0) parts.add('瘙痒');
    if ((burningLevel ?? 0) > 0) parts.add('灼热');
    return parts.isEmpty ? '无不适' : parts.join('、');
  }

  /// 剂量展示（含单位）。
  String get doseLabel =>
      dose == null ? '未记录' : '${dose!.toStringAsFixed(2)} ${doseUnit ?? ''}'.trim();

  PhototherapyRecord copyWith({
    String? id,
    String? patientId,
    String? diseaseId,
    DateTime? occurredAt,
    String? device,
    bool clearDevice = false,
    String? bodyPart,
    bool clearBodyPart = false,
    String? laterality,
    bool clearLaterality = false,
    double? dose,
    bool clearDose = false,
    String? doseUnit,
    bool clearDoseUnit = false,
    bool? erythema,
    DateTime? erythemaStart,
    bool clearErythemaStart = false,
    int? erythemaDurationHours,
    bool clearErythemaDurationHours = false,
    int? painLevel,
    bool clearPainLevel = false,
    int? itchingLevel,
    bool clearItchingLevel = false,
    int? burningLevel,
    bool clearBurningLevel = false,
    bool? blister,
    String? otherReaction,
    bool clearOtherReaction = false,
    String? doctorNotes,
    bool clearDoctorNotes = false,
    String? patientNotes,
    bool clearPatientNotes = false,
    DateTime? createdAt,
  }) {
    return PhototherapyRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: diseaseId ?? this.diseaseId,
      occurredAt: occurredAt ?? this.occurredAt,
      device: clearDevice ? null : (device ?? this.device),
      bodyPart: clearBodyPart ? null : (bodyPart ?? this.bodyPart),
      laterality: clearLaterality ? null : (laterality ?? this.laterality),
      dose: clearDose ? null : (dose ?? this.dose),
      doseUnit: clearDoseUnit ? null : (doseUnit ?? this.doseUnit),
      erythema: erythema ?? this.erythema,
      erythemaStart:
          clearErythemaStart ? null : (erythemaStart ?? this.erythemaStart),
      erythemaDurationHours: clearErythemaDurationHours
          ? null
          : (erythemaDurationHours ?? this.erythemaDurationHours),
      painLevel: clearPainLevel ? null : (painLevel ?? this.painLevel),
      itchingLevel:
          clearItchingLevel ? null : (itchingLevel ?? this.itchingLevel),
      burningLevel:
          clearBurningLevel ? null : (burningLevel ?? this.burningLevel),
      blister: blister ?? this.blister,
      otherReaction:
          clearOtherReaction ? null : (otherReaction ?? this.otherReaction),
      doctorNotes: clearDoctorNotes ? null : (doctorNotes ?? this.doctorNotes),
      patientNotes:
          clearPatientNotes ? null : (patientNotes ?? this.patientNotes),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 身体左右侧。
enum BodyLaterality {
  none('未指定'),
  left('左侧'),
  right('右侧'),
  bilateral('双侧');

  const BodyLaterality(this.labelZh);

  final String labelZh;
}
