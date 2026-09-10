import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import 'disease_templates.dart';

/// 应用指南模板前的周期设置弹层。
///
/// 返回用户设定好的 [TaskRecurrence]；取消返回 null。仅调整重复频率 / 间隔 /
/// 星期（计划的疗程时长仍取模板默认），不产生剂量等医学指令。
Future<TaskRecurrence?> showTemplateApplySheet(
  BuildContext context,
  DiseaseTaskTemplate template,
) {
  return showModalBottomSheet<TaskRecurrence>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TemplateApplySheet(template: template),
  );
}

class _TemplateApplySheet extends StatefulWidget {
  const _TemplateApplySheet({required this.template});

  final DiseaseTaskTemplate template;

  @override
  State<_TemplateApplySheet> createState() => _TemplateApplySheetState();
}

class _TemplateApplySheetState extends State<_TemplateApplySheet> {
  late RecurrenceFrequency _frequency;
  late final TextEditingController _intervalController;
  late Set<int> _weekdays;

  @override
  void initState() {
    super.initState();
    final rule = widget.template.defaultRecurrence;
    _frequency = rule.frequency;
    _intervalController = TextEditingController(text: '${rule.interval}');
    _weekdays = rule.weekdays.toSet();
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  int get _interval {
    final parsed = int.tryParse(_intervalController.text.trim());
    return (parsed != null && parsed >= 1) ? parsed : 1;
  }

  String get _unit => switch (_frequency) {
        RecurrenceFrequency.daily => '天',
        RecurrenceFrequency.weekly => '周',
        RecurrenceFrequency.monthly => '个月',
        RecurrenceFrequency.none => '',
      };

  /// 当前选择的预览（供用户确认）。
  TaskRecurrence get _preview => TaskRecurrence(
        frequency: _frequency,
        interval: _interval,
        weekdays: _weekdays.toList()..sort(),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  SpacingTokens.x5,
                  SpacingTokens.x4,
                  SpacingTokens.x5,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('设置计划周期', style: context.headlineStyle),
                    SizedBox(height: SpacingTokens.x1),
                    Text(
                      widget.template.title,
                      style: context.secondaryLabelStyle,
                    ),
                    SizedBox(height: SpacingTokens.x4),
                    Text('重复频率', style: context.labelBoldStyle),
                    SizedBox(height: SpacingTokens.x2),
                    Wrap(
                      spacing: SpacingTokens.x2,
                      runSpacing: SpacingTokens.x2,
                      children: [
                        _FrequencyChip(
                          label: '每天',
                          selected: _frequency == RecurrenceFrequency.daily,
                          onTap: () => setState(
                            () => _frequency = RecurrenceFrequency.daily,
                          ),
                        ),
                        _FrequencyChip(
                          label: '每周',
                          selected: _frequency == RecurrenceFrequency.weekly,
                          onTap: () => setState(
                            () => _frequency = RecurrenceFrequency.weekly,
                          ),
                        ),
                        _FrequencyChip(
                          label: '每月',
                          selected: _frequency == RecurrenceFrequency.monthly,
                          onTap: () => setState(
                            () => _frequency = RecurrenceFrequency.monthly,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SpacingTokens.x4),
                    Text('间隔', style: context.labelBoldStyle),
                    SizedBox(height: SpacingTokens.x2),
                    TextField(
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: '每',
                        suffixText: _unit,
                        hintText: '1',
                      ),
                    ),
                    if (_frequency == RecurrenceFrequency.weekly) ...[
                      SizedBox(height: SpacingTokens.x4),
                      Text('星期', style: context.labelBoldStyle),
                      SizedBox(height: SpacingTokens.x2),
                      Wrap(
                        spacing: SpacingTokens.x2,
                        runSpacing: SpacingTokens.x2,
                        children: [
                          for (var weekday = 1; weekday <= 7; weekday++)
                            FilterChip(
                              label: Text(_weekdayLabels[weekday - 1]),
                              selected: _weekdays.contains(weekday),
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _weekdays.add(weekday);
                                } else {
                                  _weekdays.remove(weekday);
                                }
                              }),
                            ),
                        ],
                      ),
                    ],
                    SizedBox(height: SpacingTokens.x4),
                    Text(
                      _frequency == RecurrenceFrequency.weekly &&
                              _weekdays.isEmpty
                          ? '请至少选择一个星期'
                          : '将按「${_preview.descriptionZh}」生成任务；'
                              '具体频率请以医生方案为准。',
                      style: context.captionStyle.copyWith(
                        color: _frequency == RecurrenceFrequency.weekly &&
                                _weekdays.isEmpty
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacingTokens.x5,
                SpacingTokens.x3,
                SpacingTokens.x5,
                SpacingTokens.x6,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('应用并创建'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  void _submit() {
    if (_frequency == RecurrenceFrequency.weekly && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请至少选择一个星期')));
      return;
    }
    Navigator.of(context).pop(_preview);
  }
}

/// 频率单选（互斥）。
class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) {
        if (isSelected) onTap();
      },
    );
  }
}
