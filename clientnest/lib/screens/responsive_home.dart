import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/freelancer_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/project_card.dart';

// ---------------------------------------------------------------------------
// Static sample data — no Firestore writes, purely presentational.
// ---------------------------------------------------------------------------

const List<CategoryData> _categories = [
  CategoryData(label: 'Design',       icon: Icons.brush_outlined,           color: Color(0xFF6366F1)),
  CategoryData(label: 'Development',  icon: Icons.code_rounded,             color: Color(0xFF0EA5E9)),
  CategoryData(label: 'Writing',      icon: Icons.edit_note_rounded,        color: Color(0xFF10B981)),
  CategoryData(label: 'Marketing',    icon: Icons.campaign_outlined,        color: Color(0xFFF59E0B)),
  CategoryData(label: 'Video',        icon: Icons.videocam_outlined,        color: Color(0xFFEF4444)),
  CategoryData(label: 'Finance',      icon: Icons.attach_money_rounded,     color: Color(0xFF8B5CF6)),
];

const List<FreelancerData> _freelancers = [
  FreelancerData(
    name: 'Aria Chen',
    specialty: 'UI/UX Designer',
    rating: 4.9,
    completedJobs: 134,
    avatarInitial: 'A',
    avatarColor: Color(0xFF6366F1),
    hourlyRate: '\$85/hr',
    isOnline: true,
  ),
  FreelancerData(
    name: 'Marco Rossi',
    specialty: 'Flutter Developer',
    rating: 4.8,
    completedJobs: 98,
    avatarInitial: 'M',
    avatarColor: Color(0xFF0EA5E9),
    hourlyRate: '\$95/hr',
    isOnline: true,
  ),
  FreelancerData(
    name: 'Priya Singh',
    specialty: 'Content Writer',
    rating: 4.7,
    completedJobs: 217,
    avatarInitial: 'P',
    avatarColor: Color(0xFF10B981),
    hourlyRate: '\$45/hr',
    isOnline: false,
  ),
  FreelancerData(
    name: 'Jake Turner',
    specialty: 'Full-Stack Engineer',
    rating: 5.0,
    completedJobs: 61,
    avatarInitial: 'J',
    avatarColor: Color(0xFFF59E0B),
    hourlyRate: '\$110/hr',
    isOnline: true,
  ),
];

const List<ProjectCardData> _activeProjects = [
  ProjectCardData(
    title: 'Brand Refresh 2025',
    clientName: 'Acme Corp.',
    progress: 0.65,
    deadline: 'Mar 20, 2025',
    budget: 2400,
    status: ProjectCardStatus.active,
    accentColor: Color(0xFF6366F1),
  ),
  ProjectCardData(
    title: 'E-commerce Mobile App',
    clientName: 'ShopWave Inc.',
    progress: 0.30,
    deadline: 'Apr 5, 2025',
    budget: 6800,
    status: ProjectCardStatus.active,
    accentColor: Color(0xFF0EA5E9),
  ),
  ProjectCardData(
    title: 'SEO Strategy Q2',
    clientName: 'GreenLeaf Agency',
    progress: 0.90,
    deadline: 'Mar 10, 2025',
    budget: 1200,
    status: ProjectCardStatus.lead,
    accentColor: Color(0xFFF59E0B),
  ),
];

// ---------------------------------------------------------------------------
// Main responsive home screen
// ---------------------------------------------------------------------------

class ResponsiveHomeScreen extends StatefulWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  State<ResponsiveHomeScreen> createState() => _ResponsiveHomeScreenState();
}

class _ResponsiveHomeScreenState extends State<ResponsiveHomeScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final user = Provider.of<AuthService>(context).currentUser;

    return Scaffold(
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(context, user)
            : _buildMobileLayout(context, user),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TABLET layout: two-column dashboard
  // -------------------------------------------------------------------------

  Widget _buildTabletLayout(BuildContext context, dynamic user) {
    return Column(
      children: [
        _buildHeader(context, user, isTablet: true),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT panel — categories + projects
              Expanded(
                flex: 5,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 10, 100),
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Browse by Category', null),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(context, crossAxisCount: 3),
                    const SizedBox(height: 28),
                    _buildSectionHeader(context, 'Active Projects', 'See All'),
                    const SizedBox(height: 14),
                    ..._activeProjects.map(
                      (p) => ProjectCard(project: p, isCompact: true),
                    ),
                  ],
                ),
              ),
              // RIGHT panel — freelancers
              Expanded(
                flex: 4,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(10, 16, 20, 100),
                  children: [
                    _buildSectionHeader(context, 'Recommended Freelancers', 'View All'),
                    const SizedBox(height: 14),
                    ..._freelancers.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FreelancerCard(freelancer: f, isCompact: true),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildQuickStatsRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // MOBILE layout: vertical scroll
  // -------------------------------------------------------------------------

  Widget _buildMobileLayout(BuildContext context, dynamic user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        isLandscape ? 20 : 100,
      ),
      children: [
        _buildHeader(context, user, isTablet: false),
        const SizedBox(height: 20),
        _buildSearchBar(context),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Browse by Category', null),
        const SizedBox(height: 14),
        _buildCategoryGrid(
          context,
          crossAxisCount: isLandscape || screenWidth > 400 ? 3 : 2,
        ),
        const SizedBox(height: 28),
        _buildSectionHeader(context, 'Recommended Freelancers', 'View All'),
        const SizedBox(height: 14),
        _buildFreelancerGrid(context, screenWidth),
        const SizedBox(height: 28),
        _buildSectionHeader(context, 'Active Projects', 'See All'),
        const SizedBox(height: 14),
        ..._activeProjects.map(
          (p) => ProjectCard(project: p, isCompact: false),
        ),
        const SizedBox(height: 20),
        _buildQuickStatsRow(context),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Shared sub-widgets
  // -------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, dynamic user,
      {required bool isTablet}) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstName = user?.displayName?.split(' ')[0] ?? 'Freelancer';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 0,
        vertical: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 22 : 20,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Text(
                    (user?.displayName?.isNotEmpty == true)
                        ? user!.displayName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, $firstName 👋',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isTablet ? 20 : 18,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Find your next great hire today',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildNotificationBell(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(
      BuildContext context, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 22,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search freelancers, services...',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.35),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 22,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: colorScheme.onPrimary,
              size: 16,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String? actionLabel) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context,
      {required int crossAxisCount}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return CategoryChip(
              category: _categories[index],
              isSelected: _selectedCategoryIndex == index,
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFreelancerGrid(BuildContext context, double screenWidth) {
    final crossAxisCount = screenWidth >= 480 ? 2 : 1;

    if (crossAxisCount == 1) {
      return Column(
        children: _freelancers
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FreelancerCard(freelancer: f, isCompact: false),
              ),
            )
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: _freelancers.length,
      itemBuilder: (context, index) => FreelancerCard(
        freelancer: _freelancers[index],
        isCompact: false,
      ),
    );
  }

  Widget _buildQuickStatsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildQuickStatCard(
          context,
          colorScheme,
          icon: Icons.people_outline_rounded,
          label: 'Freelancers',
          value: '2.4K+',
          color: const Color(0xFF6366F1),
        ),
        _buildQuickStatCard(
          context,
          colorScheme,
          icon: Icons.task_alt_rounded,
          label: 'Jobs Done',
          value: '18K+',
          color: const Color(0xFF10B981),
        ),
        _buildQuickStatCard(
          context,
          colorScheme,
          icon: Icons.star_rounded,
          label: 'Avg. Rating',
          value: '4.8',
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth >= 600
            ? (screenWidth - 80) / 3
            : (screenWidth - 64) / 3;

        return SizedBox(
          width: cardWidth.clamp(90.0, 200.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
