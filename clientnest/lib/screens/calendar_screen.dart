import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Deadline Planner',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          final events = _getEvents(provider.projects);
          final selectedKey = _selectedDay != null
              ? DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                )
              : DateTime(
                  _focusedDay.year,
                  _focusedDay.month,
                  _focusedDay.day,
                );
          final dayEvents = events[selectedKey] ?? [];

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Calendar widget
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) =>
                        events[DateTime(
                            day.year, day.month, day.day)] ??
                        [],
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primary
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold),
                      selectedDecoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle),
                      markersMaxCount: 1,
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: colorScheme.primary),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: colorScheme.primary),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: -0.04, end: 0),

                // Deadlines header for the selected day
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    children: [
                      Text(
                        'Deadlines',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: dayEvents.isNotEmpty
                              ? colorScheme.primary
                                  .withValues(alpha: 0.12)
                              : colorScheme.onSurface
                                  .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${dayEvents.length} project${dayEvents.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: dayEvents.isNotEmpty
                                ? colorScheme.primary
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Event list
                Expanded(
                  child: _buildEventList(dayEvents),
                ),
              ],
            ),
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
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            const Text(
              'No deadlines on this day.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isOverdue = project.deadline.isBefore(DateTime.now()) &&
            project.status != ProjectStatus.completed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverdue
                  ? Colors.redAccent.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant
                      .withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isOverdue
                          ? Colors.redAccent
                          : colorScheme.secondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.rocket_launch_rounded,
                  color: isOverdue
                      ? Colors.redAccent
                      : colorScheme.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${project.clientName} · ${isOverdue ? 'Overdue' : _statusLabel(project.status)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? Colors.redAccent
                            : colorScheme.onSurface
                                .withValues(alpha: 0.55),
                        fontWeight:
                            isOverdue ? FontWeight.w600 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (index * 50).ms)
            .slideX(begin: 0.05, end: 0);
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
