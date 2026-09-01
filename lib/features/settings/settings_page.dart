import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/preferences_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/glass/glass.dart';

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
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.brand.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: colors.brand, size: 28),
          ),
          SizedBox(width: SpacingTokens.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient?.name ?? '未建档',
                  style: context.bodyBoldStyle,
                ),
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
            tooltip: '修改名字',
            onPressed: patient == null
                ? null
                : () => _showRenameSheet(context, ref, patient!),
          ),
        ],
      ),
    );
  }

  void _showRenameSheet(BuildContext context, WidgetRef ref, Patient patient) {
    final controller = TextEditingController(text: patient.name);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: GlassSurface(
          level: GlassLevel.overlay,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.xlarge),
          ),
          padding: EdgeInsets.all(SpacingTokens.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('修改名字', style: context.headlineStyle),
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: '名字'),
              ),
              SizedBox(height: SpacingTokens.x4),
              GlassButton(
                expanded: true,
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  await ref
                      .read(repositoryProvider)
                      .savePatient(patient.copyWith(name: name));
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 疾病管理入口：显示已添加疾病数量。
class _DiseaseEntry extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final count = ref.watch(diseasesProvider).value?.length ?? 0;

    return GlassCard(
      onTap: () => context.push('/diseases'),
      child: Row(
        children: [
          Icon(Icons.medical_services_outlined,
              size: 22, color: colors.brand),
          SizedBox(width: SpacingTokens.x3),
          Expanded(child: Text('我的疾病', style: context.bodyBoldStyle)),
          Text(
            count > 0 ? '$count 个' : '去添加',
            style: context.captionStyle,
          ),
          SizedBox(width: SpacingTokens.x2),
          Icon(Icons.chevron_right, size: 20, color: colors.textTertiary),
        ],
      ),
    );
  }
}

/// 外观设置：主题模式切换（跟随系统 / 亮色 / 暗色）。
class _ThemeCard extends ConsumerWidget {
  const _ThemeCard();

  static const _options = [
    (mode: ThemeMode.system, label: '跟随系统', icon: Icons.brightness_auto),
    (mode: ThemeMode.light, label: '浅色', icon: Icons.light_mode_outlined),
    (mode: ThemeMode.dark, label: '深色', icon: Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final current = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 20, color: colors.brand),
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
        ],
      ),
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
    final colors = Theme.of(context).extension<ColorTokens>()!;

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
                ? colors.brand.withValues(alpha: 0.14)
                : colors.divider.withValues(alpha: 0.4),
            borderRadius: RadiusTokens.mediumShape,
            border: Border.all(
              color: selected ? colors.brand : Colors.transparent,
              width: 1.25,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? colors.brand : colors.textSecondary,
              ),
              SizedBox(height: SpacingTokens.x1),
              Text(
                label,
                style: context.captionStyle.copyWith(
                  color: selected ? colors.brand : colors.textSecondary,
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 20,
                color: Theme.of(context).extension<ColorTokens>()!.brand,
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
    );
  }
}
