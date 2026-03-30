import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'package:clientnest/widgets/premium_background.dart';
import 'dart:ui';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

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
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
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
            
            final clients = provider.clients;
            if (clients.isEmpty) {
              return const EmptyStateWidget(
                title: 'No Clients Found',
                message: 'Get started by adding your first client profile.',
                icon: Icons.person_add_rounded,
              ).animate().fadeIn();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 100),
              physics: const BouncingScrollPhysics(),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return _ClientCard(
                  client: client,
                  onEdit: () => _showAddOrEditClientDialog(context, client: client),
                  onDelete: () => _confirmDeleteClient(context, client),
                ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
              },
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
              Provider.of<ClientProvider>(context, listen: false).deleteClient(client.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextField(nameController, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(emailController, 'Email Address', Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(companyController, 'Company (Optional)', Icons.business_outlined),
              const SizedBox(height: 16),
              _buildTextField(phoneController, 'Phone Number', Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildTextField(notesController, 'Notes (Optional)', Icons.notes_outlined, maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                        
                        if (isEditing) {
                          clientProvider.updateClient(
                            client!.copyWith(
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
                              userId: '', // Service fills this
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'client_avatar_${client.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        client.name[0].toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
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
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      if (client.company.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            client.company, 
                            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              client.email, 
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          SizedBox(width: 12),
                          Text('Delete Client', style: TextStyle(color: Colors.redAccent)),
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
