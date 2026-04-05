import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import '../core/theme/nest_design_system.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _isDescending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppShell(
      title: 'CRM / Clients',
      actions: [
        IconButton(
          onPressed: () => _showAddOrEditClientDialog(context),
          icon: Icon(Icons.person_add_rounded, color: colorScheme.primary),
          tooltip: 'Add Client',
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search clients, companies...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                LayerContainer(
                  padding: EdgeInsets.zero,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.tune_rounded, color: colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                    onSelected: (value) {
                      setState(() {
                        if (_sortBy == value) {
                          _isDescending = !_isDescending;
                        } else {
                          _sortBy = value;
                          _isDescending = false;
                        }
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                      const PopupMenuItem(value: 'createdAt', child: Text('Sort by Date')),
                      const PopupMenuItem(value: 'company', child: Text('Sort by Company')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: _firestoreService.getClients(sortBy: _sortBy, descending: _isDescending),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    error: 'Error loading CRM data',
                    onRetry: () => setState(() {}),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: EmptyStateWidget(
                      title: 'Client List Empty',
                      message: 'Add your first high-value client to get started.',
                      icon: Icons.person_add_rounded,
                    ).animate().fadeIn(),
                  );
                }

                final clients = snapshot.data!.where((c) =>
                  c.name.toLowerCase().contains(_searchQuery) ||
                  c.email.toLowerCase().contains(_searchQuery) ||
                  c.company.toLowerCase().contains(_searchQuery)
                ).toList();

                if (clients.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Text(
                      "No matching clients found",
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingS),
                  itemCount: clients.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return _ClientCard(
                      client: client,
                      onTap: () => _showClientDetailSheet(context, client),
                      onEdit: () => _showAddOrEditClientDialog(context, client: client),
                      onDelete: () => _confirmDeleteClient(context, client),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                    .slideY(begin: 0.05);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NestDesignSystem.darkSurface,
        title: const Text('Remove Client?'),
        content: Text('Are you sure you want to remove ${client.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _firestoreService.deleteClient(client.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: NestDesignSystem.error)),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditClientDialog(BuildContext context, {Client? client}) {
    final isEditing = client != null;
    final nameController = TextEditingController(text: client?.name ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final companyController = TextEditingController(text: client?.company ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final notesController = TextEditingController(text: client?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32, left: 24, right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: isEditing ? 'Edit Profile' : 'New Client',
                subtitle: 'Manage client relationship details.',
              ),
              const SizedBox(height: 32),
              InputField(
                label: 'Client Name',
                hint: 'e.g. John Doe',
                prefixIcon: Icons.person_outline_rounded,
                controller: nameController,
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Email Address',
                hint: 'client@example.com',
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Company / Brand',
                hint: 'Organization name',
                prefixIcon: Icons.business_outlined,
                controller: companyController,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Register Client',
                onTap: () {
                  if (nameController.text.isNotEmpty) {
                    final newClient = Client(
                      id: client?.id ?? '',
                      userId: '',
                      name: nameController.text,
                      email: emailController.text,
                      company: companyController.text,
                      phone: phoneController.text,
                      notes: notesController.text,
                      createdAt: client?.createdAt ?? DateTime.now(),
                    );
                    if (isEditing) {
                      _firestoreService.updateClient(newClient);
                    } else {
                      _firestoreService.addClient(newClient);
                    }
                    Navigator.pop(context);
                  }
                },
                icon: isEditing ? Icons.check_circle_outline : Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClientDetailSheet(BuildContext context, Client client) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        client.company.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddOrEditClientDialog(context, client: client);
                  },
                  icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildDetailRow(context, Icons.email_outlined, 'EMAIL ADDRESS', client.email),
            const SizedBox(height: 24),
            _buildDetailRow(context, Icons.phone_outlined, 'PHONE NUMBER', client.phone.isNotEmpty ? client.phone : 'Not provided'),
            const SizedBox(height: 24),
            Text(
              'PRIVATE NOTES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            LayerContainer(
              padding: const EdgeInsets.all(16),
              color: colorScheme.onSurface.withValues(alpha: 0.03),
              child: Text(
                client.notes.isNotEmpty ? client.notes : 'No notes recorded for this client yet.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Close View',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientCard({
    required this.client,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayerContainer(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: NestDesignSystem.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  client.company.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit_note_rounded, size: 22, color: colorScheme.onSurface.withValues(alpha: 0.3))),
          IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline_rounded, size: 22, color: NestDesignSystem.error.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
