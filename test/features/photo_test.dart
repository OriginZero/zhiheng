import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/core/theme/theme.dart';
import 'package:zhiheng/features/photo/photo_timeline_section.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 光疗照片记录（§34）测试。
///
/// 仓储 CRUD、guidePassed 往返、diseaseId 过滤、
/// 时间线空状态渲染。不真拍照：文件路径用假字符串。
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

  CarePhoto makePhoto({
    String id = 'p1',
    String diseaseId = 'd1',
    String? phototherapyRecordId,
    PhotoKind kind = PhotoKind.after,
    String filePath = 'test_photo.jpg',
    DateTime? takenAt,
    List<String> guidePassed = const ['sameAngle', 'sameDistance'],
  }) {
    return CarePhoto(
      id: id,
      patientId: localPatientId,
      diseaseId: diseaseId,
      phototherapyRecordId: phototherapyRecordId,
      kind: kind,
      filePath: filePath,
      takenAt: takenAt ?? DateTime(2026, 9, 1, 10),
      guidePassed: guidePassed,
    );
  }

  test('addCarePhoto 后 watchPhotos 返回，guidePassed 往返一致', () async {
    final photo = makePhoto(guidePassed: ['sameAngle', 'lesionVisible']);
    await repo.addCarePhoto(photo);

    final list = await repo.watchPhotos(localPatientId, diseaseId: 'd1').first;

    expect(list, hasLength(1));
    expect(list.single.id, 'p1');
    expect(list.single.kind, PhotoKind.after);
    expect(list.single.filePath, 'test_photo.jpg');
    expect(list.single.guidePassed, ['sameAngle', 'lesionVisible']);
    expect(
      list.single.guidePassedJson,
      jsonEncode(['sameAngle', 'lesionVisible']),
    );
  });

  test('watchPhotos 按 diseaseId 过滤', () async {
    await repo.addCarePhoto(makePhoto(id: 'p1', diseaseId: 'd1'));
    await repo.addCarePhoto(makePhoto(id: 'p2', diseaseId: 'd2'));

    final d1 = await repo.watchPhotos(localPatientId, diseaseId: 'd1').first;
    final all = await repo.watchPhotos(localPatientId).first;

    expect(d1.map((e) => e.id).toList(), ['p1']);
    expect(all.map((e) => e.id).toSet(), {'p1', 'p2'});
  });

  test('deleteCarePhoto 后列表为空', () async {
    await repo.addCarePhoto(makePhoto());
    await repo.deleteCarePhoto('p1');

    final list = await repo.watchPhotos(localPatientId, diseaseId: 'd1').first;
    expect(list, isEmpty);
  });

  testWidgets('PhotoTimelineSection 空状态渲染不崩（内存 DB 无照片）',
      (tester) async {
    // 独立内存库：避免与 setUp 共享导致重复 close；测试体内关闭以释放 drift 定时器。
    final localRepo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(localRepo)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: PhotoTimelineSection(diseaseId: 'd1')),
        ),
      ),
    );
    // 等待 drift 流首次发射（真实异步，需 runAsync）。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();

    expect(find.text('还没有照片'), findsOneWidget);
    expect(find.text('拍照'), findsOneWidget);

    await tester.runAsync(() => localRepo.close());
  });

  test('CarePhoto.guidePassedJson/guideFromJson 往返', () {
    final photo = makePhoto(guidePassed: ['sameAngle', 'consistentLighting']);
    expect(
      CarePhoto.guideFromJson(photo.guidePassedJson),
      ['sameAngle', 'consistentLighting'],
    );
    expect(CarePhoto.guideFromJson(null), isEmpty);
    expect(CarePhoto.guideFromJson(''), isEmpty);
    expect(CarePhoto.guideFromJson(photo.guidePassedJson).length, 2);
  });
}
