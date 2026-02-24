import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Deadline Calendar')),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          final events = _getEvents(provider.projects);

          return Column(
            children: [
              TableCalendar(
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
                  todayDecoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.3), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildEventList(events[_selectedDay ?? DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day)] ?? []),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<Project>> _getEvents(List<Project> projects) {
    final Map<DateTime, List<Project>> data = {};
    for (var project in projects) {
      final date = DateTime(project.deadline.year, project.deadline.month, project.deadline.day);
      if (data[date] == null) data[date] = [];
      data[date]!.add(project);
    }
    return data;
  }

  Widget _buildEventList(List<Project> projects) {
    if (projects.isEmpty) {
      return const Center(child: Text('No deadlines today.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(project.clientName),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
