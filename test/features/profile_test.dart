import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 患者档案完善与疾病状态管理测试。
///
/// 场景 1：savePatient 带 gender/birthDate 保存后 watchPatient 返回一致；
/// 场景 2：updateDiseaseStatus 后 watchDiseases 返回新状态；
/// 场景 3：Patient.ageYears 边界（生日今天 / 未来）。
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

  test('savePatient 保存 gender/birthDate 后 watchPatient 返回一致', () async {
    final birthDate = DateTime(1990, 5, 20);
    await repo.savePatient(
      Patient(
        id: localPatientId,
        name: '张三',
        gender: Gender.male,
        birthDate: birthDate,
      ),
    );

    final saved = await repo.watchPatient(localPatientId).first;
    expect(saved, isNotNull);
    expect(saved!.name, '张三');
    expect(saved.gender, Gender.male);
    expect(saved.birthDate, birthDate);

    // 通过 Provider 链路读取同一档案
    final fromProvider = await container.read(currentPatientProvider.future);
    expect(fromProvider?.name, '张三');
    expect(fromProvider?.gender, Gender.male);
    expect(fromProvider?.birthDate, birthDate);

    // 再次保存更新性别 / 出生日期（对应设置页二次编辑）
    final newBirthDate = DateTime(1988, 11, 3);
    await repo.savePatient(
      saved.copyWith(gender: Gender.female, birthDate: newBirthDate),
    );
    final updated = await repo.watchPatient(localPatientId).first;
    expect(updated!.name, '张三');
    expect(updated.gender, Gender.female);
    expect(updated.birthDate, newBirthDate);
  });

  test('updateDiseaseStatus 后 watchDiseases 返回新状态', () async {
    await repo.savePatient(Patient(id: localPatientId, name: '我的档案'));
    await repo.saveDisease(
      Disease(
        id: 'd1',
        patientId: localPatientId,
        code: DiseaseCodes.vitiligo,
        name: '白癜风',
        status: DiseaseStatus.active,
      ),
    );
    await repo.saveDisease(
      Disease(
        id: 'd2',
        patientId: localPatientId,
        code: DiseaseCodes.type2Diabetes,
        name: '2 型糖尿病',
        status: DiseaseStatus.active,
      ),
    );

    await repo.updateDiseaseStatus('d1', DiseaseStatus.remission);

    final diseases = await repo.watchDiseases(localPatientId).first;
    expect(diseases, hasLength(2));
    expect(
      diseases.firstWhere((d) => d.id == 'd1').status,
      DiseaseStatus.remission,
    );
    // 其他疾病状态不受影响
    expect(
      diseases.firstWhere((d) => d.id == 'd2').status,
      DiseaseStatus.active,
    );

    // 通过 Provider 链路读取同一状态
    final viaProvider = await container.read(diseasesProvider.future);
    expect(
      viaProvider.firstWhere((d) => d.id == 'd1').status,
      DiseaseStatus.remission,
    );
  });

  test('Patient.ageYears 边界：生日今天满周岁，未来生日返回 null', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 今天出生 → 0 岁（不递减）
    expect(
      Patient(id: 'p1', name: 'a', birthDate: today).ageYears,
      0,
    );

    // 10 年前的今天出生 → 恰好 10 岁（生日当天不递减）
    final tenYearsAgo = DateTime(today.year - 10, today.month, today.day);
    expect(
      Patient(id: 'p2', name: 'b', birthDate: tenYearsAgo).ageYears,
      10,
    );

    // 未来出生日期 → null
    final tomorrow = today.add(const Duration(days: 1));
    expect(
      Patient(id: 'p3', name: 'c', birthDate: tomorrow).ageYears,
      isNull,
    );

    // 今年生日未到（12 月 31 日出生）→ 递减一岁；恰好 12 月 31 日则满周岁
    final born = DateTime(today.year - 26, 12, 31);
    final isDec31 = today.month == 12 && today.day == 31;
    expect(
      Patient(id: 'p4', name: 'd', birthDate: born).ageYears,
      isDec31 ? 26 : 25,
    );
  });
}
