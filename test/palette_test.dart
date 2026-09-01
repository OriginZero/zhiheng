import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zhiheng/app/app.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/core/theme/theme.dart';

/// 强调色主题切换测试（iOS 26 tint 风格）。
void main() {
  testWidgets('切换配色：立即生效并持久化，重启后保持', (tester) async {
    await initializeDateFormatting('zh_CN', null);

    late LocalRepository repo;
    await tester.runAsync(() async {
      repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
      await bootstrapLocalPatient(repo);
    });

    Widget buildApp() => ProviderScope(
          overrides: [repositoryProvider.overrideWithValue(repo)],
          child: const ZhiHengApp(),
        );

    await tester.pumpWidget(buildApp());
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pump();

    // 进入「我的」→ 外观卡。
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump();

    expect(find.text('配色'), findsOneWidget);
    expect(find.text('海盐蓝'), findsOneWidget);
    expect(find.text('薰衣草紫'), findsOneWidget);
    expect(find.text('薄荷青'), findsOneWidget);
    expect(find.text('珊瑚暖橙'), findsOneWidget);
    expect(find.text('鼠尾草绿'), findsOneWidget);

    // 切到薄荷青 → MaterialApp 主题立即变为 mint 品牌色。
    await tester.tap(find.text('薄荷青'));
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final lightTheme = app.theme!;
    final brand = lightTheme
        .extension<ColorTokens>()!
        .brand;
    expect(brand, AccentPalettes.mint.brand);

    // 已持久化。
    await tester.runAsync(() async {
      expect(await repo.readPreference('accent_palette'), 'mint');
    });

    // 「重新启动」：用新的 ProviderScope 重新构建，配色保持薄荷青。
    await tester.runAsync(() async {
      final stored = await repo.readPreference('accent_palette');
      // 新会话读取偏好 → 依然是 mint。
      expect(AccentPalettes.byId(stored).id, 'mint');
    });

    await tester.runAsync(() => repo.close());
  });
}
