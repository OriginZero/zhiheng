import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../core/theme/theme.dart';

/// 统一异步状态视图（开发文档 §38）。
///
/// 禁止只实现 Success：Loading / Empty / Error 必须各有对应呈现。
class AsyncStatusView<T> extends StatelessWidget {
  const AsyncStatusView({
    super.key,
    required this.value,
    required this.builder,
    this.emptyState,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  /// 空状态。数据为空列表或未提供时使用通用 [EmptyState]。
  final Widget? emptyState;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error, onRetry: onRetry),
      data: (data) {
        if (data is List && data.isEmpty) {
          return emptyState ?? const EmptyState();
        }
        return builder(data);
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.x8),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppError
        ? (error as AppError).message
        : '页面数据加载失败，请重试。';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: SpacingTokens.x3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.secondaryBodyStyle,
            ),
            if (onRetry != null) ...[
              SizedBox(height: SpacingTokens.x4),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.refresh),
                onPressed: onRetry,
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 空状态（开发文档 §39）。
///
/// 必须说明：没有数据 → 为什么 → 下一步可以做什么。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = '还没有数据',
    this.message = '产生第一条记录后，这里会开始展示内容。',
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;

  /// 引导动作，如「记录一次治疗」。
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Theme.of(context).colorScheme.outline),
            SizedBox(height: SpacingTokens.x3),
            Text(title, style: context.labelBoldStyle),
            SizedBox(height: SpacingTokens.x2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.secondaryLabelStyle,
            ),
            if (action != null) ...[
              SizedBox(height: SpacingTokens.x4),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
