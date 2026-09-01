import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 光疗记录测试。
///
/// 场景 1：新增光疗记录后可按患者 + 疾病读回，字段完整（红斑/疼痛/剂量）；
/// 场景 2：按 diseaseId 过滤，两个疾病的记录互不干扰；
/// 场景 3：doseLabel / reactionSummary 展示逻辑。
void main() {
  late ProviderContainer container;
  late LocalRepository repo;

  setUp(() {
    repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await repo.close();
  });

  PhototherapyRecord buildRecord({
    String id = 'p1',
    String diseaseId = 'd1',
    DateTime? occurredAt,
    double? dose = 1.5,
    String? doseUnit = 'J/cm²',
    bool erythema = false,
    int? painLevel,
    bool blister = false,
  }) {
    return PhototherapyRecord(
      id: id,
      patientId: localPatientId,
      diseaseId: diseaseId,
      occurredAt: occurredAt ?? DateTime(2026, 9, 1, 10, 30),
      device: '308nm',
      bodyPart: '手背',
      laterality: BodyLaterality.left.name,
      dose: dose,
      doseUnit: doseUnit,
      erythema: erythema,
      erythemaStart: erythema ? DateTime(2026, 9, 1, 11) : null,
      erythemaDurationHours: erythema ? 6 : null,
      painLevel: painLevel,
      itchingLevel: 0,
      burningLevel: 0,
      blister: blister,
      patientNotes: '无不适',
    );
  }

  test('新增光疗记录后可按患者+疾病读回，字段完整', () async {
    await repo.addPhototherapyRecord(buildRecord(erythema: true, painLevel: 2));

    final records = await repo
        .watchPhototherapyRecords(localPatientId, diseaseId: 'd1')
        .first;
    expect(records, hasLength(1));
    final r = records.single;
    expect(r.bodyPart, '手背');
    expect(r.laterality, BodyLaterality.left.name);
    expect(r.device, '308nm');
    expect(r.dose, 1.5);
    expect(r.doseUnit, 'J/cm²');
    expect(r.erythema, isTrue);
    expect(r.erythemaStart, DateTime(2026, 9, 1, 11));
    expect(r.erythemaDurationHours, 6);
    expect(r.painLevel, 2);
    expect(r.blister, isFalse);
    expect(r.patientNotes, '无不适');
  });

  test('光疗记录按 diseaseId 过滤，两个疾病互不干扰', () async {
    await repo.addPhototherapyRecord(buildRecord(id: 'p1', diseaseId: 'd1'));
    await repo.addPhototherapyRecord(buildRecord(id: 'p2', diseaseId: 'd2'));

    final d1 = await repo
        .watchPhototherapyRecords(localPatientId, diseaseId: 'd1')
        .first;
    final d2 = await repo
        .watchPhototherapyRecords(localPatientId, diseaseId: 'd2')
        .first;
    expect(d1.map((e) => e.id), ['p1']);
    expect(d2.map((e) => e.id), ['p2']);

    // provider 同样按 diseaseId 过滤。
    final viaProvider = await container.read(
      phototherapyRecordsProvider('d1').future,
    );
    expect(viaProvider.map((e) => e.id), ['p1']);
  });

  test('doseLabel / reactionSummary 展示逻辑', () {
    expect(buildRecord(dose: null).doseLabel, '未记录');
    expect(buildRecord(dose: 1.5, doseUnit: 'J/cm²').doseLabel, '1.50 J/cm²');

    expect(buildRecord().reactionSummary, '无不适');
    expect(buildRecord(erythema: true, blister: true).reactionSummary, '红斑、水疱');
    expect(
      buildRecord(erythema: true, blister: true, painLevel: 2).reactionSummary,
      '红斑、水疱、疼痛',
    );
    expect(buildRecord(painLevel: 3).reactionSummary, '疼痛');
  });
}
