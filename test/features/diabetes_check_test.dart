import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/features/diabetes/diabetes_check_task_flow.dart';
import 'package:zhiheng/features/task/disease_templates.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 糖尿病检查类任务（复查 HbA1c / 年度综合检查）补充记录测试。
///
/// - isDiabetesCheckTask 路由识别（与血糖/光疗互斥）；
/// - 检查单据补充记录（diabetes.check.report.v1）的提取与时间线摘要；
/// - UI 闭环：首页勾选「年度糖尿病综合检查」→ 弹「记录年度检查结果」
///   （单据照片上传区）→ 保存并完成 → 任务完成 + 时间线事件 + 生成下一次。
void main() {
  setUp(() async {
    await initializeDateFormatting('zh_CN', null);
  });

  Task fakeTask(String? templateId) => Task(
    id: 'test',
    patientId: localPatientId,
    title: '测试',
    type: TaskType.measurement,
    source: TaskSource.clinicalRule,
    dueAt: DateTime.now(),
    templateId: templateId,
  );

  group('isDiabetesCheckTask', () {
    test('识别糖尿病检查任务模板', () {
      expect(isDiabetesCheckTask(fakeTask('diabetes.hba1c')), true);
      expect(isDiabetesCheckTask(fakeTask('diabetes.annual')), true);
    });

    test('排除非检查类任务', () {
      expect(isDiabetesCheckTask(fakeTask('vitiligo.phototherapy')), false);
      expect(isDiabetesCheckTask(fakeTask('diabetes.glucose.fasting')), false);
      expect(isDiabetesCheckTask(fakeTask('custom')), false);
      expect(isDiabetesCheckTask(fakeTask(null)), false);
    });
  });

  group('diabetes.check.report.v1 补充记录', () {
    test('photoIds 提取', () {
      const supplement = TaskSupplement(
        schema: kDiabetesCheckReportSchema,
        content: {
          'photoIds': ['ph1', 'ph2'],
        },
      );
      expect(diabetesCheckReportPhotoIds(supplement), ['ph1', 'ph2']);
      // 未知 schema / 空结构 → null。
      expect(
        diabetesCheckReportPhotoIds(
          const TaskSupplement(schema: 'unknown.schema', content: {}),
        ),
        isNull,
      );
    });

    test('时间线摘要：检查单据照片数量；空/未知 schema 无摘要', () {
      const withPhotos = TaskSupplement(
        schema: kDiabetesCheckReportSchema,
        content: {
          'photoIds': ['ph1', 'ph2'],
        },
      );
      expect(supplementSummaryZh(withPhotos), '检查单据照片 2 张');

      const empty = TaskSupplement(
        schema: kDiabetesCheckReportSchema,
        content: {'photoIds': <String>[]},
      );
      expect(supplementSummaryZh(empty), isNull);

      expect(supplementSummaryZh(null), isNull);
      expect(
        supplementSummaryZh(
          const TaskSupplement(
            schema: kGlucoseReadingSchema,
            content: {'value': 6.8},
          ),
        ),
        isNull,
      );
    });
  });

  testWidgets('UI 闭环：勾选年度综合检查 → 记录检查结果弹层 → 完成', (tester) async {
    final repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    await tester.runAsync(() async {
      await bootstrapLocalPatient(repo);
      await repo.saveDisease(
        Disease(
          id: 'd1',
          patientId: localPatientId,
          code: DiseaseCodes.type2Diabetes,
          name: '2 型糖尿病',
        ),
      );
      final template = DiseaseTemplates.all.firstWhere(
        (t) => t.id == 'diabetes.annual',
      );
      final now = DateTime.now();
      final plan = template.buildCarePlan(
        patientId: localPatientId,
        diseaseId: 'd1',
        startAt: now,
        endAtMonths: template.defaultEndAtMonths > 0
            ? template.defaultEndAtMonths
            : null,
      );
      await repo.saveCarePlan(plan);
      await repo.saveTask(
        template.buildFirstTask(
          patientId: localPatientId,
          diseaseId: 'd1',
          carePlanId: plan.id,
          dueAt: now,
        ),
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: const ZhiHengApp(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();

    // 今日管理出现「年度糖尿病综合检查」，点左侧勾选圈 → 记录弹层。
    expect(find.text('年度糖尿病综合检查'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('记录年度检查结果'), findsOneWidget);
    expect(find.text('检查报告 / 化验单照片'), findsOneWidget);
    expect(find.text('拍摄 / 选择单据照片'), findsOneWidget);

    // 无单据也允许完成：保存并完成 → 任务完成 + 事件 + 生成下一次。
    await tester.tap(find.text('保存并完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    expect(find.text('任务已完成'), findsOneWidget); // snackbar

    await tester.runAsync(() async {
      // 任务完成 + 时间线事件沉淀。
      final events = await repo
          .watchEvents(localPatientId, diseaseId: 'd1')
          .first;
      expect(events, hasLength(1));
      expect(events.single.title, '年度糖尿病综合检查');

      // 周期链自动生成下一次（12 个月后）。
      final tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
      final next = tasks.firstWhere((t) => t.templateId == 'diabetes.annual');
      expect(next.status, TaskStatus.pending);
    });

    await tester.runAsync(() => repo.close());
  });
}
