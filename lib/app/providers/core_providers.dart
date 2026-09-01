import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_repository.dart';
import '../../core/storage/open_database.dart';
import '../../shared/domain/domain.dart';

/// 仓储 Provider：全局唯一数据通道（§19）。
///
/// 应用启动时必须用 [buildRepositoryOverride] 覆盖；
/// 测试可注入内存数据库。
final repositoryProvider = Provider<LocalRepository>((ref) {
  throw StateError(
    'repositoryProvider 未初始化：必须通过 override 注入。',
  );
});

/// 打开磁盘数据库并构建仓储覆盖。
Future<Override> buildRepositoryOverride() async {
  final db = await openAppDatabase();
  final repo = LocalRepository(db);
  return repositoryProvider.overrideWithValue(repo);
}

/// 当前患者 id。本地单用户版：固定本地患者。
const String localPatientId = 'local-patient';

/// 当前患者（首次启动由 [bootstrapLocalPatient] 建档）。
final currentPatientProvider = StreamProvider<Patient?>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchPatient(localPatientId);
});

/// 首次启动时创建默认患者档案（名字可后续在设置页修改）。
Future<void> bootstrapLocalPatient(LocalRepository repo) async {
  final snapshot = await repo.watchPatient(localPatientId).first;
  if (snapshot != null) return;
  await repo.savePatient(
    Patient(id: localPatientId, name: '我的档案'),
  );
}
