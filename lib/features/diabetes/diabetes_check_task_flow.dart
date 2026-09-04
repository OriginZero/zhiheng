import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/task_providers.dart';
import '../../shared/domain/domain.dart';
import 'diabetes_check_completion_sheet.dart';

/// 勾选糖尿病检查类任务（复查 HbA1c / 年度糖尿病综合检查）时的完整流程。
///
/// 1. 弹出「记录检查结果」补充表单：上传本次检查报告 / 化验单单据照片
///    （多张，走 [PhotoCaptureSheet] 单据引导）；无照片也可直接完成；
///    用户取消 → 任务保持待办，无任何写入；
/// 2. 确认后完成：单据照片关联任务入库（care_photos.taskId），补充以
///    [kDiabetesCheckReportSchema] 保存，周期链按实际完成时刻生成下一次。
///
/// 非检查类任务不走此流程（保持原样一键完成）。
Future<void> completeDiabetesCheckTaskFlow(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  // 1. 记录本次检查结果（单据照片/备注），取消则不完成。
  final result = await DiabetesCheckCompletionSheet.show(context, task: task);
  if (result == null || !context.mounted) return;

  // 2. 完成：状态、事件、补充、链排程（provider 内完成）。
  await ref
      .read(completeTaskProvider.notifier)
      .complete(
        task,
        notes: result.notes,
        supplement: result.supplement,
        completedAt: DateTime.now(),
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.supplement == null ? '任务已完成' : '已记录检查结果并完成任务'),
    ),
  );
}

/// 判断任务是否为糖尿病检查类任务（复查 HbA1c / 年度综合检查，用于路由）。
bool isDiabetesCheckTask(Task task) =>
    task.templateId == 'diabetes.hba1c' || task.templateId == 'diabetes.annual';
