import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import '../shared/widgets/dashboard_widgets.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _showAddClientDialog(context),
            icon: Icon(Icons.person_add_outlined, color: colorScheme.primary),
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
            return EmptyStateWidget(
              title: 'No Clients Found',
              message: 'Get started by adding your first client profile.',
              icon: Icons.person_add_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return _ClientCard(client: client);
            },
          );
        },
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Client', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(emailController, 'Email Address', Icons.email_outlined),
            const SizedBox(height: 12),
            _buildTextField(companyController, 'Company (Optional)', Icons.business_outlined),
            const SizedBox(height: 12),
            _buildTextField(phoneController, 'Phone Number', Icons.phone_outlined),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final clientProvider = Provider.of<ClientProvider>(context, listen: false);
                  // userId is handled by FirestoreService
                  // I'll use a dummy for now, but I should pass userId
                  // Actually I can get it from AuthService inside provider/service
                  clientProvider.addClient(Client(
                    id: '',
                    userId: '', // Service fills this
                    name: nameController.text,
                    email: emailController.text,
                    company: companyController.text,
                    phone: phoneController.text,
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Profile'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Text(client.name[0].toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (client.company.isNotEmpty)
                  Text(client.company, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(client.email, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.4))),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
