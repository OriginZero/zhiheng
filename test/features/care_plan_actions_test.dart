import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 疾病详情页计划操作 UI 流程：
/// 模板卡防重（二次点击不重复创建）→ 暂停 → 恢复 → 完成 → 删除。
void main() {
  testWidgets('计划生命周期 UI 全流程', (tester) async {
    await initializeDateFormatting('zh_CN', null);

    late LocalRepository repo;
    await tester.runAsync(() async {
      repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
      await bootstrapLocalPatient(repo);
      await repo.saveDisease(Disease(
        id: 'd1',
        patientId: localPatientId,
        code: 'vitiligo',
        name: '白癜风',
      ));
    });

    Future<void> settle([int ms = 400]) async {
      await tester.runAsync(
        () => Future<void>.delayed(Duration(milliseconds: ms)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }

    Future<int> planCount() async {
      final n = await tester.runAsync(
        () => repo.watchCarePlans(localPatientId).first,
      );
      return n!.length;
    }

    Future<CarePlanStatus?> planStatus(String planId) async {
      return tester.runAsync(() => repo.getCarePlan(planId)).then(
            (p) => p?.status,
          );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: const ZhiHengApp(),
      ),
    );
    await settle(500);

    // 进入疾病详情页。
    await tester.tap(find.text('白癜风'));
    await settle();

    // 点模板卡创建计划。
    await tester.scrollUntilVisible(find.text('308nm 光疗'), 120);
    await tester.pump();
    await tester.tap(find.text('308nm 光疗').first);
    await settle(500);
    expect(await planCount(), 1, reason: '首次点击创建一份计划');

    // 防重：再次点击同一模板卡 → 不重复创建。
    await tester.tap(find.text('308nm 光疗').first);
    await settle(500);
    expect(await planCount(), 1, reason: '同模板已有计划时二次点击不再创建');

    final plan = (await tester.runAsync(
      () => repo.watchCarePlans(localPatientId).first,
    ))!.single;
    expect(plan.status, CarePlanStatus.active);

    // 暂停计划。
    await tester.scrollUntilVisible(find.text('暂停'), 120);
    await tester.pump();
    await tester.tap(find.text('暂停'));
    await settle();
    expect(await planStatus(plan.id), CarePlanStatus.paused);

    // 恢复计划（暂停态出现「恢复计划」按钮）。
    await tester.scrollUntilVisible(find.text('恢复计划'), 120);
    await tester.pump();
    await tester.tap(find.text('恢复计划'));
    await settle();
    expect(await planStatus(plan.id), CarePlanStatus.active);

    // 完成计划（带确认对话框）。
    await tester.scrollUntilVisible(find.text('完成计划'), 120);
    await tester.pump();
    await tester.tap(find.text('完成计划'));
    await settle(300);
    expect(find.widgetWithText(FilledButton, '完成'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '完成'));
    await settle();
    expect(await planStatus(plan.id), CarePlanStatus.completed);

    // 删除计划（终态计划仅剩删除；对话框确认）。
    await tester.scrollUntilVisible(find.text('删除计划'), 120);
    await tester.pump();
    await tester.tap(find.text('删除计划'));
    await settle(300);
    expect(find.textContaining('不可恢复'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await settle(500);
    expect(await planCount(), 0, reason: '删除后计划清零');

    await tester.runAsync(() => repo.close());
  });
}
