import 'dart:convert';

/// 医疗照片记录（开发文档 §34）。
///
/// 治疗前后 / 患处变化照片，记录拍摄引导通过项，
/// 照片文件存应用私有目录，数据库只存路径与元数据。
/// 可关联光疗记录（[phototherapyRecordId]）或任务执行补充（[taskId]）。
class CarePhoto {
  const CarePhoto({
    required this.id,
    required this.patientId,
    required this.diseaseId,
    this.phototherapyRecordId,
    this.taskId,
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

  /// 关联的任务执行补充（可选，v8 起：勾选任务时按部位上传的照片）。
  final String? taskId;

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
    String? taskId,
    bool clearTaskId = false,
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
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      kind: kind ?? this.kind,
      filePath: filePath ?? this.filePath,
      takenAt: takenAt ?? this.takenAt,
      guidePassed: guidePassed ?? this.guidePassed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 照片拍摄时机 / 内容类别。
enum PhotoKind {
  before('治疗前'),
  after('治疗后'),
  lesion('患处'),

  /// 检查报告 / 化验单等单据照片（糖尿病复查等任务勾选完成时上传）。
  document('检查单据');

  const PhotoKind(this.labelZh);

  final String labelZh;
}

/// 拍摄引导项（§34）：key 入库，labelZh 展示。
typedef PhotoGuideItem = ({String key, String labelZh});

/// 拍摄引导 checklist（§34）：与上次同角度 / 同距离 / 光线一致 / 患处可见。
const List<PhotoGuideItem> kPhotoGuideItems = [
  (key: 'sameAngle', labelZh: '与上次相同角度'),
  (key: 'sameDistance', labelZh: '与上次相同距离'),
  (key: 'consistentLighting', labelZh: '光线充足一致'),
  (key: 'lesionVisible', labelZh: '患处完整可见'),
];

/// 单据类拍摄引导 checklist：检查报告 / 化验单照片用（完整入镜、清晰、无反光）。
const List<PhotoGuideItem> kPhotoDocumentGuideItems = [
  (key: 'documentWhole', labelZh: '单据完整入镜'),
  (key: 'documentReadable', labelZh: '字迹与数据清晰'),
  (key: 'documentNoGlare', labelZh: '无反光遮挡'),
  (key: 'documentUpright', labelZh: '方向端正'),
];

/// 拍摄引导项中文文案（供全屏查看等展示场景使用）。
String photoGuideLabel(String key) {
  for (final item in kPhotoGuideItems) {
    if (item.key == key) return item.labelZh;
  }
  return key;
}
