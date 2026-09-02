import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';

import 'app/app.dart';
import 'app/providers/core_providers.dart';
import 'features/notification/notification_service.dart';
import 'features/notification/reminder_dispatcher.dart';
import 'core/storage/local_repository.dart';
import 'core/storage/open_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);

  final db = await openAppDatabase();
  final repo = LocalRepository(db);

  // 首次启动建档（§6：Patient 是核心模型入口）。
  await bootstrapLocalPatient(repo);

  // 提醒通知初始化 + 补发到期提醒（失败不阻塞启动，§11）。
  unawaited(_bootstrapReminders(repo));

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
      ],
      child: const ZhiHengApp(),
    ),
  );
}

/// 初始化通知服务并派发已到期提醒。
Future<void> _bootstrapReminders(LocalRepository repo) async {
  try {
    final service = LocalNotificationService();
    await service.init();
    await ReminderDispatcher(repo, service).dispatchDue();
  } catch (e) {
    debugPrint('提醒初始化失败（不影响使用）: $e');
  }
}
