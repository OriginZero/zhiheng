import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/glass/glass.dart';

/// 医疗时间线（开发文档 §9）。
///
/// 支持按疾病、事件类型过滤；时间线是患者理解长期疾病变化的入口。
class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  TimelineFilter _filter = const TimelineFilter();

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(timelineEventsProvider(_filter));
    final diseases = ref.watch(diseasesProvider).value ?? const [];

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
          child: Text('医疗时间线', style: context.titleStyle),
        ),
        _FilterBar(
          diseases: diseases,
          filter: _filter,
          onDiseaseSelected: (id) {
            setState(() {
              _filter = TimelineFilter(
                diseaseId: _filter.diseaseId == id ? null : id,
                type: _filter.type,
              );
            });
          },
          onTypeSelected: (type) {
            setState(() {
              _filter = TimelineFilter(
                diseaseId: _filter.diseaseId,
                type: _filter.type == type ? null : type,
              );
            });
          },
        ),
        SizedBox(height: SpacingTokens.x4),
        AsyncStatusView(
          value: events,
          emptyState: const EmptyState(
            icon: Icons.timeline_outlined,
            title: '时间线还是空的',
            message: '完成一次任务、记录一次治疗或测量后，\n'
                '这里会按时间展示你的完整健康轨迹。',
          ),
          builder: (list) => _TimelineList(events: list),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.diseases,
    required this.filter,
    required this.onDiseaseSelected,
    required this.onTypeSelected,
  });

  final List<Disease> diseases;
  final TimelineFilter filter;
  final ValueChanged<String?> onDiseaseSelected;
  final ValueChanged<EventType?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SpacingTokens.x2,
      runSpacing: SpacingTokens.x2,
      children: [
        for (final disease in diseases)
          _FilterChip(
            label: disease.name,
            selected: filter.diseaseId == disease.id,
            onTap: () => onDiseaseSelected(disease.id),
          ),
        for (final type in const [
          EventType.treatment,
          EventType.medication,
          EventType.measurement,
          EventType.taskCompleted,
        ])
          _FilterChip(
            label: type.labelZh,
            selected: filter.type == type,
            onTap: () => onTypeSelected(type),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

/// 时间线列表：按日期分组。
class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.events});

  final List<HealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<HealthEvent>>{};
    for (final event in events) {
      final day = DateTime(
        event.occurredAt.year,
        event.occurredAt.month,
        event.occurredAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: EdgeInsets.only(
              top: SpacingTokens.x3,
              bottom: SpacingTokens.x2,
            ),
            child: Text(
              DateFormat('M月d日 EEEE', 'zh_CN').format(entry.key),
              style: context.secondaryLabelStyle,
            ),
          ),
          for (final event in entry.value) _EventTile(event: event),
        ],
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final HealthEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventIcon(type: event.type),
          SizedBox(width: SpacingTokens.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title ?? event.type.labelZh,
                  style: context.bodyBoldStyle,
                ),
                SizedBox(height: SpacingTokens.x1),
                Row(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(event.occurredAt),
                      style: context.captionStyle,
                    ),
                    SizedBox(width: SpacingTokens.x2),
                    Text(
                      event.type.labelZh,
                      style: context.captionStyle.copyWith(color: colors.brand),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventIcon extends StatelessWidget {
  const _EventIcon({required this.type});

  final EventType type;

  IconData get _icon => switch (type) {
        EventType.treatment => Icons.healing_outlined,
        EventType.medication => Icons.medication_outlined,
        EventType.measurement => Icons.monitor_heart_outlined,
        EventType.symptom => Icons.sick_outlined,
        EventType.lab => Icons.science_outlined,
        EventType.photo => Icons.photo_outlined,
        EventType.exercise => Icons.directions_run_outlined,
        EventType.adverse => Icons.warning_amber_outlined,
        EventType.appointment => Icons.event_outlined,
        EventType.taskCompleted => Icons.check_circle_outline,
        EventType.diagnosis => Icons.description_outlined,
        EventType.planAdjustment => Icons.tune_outlined,
        EventType.custom => Icons.note_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final isAlert = type == EventType.adverse;

    return Container(
      padding: EdgeInsets.all(SpacingTokens.x2),
      decoration: BoxDecoration(
        color: (isAlert ? colors.warning : colors.brand)
            .withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _icon,
        size: 20,
        color: isAlert ? colors.warning : colors.brand,
      ),
    );
  }
}
