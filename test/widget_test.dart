import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';

void main() {
  testWidgets('应用启动：显示首页问候语、空任务状态与底部导航',
      (tester) async {
    await initializeDateFormatting('zh_CN', null);

    // Drift 是真实隔离异步：所有数据库交互必须在 runAsync 内（§42）。
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

    // 等首帧流数据到达。
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pump();

    // 首页：问候语 + 标题 + 空状态文案（§31、§39）。
    expect(find.textContaining('我的档案'), findsOneWidget);
    expect(find.text('今日管理'), findsOneWidget);
    expect(find.text('今天还没有任务'), findsOneWidget);

    // 玻璃导航三个入口（§22）。
    expect(find.text('今日'), findsOneWidget);
    expect(find.text('时间线'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // 切换到时间线页：先 pump 让页面入树，再给真实异步时间。
    await tester.tap(find.text('时间线'));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump();
    expect(find.text('医疗时间线'), findsOneWidget);
    expect(find.text('时间线还是空的'), findsOneWidget);

    // 切换到「我的」页：档案卡 + 医疗安全说明（§3）。
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump();
    expect(find.text('医疗安全说明'), findsOneWidget);

    await tester.runAsync(() => repo.close());
  });
}
