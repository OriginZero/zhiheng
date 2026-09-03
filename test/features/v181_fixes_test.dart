import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/core/theme/theme.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// v1.8.1 三项修复回归测试。
///
/// 1. 时间线摘要不再出现「Instance of …」（'$part.name' 插值 bug）+ 历史脏数据清洗；
/// 2. 「应用上一次记录」数据源 lastSupplementedTaskForTemplate；
/// 3. 输入框填充色明暗方向正确（fill token，不再用 divider 反色）。
void main() {
  TaskSupplement supplementWith(List<PhototherapyExposurePart> parts) =>
      TaskSupplement(
        schema: kPhototherapyExposureSchema,
        content: <String, Object?>{
          'parts': [for (final p in parts) p.toJson()],
        },
      );

  group('光疗补充摘要（时间线显示）', () {
    test('摘要输出部位名与时长，绝不含 Instance of', () {
      final supplement = supplementWith(const [
        PhototherapyExposurePart(
          partId: 'p1',
          name: '左前臂',
          durationSeconds: 90,
          photoIds: ['ph1', 'ph2'],
        ),
        PhototherapyExposurePart(
          partId: 'p2',
          name: '颈部',
          durationSeconds: 60,
        ),
      ]);

      final summary = supplementSummaryZh(supplement)!;
      expect(summary, contains('左前臂'));
      expect(summary, contains('1 分 30 秒'));
      expect(summary, contains('2 张照片'));
      expect(summary, contains('颈部'));
      expect(summary, isNot(contains('Instance of')));
      expect(
        summary,
        '治疗记录：左前臂 1 分 30 秒（2 张照片）；颈部 1 分钟',
      );
    });

    test('formatDurationZh 边界：null/负数/整分/整秒/混合', () {
      expect(formatDurationZh(null), isNull);
      expect(formatDurationZh(0), '0 秒');
      expect(formatDurationZh(-5), isNull);
      expect(formatDurationZh(45), '45 秒');
      expect(formatDurationZh(60), '1 分钟');
      expect(formatDurationZh(90), '1 分 30 秒');
      expect(formatDurationZh(600), '10 分钟');
    });

    test('无时长部位只输出名称；空补充返回 null', () {
      expect(
        supplementSummaryZh(
          supplementWith(const [
            PhototherapyExposurePart(partId: 'p1', name: '手背'),
          ]),
        ),
        '治疗记录：手背',
      );
      expect(supplementSummaryZh(null), isNull);
    });

    test('sanitizeDisplayNotes 清洗历史脏数据', () {
      // v1.8.0 写入的真实脏文本：'$part.name' 被解析为 ${part}.name，
      // Dart 默认 toString 带单引号。
      expect(
        sanitizeDisplayNotes(
          "治疗记录：Instance of 'PhototherapyExposurePart'.name 1 分 30 秒",
        ),
        '治疗记录：1 分 30 秒',
      );
      // 整条都是脏数据 → null（不显示空壳）。
      expect(
        sanitizeDisplayNotes(
          "治疗记录：Instance of 'PhototherapyExposurePart'.name",
        ),
        isNull,
      );
      expect(
        sanitizeDisplayNotes(
          "治疗记录：左前臂 1 分 30 秒；Instance of 'PhototherapyExposurePart'",
        ),
        '治疗记录：左前臂 1 分 30 秒',
      );
      // 正常文本原样返回。
      expect(sanitizeDisplayNotes('有点红'), '有点红');
      expect(sanitizeDisplayNotes(null), isNull);
      // 多段全脏 → 只剩裸标签 → null（不留「治疗记录：；」残尾）。
      expect(
        sanitizeDisplayNotes(
          "治疗记录：Instance of 'PhototherapyExposurePart'.name；"
          "Instance of 'PhototherapyExposurePart'.name",
        ),
        isNull,
      );
      // 无引号变体（部分 Dart 版本 toString 不带引号）也要清洗。
      expect(
        sanitizeDisplayNotes(
          '治疗记录：Instance of PhototherapyExposurePart 1 分钟',
        ),
        '治疗记录：1 分钟',
      );
      // 非备注类脏数据（其它对象名）同样移除。
      expect(
        sanitizeDisplayNotes(
          "随访：Instance of 'Diagnosis'.name 已确认",
        ),
        '随访：已确认',
      );
    });
  });

  group('存储层：上一次记录复用与任务读取', () {
    late LocalRepository repo;

    setUp(() {
      repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    });

    tearDown(() => repo.close());

    Future<Task> completedTask({
      required String id,
      required String templateId,
      required DateTime completedAt,
      TaskSupplement? supplement,
      TaskStatus status = TaskStatus.completed,
    }) async {
      final task = Task(
        id: id,
        patientId: localPatientId,
        diseaseId: 'd1',
        title: '308nm 光疗',
        type: TaskType.treatment,
        source: TaskSource.clinicalRule,
        dueAt: completedAt,
        templateId: templateId,
        status: status,
        completedAt: status == TaskStatus.completed ? completedAt : null,
        supplement: supplement,
      );
      await repo.saveTask(task);
      if (supplement != null) {
        await repo.saveTaskSupplement(id, supplement);
      }
      return task;
    }

    test('lastSupplementedTaskForTemplate 取最近一次带补充的已完成任务', () async {
      await completedTask(
        id: 'old',
        templateId: 'vitiligo.phototherapy',
        completedAt: DateTime(2026, 8, 28, 10),
        supplement: supplementWith(const [
          PhototherapyExposurePart(
            partId: 'p1',
            name: '左前臂',
            durationSeconds: 60,
          ),
        ]),
      );
      await completedTask(
        id: 'new',
        templateId: 'vitiligo.phototherapy',
        completedAt: DateTime(2026, 8, 31, 10),
        supplement: supplementWith(const [
          PhototherapyExposurePart(
            partId: 'p2',
            name: '颈部',
            durationSeconds: 90,
          ),
        ]),
      );
      // 无补充 / 其他模板 / 未完成的记录都不参与。
      await completedTask(
        id: 'plain',
        templateId: 'vitiligo.phototherapy',
        completedAt: DateTime(2026, 9, 1, 10),
      );
      await completedTask(
        id: 'other',
        templateId: 'diabetes.glucose',
        completedAt: DateTime(2026, 9, 2, 10),
        supplement: supplementWith(const [
          PhototherapyExposurePart(partId: 'p3', name: '无关部位'),
        ]),
      );

      final last = await repo.lastSupplementedTaskForTemplate(
        localPatientId,
        'vitiligo.phototherapy',
      );
      expect(last, isNotNull);
      expect(last!.id, 'new');
      expect(phototherapyExposureParts(last.supplement).single.name, '颈部');

      // 排除自身（重新记录场景）→ 回落到上一次。
      final prev = await repo.lastSupplementedTaskForTemplate(
        localPatientId,
        'vitiligo.phototherapy',
        excludeTaskId: 'new',
      );
      expect(prev!.id, 'old');

      // 无历史 → null。
      expect(
        await repo.lastSupplementedTaskForTemplate(
          localPatientId,
          'nonexistent.template',
        ),
        isNull,
      );
    });

    test('getTaskById 读取单个任务（时间线详情入口）', () async {
      await completedTask(
        id: 't1',
        templateId: 'vitiligo.phototherapy',
        completedAt: DateTime(2026, 8, 31, 10),
        status: TaskStatus.pending,
      );
      final task = await repo.getTaskById('t1');
      expect(task, isNotNull);
      expect(task!.title, '308nm 光疗');
      expect(await repo.getTaskById('missing'), isNull);
    });
  });

  group('主题：输入框与次级填充面明暗方向', () {
    ColorTokens tokensFor(Brightness brightness) {
      final theme = brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark();
      return theme.extension<ColorTokens>()!;
    }

    test('亮色模式 fill 为浅色、暗色模式 fill 为深色（divider 反色 bug 回归）', () {
      final light = tokensFor(Brightness.light);
      final dark = tokensFor(Brightness.dark);

      // 旧实现：divider.withValues(alpha: 0.5) → 亮色 50% 黑 / 暗色 50% 白。
      // 新实现：fill token 方向正确（亮色 fill 亮度高于亮色文字，暗色反之）。
      expect(_luminance(light.fill), greaterThan(0.6));
      expect(_luminance(dark.fill), lessThan(0.2));
      expect(light.fill, isNot(equals(dark.fill)));
    });

    test('输入框主题使用 fill 作为填充色', () {
      final light = tokensFor(Brightness.light);
      final dark = tokensFor(Brightness.dark);
      final lightInput = AppTheme.light().inputDecorationTheme;
      final darkInput = AppTheme.dark().inputDecorationTheme;

      expect(lightInput.fillColor, light.fill);
      expect(darkInput.fillColor, dark.fill);
      expect(lightInput.filled, isTrue);
      // 填充色上输入文字（textPrimary）对比度 ≥ 4.5:1。
      expect(
        _contrast(light.fill, light.textPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(dark.fill, dark.textPrimary),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('fillStrong 与 fill 分层且方向一致', () {
      final light = tokensFor(Brightness.light);
      final dark = tokensFor(Brightness.dark);
      expect(light.fillStrong, isNot(equals(light.fill)));
      expect(_luminance(light.fillStrong), greaterThan(0.5));
      expect(_luminance(dark.fillStrong), lessThan(0.25));
    });
  });
}

/// WCAG 相对亮度对比度（Color.computeLuminance）。
double _luminance(Color c) => c.computeLuminance();

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
