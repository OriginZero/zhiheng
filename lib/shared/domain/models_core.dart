import 'enums.dart';

/// 患者档案。
///
/// 一个设备当前阶段只有一个本地患者（单用户本地版），
/// 模型仍保留 id 以便未来扩展。
class Patient {
  const Patient({
    required this.id,
    required this.name,
    this.gender = Gender.unspecified,
    this.birthDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final Gender gender;
  final DateTime? birthDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int? get ageYears {
    final birth = birthDate;
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  Patient copyWith({
    String? id,
    String? name,
    Gender? gender,
    DateTime? birthDate,
    bool clearBirthDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 疾病（开发文档 §6：疾病模块可扩展，通过 [code] 区分）。
class Disease {
  const Disease({
    required this.id,
    required this.patientId,
    required this.code,
    required this.name,
    this.status = DiseaseStatus.active,
    this.diagnosedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;

  /// 疾病编码，如 `vitiligo` / `type2_diabetes`。
  final String code;
  final String name;
  final DiseaseStatus status;
  final DateTime? diagnosedAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Disease copyWith({
    String? id,
    String? patientId,
    String? code,
    String? name,
    DiseaseStatus? status,
    DateTime? diagnosedAt,
    bool clearDiagnosedAt = false,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Disease(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      code: code ?? this.code,
      name: name ?? this.name,
      status: status ?? this.status,
      diagnosedAt: clearDiagnosedAt ? null : (diagnosedAt ?? this.diagnosedAt),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 管理计划（开发文档 §6）。
///
/// 计划是任务的上游来源之一（[TaskSource.carePlan]）。
/// 历史不可变原则（§44）：计划调整应新建版本，不改写历史任务。
class CarePlan {
  const CarePlan({
    required this.id,
    required this.patientId,
    this.diseaseId,
    required this.title,
    this.description,
    this.status = CarePlanStatus.active,
    this.startAt,
    this.endAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;

  /// 关联疾病；为空表示跨疾病通用计划。
  final String? diseaseId;
  final String title;
  final String? description;
  final CarePlanStatus status;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CarePlan copyWith({
    String? id,
    String? patientId,
    String? diseaseId,
    bool clearDiseaseId = false,
    String? title,
    String? description,
    bool clearDescription = false,
    CarePlanStatus? status,
    DateTime? startAt,
    bool clearStartAt = false,
    DateTime? endAt,
    bool clearEndAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarePlan(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: clearDiseaseId ? null : (diseaseId ?? this.diseaseId),
      title: title ?? this.title,
      description:
          clearDescription ? null : (description ?? this.description),
      status: status ?? this.status,
      startAt: clearStartAt ? null : (startAt ?? this.startAt),
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
