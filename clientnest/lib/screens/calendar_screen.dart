import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import '../core/theme/nest_design_system.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppShell(
      title: 'Timeline & Calendar',
      child: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          final events = _getEvents(provider.allProjects);
          final selectedKey = _selectedDay != null
              ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
              : DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
          final dayEvents = events[selectedKey] ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingS),
                child: LayerContainer(
                  padding: const EdgeInsets.all(NestDesignSystem.spacingM),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      todayTextStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: NestDesignSystem.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      markerDecoration: const BoxDecoration(
                        color: NestDesignSystem.graphCyan,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                      outsideDaysVisible: false,
                      defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                      weekendTextStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded, color: colorScheme.primary),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.02),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingM),
                child: Row(
                  children: [
                    Text(
                      'Deadlines & Milestones',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: dayEvents.isNotEmpty ? NestDesignSystem.accent.withValues(alpha: 0.1) : colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${dayEvents.length} Events',
                        style: TextStyle(
                          color: dayEvents.isNotEmpty ? NestDesignSystem.accent : colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildEventList(dayEvents),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<Project>> _getEvents(List<Project> projects) {
    final Map<DateTime, List<Project>> data = {};
    for (final project in projects) {
      final date = DateTime(
        project.deadline.year,
        project.deadline.month,
        project.deadline.day,
      );
      data.putIfAbsent(date, () => []).add(project);
    }
    return data;
  }

  Widget _buildEventList(List<Project> projects) {
    final colorScheme = Theme.of(context).colorScheme;
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            const SizedBox(height: 16),
            Text(
              'Workspace clear on this date.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(NestDesignSystem.spacingL, 0, NestDesignSystem.spacingL, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final theme = Theme.of(context);
        final isOverdue = project.deadline.isBefore(DateTime.now()) && project.status != ProjectStatus.completed;

        return LayerContainer(
          margin: const EdgeInsets.only(bottom: NestDesignSystem.spacingM),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isOverdue ? NestDesignSystem.error : colorScheme.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOverdue ? Icons.warning_amber_rounded : Icons.rocket_launch_rounded,
                  color: isOverdue ? NestDesignSystem.error : colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${project.clientName} · ${isOverdue ? 'Overdue' : _statusLabel(project.status)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isOverdue ? NestDesignSystem.error : colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: isOverdue ? FontWeight.w900 : FontWeight.w800,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
      },
    );
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.lead:
        return 'Lead';
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }
}
