import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/task_providers.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/task_sheet.dart';
import 'phototherapy_completion_sheet.dart';

/// 勾选 308nm 光疗任务时的完整流程（开发文档 §10）。
///
/// 1. 任务计划日不是今天（提前完成/补做）→ 先提示用户：后续光疗任务将
///    按**实际治疗日期**重新排程（保持每周 2～3 次的模板节奏，两次治疗
///    至少间隔 2 天），确认后继续；
/// 2. 弹出「记录本次光疗」补充表单：按部位记录照射时长（分/秒）与照片；
///    用户取消 → 任务保持待办，无任何写入；
/// 3. 确认后完成：补充入 [TaskSupplement]（schema 可扩展），周期链按
///    实际完成时刻生成下一次，24h 反应记录任务也按实际时刻生成。
///
/// 非光疗任务不走此流程（保持原样一键完成）。
Future<void> completePhototherapyTaskFlow(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  final now = DateTime.now();
  final due = task.dueAt;
  final isToday = due.year == now.year &&
      due.month == now.month &&
      due.day == now.day;

  // 1. 非计划日勾选提示（提前完成 / 逾期补做）。
  if (!isToday) {
    final dateLabel = due.isAfter(now) ? '将于' : '原计划';
    final ok = await showConfirmDialog(
      context,
      title: '不是今天的任务',
      message: '本任务$dateLabel ${DateFormat('M月d日 HH:mm').format(due)} 执行，'
          '今天勾选属于提前完成或补做。\n\n'
          '继续勾选将按今天的实际治疗日期重新排程后续光疗任务，'
          '保持每周 2～3 次的节奏（两次治疗之间至少间隔 2 天），'
          '避免治疗过于密集。',
      confirmLabel: '仍然勾选',
    );
    if (ok != true || !context.mounted) return;
  }

  // 2. 记录本次治疗补充（部位/时长/照片），取消则不完成。
  final result = await PhototherapyCompletionSheet.show(context, task: task);
  if (result == null || !context.mounted) return;

  // 3. 完成：状态、事件、补充、链排程（provider 内完成）。
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
        result.supplement == null ? '任务已完成' : '已记录本次光疗并完成任务',
      ),
    ),
  );
}
