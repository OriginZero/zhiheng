import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/preferences_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';

/// 「我的」页面：患者档案 + 疾病管理入口 + 外观设置 + 医疗安全说明。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(currentPatientProvider).value;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.x5,
        SpacingTokens.x2,
        SpacingTokens.x5,
        SpacingTokens.x6,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: SpacingTokens.x4),
          child: Text('我的', style: context.titleStyle),
        ),
        _ProfileCard(patient: patient),
        SizedBox(height: SpacingTokens.x3),
        _DiseaseEntry(),
        SizedBox(height: SpacingTokens.x3),
        const _ThemeCard(),
        SizedBox(height: SpacingTokens.x3),
        _SafetyCard(),
      ],
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.patient});

  final Patient? patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: scheme.primary, size: 28),
            ),
            SizedBox(width: SpacingTokens.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient?.name ?? '未建档', style: context.bodyBoldStyle),
                  SizedBox(height: SpacingTokens.x1),
                  Text(
                    [
                      patient?.gender.labelZh,
                      if (patient?.ageYears != null) '${patient!.ageYears} 岁',
                    ].join(' · '),
                    style: context.captionStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: '编辑档案',
              onPressed: patient == null
                  ? null
                  : () => _showProfileSheet(context, patient!),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context, Patient patient) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProfileSheet(patient: patient),
    );
  }
}

/// 档案编辑弹层：姓名 + 性别 + 出生日期。
class _ProfileSheet extends ConsumerStatefulWidget {
  const _ProfileSheet({required this.patient});

  final Patient patient;

  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  late final TextEditingController _nameController;
  late Gender _gender;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _gender = widget.patient.gender;
    _birthDate = widget.patient.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: '选择出生日期',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref
        .read(repositoryProvider)
        .savePatient(
          widget.patient.copyWith(
            name: name,
            gender: _gender,
            birthDate: _birthDate,
            clearBirthDate: _birthDate == null,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

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
                    Text('编辑档案', style: context.headlineStyle),
                    SizedBox(height: SpacingTokens.x4),
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: '名字'),
                    ),
                    SizedBox(height: SpacingTokens.x4),
                    Text('性别', style: context.labelBoldStyle),
                    SizedBox(height: SpacingTokens.x2),
                    Wrap(
                      spacing: SpacingTokens.x2,
                      runSpacing: SpacingTokens.x2,
                      children: [
                        for (final gender in Gender.values)
                          ChoiceChip(
                            label: Text(gender.labelZh),
                            selected: _gender == gender,
                            onSelected: (_) => setState(() => _gender = gender),
                          ),
                      ],
                    ),
                    SizedBox(height: SpacingTokens.x4),
                    Text('出生日期', style: context.labelBoldStyle),
                    SizedBox(height: SpacingTokens.x2),
                    _BirthDateField(
                      date: _birthDate,
                      onTap: _pickBirthDate,
                      onClear: _birthDate == null
                          ? null
                          : () => setState(() => _birthDate = null),
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
                child: FilledButton(onPressed: _save, child: const Text('保存')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 出生日期选择字段：点击弹日期选择器，已选时显示日期与清除按钮。
class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.date,
    required this.onTap,
    this.onClear,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: RadiusTokens.mediumShape,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x4,
          vertical: SpacingTokens.x3,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: RadiusTokens.mediumShape,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, size: 18, color: scheme.onSurfaceVariant),
            SizedBox(width: SpacingTokens.x2),
            Expanded(
              child: Text(
                date == null ? '未设置' : DateFormat('yyyy年M月d日').format(date!),
                style: date == null
                    ? context.labelStyle.copyWith(color: scheme.outline)
                    : context.labelStyle,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsets.all(SpacingTokens.x1),
                  child: Text(
                    '清除',
                    style: context.labelStyle.copyWith(color: scheme.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 疾病管理入口：显示已添加疾病数量。
class _DiseaseEntry extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final count = ref.watch(diseasesProvider).value?.length ?? 0;

    return Card(
      child: InkWell(
        borderRadius: RadiusTokens.mediumShape,
        onTap: () => context.push('/diseases'),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.x4),
          child: Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 22,
                color: scheme.primary,
              ),
              SizedBox(width: SpacingTokens.x3),
              Expanded(child: Text('我的疾病', style: context.bodyBoldStyle)),
              Text(count > 0 ? '$count 个' : '去添加', style: context.captionStyle),
              SizedBox(width: SpacingTokens.x2),
              Icon(Icons.chevron_right, size: 20, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// 外观设置：主题模式（明暗）+ 强调色配色（iOS 26 tint 风格）。
class _ThemeCard extends ConsumerWidget {
  const _ThemeCard();

  static const _options = [
    (mode: ThemeMode.system, label: '跟随系统', icon: Icons.brightness_auto),
    (mode: ThemeMode.light, label: '浅色', icon: Icons.light_mode_outlined),
    (mode: ThemeMode.dark, label: '深色', icon: Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final current = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, size: 20, color: scheme.primary),
                SizedBox(width: SpacingTokens.x2),
                Text('外观', style: context.labelBoldStyle),
              ],
            ),
            SizedBox(height: SpacingTokens.x3),
            Row(
              children: [
                for (final option in _options)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SpacingTokens.x1,
                      ),
                      child: _ThemeOption(
                        label: option.label,
                        icon: option.icon,
                        selected: current == option.mode,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(option.mode),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: SpacingTokens.x4),
            Text('配色', style: context.labelBoldStyle),
            SizedBox(height: SpacingTokens.x2),
            _PalettePicker(
              currentId: ref.watch(accentPaletteProvider).value?.id,
              onSelect: (palette) =>
                  ref.read(accentPaletteProvider.notifier).setPalette(palette),
            ),
          ],
        ),
      ),
    );
  }
}

/// 强调色选择器（iOS 26 tint 风格，低饱和 5 色）。
class _PalettePicker extends StatelessWidget {
  const _PalettePicker({required this.currentId, required this.onSelect});

  final String? currentId;
  final ValueChanged<AccentPalette> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: SpacingTokens.x3,
      runSpacing: SpacingTokens.x2,
      children: [
        for (final palette in AccentPalettes.all)
          Semantics(
            button: true,
            selected: palette.id == currentId,
            label: palette.labelZh,
            child: InkWell(
              borderRadius: RadiusTokens.pillShape,
              onTap: () => onSelect(palette),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.brand,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.id == currentId
                            ? scheme.onSurface
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (palette.id == currentId)
                          BoxShadow(
                            color: palette.brand.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: palette.id == currentId
                        ? Icon(Icons.check, size: 18, color: palette.onBrand)
                        : null,
                  ),
                  SizedBox(height: SpacingTokens.x1),
                  Text(
                    palette.labelZh,
                    style: context.captionStyle.copyWith(
                      color: palette.id == currentId
                          ? scheme.primary
                          : scheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: RadiusTokens.mediumShape,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: SpacingTokens.x3),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.14)
                : scheme.surfaceContainerHighest,
            borderRadius: RadiusTokens.mediumShape,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 1.25,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              SizedBox(height: SpacingTokens.x1),
              Text(
                label,
                style: context.captionStyle.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 医疗安全边界说明（开发文档 §3、§61）。
class _SafetyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
                SizedBox(width: SpacingTokens.x2),
                Text('医疗安全说明', style: context.labelBoldStyle),
              ],
            ),
            SizedBox(height: SpacingTokens.x3),
            Text(
              '知衡用于记录、提醒与整理你的健康管理数据，'
              '不提供诊断、处方或治疗剂量建议。\n\n'
              '涉及治疗方案、药物与光疗剂量的决定，'
              '请务必遵循你的主治医生意见。',
              style: context.secondaryLabelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
