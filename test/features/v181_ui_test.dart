import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/core/theme/theme.dart';
import 'package:zhiheng/features/phototherapy/phototherapy_completion_sheet.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// v1.8.1 时间线显示与「应用上一次记录」UI 测试。
///
/// 时间线：完成光疗任务 → 事件摘要显示部位/时长/照片数，无 Instance of；
/// 点击事件行 → 任务详情弹层展示完整治疗补充；
/// 历史脏数据（Instance of …）在展示层被清洗。
/// 完成弹层：同模板有上次记录时出现「应用上一次记录」，点击带入部位与时长。
void main() {
  late LocalRepository repo;

  setUp(() async {
    await initializeDateFormatting('zh_CN', null);
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

  /// 收尾：先关库再卸载树，避免 drift 流取消留下 pending timer。
  Future<void> tearDownRepo(WidgetTester tester) =>
      tester.runAsync(() => repo.close());

  Future<Task> savePhototherapyTask({
    required String id,
    DateTime? dueAt,
  }) async {
    final task = Task(
      id: id,
      patientId: localPatientId,
      diseaseId: 'd1',
      title: '308nm 光疗',
      type: TaskType.treatment,
      source: TaskSource.clinicalRule,
      dueAt: dueAt ?? DateTime.now(),
      templateId: 'vitiligo.phototherapy',
    );
    await repo.saveTask(task);
    return task;
  }

  TaskSupplement twoPartSupplement() => const TaskSupplement(
    schema: kPhototherapyExposureSchema,
    content: <String, Object?>{
      'parts': [
        {
          'partId': 'p1',
          'name': '左前臂',
          'durationSeconds': 90,
          'photoIds': ['ph1', 'ph2'],
        },
        {'partId': 'p2', 'name': '颈部', 'durationSeconds': 60, 'photoIds': []},
      ],
    },
  );

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
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
    return container;
  }

  Future<void> gotoTimeline(WidgetTester tester) async {
    await tester.tap(find.text('时间线'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();
  }

  testWidgets('时间线：光疗事件显示部位摘要，点击进入任务详情', (tester) async {
    final container = await pumpApp(tester);
    final task = await savePhototherapyTask(id: 't1');

    await container
        .read(completeTaskProvider.notifier)
        .complete(task, supplement: twoPartSupplement());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );

    await gotoTimeline(tester);

    // 摘要行：部位 + 时长 + 照片计数（概述，不展开照片）。
    expect(find.textContaining('治疗记录：左前臂'), findsOneWidget);
    expect(find.textContaining('2 张照片'), findsOneWidget);
    expect(find.textContaining('颈部'), findsOneWidget);
    expect(find.textContaining('Instance of'), findsNothing);
    expect(find.text('查看详情'), findsOneWidget);

    // 点击 → 任务详情弹层展示完整补充记录。
    await tester.tap(find.text('查看详情'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('本次治疗补充'), findsOneWidget);
    expect(find.text('左前臂'), findsOneWidget);
    expect(find.text('1 分 30 秒'), findsOneWidget);

    await tearDownRepo(tester);
  });

  testWidgets('时间线：历史脏数据 Instance of 被清洗不显示', (tester) async {
    await pumpApp(tester);
    final now = DateTime.now();
    await repo.addEvent(
      HealthEvent(
        id: 'e1',
        patientId: localPatientId,
        diseaseId: 'd1',
        type: EventType.taskCompleted,
        occurredAt: now,
        createdAt: now,
        title: '308nm 光疗',
        source: EventSource.user,
        notes:
            "治疗记录：Instance of 'PhototherapyExposurePart'.name 1 分 30 秒",
        taskId: 'gone-task',
      ),
    );
    await repo.addEvent(
      HealthEvent(
        id: 'e2',
        patientId: localPatientId,
        diseaseId: 'd1',
        type: EventType.taskCompleted,
        occurredAt: now,
        createdAt: now,
        title: '308nm 光疗（全脏）',
        source: EventSource.user,
        notes: "治疗记录：Instance of 'PhototherapyExposurePart'",
        taskId: 'gone-task-2',
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );

    await gotoTimeline(tester);

    expect(find.textContaining('Instance of'), findsNothing);
    // 部分脏 → 保留可用信息。
    expect(find.textContaining('1 分 30 秒'), findsOneWidget);
    // 全脏 → 整条备注不显示（只剩标题与时间）。
    expect(find.text('308nm 光疗（全脏）'), findsOneWidget);

    // 失败模式：关联任务已删除的事件 → 详情入口静默无操作，不崩溃。
    await tester.tap(find.text('308nm 光疗（全脏）'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('本次治疗补充'), findsNothing);

    await tearDownRepo(tester);
  });

  testWidgets('完成弹层：应用上一次记录带入部位与时长', (tester) async {
    final container = await pumpApp(tester);
    // 上一次已完成的光疗（带补充）。
    final last = await savePhototherapyTask(
      id: 't-old',
      dueAt: DateTime.now().subtract(const Duration(days: 3)),
    );
    await container.read(completeTaskProvider.notifier).complete(
      last,
      supplement: twoPartSupplement(),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );

    // 本次新任务打开记录弹层。
    final task = await savePhototherapyTask(id: 't-new');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => PhototherapyCompletionSheet.show(
                    context,
                    task: task,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // 按钮出现并带摘要。
    expect(find.textContaining('应用上一次记录'), findsOneWidget);
    expect(
      find.textContaining('应用上一次记录（').first,
      findsOneWidget,
    );

    await tester.tap(find.textContaining('应用上一次记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 两个部位草稿生成，名称与时长带入；照片不复用。
    expect(find.text('左前臂'), findsOneWidget);
    expect(find.text('颈部'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // 分钟位
    expect(find.text('30'), findsOneWidget); // 秒位
    expect(find.text('拍/选该部位照片'), findsNWidgets(2));

    await tearDownRepo(tester);
  });

  testWidgets('完成弹层：已有输入时应用上一次先确认，取消不覆盖', (tester) async {
    final container = await pumpApp(tester);
    final last = await savePhototherapyTask(
      id: 't-old2',
      dueAt: DateTime.now().subtract(const Duration(days: 3)),
    );
    await container.read(completeTaskProvider.notifier).complete(
      last,
      supplement: twoPartSupplement(),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );

    final task = await savePhototherapyTask(id: 't-mine');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () =>
                      PhototherapyCompletionSheet.show(context, task: task),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    // 用户先手填一个部位名，制造「已有输入」。
    await tester.enterText(find.widgetWithText(TextField, '部位名称'), '肚皮');
    await tester.pump();

    await tester.tap(find.textContaining('应用上一次记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 弹出替换确认，而不是直接覆盖。
    expect(find.textContaining('将用上一次治疗的部位与时长替换'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('替换'), findsOneWidget);

    // 取消 → 保留用户输入，未带入上一次记录。
    await tester.tap(find.text('取消'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('肚皮'), findsOneWidget);
    expect(find.text('左前臂'), findsNothing);
    expect(find.text('颈部'), findsNothing);

    await tearDownRepo(tester);
  });

  testWidgets('完成弹层：确认替换后覆盖已有输入', (tester) async {
    final container = await pumpApp(tester);
    final last = await savePhototherapyTask(
      id: 't-old3',
      dueAt: DateTime.now().subtract(const Duration(days: 3)),
    );
    await container.read(completeTaskProvider.notifier).complete(
      last,
      supplement: twoPartSupplement(),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );

    final task = await savePhototherapyTask(id: 't-mine2');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () =>
                      PhototherapyCompletionSheet.show(context, task: task),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, '部位名称'), '肚皮');
    await tester.pump();
    await tester.tap(find.textContaining('应用上一次记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('将用上一次治疗的部位与时长替换'), findsOneWidget);

    // 确认替换 → 覆盖为用户输入消失，带入上一次两个部位。
    await tester.tap(find.text('替换'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('肚皮'), findsNothing);
    expect(find.text('左前臂'), findsOneWidget);
    expect(find.text('颈部'), findsOneWidget);

    await tearDownRepo(tester);
  });

  testWidgets('完成弹层：无历史记录时不显示应用按钮', (tester) async {
    final container = await pumpApp(tester);
    final task = await savePhototherapyTask(id: 't-first');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => PhototherapyCompletionSheet.show(
                    context,
                    task: task,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();

    expect(find.textContaining('应用上一次记录'), findsNothing);
    expect(find.text('记录本次光疗'), findsOneWidget);

    await tearDownRepo(tester);
  });

  // —— v1.8.1 输入框对比度：真实表单像素级回归 ——
  //
  // 渲染真实的 PhototherapyCompletionSheet（亮/暗两套主题），对「分」输入框
  // 内部取点采样渲染像素：亮色模式必须是浅填充面、暗色模式必须是深填充面。
  // 这是对 divider-as-fill 反色 bug（亮色 50% 实黑 / 暗色 50% 实白）的最终
  // 观测证据，而不是只断言 token 值。
  testWidgets('真实光疗表单输入框像素：亮色浅底、暗色深底（反色 bug 回归）', (tester) async {
    final container = await pumpApp(tester);
    final task = await savePhototherapyTask(id: 't-pixel');
    final boundaryKey = GlobalKey();

    Future<void> pumpForm(ThemeData theme) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: theme,
            home: RepaintBoundary(
              key: boundaryKey,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: PhototherapyCompletionSheet(task: task),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    /// 对「分」输入框右侧内缘取样（避开边框/文字/圆角）。
    Future<Color> sampleInputPixel() async {
      final rect = tester.getRect(find.widgetWithText(TextField, '分'));
      final boundary = boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = (await tester.runAsync(
        () => boundary.toImage(pixelRatio: 1),
      ))!;
      addTearDown(image.dispose);
      final bytes = (await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!
          .buffer
          .asUint8List();
      final x = (rect.right - 8).round().clamp(0, image.width - 1);
      final y = rect.center.dy.round().clamp(0, image.height - 1);
      final i = (y * image.width + x) * 4;
      return Color.fromARGB(bytes[i + 3], bytes[i], bytes[i + 1], bytes[i + 2]);
    }

    ColorTokens tokensFor(Brightness b) =>
        (b == Brightness.light ? AppTheme.light() : AppTheme.dark())
            .extension<ColorTokens>()!;
    final lightTokens = tokensFor(Brightness.light);
    final darkTokens = tokensFor(Brightness.dark);

    await pumpForm(AppTheme.light());
    final lightPixel = await sampleInputPixel();
    await pumpForm(AppTheme.dark());
    final darkPixel = await sampleInputPixel();

    // 填充面不透明：采样像素应等于 fill token（容差 4，抗锯齿/合成误差）。
    Color near(Color actual, Color expected) {
      bool close(double a, double b) => ((a - b) * 255).abs() <= 4;
      expect(
        close(actual.r, expected.r) &&
            close(actual.g, expected.g) &&
            close(actual.b, expected.b),
        isTrue,
        reason: 'actual=$actual expected≈$expected',
      );
      return actual;
    }

    near(lightPixel, lightTokens.fill);
    near(darkPixel, darkTokens.fill);

    // 反色 bug 的直接观测断言：方向必须正确（旧 bug 为亮色深底/暗色浅底）。
    expect(lightPixel.computeLuminance(), greaterThan(0.5));
    expect(darkPixel.computeLuminance(), lessThan(0.25));

    await tearDownRepo(tester);
  });
}
