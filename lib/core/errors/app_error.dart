import 'package:flutter/foundation.dart';

/// 应用错误分类（开发文档 §37）。
///
/// 医疗应用不得显示裸的「Something went wrong」；
/// 每种错误都有面向用户的中文描述，技术细节仅进调试日志。
sealed class AppError implements Exception {
  const AppError(this.message, {this.cause});

  /// 面向用户的简短描述。
  final String message;

  /// 原始异常，仅用于日志，不得直接展示给用户。
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}

/// 本地存储读写失败。
class StorageError extends AppError {
  const StorageError({super.cause})
      : super('数据保存失败，请重试。若持续失败请重启应用。');
}

/// 数据格式 / 校验失败（如表单非法输入）。
class ValidationError extends AppError {
  const ValidationError(super.message);
}

/// 网络错误（未来接入后端时使用，当前预留）。
class NetworkError extends AppError {
  const NetworkError({super.cause})
      : super('发生网络问题，数据暂未同步。本地记录已保存，网络恢复后会自动同步。');
}

/// 权限错误（如通知、相机权限被拒绝）。
class PermissionError extends AppError {
  const PermissionError(super.message);
}

/// 兜底包装：把底层异常转换为带用户提示的错误。
AppError wrapError(Object error, {String? fallbackMessage}) {
  if (error is AppError) return error;
  debugPrint('Unhandled error: $error');
  return StorageError(cause: error);
}
