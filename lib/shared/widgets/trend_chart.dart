import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// 趋势图上的单个数据点。
class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.value,
    this.isAbnormal = false,
  });

  /// x 轴标签（如「9/3」）。
  final String label;

  /// 数值。
  final double value;

  /// 是否异常（如光疗后的红斑 / 水疱），异常点用 critical 色突出。
  final bool isAbnormal;
}

/// 自绘折线趋势图（开发文档 §33：每个图表回答一个问题）。
///
/// 不引入图表库，CustomPaint 手绘：
/// - y 轴自动刻度：含 0 基线；值全同时显示该值 ±1，避免平线；
/// - x 轴显示首 / 中 / 尾 label；
/// - 折线用 brand 色，异常点 critical 实心圆、普通点小圆；
/// - 传入 [targetMin] / [targetMax] 时绘制目标范围淡色带；
/// - 点击最近点，图表上方显示 label + value tooltip。
///
/// 边界：空列表显示占位；单点水平居中。
class TrendChart extends StatefulWidget {
  const TrendChart({
    super.key,
    required this.points,
    this.targetMin,
    this.targetMax,
    this.height = 180,
  });

  /// 按时间顺序排列的数据点（左侧为最早）。
  final List<TrendPoint> points;

  /// 目标范围下界（参考线带，可只给一端）。
  final double? targetMin;

  /// 目标范围上界。
  final double? targetMax;

  /// 图表高度。
  final double height;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // 颜色在 build 处从主题取色后以值传入 painter（异常点 critical 为医疗语义色）。
    final scheme = Theme.of(context).colorScheme;
    final critical = Theme.of(context).extension<ColorTokens>()!.critical;
    if (widget.points.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(child: Text('暂无趋势数据', style: context.captionStyle)),
      );
    }
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: _handleTapUp,
                  child: CustomPaint(
                    painter: _TrendChartPainter(
                      points: widget.points,
                      targetMin: widget.targetMin,
                      targetMax: widget.targetMax,
                      lineColor: scheme.primary,
                      abnormalColor: critical,
                      gridColor: scheme.outlineVariant,
                      baselineColor: scheme.outline,
                      axisStyle: context.captionStyle,
                      selectedIndex: _selectedIndex,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              if (_selectedIndex != null) _buildTooltip(context, scheme, size),
            ],
          );
        },
      ),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final size = context.size;
    if (size == null) return;
    final plot = _ChartLayout.plot(size);
    final tappedX = details.localPosition.dx;
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < widget.points.length; i++) {
      final distance =
          (tappedX - _ChartLayout.xFor(i, widget.points.length, plot)).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    setState(() => _selectedIndex = best);
  }

  Widget _buildTooltip(BuildContext context, ColorScheme scheme, Size size) {
    final index = _selectedIndex;
    if (index == null || index >= widget.points.length) {
      return const SizedBox.shrink();
    }
    final point = widget.points[index];
    final style = context.labelBoldStyle;
    final text = '${point.label} · ${_formatValue(point.value)}';
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final plot = _ChartLayout.plot(size);
    final x = _ChartLayout.xFor(index, widget.points.length, plot);
    final width = textPainter.width + SpacingTokens.x4;
    final left = (x - width / 2)
        .clamp(
          SpacingTokens.x1,
          math.max(SpacingTokens.x1, size.width - width - SpacingTokens.x1),
        )
        .toDouble();
    return Positioned(
      top: SpacingTokens.x1,
      left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.x2,
          vertical: SpacingTokens.x1,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: RadiusTokens.mediumShape,
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(text, style: style),
      ),
    );
  }
}

/// 图表绘制区布局常量：左侧 y 轴刻度、底部 x 轴标签。
class _ChartLayout {
  static const double leftGap = 36;
  static const double rightGap = 8;
  static const double topGap = 12;
  static const double bottomGap = 20;

  static Rect plot(Size size) => Rect.fromLTRB(
    leftGap,
    topGap,
    math.max(leftGap + 1, size.width - rightGap),
    math.max(topGap + 1, size.height - bottomGap),
  );

  /// 第 [index] 个点的 x 坐标；单点水平居中。
  static double xFor(int index, int length, Rect plot) {
    if (length <= 1) return plot.center.dx;
    return plot.left + plot.width * index / (length - 1);
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.targetMin,
    required this.targetMax,
    required this.lineColor,
    required this.abnormalColor,
    required this.gridColor,
    required this.baselineColor,
    required this.axisStyle,
    required this.selectedIndex,
  });

  final List<TrendPoint> points;
  final double? targetMin;
  final double? targetMax;

  /// 折线 / 普通点颜色（scheme.primary）。
  final Color lineColor;

  /// 异常点颜色（医疗语义色 critical）。
  final Color abnormalColor;

  /// 网格线颜色（scheme.outlineVariant）。
  final Color gridColor;

  /// 0 基线颜色（scheme.outline）。
  final Color baselineColor;

  final TextStyle axisStyle;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _ChartLayout.plot(size);
    if (plot.width <= 0 || plot.height <= 0) return;

    final minValue = points.map((p) => p.value).reduce(math.min);
    final maxValue = points.map((p) => p.value).reduce(math.max);

    // y 轴范围：含 0 基线；值全同（平线）时显示该值 ±1。
    double yMin;
    double yMax;
    if (minValue == maxValue) {
      yMin = minValue - 1;
      yMax = maxValue + 1;
    } else {
      yMin = math.min(0, minValue);
      yMax = maxValue;
    }
    if (yMax <= yMin) yMax = yMin + 1;

    double yFor(double value) =>
        plot.bottom - (value - yMin) / (yMax - yMin) * plot.height;

    // 1. y 轴网格与刻度（含 0 基线）。
    final ticks = _niceTicks(yMin, yMax);
    for (final tick in ticks) {
      if (tick < yMin - 1e-9 || tick > yMax + 1e-9) continue;
      final y = yFor(tick);
      final isBaseline = tick == 0;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = isBaseline
              ? baselineColor.withValues(alpha: 0.6)
              : gridColor
          ..strokeWidth = 1,
      );
      final label = _formatTick(
        tick,
        ticks.length > 1 ? ticks[1] - ticks[0] : 1,
      );
      final tp = _textPainter(label);
      tp.paint(canvas, Offset(plot.left - tp.width - 6, y - tp.height / 2));
    }

    // 2. 目标范围淡色带。
    if (targetMin != null || targetMax != null) {
      final topRaw = targetMax != null ? yFor(targetMax!) : plot.top;
      final bottomRaw = targetMin != null ? yFor(targetMin!) : plot.bottom;
      final bandTop = topRaw.clamp(plot.top, plot.bottom).toDouble();
      final bandBottom = bottomRaw.clamp(plot.top, plot.bottom).toDouble();
      if (bandTop < bandBottom) {
        final bandRect = Rect.fromLTRB(
          plot.left,
          bandTop,
          plot.right,
          bandBottom,
        );
        canvas.drawRect(
          bandRect,
          Paint()..color = lineColor.withValues(alpha: 0.08),
        );
        final edgePaint = Paint()
          ..color = lineColor.withValues(alpha: 0.3)
          ..strokeWidth = 1;
        if (topRaw > plot.top && topRaw < plot.bottom) {
          canvas.drawLine(bandRect.topLeft, bandRect.topRight, edgePaint);
        }
        if (bottomRaw > plot.top && bottomRaw < plot.bottom) {
          canvas.drawLine(bandRect.bottomLeft, bandRect.bottomRight, edgePaint);
        }
      }
    }

    // 3. 折线。
    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = _ChartLayout.xFor(i, points.length, plot);
      final y = yFor(points[i].value);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    // 4. x 轴标签：首 / 中 / 尾。
    final labelIndices = <int>{
      0,
      points.length ~/ 2,
      points.length - 1,
    }.toList()..sort();
    for (final i in labelIndices) {
      final x = _ChartLayout.xFor(i, points.length, plot);
      final tp = _textPainter(points[i].label);
      final left = (x - tp.width / 2)
          .clamp(plot.left, math.max(plot.left, plot.right - tp.width))
          .toDouble();
      tp.paint(canvas, Offset(left, size.height - 2 - tp.height));
    }

    // 5. 数据点：异常点 critical 实心圆，普通点小圆；选中点加外圈。
    for (var i = 0; i < points.length; i++) {
      final x = _ChartLayout.xFor(i, points.length, plot);
      final y = yFor(points[i].value);
      if (i == selectedIndex) {
        canvas.drawCircle(
          Offset(x, y),
          6,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
      if (points[i].isAbnormal) {
        canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = abnormalColor);
      } else {
        canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = lineColor);
      }
    }
  }

  TextPainter _textPainter(String text) => TextPainter(
    text: TextSpan(text: text, style: axisStyle),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.targetMin != targetMin ||
        oldDelegate.targetMax != targetMax ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.abnormalColor != abnormalColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.baselineColor != baselineColor ||
        oldDelegate.axisStyle != axisStyle ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

/// 生成 3~5 个「整齐」的刻度值（步长取 1/2/5 × 10ⁿ）。
List<double> _niceTicks(double yMin, double yMax, {int targetCount = 4}) {
  final rawStep = (yMax - yMin) / targetCount;
  if (rawStep <= 0) return [yMin];
  final magnitude = math
      .pow(10, (math.log(rawStep) / math.ln10).floor())
      .toDouble();
  final normalized = rawStep / magnitude;
  final step =
      (normalized < 1.5
          ? 1.0
          : normalized < 3
          ? 2.0
          : normalized < 7
          ? 5.0
          : 10.0) *
      magnitude;
  final first = (yMin / step).ceil() * step;
  final count = ((yMax - first) / step).ceil() + 1;
  return [for (var i = 0; i < count; i++) first + i * step];
}

/// 刻度标签：整数值不带小数，其余按步长精度显示。
String _formatTick(double value, double step) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  final decimals = math.max(0, (math.log(step) / math.ln10).floor() * -1);
  return value.toStringAsFixed(decimals);
}

/// 数值展示：去掉多余的尾零（如 0.50 → 0.5，3.00 → 3）。
String _formatValue(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
