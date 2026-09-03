import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';

/// 疾病管理页：列出所有疾病，支持添加（§6 疾病模块可扩展）。
class DiseasesPage extends ConsumerWidget {
  const DiseasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseases = ref.watch(diseasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的疾病'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加疾病',
            onPressed: () => _showCreateSheet(context, ref),
          ),
        ],
      ),
      body: AsyncStatusView(
        value: diseases,
        emptyState: EmptyState(
          icon: Icons.medical_services_outlined,
          title: '还没有添加疾病',
          message:
              '添加你在管理的疾病后，\n'
              '可以为它制定计划、生成任务、记录治疗。',
          action: FilledButton.tonalIcon(
            onPressed: () => _showCreateSheet(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('添加疾病'),
          ),
        ),
        builder: (list) => ListView.separated(
          padding: EdgeInsets.all(SpacingTokens.x5),
          itemCount: list.length,
          separatorBuilder: (context, _) => SizedBox(height: SpacingTokens.x3),
          itemBuilder: (context, index) => _DiseaseTile(disease: list[index]),
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _DiseaseFormSheet(),
    );
  }
}

class _DiseaseTile extends ConsumerWidget {
  const _DiseaseTile({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: () => _showStatusSheet(context, ref),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: RadiusTokens.mediumShape,
          onTap: () => context.push('/disease/${disease.id}'),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.x4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: scheme.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: SpacingTokens.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(disease.name, style: context.bodyBoldStyle),
                      SizedBox(height: SpacingTokens.x1),
                      Text(
                        [
                          disease.status.labelZh,
                          if (disease.diagnosedAt != null)
                            '确诊于 ${DateFormat('yyyy/M/d').format(disease.diagnosedAt!)}',
                        ].join(' · '),
                        style: context.captionStyle,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 长按弹出疾病状态选择：管理中 / 缓解期 / 已痊愈。
  void _showStatusSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.x5,
          SpacingTokens.x4,
          SpacingTokens.x5,
          SpacingTokens.x6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${disease.name} · 状态', style: context.headlineStyle),
            SizedBox(height: SpacingTokens.x4),
            RadioGroup<DiseaseStatus>(
              groupValue: disease.status,
              onChanged: (status) async {
                if (status == null) return;
                await ref
                    .read(repositoryProvider)
                    .updateDiseaseStatus(disease.id, status);
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final status in DiseaseStatus.values)
                    RadioListTile<DiseaseStatus>(
                      value: status,
                      title: Text(status.labelZh),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 疾病创建表单。
///
/// 内置可选疾病（白癜风、2 型糖尿病），也允许自定义。
/// 这里只做记录，不生成任何医学建议（§3）。
class _DiseaseFormSheet extends ConsumerStatefulWidget {
  const _DiseaseFormSheet();

  @override
  ConsumerState<_DiseaseFormSheet> createState() => _DiseaseFormSheetState();
}

class _DiseaseFormSheetState extends ConsumerState<_DiseaseFormSheet> {
  String? _code;
  final _customController = TextEditingController();

  static const _builtIn = [DiseaseCodes.vitiligo, DiseaseCodes.type2Diabetes];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
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
                    Text('添加疾病', style: context.headlineStyle),
                    SizedBox(height: SpacingTokens.x4),
                    RadioGroup<String>(
                      groupValue: _code,
                      onChanged: (code) => setState(() => _code = code),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final code in _builtIn)
                            RadioListTile<String>(
                              value: code,
                              title: Text(DiseaseCodes.displayName(code)),
                            ),
                          RadioListTile<String>(
                            value: 'custom',
                            title: const Text('其他疾病'),
                          ),
                        ],
                      ),
                    ),
                    if (_code == 'custom') ...[
                      SizedBox(height: SpacingTokens.x3),
                      TextField(
                        controller: _customController,
                        autofocus: true,
                        decoration: const InputDecoration(labelText: '疾病名称'),
                      ),
                    ],
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
                  child: const Text('添加'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_code == null) return;

    String name;
    String code;
    if (_code == 'custom') {
      name = _customController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('请填写疾病名称')));
        return;
      }
      code = name;
    } else {
      code = _code!;
      name = DiseaseCodes.displayName(code);
    }

    final repo = ref.read(repositoryProvider);
    await repo.saveDisease(
      Disease(
        id: newId(),
        patientId: localPatientId,
        code: code,
        name: name,
        status: DiseaseStatus.active,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}
