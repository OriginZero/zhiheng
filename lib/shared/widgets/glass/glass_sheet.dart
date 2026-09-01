import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/motion_tokens.dart';
import 'package:zhiheng/core/theme/tokens/radius_tokens.dart';
import 'package:zhiheng/core/theme/tokens/spacing_tokens.dart';
import 'glass_surface.dart';

/// 玻璃底部弹层（开发文档 §22）。
///
/// 用法：`GlassSheet.show(context, child: ...)`。
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child, this.title});

  final Widget child;
  final Widget? title;

  /// 统一的弹层入口。业务页面不得自行 showModalBottomSheet。
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: MotionTokens.base,
        reverseDuration: MotionTokens.base,
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) => GlassSheet(
          child: builder(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      level: GlassLevel.overlay,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.xlarge),
      ),
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.x5,
        SpacingTokens.x3,
        SpacingTokens.x5,
        SpacingTokens.x8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 拖拽指示条。
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: RadiusTokens.pillShape,
              ),
            ),
          ),
          SizedBox(height: SpacingTokens.x4),
          if (title != null) ...[
            title!,
            SizedBox(height: SpacingTokens.x4),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}
