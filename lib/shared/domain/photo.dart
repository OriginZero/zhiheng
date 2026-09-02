import 'dart:convert';

/// 医疗照片记录（开发文档 §34）。
///
/// 治疗前后 / 患处变化照片，记录拍摄引导通过项，
/// 照片文件存应用私有目录，数据库只存路径与元数据。
class CarePhoto {
  const CarePhoto({
    required this.id,
    required this.patientId,
    required this.diseaseId,
    this.phototherapyRecordId,
    required this.kind,
    required this.filePath,
    required this.takenAt,
    this.guidePassed = const [],
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String diseaseId;

  /// 关联的光疗记录（可选）。
  final String? phototherapyRecordId;

  /// 拍摄时机：治疗前 / 治疗后 / 患处。
  final PhotoKind kind;

  /// 应用私有目录下的文件路径。
  final String filePath;

  final DateTime takenAt;

  /// 已通过的拍摄引导项（§34：同角度/同距离/同光线/患处可见）。
  final List<String> guidePassed;

  final DateTime? createdAt;

  String get guidePassedJson => jsonEncode(guidePassed);

  static List<String> guideFromJson(String? json) {
    if (json == null || json.isEmpty) return const [];
    return (jsonDecode(json) as List).cast<String>();
  }

  CarePhoto copyWith({
    String? id,
    String? patientId,
    String? diseaseId,
    String? phototherapyRecordId,
    bool clearPhototherapyRecordId = false,
    PhotoKind? kind,
    String? filePath,
    DateTime? takenAt,
    List<String>? guidePassed,
    DateTime? createdAt,
  }) {
    return CarePhoto(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: diseaseId ?? this.diseaseId,
      phototherapyRecordId: clearPhototherapyRecordId
          ? null
          : (phototherapyRecordId ?? this.phototherapyRecordId),
      kind: kind ?? this.kind,
      filePath: filePath ?? this.filePath,
      takenAt: takenAt ?? this.takenAt,
      guidePassed: guidePassed ?? this.guidePassed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 照片拍摄时机。
enum PhotoKind {
  before('治疗前'),
  after('治疗后'),
  lesion('患处');

  const PhotoKind(this.labelZh);

  final String labelZh;
}
