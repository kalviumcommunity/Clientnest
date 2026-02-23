import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Nests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'In Progress'),
            Tab(text: 'Under Review'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getProjectsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No projects found.'));
          }

          final projects = snapshot.data!;
          final inProgress = projects.where((p) => p['status'] == 'in_progress' || p['status'] == null).toList();
          final underReview = projects.where((p) => p['status'] == 'under_review').toList();
          final completed = projects.where((p) => p['status'] == 'completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProjectList(inProgress),
              _buildProjectList(underReview),
              _buildProjectList(completed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProjectList(List<Map<String, dynamic>> projects) {
    if (projects.isEmpty) {
      return const Center(child: Text('No projects found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final p = projects[index];
        final double progress = (p['progress'] ?? 0).toDouble();
        
        // Deadline badge logic
        Color badgeColor = Colors.green;
        String badgeText = "On Track";
        if (p['deadline'] != null && p['status'] != 'completed') {
           final deadline = (p['deadline'] as Timestamp).toDate();
           final now = DateTime.now();
           final diff = deadline.difference(now).inDays;
           if (diff < 0) {
             badgeColor = Colors.red;
             badgeText = "Overdue";
           } else if (diff == 0) {
             badgeColor = Colors.orange;
             badgeText = "Due Today";
           } else if (diff <= 3) {
             badgeColor = Colors.orangeAccent;
             badgeText = "Due Soon";
           }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p['title'] ?? 'Untitled Project',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Client: ${p['clientId'] ?? 'Unknown'}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 12)),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
