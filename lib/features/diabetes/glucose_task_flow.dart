import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/task_providers.dart';
import '../../shared/domain/domain.dart';
import 'glucose_completion_sheet.dart';

/// 勾选血糖任务时的完整流程（任务驱动血糖监测）。
///
/// 1. 弹出「记录本次血糖」补充表单：血糖值、测量方式、症状、运动前后；
///    血糖 <3.9 mmol/L 自动标记低血糖并提示补充症状/原因；
///    用户取消 → 任务保持待办，无任何写入；
/// 2. 确认后完成：补充入 [TaskSupplement]（schema 可扩展），周期链按
///    实际完成时刻生成下一次。
///
/// 非血糖任务不走此流程（保持原样一键完成）。
Future<void> completeGlucoseTaskFlow(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  // 1. 记录本次血糖补充（值/方式/症状/运动），取消则不完成。
  final result = await GlucoseCompletionSheet.show(context, task: task);
  if (result == null || !context.mounted) return;

  // 2. 完成：状态、事件、补充、链排程（provider 内完成）。
  await ref.read(completeTaskProvider.notifier).complete(
        task,
        notes: result.notes,
        supplement: result.supplement,
        completedAt: DateTime.now(),
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result.supplement == null ? '任务已完成' : '已记录本次血糖并完成任务',
      ),
    ),
  );
}

/// 判断任务是否为血糖任务（用于路由）。
bool isGlucoseTask(Task task) => switch (task.templateId) {
      'diabetes.glucose.fasting' ||
      'diabetes.glucose.postMeal' ||
      'diabetes.glucose.bedtime' =>
        true,
      _ => false,
    };
