import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/glass/glass.dart';

/// 308nm 光疗记录表单（玻璃底部弹层）。
///
/// 结构化记录治疗部位、左右侧、剂量、红斑及不良反应。
/// 记录只做数据沉淀，不做剂量建议。
///
/// 用法：`PhototherapyFormSheet.show(context, patientId: …, diseaseId: …)`。
class PhototherapyFormSheet extends ConsumerStatefulWidget {
  const PhototherapyFormSheet({
    super.key,
    required this.patientId,
    required this.diseaseId,
  });

  final String patientId;
  final String diseaseId;

  /// 统一的弹层入口。
  static Future<void> show(
    BuildContext context, {
    required String patientId,
    required String diseaseId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) =>
          PhototherapyFormSheet(patientId: patientId, diseaseId: diseaseId),
    );
  }

  @override
  ConsumerState<PhototherapyFormSheet> createState() =>
      _PhototherapyFormSheetState();
}

/// 不良反应等级文案（0=无 1=轻 2=中 3=重）。
const _levelLabels = ['无', '轻', '中', '重'];

class _PhototherapyFormSheetState extends ConsumerState<PhototherapyFormSheet> {
  final _bodyPartController = TextEditingController(text: '');
  final _deviceController = TextEditingController(text: '308nm');
  final _doseController = TextEditingController(text: '');
  final _doseUnitController = TextEditingController(text: 'J/cm²');
  final _erythemaDurationController = TextEditingController(text: '');
  final _otherReactionController = TextEditingController(text: '');
  final _patientNotesController = TextEditingController(text: '');

  late DateTime _occurredAt;
  BodyLaterality _laterality = BodyLaterality.none;
  bool _erythema = false;
  late DateTime _erythemaStart;
  int _painLevel = 0;
  int _itchingLevel = 0;
  int _burningLevel = 0;
  bool _blister = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _occurredAt = now;
    _erythemaStart = now;
  }

  @override
  void dispose() {
    _bodyPartController.dispose();
    _deviceController.dispose();
    _doseController.dispose();
    _doseUnitController.dispose();
    _erythemaDurationController.dispose();
    _otherReactionController.dispose();
    _patientNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('记录光疗', style: context.headlineStyle),
              SizedBox(height: SpacingTokens.x1),
              Text(
                '记录 308nm 光疗的剂量与皮肤反应，便于长期追踪效果。',
                style: context.secondaryLabelStyle,
              ),
              SizedBox(height: SpacingTokens.x4),
              Text('治疗时间', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              Row(
                children: [
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('yyyy/M/d').format(_occurredAt),
                      onTap: _pickOccurredDate,
                    ),
                  ),
                  SizedBox(width: SpacingTokens.x3),
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.access_time,
                      label: DateFormat('HH:mm').format(_occurredAt),
                      onTap: _pickOccurredTime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _bodyPartController,
                decoration: const InputDecoration(labelText: '治疗部位（必填）'),
              ),
              SizedBox(height: SpacingTokens.x4),
              Text('左右侧', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              Wrap(
                spacing: SpacingTokens.x2,
                runSpacing: SpacingTokens.x2,
                children: [
                  for (final laterality in BodyLaterality.values)
                    _ChoiceChip(
                      label: laterality.labelZh,
                      selected: _laterality == laterality,
                      onTap: () => setState(() => _laterality = laterality),
                    ),
                ],
              ),
              SizedBox(height: SpacingTokens.x4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _deviceController,
                      decoration: const InputDecoration(labelText: '设备'),
                    ),
                  ),
                  SizedBox(width: SpacingTokens.x3),
                  Expanded(
                    child: TextField(
                      controller: _doseUnitController,
                      decoration: const InputDecoration(labelText: '剂量单位'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _doseController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: '单次剂量（可选）'),
              ),
              SizedBox(height: SpacingTokens.x4),
              Row(
                children: [
                  Expanded(child: Text('红斑', style: context.labelBoldStyle)),
                  Switch(
                    value: _erythema,
                    onChanged: (v) => setState(() {
                      _erythema = v;
                      if (v) {
                        _erythemaStart = _occurredAt;
                      }
                    }),
                  ),
                ],
              ),
              if (_erythema) ...[
                SizedBox(height: SpacingTokens.x2),
                Text('开始时间', style: context.labelBoldStyle),
                SizedBox(height: SpacingTokens.x2),
                Row(
                  children: [
                    Expanded(
                      child: _FieldButton(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('yyyy/M/d').format(_erythemaStart),
                        onTap: _pickErythemaDate,
                      ),
                    ),
                    SizedBox(width: SpacingTokens.x3),
                    Expanded(
                      child: _FieldButton(
                        icon: Icons.access_time,
                        label: DateFormat('HH:mm').format(_erythemaStart),
                        onTap: _pickErythemaTime,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SpacingTokens.x4),
                TextField(
                  controller: _erythemaDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '持续时间（小时，可选）'),
                ),
              ],
              SizedBox(height: SpacingTokens.x4),
              Text('不良反应', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              _LevelRow(
                label: '疼痛',
                level: _painLevel,
                onChanged: (v) => setState(() => _painLevel = v),
              ),
              SizedBox(height: SpacingTokens.x2),
              _LevelRow(
                label: '瘙痒',
                level: _itchingLevel,
                onChanged: (v) => setState(() => _itchingLevel = v),
              ),
              SizedBox(height: SpacingTokens.x2),
              _LevelRow(
                label: '灼热',
                level: _burningLevel,
                onChanged: (v) => setState(() => _burningLevel = v),
              ),
              SizedBox(height: SpacingTokens.x2),
              Row(
                children: [
                  Expanded(child: Text('水疱', style: context.labelStyle)),
                  Checkbox(
                    value: _blister,
                    onChanged: (v) => setState(() => _blister = v ?? false),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x2),
              TextField(
                controller: _otherReactionController,
                decoration: const InputDecoration(labelText: '其他反应（可选）'),
              ),
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _patientNotesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '患者备注（可选）'),
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

  Future<void> _pickOccurredDate() async {
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

  Future<void> _pickOccurredTime() async {
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

  Future<void> _pickErythemaDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _erythemaStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _erythemaStart = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _erythemaStart.hour,
          _erythemaStart.minute,
        );
      });
    }
  }

  Future<void> _pickErythemaTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_erythemaStart),
    );
    if (picked != null) {
      setState(() {
        _erythemaStart = DateTime(
          _erythemaStart.year,
          _erythemaStart.month,
          _erythemaStart.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    final bodyPart = _bodyPartController.text.trim();
    if (bodyPart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请填写治疗部位')));
      return;
    }

    final device = _deviceController.text.trim();
    final doseUnit = _doseUnitController.text.trim();
    final doseText = _doseController.text.trim();
    final durationText = _erythemaDurationController.text.trim();
    final otherReaction = _otherReactionController.text.trim();
    final patientNotes = _patientNotesController.text.trim();

    final repo = ref.read(repositoryProvider);
    await repo.addPhototherapyRecord(
      PhototherapyRecord(
        id: newId(),
        patientId: widget.patientId,
        diseaseId: widget.diseaseId,
        occurredAt: _occurredAt,
        device: device.isEmpty ? null : device,
        bodyPart: bodyPart,
        laterality: _laterality == BodyLaterality.none
            ? null
            : _laterality.name,
        dose: doseText.isEmpty ? null : double.tryParse(doseText),
        doseUnit: doseUnit.isEmpty ? null : doseUnit,
        erythema: _erythema,
        erythemaStart: _erythema ? _erythemaStart : null,
        erythemaDurationHours: _erythema && durationText.isNotEmpty
            ? int.tryParse(durationText)
            : null,
        painLevel: _painLevel,
        itchingLevel: _itchingLevel,
        burningLevel: _burningLevel,
        blister: _blister,
        otherReaction: otherReaction.isEmpty ? null : otherReaction,
        patientNotes: patientNotes.isEmpty ? null : patientNotes,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.label,
    required this.level,
    required this.onChanged,
  });

  final String label;
  final int level;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label, style: context.labelStyle)),
        Expanded(
          child: Wrap(
            spacing: SpacingTokens.x2,
            runSpacing: SpacingTokens.x2,
            children: [
              for (var i = 0; i < _levelLabels.length; i++)
                _ChoiceChip(
                  label: _levelLabels[i],
                  selected: level == i,
                  onTap: () => onChanged(i),
                ),
            ],
          ),
        ),
      ],
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
          color: selected ? colors.brand : colors.divider,
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
          color: colors.divider.withValues(alpha: 0.5),
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
