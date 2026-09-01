import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/radius_tokens.dart';
import 'package:zhiheng/core/theme/tokens/spacing_tokens.dart';
import 'package:zhiheng/core/theme/tokens/typography_tokens.dart';
import 'glass_surface.dart';

/// 玻璃对话框（开发文档 §22）。
///
/// 用法：`GlassDialog.show(context, builder: ...)`。
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  final Widget? title;
  final Widget child;
  final List<Widget>? actions;

  /// 统一的对话框入口。
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, _, _) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SpacingTokens.x8),
          child: builder(context),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      level: GlassLevel.overlay,
      borderRadius: RadiusTokens.xlargeShape,
      padding: EdgeInsets.all(SpacingTokens.x6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            DefaultTextStyle(
              style: context.headlineStyle,
              child: title!,
            ),
            SizedBox(height: SpacingTokens.x3),
          ],
          DefaultTextStyle(
            style: context.secondaryBodyStyle,
            child: child,
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(height: SpacingTokens.x5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final (i, action) in actions!.indexed) ...[
                  if (i > 0) SizedBox(width: SpacingTokens.x3),
                  action,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
