import 'package:flutter/material.dart';

import '../core/colors.dart';

/// The GitHub contribution grid: rows of small rounded squares whose green
/// intensity reflects daily activity. On mount the squares animate in with a
/// staggered pop (column by column), matching the reference design.
class ContributionGrid extends StatefulWidget {
  const ContributionGrid({
    super.key,
    required this.levels,
    required this.palette,
    this.columns = 18,
    this.gap = 3,
    this.animate = true,
  });

  /// Intensity per cell, 0–4. Rendered left-to-right, top-to-bottom.
  final List<int> levels;
  final WidgetPalette palette;
  final int columns;
  final double gap;
  final bool animate;

  @override
  State<ContributionGrid> createState() => ContributionGridState();
}

class ContributionGridState extends State<ContributionGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  /// Restarts the pop-in animation.
  void replay() => _controller.forward(from: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _cellProgress(int index, int rows) {
    final col = index % widget.columns;
    final row = index ~/ widget.columns;
    final start = (col * 0.028 + row * 0.012).clamp(0.0, 0.7);
    const window = 0.3;
    return Interval(start, start + window, curve: Curves.easeOutBack)
        .transform(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    final rows = (widget.levels.length / widget.columns).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell =
            (constraints.maxWidth - (widget.columns - 1) * widget.gap) /
                widget.columns;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Wrap(
              spacing: widget.gap,
              runSpacing: widget.gap,
              children: [
                for (var i = 0; i < widget.levels.length; i++)
                  _buildCell(i, cell, _cellProgress(i, rows)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCell(int index, double size, double t) {
    final level = widget.levels[index];
    final color = level <= 0
        ? widget.palette.emptyCell
        : widget.palette.gridLevels[
            (level - 1).clamp(0, widget.palette.gridLevels.length - 1)];
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: (0.3 + 0.7 * t).clamp(0.0, 1.05),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
        ),
      ),
    );
  }
}
