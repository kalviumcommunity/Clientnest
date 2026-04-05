import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../providers/project_provider.dart';

class CreateProjectScreen extends StatefulWidget {
  final Project? project;
  const CreateProjectScreen({super.key, this.project});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _clientIdController;
  late final TextEditingController _budgetController;

  late DateTime _deadline;
  late ProjectStatus _status;
  int _priority = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _clientIdController = TextEditingController(text: widget.project?.clientName ?? '');
    _budgetController = TextEditingController(text: widget.project?.budget.toString() ?? '');
    _deadline = widget.project?.deadline ?? DateTime.now().add(const Duration(days: 30));
    _status = widget.project?.status ?? ProjectStatus.active;
    _priority = widget.project?.priority ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientIdController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final budget = double.tryParse(_budgetController.text.replaceAll(',', '')) ?? 0.0;
      
      final project = Project(
        id: widget.project?.id ?? const Uuid().v4(),
        userId: widget.project?.userId ?? uid,
        clientId: _clientIdController.text.trim(),
        clientName: _clientIdController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        priority: _priority,
        budget: budget,
        deadline: _deadline,
        createdAt: widget.project?.createdAt ?? DateTime.now(),
      );

      if (widget.project != null) {
        await context.read<ProjectProvider>().updateProject(project);
      } else {
        await context.read<ProjectProvider>().addProject(project);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.project != null ? 'Project updated successfully!' : 'Project created successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Text(
                    widget.project != null ? 'Edit Project Details' : 'Project Details',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fill in the information below to create your project.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  _buildLabel('Project Title *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(
                      context,
                      hint: 'e.g. Mobile App Redesign',
                      icon: Icons.folder_outlined,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration(
                      context,
                      hint: 'Brief description of the project...',
                      icon: Icons.notes_outlined,
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // Client
                  _buildLabel('Client Name / ID'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _clientIdController,
                    decoration: _inputDecoration(
                      context,
                      hint: 'e.g. Acme Corp',
                      icon: Icons.person_outline_rounded,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // Budget
                  _buildLabel('Budget (\$)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration(
                      context,
                      hint: 'e.g. 5000',
                      icon: Icons.attach_money_rounded,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),

                  // Status
                  _buildLabel('Status'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: DropdownButtonFormField<ProjectStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                      ),
                      dropdownColor: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(
                          value: ProjectStatus.lead,
                          child: Text('Lead'),
                        ),
                        DropdownMenuItem(
                          value: ProjectStatus.pending,
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: ProjectStatus.active,
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: ProjectStatus.completed,
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority
                  _buildLabel('Priority'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _priority,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                      ),
                      dropdownColor: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Low')),
                        DropdownMenuItem(value: 1, child: Text('Medium')),
                        DropdownMenuItem(value: 2, child: Text('High')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _priority = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Deadline
                  _buildLabel('Deadline *'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDeadline,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 18, color: colorScheme.primary),
                          const SizedBox(width: 14),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(_deadline),
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down,
                              color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.project != null ? 'Update Project' : 'Create Project',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
