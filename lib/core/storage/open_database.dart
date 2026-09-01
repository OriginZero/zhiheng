import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// 打开本地数据库（应用单例，由 Provider 持有）。
///
/// 文件位于应用私有目录（§35：本地敏感数据不放到共享目录）。
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'zhiheng.sqlite'));
  return AppDatabase(NativeDatabase.createInBackground(file));
}
