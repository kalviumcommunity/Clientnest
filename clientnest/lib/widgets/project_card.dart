import 'package:flutter/material.dart';

enum ProjectCardStatus { active, lead, completed }

class ProjectCardData {
  final String title;
  final String clientName;
  final double progress;
  final String deadline;
  final double budget;
  final ProjectCardStatus status;
  final Color accentColor;

  const ProjectCardData({
    required this.title,
    required this.clientName,
    required this.progress,
    required this.deadline,
    required this.budget,
    required this.status,
    required this.accentColor,
  });
}

class ProjectCard extends StatelessWidget {
  final ProjectCardData project;
  final bool isCompact;

  const ProjectCard({
    super.key,
    required this.project,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 10 : 14),
      padding: EdgeInsets.all(isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: project.accentColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: isCompact ? 36 : 44,
                decoration: BoxDecoration(
                  color: project.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 13 : 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.clientName,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusChip(colorScheme),
            ],
          ),
          SizedBox(height: isCompact ? 10 : 14),
          _buildProgressBar(colorScheme),
          SizedBox(height: isCompact ? 8 : 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  project.deadline,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Text(
                '\$${project.budget.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isCompact ? 12 : 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(project.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: project.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: project.progress,
            backgroundColor: project.accentColor.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(project.accentColor),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    String label;
    Color chipColor;

    switch (project.status) {
      case ProjectCardStatus.active:
        label = 'Active';
        chipColor = Colors.green;
        break;
      case ProjectCardStatus.lead:
        label = 'Lead';
        chipColor = const Color(0xFFF59E0B);
        break;
      case ProjectCardStatus.completed:
        label = 'Done';
        chipColor = colorScheme.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}
