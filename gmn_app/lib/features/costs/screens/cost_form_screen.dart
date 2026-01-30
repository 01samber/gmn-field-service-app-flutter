import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/validators.dart';
import '../providers/costs_provider.dart';
import '../../work_orders/providers/work_orders_provider.dart';
import '../../technicians/providers/technicians_provider.dart';

class CostFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const CostFormScreen({super.key, this.id});

  @override
  ConsumerState<CostFormScreen> createState() => _CostFormScreenState();
}

class _CostFormScreenState extends ConsumerState<CostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _workOrderId;
  String? _technicianId;
  bool _isLoading = false;

  bool get isEditing => widget.id != null;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersProvider);
    final techniciansAsync = ref.watch(techniciansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Cost' : 'Request Payment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _amountController,
              label: 'Amount',
              hint: 'Enter amount',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money),
              validator: (value) => Validators.number(value, min: 0.01, fieldName: 'Amount'),
            ),
            const SizedBox(height: 16),

            // Work Order dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Order',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                workOrdersAsync.when(
                  data: (response) {
                    final workOrders = response.data;
                    return DropdownButtonFormField<String?>(
                      value: _workOrderId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      hint: const Text('Select work order'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...workOrders.map((wo) {
                          return DropdownMenuItem(
                            value: wo.id,
                            child: Text('${wo.woNumber} - ${wo.client}'),
                          );
                        }),
                      ],
                      onChanged: (value) => setState(() => _workOrderId = value),
                    );
                  },
                  loading: () => const LoadingSpinner(),
                  error: (_, __) => const Text('Error loading work orders'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Technician dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Technician',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                techniciansAsync.when(
                  data: (response) {
                    final technicians = response.data;
                    return DropdownButtonFormField<String?>(
                      value: _technicianId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      hint: const Text('Select technician'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...technicians.where((t) => !t.isBlacklisted).map((tech) {
                          return DropdownMenuItem(
                            value: tech.id,
                            child: Text('${tech.name} (${tech.trade})'),
                          );
                        }),
                      ],
                      onChanged: (value) => setState(() => _technicianId = value),
                    );
                  },
                  loading: () => const LoadingSpinner(),
                  error: (_, __) => const Text('Error loading technicians'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _noteController,
              label: 'Note',
              hint: 'Add a note (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            CustomButton(
              label: isEditing ? 'Update Request' : 'Submit Request',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'amount': double.tryParse(_amountController.text) ?? 0,
      if (_workOrderId != null) 'workOrderId': _workOrderId,
      if (_technicianId != null) 'technicianId': _technicianId,
      if (_noteController.text.isNotEmpty) 'note': _noteController.text.trim(),
    };

    final notifier = ref.read(costsNotifierProvider.notifier);
    final result = isEditing
        ? await notifier.update(widget.id!, data)
        : await notifier.create(data);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      showSnackBar(
        context,
        message: isEditing ? 'Cost updated' : 'Payment request submitted',
      );
      context.go('/costs');
    } else if (mounted) {
      showSnackBar(
        context,
        message: 'Failed to ${isEditing ? 'update' : 'submit'} request',
        isError: true,
      );
    }
  }
}
