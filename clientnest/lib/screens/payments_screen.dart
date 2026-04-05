import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../models/invoice_model.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'package:clientnest/widgets/status_filter_bar.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import '../core/theme/nest_design_system.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppShell(
      title: 'Finance & Payments',
      actions: [
        IconButton(
          onPressed: () => _showCreateInvoiceModal(context),
          icon: Icon(Icons.add_chart_rounded, color: colorScheme.primary),
          tooltip: 'New Invoice',
        ),
      ],
      child: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              if (provider.allInvoices.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingM),
                  child: _SummaryBanner(
                    totalIncome: provider.totalIncome,
                    totalPending: provider.totalPending,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.02),
              FilterBar<String>(
                selectedStatus: _selectedStatus,
                options: [
                  FilterOption(label: 'all', value: 'All'),
                  FilterOption(label: 'paid', value: 'Paid'),
                  FilterOption(label: 'pending', value: 'Pending'),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              Expanded(
                child: StreamBuilder<List<Invoice>>(
                  stream: _firestoreService.getInvoices(status: _selectedStatus == 'All' ? null : _selectedStatus),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return ErrorStateWidget(
                        error: 'Failed to sync invoices',
                        onRetry: () => setState(() {}),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: EmptyStateWidget(
                          title: 'No Invoices Yet',
                          message: 'Create your first invoice to begin tracking revenue.',
                          icon: Icons.receipt_long_rounded,
                        ).animate().fadeIn(),
                      );
                    }

                    final invoices = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingS),
                      itemCount: invoices.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final invoice = invoices[index];
                        return _InvoiceCard(
                          invoice: invoice,
                          onMarkPaid: invoice.status != 'Paid' ? () => _markPaid(context, invoice) : null,
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
          );
        },
      ),
    );
  }

  Future<void> _markPaid(BuildContext context, Invoice invoice) async {
    final updated = invoice.copyWith(status: 'Paid');
    await _firestoreService.updateInvoice(updated);
  }

  void _showCreateInvoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateInvoiceSheet(
        onSave: (invoice) async {
          await _firestoreService.addInvoice(invoice);
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final double totalIncome;
  final double totalPending;

  const _SummaryBanner({required this.totalIncome, required this.totalPending});

  @override
  Widget build(BuildContext context) {
    return LayerContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'REVENUE',
            value: '\$${totalIncome.toStringAsFixed(0)}',
            color: NestDesignSystem.graphGreen,
            icon: Icons.check_circle_outline_rounded,
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          _SummaryItem(
            label: 'PENDING',
            value: '\$${totalPending.toStringAsFixed(0)}',
            color: NestDesignSystem.graphOrange,
            icon: Icons.hourglass_empty_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.5), size: 10),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onMarkPaid;

  const _InvoiceCard({required this.invoice, this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = invoice.status == 'Paid';

    return LayerContainer(
      margin: const EdgeInsets.only(bottom: NestDesignSystem.spacingM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    invoice.clientName.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isPaid ? NestDesignSystem.graphGreen : NestDesignSystem.graphOrange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.status.toUpperCase(),
                  style: TextStyle(
                    color: isPaid ? NestDesignSystem.graphGreen : NestDesignSystem.graphOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: colorScheme.onSurface.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${invoice.amount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.0),
              ),
              Row(
                children: [
                  if (onMarkPaid != null)
                    SecondaryButton(
                      label: 'Mark Paid',
                      onTap: onMarkPaid!,
                      icon: Icons.check_rounded,
                      small: true,
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => PdfService.generateInvoice(invoice),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 20,
                      color: NestDesignSystem.graphCyan,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateInvoiceSheet extends StatefulWidget {
  final Future<void> Function(Invoice invoice) onSave;

  const _CreateInvoiceSheet({required this.onSave});

  @override
  State<_CreateInvoiceSheet> createState() => _CreateInvoiceSheetState();
}

class _CreateInvoiceSheetState extends State<_CreateInvoiceSheet> {
  final _numController = TextEditingController();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            const SectionHeader(
              title: 'Generate Invoice',
              subtitle: 'Create a new payment request.',
            ),
            const SizedBox(height: 32),
            InputField(
              label: 'Invoice Number',
              hint: 'INV-001',
              prefixIcon: Icons.tag_rounded,
              controller: _numController,
            ),
            const SizedBox(height: 20),
            InputField(
              label: 'Client / Project',
              hint: 'Name of the payer',
              prefixIcon: Icons.person_outline_rounded,
              controller: _clientController,
            ),
            const SizedBox(height: 20),
            InputField(
              label: 'Total Amount (\$)',
              hint: '0.00',
              prefixIcon: Icons.attach_money_rounded,
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onTap: () {
                final invoice = Invoice(
                  id: '',
                  userId: '',
                  clientId: '',
                  clientName: _clientController.text,
                  projectId: '',
                  invoiceNumber: _numController.text,
                  amount: double.tryParse(_amountController.text) ?? 0,
                  status: 'Pending',
                  issueDate: DateTime.now(),
                  dueDate: DateTime.now(),
                  items: [],
                );
                widget.onSave(invoice);
                Navigator.pop(context);
              },
              label: 'Create Invoice',
              icon: Icons.receipt_long_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
