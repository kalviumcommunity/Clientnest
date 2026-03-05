import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/time_tracker_provider.dart';

class FloatingTimeTracker extends StatelessWidget {
  const FloatingTimeTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTrackerProvider>(
      builder: (context, provider, child) {
        final activeLog = provider.activeLog;
        if (activeLog == null) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;
        final minutes = provider.currentDuration;
        final h = minutes ~/ 60;
        final m = minutes % 60;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.timer, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeLog.projectTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} elapsed',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => provider.stopTracking(),
                icon: const Icon(Icons.stop_circle, color: Colors.redAccent, size: 32),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
}
