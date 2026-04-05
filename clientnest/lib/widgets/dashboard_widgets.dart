import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import 'package:clientnest/core/theme/nest_design_system.dart';

// ─── Deadline Countdown ────────────────────────────────────────────────────────

class DeadlineCountdown extends StatefulWidget {
  final DateTime deadline;
  final String title;

  const DeadlineCountdown({super.key, required this.deadline, required this.title});

  @override
  State<DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<DeadlineCountdown> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _calculateRemaining());
  }

  void _calculateRemaining() {
    if (mounted) {
      setState(() {
        _remaining = widget.deadline.difference(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days = _remaining.inDays.clamp(0, 9999);
    final hours = _remaining.inHours % 24;
    final isPast = _remaining.isNegative;

    return LayerContainer(
      padding: const EdgeInsets.all(NestDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPast ? NestDesignSystem.error.withValues(alpha: 0.1) : colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPast ? Icons.warning_amber_rounded : Icons.timer_outlined,
                      color: isPast ? NestDesignSystem.error : colorScheme.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPast ? 'OVERDUE' : 'NEXT DEADLINE',
                      style: TextStyle(
                        color: isPast ? NestDesignSystem.error : colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: NestDesignSystem.spacingL),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: NestDesignSystem.spacingM),
          if (isPast)
            Text(
              'Missed by ${days.abs()} days',
              style: const TextStyle(
                color: NestDesignSystem.error,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          else
            Row(
              children: [
                _TimeBox(value: days.toString(), label: 'DAYS'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    ':',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                _TimeBox(value: hours.abs().toString(), label: 'HOURS'),
              ],
            ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  final String label;

  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.padLeft(2, '0'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 36,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        ),
      ],
    );
  }
}

// ─── Financial Snapshot ────────────────────────────────────────────────────────

class FinancialSnapshot extends StatelessWidget {
  final double income;
  final double pending;

  const FinancialSnapshot({super.key, required this.income, required this.pending});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasData = income > 0 || pending > 0;
    final maxY = hasData ? (income > pending ? income : pending) * 1.3 : 1.0;

    return GraphCard(
      title: 'Financial Analysis',
      value: '\$${(income + pending).toStringAsFixed(0)}',
      chart: hasData
          ? BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: maxY,
                minY: 0,
                groupsSpace: 40,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: NestDesignSystem.darkElevated,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: NestDesignSystem.darkTextSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('INCOME', style: style),
                            );
                          case 1:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('PENDING', style: style),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: NestDesignSystem.graphBlue,
                        width: 48,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: colorScheme.onSurface.withValues(alpha: 0.04),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: pending,
                        color: NestDesignSystem.graphPurple,
                        width: 48,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: colorScheme.onSurface.withValues(alpha: 0.04),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).scaleY(begin: 0.5, alignment: Alignment.bottomCenter)
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 12),
                  const Text('No financial data available'),
                ],
              ),
            ),
      legend: Row(
        children: [
          _LegendItem(label: 'Income', color: NestDesignSystem.graphBlue),
          const SizedBox(width: 20),
          _LegendItem(label: 'Pending', color: NestDesignSystem.graphPurple),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.folder_open_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ───────────────────────────────────────────────────────────────

class ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorStateWidget({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: NestDesignSystem.error,
              size: 52,
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Try Again',
              onTap: onRetry,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading Skeleton ──────────────────────────────────────────────────────────

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 20,
    this.width,
    this.borderRadius = NestDesignSystem.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1200.ms, color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5));
  }
}
