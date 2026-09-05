import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/core/theme/theme.dart';
import 'package:zhiheng/features/photo/photo_timeline_section.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 1×1 PNG（真实可解码，保证 FileImage 不报错）。
const tinyPngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
    'AAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

/// 照片全屏查看（§34）UI 测试。
///
/// 所有照片缩略图入口点击都应打开全屏查看页（原图 + 拍摄引导通过项）：
/// - 光疗照片时间线缩略图；
/// - 任务详情弹层（时间线事件 → 查看详情）里的执行补充照片。
/// 照片文件用临时目录里的真实 PNG，避免 FileImage 读文件失败。
void main() {
  setUp(() async {
    await initializeDateFormatting('zh_CN', null);
  });

  /// 写一个真实 PNG 到临时目录（真实 IO 必须放 runAsync），返回文件路径；
  /// 目录在测试结束时递归删除。
  Future<String> createTempPng(WidgetTester tester) async {
    late final String path;
    await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('zhiheng_photo_test');
      final file = File('${dir.path}${Platform.pathSeparator}photo.png');
      await file.writeAsBytes(base64Decode(tinyPngBase64), flush: true);
      path = file.path;
      addTearDown(() => tester.runAsync(() => dir.delete(recursive: true)));
    });
    return path;
  }

  /// 光疗照片时间线：点击缩略图 → 全屏查看（标题含时机时间 + 引导通过项）。
  testWidgets('照片时间线：点击缩略图打开全屏查看', (tester) async {
    final pngPath = await createTempPng(tester);
    final localRepo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    await localRepo.addCarePhoto(
      CarePhoto(
        id: 'ph1',
        patientId: localPatientId,
        diseaseId: 'd1',
        kind: PhotoKind.before,
        filePath: pngPath,
        takenAt: DateTime(2026, 9, 1, 10),
        guidePassed: const ['sameDistance'],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(localRepo)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: PhotoTimelineSection(diseaseId: 'd1')),
        ),
      ),
    );
    // 等待 drift 照片流首次发射（真实异步）。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byType(Image).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    // 全屏查看页：黑底 + 可缩放原图，无额外信息层。
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('拍摄引导通过项'), findsNothing);

    await tester.runAsync(() => localRepo.close());
  });

  /// 任务详情弹层（时间线 → 查看详情）：补充照片点击 → 全屏查看。
  testWidgets('任务详情：执行补充照片点击打开全屏查看', (tester) async {
    final pngPath = await createTempPng(tester);
    final repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    // watchPatient().first 走 drift 流（真实异步），必须放 runAsync 才不会挂起。
    await tester.runAsync(() => bootstrapLocalPatient(repo));
    await repo.saveDisease(
      Disease(
        id: 'd1',
        patientId: localPatientId,
        code: 'vitiligo',
        name: '白癜风',
      ),
    );

    final task = Task(
      id: 't1',
      patientId: localPatientId,
      diseaseId: 'd1',
      title: '308nm 光疗',
      type: TaskType.treatment,
      source: TaskSource.clinicalRule,
      dueAt: DateTime.now(),
      templateId: 'vitiligo.phototherapy',
    );
    await repo.saveTask(task);
    await repo.addCarePhoto(
      CarePhoto(
        id: 'ph1',
        patientId: localPatientId,
        diseaseId: 'd1',
        taskId: task.id,
        kind: PhotoKind.after,
        filePath: pngPath,
        takenAt: DateTime(2026, 9, 1, 10),
        guidePassed: const ['sameAngle', 'lesionVisible'],
      ),
    );

    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await container.read(completeTaskProvider.notifier).complete(
      task,
      supplement: const TaskSupplement(
        schema: kPhototherapyExposureSchema,
        content: <String, Object?>{
          'parts': [
            {
              'partId': 'p1',
              'name': '左前臂',
              'durationSeconds': 90,
              'photoIds': ['ph1'],
            },
          ],
        },
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ZhiHengApp(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();

    // 进入时间线 → 点「查看详情」打开任务详情弹层。
    await tester.tap(find.text('时间线'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();
    await tester.tap(find.text('查看详情'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('本次治疗补充'), findsOneWidget);
    // 等待补充照片异步加载。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    await tester.tap(find.byType(Image).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('拍摄引导通过项'), findsNothing);

    await tester.runAsync(() => repo.close());
  });
}
