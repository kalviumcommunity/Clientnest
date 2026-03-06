import 'package:flutter/material.dart';

class FreelancerData {
  final String name;
  final String specialty;
  final double rating;
  final int completedJobs;
  final String avatarInitial;
  final Color avatarColor;
  final String hourlyRate;
  final bool isOnline;

  const FreelancerData({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.completedJobs,
    required this.avatarInitial,
    required this.avatarColor,
    required this.hourlyRate,
    this.isOnline = false,
  });
}

class FreelancerCard extends StatelessWidget {
  final FreelancerData freelancer;
  final bool isCompact;

  const FreelancerCard({
    super.key,
    required this.freelancer,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(
        vertical: isCompact ? 4 : 6,
        horizontal: isCompact ? 0 : 0,
      ),
      padding: EdgeInsets.all(isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact ? _buildCompactLayout(context, colorScheme) : _buildFullLayout(context, colorScheme),
    );
  }

  Widget _buildFullLayout(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAvatar(colorScheme, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    freelancer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    freelancer.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildOnlineBadge(colorScheme),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildRatingBadge(colorScheme),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${freelancer.completedJobs} jobs',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              freelancer.hourlyRate,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildAvatar(colorScheme, radius: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                freelancer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                freelancer.specialty,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildRatingBadge(colorScheme),
            const SizedBox(height: 4),
            Text(
              freelancer.hourlyRate,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, {required double radius}) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: freelancer.avatarColor.withValues(alpha: 0.15),
          child: Text(
            freelancer.avatarInitial,
            style: TextStyle(
              color: freelancer.avatarColor,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.75,
            ),
          ),
        ),
        if (freelancer.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOnlineBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: freelancer.isOnline
            ? Colors.green.withValues(alpha: 0.1)
            : colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        freelancer.isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: freelancer.isOnline ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildRatingBadge(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
        const SizedBox(width: 3),
        Text(
          freelancer.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
