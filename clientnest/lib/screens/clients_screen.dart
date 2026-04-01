import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'dart:ui';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'CRM Dashboard',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddOrEditClientDialog(context),
            icon: Icon(Icons.person_add_outlined, color: colorScheme.primary),
            tooltip: 'Add Client',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ClientProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return ErrorStateWidget(
              error: provider.error!,
              onRetry: () => provider.fetchClients(),
            );
          }

          if (provider.isLoading && provider.clients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allClients = provider.clients;
          final filtered = _searchQuery.isEmpty
              ? allClients
              : allClients
                  .where((c) =>
                      c.name.toLowerCase().contains(_searchQuery) ||
                      c.email.toLowerCase().contains(_searchQuery) ||
                      c.company.toLowerCase().contains(_searchQuery))
                  .toList();

          return RefreshIndicator(
            onRefresh: () async => provider.fetchClients(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: [
                // Space for AppBar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search clients…',
                          hintStyle: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      size: 18,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.4)),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      title: _searchQuery.isNotEmpty
                          ? 'No Results Found'
                          : 'No Clients Found',
                      message: _searchQuery.isNotEmpty
                          ? 'Try a different name, email, or company.'
                          : 'Get started by adding your first client profile.',
                      icon: _searchQuery.isNotEmpty
                          ? Icons.search_off_rounded
                          : Icons.person_add_rounded,
                    ).animate().fadeIn(),
                  )
                else
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final client = filtered[index];
                          return _ClientCard(
                            client: client,
                            onEdit: () => _showAddOrEditClientDialog(
                                context,
                                client: client),
                            onDelete: () =>
                                _confirmDeleteClient(context, client),
                          )
                              .animate()
                              .fadeIn(
                                  duration: 350.ms,
                                  delay: (index * 40).ms)
                              .slideX(begin: 0.08, end: 0);
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ClientProvider>(context, listen: false)
                  .deleteClient(client.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditClientDialog(BuildContext context, {Client? client}) {
    final isEditing = client != null;
    final nameController =
        TextEditingController(text: client?.name ?? '');
    final emailController =
        TextEditingController(text: client?.email ?? '');
    final companyController =
        TextEditingController(text: client?.company ?? '');
    final phoneController =
        TextEditingController(text: client?.phone ?? '');
    final notesController =
        TextEditingController(text: client?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isEditing ? 'Edit Client' : 'Add New Client',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                  nameController, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(emailController, 'Email Address',
                  Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(companyController,
                  'Company (Optional)', Icons.business_outlined),
              const SizedBox(height: 16),
              _buildTextField(phoneController, 'Phone Number',
                  Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildTextField(notesController,
                  'Notes (Optional)', Icons.notes_outlined,
                  maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final clientProvider =
                            Provider.of<ClientProvider>(context,
                                listen: false);
                        if (isEditing) {
                          // Use early-return guard for type promotion (avoids both
                          // unnecessary_non_null_assertion and unnecessary_null_comparison).
                          final c = client;
                          if (c == null) return; // unreachable at runtime: isEditing ⟹ client ≠ null
                          clientProvider.updateClient(
                            c.copyWith(
                              name: nameController.text,
                              email: emailController.text,
                              company: companyController.text,
                              phone: phoneController.text,
                              notes: notesController.text,
                            ),
                          );
                        } else {
                          clientProvider.addClient(
                            Client(
                              id: '',
                              userId: '',
                              name: nameController.text,
                              email: emailController.text,
                              company: companyController.text,
                              phone: phoneController.text,
                              notes: notesController.text,
                              createdAt: DateTime.now(),
                            ),
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      isEditing ? 'Update Profile' : 'Create Profile',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }
}

// ─── Client Card ───────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientCard({
    required this.client,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'client_avatar_${client.id}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (client.company.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            client.company,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 13,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              client.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz,
                      color:
                          colorScheme.onSurface.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 12),
                          Text('Edit Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: Colors.redAccent),
                          SizedBox(width: 12),
                          Text('Delete Client',
                              style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
