import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../widgets/glass/glass.dart';

/// 手动记录支持的事件类型（§7 Event First，覆盖日常高频行为）。
const _recordTypes = [
  EventType.measurement,
  EventType.symptom,
  EventType.medication,
  EventType.treatment,
  EventType.custom,
];

/// 手动健康记录表单（玻璃底部弹层，§7 Event First 的 user 来源入口）。
///
/// 用法：`EventRecordSheet.show(context)`，保存成功写入事件并关闭。
/// 测量事件额外采集「指标 / 数值 / 单位」，存入 [HealthEvent.payload]。
class EventRecordSheet extends ConsumerStatefulWidget {
  const EventRecordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => const EventRecordSheet(),
    );
  }

  @override
  ConsumerState<EventRecordSheet> createState() => _EventRecordSheetState();
}

class _EventRecordSheetState extends ConsumerState<EventRecordSheet> {
  final _titleController = TextEditingController();
  final _metricController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  EventType _type = EventType.measurement;
  String? _diseaseId;
  late DateTime _occurredAt;

  @override
  void initState() {
    super.initState();
    _occurredAt = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _metricController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 标题占位符随类型变化。
  String get _titlePlaceholder => switch (_type) {
    EventType.measurement => '空腹血糖',
    EventType.symptom => '头痛',
    EventType.medication => '服药',
    EventType.treatment => '308nm 光疗',
    _ => '记录内容',
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _occurredAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _occurredAt.hour,
          _occurredAt.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (picked != null) {
      setState(() {
        _occurredAt = DateTime(
          _occurredAt.year,
          _occurredAt.month,
          _occurredAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请填写标题')));
      return;
    }

    final payload = <String, Object?>{};
    if (_type == EventType.measurement) {
      final metric = _metricController.text.trim();
      final valueText = _valueController.text.trim();
      final unit = _unitController.text.trim();
      if (metric.isEmpty || valueText.isEmpty || unit.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('请填写指标、数值和单位')));
        return;
      }
      final value = double.tryParse(valueText);
      if (value == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('数值格式不正确')));
        return;
      }
      payload['metric'] = metric;
      payload['value'] = value;
      payload['unit'] = unit;
    }

    final notes = _notesController.text.trim();
    final now = DateTime.now();
    final event = HealthEvent(
      id: newId(),
      patientId: localPatientId,
      diseaseId: _diseaseId,
      type: _type,
      occurredAt: _occurredAt,
      createdAt: now,
      title: title,
      source: EventSource.user,
      payload: payload,
      notes: notes.isEmpty ? null : notes,
    );

    final repo = ref.read(repositoryProvider);
    await repo.addEvent(event);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final diseases = ref.watch(diseasesProvider).value ?? const <Disease>[];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassSurface(
        level: GlassLevel.overlay,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.xlarge),
        ),
        padding: EdgeInsets.fromLTRB(
          SpacingTokens.x5,
          SpacingTokens.x4,
          SpacingTokens.x5,
          SpacingTokens.x6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('记录健康数据', style: context.headlineStyle),
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '标题',
                  hintText: _titlePlaceholder,
                ),
              ),
              SizedBox(height: SpacingTokens.x4),
              Text('类型', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              Wrap(
                spacing: SpacingTokens.x2,
                runSpacing: SpacingTokens.x2,
                children: [
                  for (final type in _recordTypes)
                    _ChoiceChip(
                      label: type.labelZh,
                      selected: _type == type,
                      onTap: () => setState(() => _type = type),
                    ),
                ],
              ),
              if (_type == EventType.measurement) ...[
                SizedBox(height: SpacingTokens.x4),
                Text('测量数据', style: context.labelBoldStyle),
                SizedBox(height: SpacingTokens.x2),
                TextField(
                  controller: _metricController,
                  decoration: const InputDecoration(
                    labelText: '指标',
                    hintText: '如 fasting_glucose',
                  ),
                ),
                SizedBox(height: SpacingTokens.x3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _valueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: '数值'),
                      ),
                    ),
                    SizedBox(width: SpacingTokens.x3),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: '单位',
                          hintText: '如 mmol/L',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: '备注（可选）'),
              ),
              SizedBox(height: SpacingTokens.x4),
              Text('关联疾病（可选）', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              DropdownButtonFormField<String>(
                initialValue: _diseaseId,
                hint: const Text('不关联'),
                items: [
                  for (final disease in diseases)
                    DropdownMenuItem(
                      value: disease.id,
                      child: Text(disease.name),
                    ),
                ],
                onChanged: (value) => setState(() => _diseaseId = value),
              ),
              SizedBox(height: SpacingTokens.x4),
              Row(
                children: [
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('yyyy/M/d').format(_occurredAt),
                      onTap: _pickDate,
                    ),
                  ),
                  SizedBox(width: SpacingTokens.x3),
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.access_time,
                      label: DateFormat('HH:mm').format(_occurredAt),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x4),
              GlassButton(
                expanded: true,
                onPressed: _submit,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return InkWell(
      borderRadius: RadiusTokens.pillShape,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x3,
          vertical: SpacingTokens.x2,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.brand : colors.fill,
          borderRadius: RadiusTokens.pillShape,
        ),
        child: Text(
          label,
          style: context.labelStyle.copyWith(
            color: selected ? colors.onBrand : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return InkWell(
      borderRadius: RadiusTokens.mediumShape,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x4,
          vertical: SpacingTokens.x3,
        ),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: RadiusTokens.mediumShape,
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.textSecondary),
            SizedBox(width: SpacingTokens.x2),
            Expanded(child: Text(label, style: context.labelStyle)),
          ],
        ),
      ),
    );
  }
}
