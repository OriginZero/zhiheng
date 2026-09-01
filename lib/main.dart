import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/providers/core_providers.dart';
import 'core/storage/local_repository.dart';
import 'core/storage/open_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);

  final db = await openAppDatabase();
  final repo = LocalRepository(db);

  // 首次启动建档（§6：Patient 是核心模型入口）。
  await bootstrapLocalPatient(repo);

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
      ],
      child: const ZhiHengApp(),
    ),
  );
}
