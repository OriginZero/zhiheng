import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/core/theme/theme.dart';
import 'package:zhiheng/features/home/home_page.dart';
import 'package:zhiheng/shared/domain/domain.dart';
import 'package:zhiheng/shared/widgets/event_record_sheet.dart';
import 'package:zhiheng/shared/widgets/glass/glass.dart';

/// 手动健康记录与首页「需要关注」区测试。
///
/// 场景 1-5：EventRecordSheet 表单（测量/症状/自定义、校验、疾病关联）；
/// 场景 6-7：首页逾期关注区显隐 + 「记录」入口。
void main() {
  late LocalRepository repo;

  setUpAll(() async {
    await initializeDateFormatting('zh_CN', null);
  });

  setUp(() {
    repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
  });

  /// 测试收尾：先关库再让树卸载，避免 drift 流取消留下 pending timer。
  Future<void> closeRepo(WidgetTester tester) =>
      tester.runAsync(() => repo.close());

  /// 在独立宿主里打开记录表单弹层。
  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => EventRecordSheet.show(context),
                  child: const Text('打开记录'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// 等 drift 真实异步落地（§42）。
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<List<HealthEvent>> events() => repo.watchEvents(localPatientId).first;

  /// 表单内容超过一屏，保存按钮需先滚动到可见再点。
  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('保存'));
    await tester.pump();
    await tester.tap(find.text('保存'));
  }

  /// 等 SnackBar 计时器走完，避免测试收尾时报 pending timer。
  Future<void> flushSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('记录测量事件：填写指标/数值/单位后保存并写入事件', (tester) async {
    await pumpSheet(tester);

    expect(find.text('记录健康数据'), findsOneWidget);
    // 默认测量类型：显示测量数据区。
    expect(find.text('测量数据'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, '标题'), '空腹血糖');
    await tester.enterText(
      find.widgetWithText(TextField, '指标'),
      'fasting_glucose',
    );
    await tester.enterText(find.widgetWithText(TextField, '数值'), '6.8');
    await tester.enterText(find.widgetWithText(TextField, '单位'), 'mmol/L');
    await tester.enterText(find.widgetWithText(TextField, '备注（可选）'), '晨起空腹');

    await tapSave(tester);
    await tester.pump();
    await settle(tester);

    // 保存成功：弹层关闭。
    expect(find.text('记录健康数据'), findsNothing);

    final all = await tester.runAsync(events);
    expect(all, hasLength(1));
    final event = all!.single;
    expect(event.type, EventType.measurement);
    expect(event.title, '空腹血糖');
    expect(event.source, EventSource.user);
    expect(event.payload['metric'], 'fasting_glucose');
    expect(event.payload['value'], 6.8);
    expect(event.payload['unit'], 'mmol/L');
    expect(event.notes, '晨起空腹');

    await closeRepo(tester);
  });

  /// 直接触发保存按钮回调（等价于点击，测试环境浮层下点击命中不稳定）。
  void invokeSave(WidgetTester tester) =>
      tester.widget<GlassButton>(find.byType(GlassButton)).onPressed!();

  testWidgets('标题为空时不保存并提示', (tester) async {
    await pumpSheet(tester);

    invokeSave(tester);
    await tester.pump();

    expect(find.text('请填写标题'), findsOneWidget);
    expect(find.text('记录健康数据'), findsOneWidget);

    final all = await tester.runAsync(events);
    expect(all, isEmpty);
    await flushSnackBar(tester);
    await closeRepo(tester);
  });

  testWidgets('测量类型缺字段时提示且不保存', (tester) async {
    await pumpSheet(tester);

    await tester.enterText(find.widgetWithText(TextField, '标题'), '空腹血糖');
    invokeSave(tester);
    await tester.pump();

    expect(find.text('请填写指标、数值和单位'), findsOneWidget);
    expect(find.text('记录健康数据'), findsOneWidget);

    final all = await tester.runAsync(events);
    expect(all, isEmpty);
    await flushSnackBar(tester);
    await closeRepo(tester);
  });

  testWidgets('切换事件类型：测量字段显隐，自定义类型可保存', (tester) async {
    await pumpSheet(tester);

    // 切到「症状」：测量数据区隐藏。
    await tester.tap(find.text('症状'));
    await tester.pump();
    expect(find.text('测量数据'), findsNothing);

    // 切到「记录」（custom）后保存。
    await tester.tap(find.text('记录'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, '标题'), '今天感觉不错');

    await tapSave(tester);
    await tester.pump();
    await settle(tester);

    final all = await tester.runAsync(events);
    expect(all, hasLength(1));
    expect(all!.single.type, EventType.custom);
    expect(all.single.title, '今天感觉不错');
    expect(all.single.payload, isEmpty);

    await closeRepo(tester);
  });

  testWidgets('可关联疾病并写入事件', (tester) async {
    await tester.runAsync(
      () => repo.saveDisease(
        Disease(
          id: 'd1',
          patientId: localPatientId,
          code: 'type2_diabetes',
          name: '糖尿病',
        ),
      ),
    );
    await pumpSheet(tester);
    // 等疾病列表流到达。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    // 选中疾病：直接触发 dropdown 回调，绕开菜单浮层在测试环境的命中问题。
    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    dropdown.onChanged!('d1');
    await tester.pump();

    await tester.enterText(find.widgetWithText(TextField, '标题'), '复测血糖');
    await tester.enterText(
      find.widgetWithText(TextField, '指标'),
      'fasting_glucose',
    );
    await tester.enterText(find.widgetWithText(TextField, '数值'), '7.2');
    await tester.enterText(find.widgetWithText(TextField, '单位'), 'mmol/L');

    invokeSave(tester);
    await tester.pump();
    await settle(tester);

    final all = await tester.runAsync(events);
    expect(all, hasLength(1));
    expect(all!.single.diseaseId, 'd1');

    await closeRepo(tester);
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: HomePage()),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump();
  }

  testWidgets('首页：有逾期任务时显示需要关注警告卡', (tester) async {
    await tester.runAsync(() async {
      await repo.saveTask(
        Task(
          id: 'overdue-1',
          patientId: localPatientId,
          title: '复查血压',
          type: TaskType.measurement,
          source: TaskSource.userCreated,
          dueAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
      await repo.saveTask(
        Task(
          id: 'overdue-2',
          patientId: localPatientId,
          title: '早间服药',
          type: TaskType.medication,
          source: TaskSource.userCreated,
          dueAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );
    });

    await pumpHome(tester);

    expect(find.text('有 2 个逾期未完成的任务'), findsOneWidget);
    expect(find.text('· 复查血压'), findsOneWidget);
    expect(find.text('· 早间服药'), findsOneWidget);

    await closeRepo(tester);
  });

  testWidgets('首页：无逾期任务时不显示需要关注区', (tester) async {
    await pumpHome(tester);

    expect(find.textContaining('逾期'), findsNothing);

    await closeRepo(tester);
  });

  testWidgets('首页：「记录」按钮打开手动记录表单', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('记录健康数据'), findsOneWidget);
    expect(find.text('测量数据'), findsOneWidget);

    await closeRepo(tester);
  });
}
