import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../data/models/contribution_day.dart';

/// The GitHub contribution grid, drawn exactly like github.com: one column per
/// week, seven rows for the days of the week (Sunday at top). The most recent
/// weeks that fit are shown, and the squares animate in column by column.
class ContributionGrid extends StatefulWidget {
  const ContributionGrid({
    super.key,
    required this.weeks,
    required this.palette,
    this.gap = 4,
    this.targetCell = 15,
    this.animate = true,
  });

  /// Calendar weeks, oldest first; each week holds its days (Sun → Sat).
  final List<List<ContributionDay>> weeks;
  final WidgetPalette palette;
  final double gap;

  /// Preferred square size; the number of weeks shown adapts to fit the width.
  final double targetCell;
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

  double _cellProgress(int col, int row) {
    final start = (col * 0.03 + row * 0.008).clamp(0.0, 0.7);
    return Interval(start, start + 0.3, curve: Curves.easeOutBack)
        .transform(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final totalWeeks = widget.weeks.length;
        if (totalWeeks == 0) return const SizedBox.shrink();

        final fitWeeks =
            ((maxWidth + widget.gap) / (widget.targetCell + widget.gap))
                .floor()
                .clamp(1, totalWeeks);
        final cell = (maxWidth - (fitWeeks - 1) * widget.gap) / fitWeeks;
        final shown = widget.weeks.sublist(totalWeeks - fitWeeks);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var col = 0; col < shown.length; col++) ...[
                  if (col > 0) SizedBox(width: widget.gap),
                  _buildWeek(shown[col], col, cell),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeek(List<ContributionDay> week, int col, double cell) {
    final byWeekday = {for (final d in week) d.weekday: d};
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 7; row++) ...[
          if (row > 0) SizedBox(height: widget.gap),
          _buildCell(byWeekday[row], col, row, cell),
        ],
      ],
    );
  }

  Widget _buildCell(ContributionDay? day, int col, int row, double size) {
    if (day == null) {
      return SizedBox(width: size, height: size); // padding for partial weeks
    }
    final color = day.level <= 0
        ? widget.palette.emptyCell
        : widget.palette.gridLevels[
            (day.level - 1).clamp(0, widget.palette.gridLevels.length - 1)];
    final t = _cellProgress(col, row);
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
