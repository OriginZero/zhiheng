import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';

/// UI 连续性测试（用户场景级）：
///
/// 1. 设置页切换深色主题 → 立即生效并持久化；
/// 2. 首页添加任务 → 出现在今日管理；
/// 3. 首页 → 疾病页创建白癜风 → 疾病详情页为它添加任务。
void main() {
  testWidgets('主题切换与创建功能完整路径', (tester) async {
    await initializeDateFormatting('zh_CN', null);

    late LocalRepository repo;
    await tester.runAsync(() async {
      repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
      await bootstrapLocalPatient(repo);
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

    // ---- 1. 切换到深色主题 ----
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    expect(find.text('外观'), findsOneWidget);
    await tester.tap(find.text('深色'));
    await tester.pump();

    // MaterialApp 已应用深色模式。
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    // 偏好已持久化。
    await tester.runAsync(() async {
      expect(await repo.readPreference('theme_mode'), 'dark');
    });

    // ---- 2. 首页添加任务 ----
    await tester.tap(find.text('今日'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    await tester.tap(find.text('添加任务'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('任务名称'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '早晨用药');
    await tester.tap(find.text('添加'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // 任务出现在今日管理列表，来源为「自建」。
    expect(find.text('早晨用药'), findsOneWidget);
    expect(find.text('自建'), findsOneWidget);

    // ---- 3. 创建疾病 ----
    await tester.tap(find.textContaining('添加你在管理的疾病'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    expect(find.text('我的疾病'), findsOneWidget);
    await tester.tap(find.text('添加疾病'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('白癜风'));
    await tester.tap(find.text('添加'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // 疾病列表出现新疾病。
    expect(find.text('白癜风'), findsOneWidget);

    // ---- 4. 疾病详情页添加任务 ----
    await tester.tap(find.text('白癜风'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    expect(find.text('管理计划'), findsOneWidget);
    expect(find.text('待办任务'), findsOneWidget);

    // 模板区在页面上方，「添加任务」按钮可能在视口外，先滚动到可见。
    await tester.scrollUntilVisible(find.text('添加任务'), 120);
    await tester.pump();
    await tester.tap(find.text('添加任务'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), '308nm 光疗');
    await tester.tap(find.text('添加'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // 保存后流刷新重建列表，视口停留在页面底部（趋势区）。
    // 任务在「待办任务」区，向上滚动到可见后断言。
    await tester.scrollUntilVisible(find.text('待办任务'), -120);
    await tester.pump();
    await tester.scrollUntilVisible(find.text('308nm 光疗'), 120);
    await tester.pump();
    expect(find.text('308nm 光疗'), findsWidgets);

    await tester.runAsync(() => repo.close());
  });

  testWidgets('模板创建光疗计划：首次任务从今天立即开始', (tester) async {
    await initializeDateFormatting('zh_CN', null);

    late LocalRepository repo;
    await tester.runAsync(() async {
      repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
      await bootstrapLocalPatient(repo);
      await repo.saveDisease(
        Disease(
          id: 'd1',
          patientId: localPatientId,
          code: 'vitiligo',
          name: '白癜风',
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

    // 进入白癜风详情页。
    await tester.tap(find.text('白癜风'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // 点击「308nm 光疗」模板卡（可能需滚动到可见）。
    await tester.scrollUntilVisible(find.text('308nm 光疗'), 120);
    await tester.pump();
    await tester.tap(find.text('308nm 光疗'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();

    // 创建提示出现。
    expect(find.textContaining('已创建计划「308nm 光疗」'), findsOneWidget);

    // 首次任务从今天开始（出现在首页今日管理）。
    await tester.runAsync(() async {
      final now = DateTime.now();
      final todayTasks =
          await repo.watchTasksForDay(localPatientId, now).first;
      final phototherapy = todayTasks
          .where((t) => t.templateId == 'vitiligo.phototherapy')
          .toList();
      expect(phototherapy, isNotEmpty, reason: '模板创建后今天应有光疗任务');
      final due = phototherapy.first.dueAt;
      expect(
        due.year == now.year && due.month == now.month && due.day == now.day,
        isTrue,
        reason: '首次任务到期日必须是今天',
      );
      // 计划落库且关联模板。
      final plans = await repo.watchCarePlans(localPatientId).first;
      expect(plans.single.templateId, 'vitiligo.phototherapy');
    });

    await tester.runAsync(() => repo.close());
  });
}
