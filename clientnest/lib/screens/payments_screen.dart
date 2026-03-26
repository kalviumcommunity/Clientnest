import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import '../services/pdf_service.dart';
import '../models/invoice_model.dart';
import '../shared/widgets/dashboard_widgets.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

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
          'Financial Suite',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return ErrorStateWidget(
              error: provider.error!,
              onRetry: () => provider.fetchInvoices(),
            );
          }

          if (provider.isLoading && provider.invoices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final invoices = provider.invoices;
          if (invoices.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Invoices',
              message:
                  'Your financial portfolio is empty. Tap + to create your first invoice.',
              icon: Icons.receipt_long_rounded,
            ).animate().fadeIn();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 100, bottom: 120),
            physics: const BouncingScrollPhysics(),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              return _InvoiceCard(invoice: invoices[index])
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: FloatingActionButton.extended(
          heroTag: 'payments_screen_fab',
          onPressed: () => _showCreateInvoiceModal(context),
          label: const Text('New Invoice',
              style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add),
          elevation: 4,
        ),
      ),
    );
  }

  void _showCreateInvoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateInvoiceSheet(
        onSave: (invoice) async {
          try {
            await Provider.of<InvoiceProvider>(context, listen: false)
                .addInvoice(invoice);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Invoice created!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create invoice: $e'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// ── Invoice Card ─────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = invoice.status == 'Paid';

    return Dismissible(
      key: Key(invoice.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Invoice'),
            content: Text('Delete "${invoice.invoiceNumber}"?'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<InvoiceProvider>(context, listen: false)
            .deleteInvoice(invoice.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice "${invoice.invoiceNumber}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.clientName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invoice.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${invoice.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => PdfService.generateInvoice(invoice),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.08),
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Invoice Sheet ──────────────────────────────────────────────────────

class _CreateInvoiceSheet extends StatefulWidget {
  final Future<void> Function(Invoice invoice) onSave;

  const _CreateInvoiceSheet({required this.onSave});

  @override
  State<_CreateInvoiceSheet> createState() => _CreateInvoiceSheetState();
}

class _CreateInvoiceSheetState extends State<_CreateInvoiceSheet> {
  final _invoiceNumberController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _status = 'Pending';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _clientNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final num = _invoiceNumberController.text.trim();
    final client = _clientNameController.text.trim();
    final amountText = _amountController.text.trim();

    if (num.isEmpty || client.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', ''));
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount must be a valid number.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final invoice = Invoice(
      id: '',
      userId: '',
      clientId: '',
      clientName: client,
      projectId: '',
      invoiceNumber: num,
      amount: amount,
      status: _status,
      issueDate: DateTime.now(),
      dueDate: _dueDate,
      items: [],
    );

    Navigator.pop(context);
    await widget.onSave(invoice);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
            const Text(
              'Create New Invoice',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Invoice Number
            _buildTextField(
              _invoiceNumberController,
              'Invoice Number *',
              Icons.tag_rounded,
              hint: 'e.g. INV-001',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Client Name
            _buildTextField(
              _clientNameController,
              'Client Name *',
              Icons.person_outline,
              hint: 'e.g. Acme Corp',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Amount
            _buildTextField(
              _amountController,
              'Amount (\$) *',
              Icons.attach_money_rounded,
              hint: 'e.g. 1500',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            _buildDropdown(colorScheme),
            const SizedBox(height: 16),

            // Due Date
            _buildDateTile(colorScheme),
            const SizedBox(height: 32),

            // Save Button
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Invoice',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.08, end: 0);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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

  Widget _buildDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: const [
            DropdownMenuItem(
              value: 'Pending',
              child: Row(
                children: [
                  Icon(Icons.pending_outlined,
                      size: 18, color: Colors.orange),
                  SizedBox(width: 12),
                  Text('Pending'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Paid',
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: Colors.green),
                  SizedBox(width: 12),
                  Text('Paid'),
                ],
              ),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _status = v);
          },
        ),
      ),
    );
  }

  Widget _buildDateTile(ColorScheme colorScheme) {
    return InkWell(
      onTap: _pickDueDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: colorScheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(_dueDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down,
                color: colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
