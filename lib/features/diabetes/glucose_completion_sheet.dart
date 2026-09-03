import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/record_completion_sheet.dart';

/// 血糖任务勾选完成时填写的「本次血糖测量」表单（任务驱动血糖监测）。
///
/// 任务模板（空腹 / 餐后2小时 / 睡前）决定测量时点；本表单采集血糖值、
/// 测量方式、症状、是否运动前后。血糖 <3.9 mmol/L 自动标记低血糖并提示
/// 补充症状/原因（《中国糖尿病防治指南（2024版）》1 级低血糖阈值）。
///
/// 数据以 [TaskSupplement]（schema 可扩展）保存，不属于医学建议。
/// 表单只做记录，不给出剂量/治疗建议（§4：以医生方案为准）。
///
/// 返回：保存 → [RecordCompletionResult]；用户取消（下滑/返回）→ null，
/// 任务保持待办状态，不产生任何写入。
class GlucoseCompletionSheet extends ConsumerStatefulWidget {
  const GlucoseCompletionSheet({super.key, required this.task});

  /// 被勾选的血糖任务（templateId = diabetes.glucose.fasting /
  /// diabetes.glucose.postMeal / diabetes.glucose.bedtime）。
  final Task task;

  static Future<RecordCompletionResult?> show(
    BuildContext context, {
    required Task task,
  }) {
    return showRecordCompletionSheet(
      context,
      builder: (_) => GlucoseCompletionSheet(task: task),
    );
  }

  @override
  ConsumerState<GlucoseCompletionSheet> createState() =>
      _GlucoseCompletionSheetState();
}

class _GlucoseCompletionSheetState
    extends ConsumerState<GlucoseCompletionSheet> {
  final _valueController = TextEditingController();

  /// 测量时点由任务模板决定（不可更改，保证数据一致性）。
  late final GlucoseContext _context;

  GlucoseMethod _method = GlucoseMethod.fingerstick;
  final Set<String> _symptoms = {};
  bool _exercise = false;

  /// 低血糖自动判定：value < 3.9 mmol/L。
  bool get _isHypo {
    final v = double.tryParse(_valueController.text.trim());
    return v != null && v < kHypoglycemiaThreshold;
  }

  /// 严重低血糖：value < 3.0 mmol/L。
  bool get _isSevereHypo {
    final v = double.tryParse(_valueController.text.trim());
    return v != null && v < kSevereHypoglycemiaThreshold;
  }

  @override
  void initState() {
    super.initState();
    _context = _contextFromTask(widget.task);
  }

  /// 从任务模板 id 反推测量时点。
  GlucoseContext _contextFromTask(Task task) => switch (task.templateId) {
    'diabetes.glucose.fasting' => GlucoseContext.fasting,
    'diabetes.glucose.postMeal' => GlucoseContext.postMeal,
    'diabetes.glucose.bedtime' => GlucoseContext.bedtime,
    _ => GlucoseContext.other,
  };

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  /// 外壳回调：生成补充并返回结果；校验失败返回 null（外壳保持弹层）。
  Future<RecordCompletionResult?> _submit({
    required bool skip,
    required String notes,
  }) async {
    final notesValue = notes.isEmpty ? null : notes;

    // 「仅完成，不记录本次细节」：不校验血糖值，也不生成补充。
    if (skip) {
      return RecordCompletionResult(supplement: null, notes: notesValue);
    }

    final valueText = _valueController.text.trim();
    final value = double.tryParse(valueText);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入有效的血糖值')));
      return null;
    }

    final reading = GlucoseReading(
      context: _context,
      value: value,
      method: _method,
      symptoms: _symptoms.toList(),
      exercise: _exercise,
      notes: notesValue,
    );

    return RecordCompletionResult(
      supplement: TaskSupplement(
        schema: kGlucoseReadingSchema,
        content: reading.toJson(),
      ),
      notes: notesValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordCompletionSheet(
      title: '记录${_context.labelZh}血糖',
      description: '血糖 <3.9 mmol/L 会自动标记低血糖并提示补充症状，这里只做记录。',
      saveLabelSuffix: _isHypo ? '（低血糖）' : null,
      onSubmit: _submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 血糖值输入
          _ValueInput(
            controller: _valueController,
            isHypo: _isHypo,
            isSevereHypo: _isSevereHypo,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: SpacingTokens.x3),

          // 低血糖自动警告
          if (_isHypo) ...[
            _HypoWarning(isSevere: _isSevereHypo),
            SizedBox(height: SpacingTokens.x3),
          ],

          // 测量方式
          _MethodSelector(
            method: _method,
            onChanged: (m) => setState(() => _method = m),
          ),
          SizedBox(height: SpacingTokens.x3),

          // 症状多选（低血糖时高亮提示）
          _SymptomSelector(
            symptoms: _symptoms,
            isHypo: _isHypo,
            onChanged: (s) => setState(() => _symptoms.addAll(s)),
            onRemoved: (s) => setState(() => _symptoms.remove(s)),
          ),
          SizedBox(height: SpacingTokens.x3),

          // 运动前后
          _ExerciseToggle(
            value: _exercise,
            onChanged: (v) => setState(() => _exercise = v),
          ),
        ],
      ),
    );
  }
}

/// 血糖值输入（带单位与低血糖颜色提示）。
class _ValueInput extends StatelessWidget {
  const _ValueInput({
    required this.controller,
    required this.isHypo,
    required this.isSevereHypo,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isHypo;
  final bool isSevereHypo;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 输入文字颜色：仅低血糖状态做颜色提示，其余跟随正文色（与其它表单字段一致）。
    final inputColor = isSevereHypo
        ? colors.critical
        : isHypo
        ? colors.warning
        : scheme.onSurface;
    final alertBorder = isSevereHypo
        ? colors.critical
        : isHypo
        ? colors.warning
        : null;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: textTheme.bodyLarge?.copyWith(color: inputColor),
      decoration: InputDecoration(
        labelText: '血糖值',
        hintText: '如 5.6',
        suffixText: 'mmol/L',
        // 非低血糖沿用主题默认描边；低血糖时用语义色描边提示。
        enabledBorder: alertBorder == null
            ? null
            : OutlineInputBorder(
                borderRadius: RadiusTokens.mediumShape,
                borderSide: BorderSide(color: alertBorder),
              ),
        focusedBorder: alertBorder == null
            ? null
            : OutlineInputBorder(
                borderRadius: RadiusTokens.mediumShape,
                borderSide: BorderSide(color: alertBorder, width: 2),
              ),
      ),
      onChanged: onChanged,
    );
  }
}

/// 低血糖自动警告（value < 3.9 触发）。
class _HypoWarning extends StatelessWidget {
  const _HypoWarning({required this.isSevere});

  final bool isSevere;

  @override
  Widget build(BuildContext context) {
    // 医疗警示：M3 error 角色区分严重度，图标 + 文字并用（不单靠颜色传达）。
    final scheme = Theme.of(context).colorScheme;
    final surface = isSevere ? scheme.error : scheme.errorContainer;
    final onSurface = isSevere ? scheme.onError : scheme.onErrorContainer;
    final icon = isSevere ? Icons.error_outline : Icons.warning_amber_outlined;
    final title = isSevere ? '严重低血糖（<3.0）' : '低血糖（<3.9）';
    final message = isSevere
        ? '血糖 <3.0 mmol/L 属于 2 级低血糖，建议记录本次事件并联系医生评估原因。'
        : '血糖 <3.9 mmol/L 属于 1 级低血糖，请及时处理并关注后续血糖变化。';

    return Container(
      padding: EdgeInsets.all(SpacingTokens.x3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: RadiusTokens.largeShape,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onSurface, size: 20),
          SizedBox(width: SpacingTokens.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelBoldStyle.copyWith(color: onSurface),
                ),
                SizedBox(height: SpacingTokens.x1),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 测量方式选择器。
class _MethodSelector extends StatelessWidget {
  const _MethodSelector({required this.method, required this.onChanged});

  final GlucoseMethod method;
  final ValueChanged<GlucoseMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('测量方式', style: textTheme.bodyMedium),
        SizedBox(height: SpacingTokens.x2),
        Wrap(
          spacing: SpacingTokens.x2,
          children: [
            for (final m in GlucoseMethod.values)
              ChoiceChip(
                label: Text(m.labelZh),
                selected: method == m,
                onSelected: (_) => onChanged(m),
              ),
          ],
        ),
      ],
    );
  }
}

/// 症状多选（低血糖时高亮提示必填）。
class _SymptomSelector extends StatelessWidget {
  const _SymptomSelector({
    required this.symptoms,
    required this.isHypo,
    required this.onChanged,
    required this.onRemoved,
  });

  final Set<String> symptoms;
  final bool isHypo;
  final ValueChanged<Set<String>> onChanged;
  final ValueChanged<String> onRemoved;

  /// 常见症状列表（低血糖 + 高血糖）。
  static const commonSymptoms = [
    '出汗',
    '心慌',
    '手抖',
    '饥饿',
    '头晕',
    '乏力',
    '口渴',
    '多尿',
    '视物模糊',
    '注意力下降',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('症状', style: textTheme.bodyMedium),
            if (isHypo) ...[
              SizedBox(width: SpacingTokens.x2),
              Text(
                '（低血糖时建议填写）',
                style: textTheme.bodySmall?.copyWith(color: colors.warning),
              ),
            ],
          ],
        ),
        SizedBox(height: SpacingTokens.x2),
        Wrap(
          spacing: SpacingTokens.x2,
          runSpacing: SpacingTokens.x1,
          children: [
            for (final s in commonSymptoms)
              FilterChip(
                label: Text(s),
                selected: symptoms.contains(s),
                onSelected: (selected) {
                  if (selected) {
                    onChanged({s});
                  } else {
                    onRemoved(s);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// 运动前后开关。
class _ExerciseToggle extends StatelessWidget {
  const _ExerciseToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text('运动前后', style: textTheme.bodyMedium),
        const Spacer(),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
