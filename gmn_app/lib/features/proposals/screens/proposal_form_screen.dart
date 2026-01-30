import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_spinner.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/formatters.dart';
import '../providers/proposals_provider.dart';
import '../data/models/proposal.dart';
import '../../work_orders/providers/work_orders_provider.dart';
import '../../technicians/providers/technicians_provider.dart';

class ProposalFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const ProposalFormScreen({super.key, this.id});

  @override
  ConsumerState<ProposalFormScreen> createState() => _ProposalFormScreenState();
}

class _ProposalFormScreenState extends ConsumerState<ProposalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _proposalNumberController = TextEditingController();
  final _tripFeeController = TextEditingController(text: '75');
  final _assessmentFeeController = TextEditingController(text: '0');
  final _techHoursController = TextEditingController(text: '1');
  final _techRateController = TextEditingController(text: '85');
  final _helperHoursController = TextEditingController(text: '0');
  final _helperRateController = TextEditingController(text: '45');
  final _ourCostController = TextEditingController(text: '0');
  final _taxRateController = TextEditingController(text: '0');

  String? _workOrderId;
  String? _technicianId;
  String? _helperId;
  List<Part> _parts = [];
  bool _isLoading = false;

  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProposal();
    } else {
      _generateProposalNumber();
    }
  }

  void _generateProposalNumber() {
    final now = DateTime.now();
    _proposalNumberController.text =
        'P-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecond}';
  }

  void _loadProposal() async {
    final proposal = await ref.read(proposalProvider(widget.id!).future);
    setState(() {
      _proposalNumberController.text = proposal.proposalNumber;
      _tripFeeController.text = proposal.tripFee.toString();
      _assessmentFeeController.text = proposal.assessmentFee.toString();
      _techHoursController.text = proposal.techHours.toString();
      _techRateController.text = proposal.techRate.toString();
      _helperHoursController.text = proposal.helperHours.toString();
      _helperRateController.text = proposal.helperRate.toString();
      // Calculate our cost from the stored multiplier (backwards compatible)
      // ourCost = baseCost, so we need to back-calculate it
      final calculatedBaseCost = proposal.tripFee + proposal.assessmentFee + 
          (proposal.techHours * proposal.techRate) + (proposal.helperHours * proposal.helperRate) +
          proposal.parts.fold(0.0, (sum, p) => sum + p.total);
      // If multiplier was used, ourCost was essentially baseCost / multiplier factor
      // For new logic: ourCost is entered directly
      _ourCostController.text = (calculatedBaseCost * 0.74).toStringAsFixed(2); // Default ~74% of base as cost
      _taxRateController.text = (proposal.taxRate * 100).toString();
      _workOrderId = proposal.workOrderId;
      _technicianId = proposal.technicianId;
      _helperId = proposal.helperId;
      _parts = List.from(proposal.parts);
    });
  }

  @override
  void dispose() {
    _proposalNumberController.dispose();
    _tripFeeController.dispose();
    _assessmentFeeController.dispose();
    _techHoursController.dispose();
    _techRateController.dispose();
    _helperHoursController.dispose();
    _helperRateController.dispose();
    _ourCostController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  double get _laborCost {
    final techHours = double.tryParse(_techHoursController.text) ?? 0;
    final techRate = double.tryParse(_techRateController.text) ?? 0;
    final helperHours = double.tryParse(_helperHoursController.text) ?? 0;
    final helperRate = double.tryParse(_helperRateController.text) ?? 0;
    return (techHours * techRate) + (helperHours * helperRate);
  }

  double get _partsCost => _parts.fold(0.0, (sum, part) => sum + part.total);

  double get _baseCost {
    final tripFee = double.tryParse(_tripFeeController.text) ?? 0;
    final assessmentFee = double.tryParse(_assessmentFeeController.text) ?? 0;
    return tripFee + assessmentFee + _laborCost + _partsCost;
  }

  double get _ourCost => double.tryParse(_ourCostController.text) ?? 0;

  double get _subtotal => _baseCost; // Subtotal is now just the base cost (what we charge)

  double get _tax {
    final taxRate = (double.tryParse(_taxRateController.text) ?? 0) / 100;
    return _subtotal * taxRate;
  }

  double get _total => _subtotal + _tax;

  double get _profit => _subtotal - _ourCost;

  double get _profitPercentage {
    if (_subtotal <= 0) return 0;
    return (_profit / _subtotal) * 100;
  }

  // Calculate multiplier for backwards compatibility with backend
  double get _costMultiplier {
    if (_ourCost <= 0) return 1.35; // Default multiplier
    if (_baseCost <= 0) return 1.0;
    return _baseCost / _ourCost;
  }

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersProvider);
    final techniciansAsync = ref.watch(techniciansProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Proposal' : 'New Proposal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _proposalNumberController,
              label: 'Proposal Number',
              hint: 'Auto-generated',
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Work Order dropdown
            _buildLabeledSection(
              label: 'Work Order',
              child: workOrdersAsync.when(
                data: (response) {
                  final workOrders = response.data;
                  return DropdownButtonFormField<String?>(
                    initialValue: _workOrderId,
                    decoration: const InputDecoration(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...workOrders.map(
                        (wo) => DropdownMenuItem(
                          value: wo.id,
                          child: Text('${wo.woNumber} - ${wo.client}'),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _workOrderId = value),
                  );
                },
                loading: () => const LoadingSpinner(),
                error: (_, __) => const Text('Error loading'),
              ),
            ),
            const SizedBox(height: 16),

            // Technician dropdown
            _buildLabeledSection(
              label: 'Technician',
              child: techniciansAsync.when(
                data: (response) {
                  final technicians = response.data;
                  return DropdownButtonFormField<String?>(
                    initialValue: _technicianId,
                    decoration: const InputDecoration(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...technicians
                          .where((t) => !t.isBlacklisted)
                          .map(
                            (tech) => DropdownMenuItem(
                              value: tech.id,
                              child: Text('${tech.name} (${tech.trade})'),
                            ),
                          ),
                    ],
                    onChanged: (value) => setState(() => _technicianId = value),
                  );
                },
                loading: () => const LoadingSpinner(),
                error: (_, __) => const Text('Error loading'),
              ),
            ),
            const SizedBox(height: 16),

            // Helper dropdown
            _buildLabeledSection(
              label: 'Helper (Optional)',
              child: techniciansAsync.when(
                data: (response) {
                  final technicians = response.data;
                  return DropdownButtonFormField<String?>(
                    initialValue: _helperId,
                    decoration: const InputDecoration(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...technicians
                          .where((t) => !t.isBlacklisted && t.id != _technicianId)
                          .map(
                            (tech) => DropdownMenuItem(
                              value: tech.id,
                              child: Text('${tech.name} (${tech.trade})'),
                            ),
                          ),
                    ],
                    onChanged: (value) => setState(() => _helperId = value),
                  );
                },
                loading: () => const LoadingSpinner(),
                error: (_, __) => const Text('Error loading'),
              ),
            ),
            const SizedBox(height: 24),

            // Fees section
            Text(
              'Fees',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _tripFeeController,
                    label: 'Trip Fee',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _assessmentFeeController,
                    label: 'Assessment Fee',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Labor section
            Text(
              'Labor',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _techHoursController,
                    label: 'Tech Hours',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _techRateController,
                    label: 'Tech Rate',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _helperHoursController,
                    label: 'Helper Hours',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _helperRateController,
                    label: 'Helper Rate',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Parts section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Parts & Materials',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addPart,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Part'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_parts.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No parts added',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ..._parts.asMap().entries.map(
                (entry) => _buildPartCard(entry.key, entry.value),
              ),
            const SizedBox(height: 24),

            // Our Cost and Tax
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _ourCostController,
                    label: 'Our Cost',
                    hint: 'What we pay',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _taxRateController,
                    label: 'Tax Rate (%)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary
            CustomCard(
              gradient: AppColors.primaryGradient,
              showBorder: false,
              child: Column(
                children: [
                  _buildSummaryRow('Proposal Charge', _subtotal),
                  _buildSummaryRow('Our Cost', _ourCost),
                  _buildSummaryRow('Profit', _profit),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profit Margin', style: TextStyle(color: Colors.white70)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _profitPercentage >= 100 
                                ? Colors.green.withValues(alpha: 0.3) 
                                : _profitPercentage >= 75 
                                    ? Colors.orange.withValues(alpha: 0.3)
                                    : Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_profitPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _profitPercentage >= 100 
                                  ? Colors.greenAccent 
                                  : _profitPercentage >= 75 
                                      ? Colors.orangeAccent
                                      : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSummaryRow('Tax', _tax),
                  const Divider(color: Colors.white30, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        Formatters.currency(_total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              label: isEditing ? 'Update Proposal' : 'Create Proposal',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledSection({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPartCard(int index, Part part) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${part.quantity}x @ ${Formatters.currency(part.unitPrice)} = ${Formatters.currency(part.total)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _editPart(index),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.error,
            ),
            onPressed: () => setState(() => _parts.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            Formatters.currency(value),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _addPart() {
    _showPartDialog(null);
  }

  void _editPart(int index) {
    _showPartDialog(index);
  }

  void _showPartDialog(int? editIndex) {
    final nameController = TextEditingController(
      text: editIndex != null ? _parts[editIndex].name : '',
    );
    final quantityController = TextEditingController(
      text: editIndex != null ? _parts[editIndex].quantity.toString() : '1',
    );
    final priceController = TextEditingController(
      text: editIndex != null ? _parts[editIndex].unitPrice.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex != null ? 'Edit Part' : 'Add Part'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Part Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Unit Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final part = Part(
                name: nameController.text,
                quantity: int.tryParse(quantityController.text) ?? 1,
                unitPrice: double.tryParse(priceController.text) ?? 0,
              );
              setState(() {
                if (editIndex != null) {
                  _parts[editIndex] = part;
                } else {
                  _parts.add(part);
                }
              });
              Navigator.pop(context);
            },
            child: Text(editIndex != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'proposalNumber': _proposalNumberController.text,
      'tripFee': double.tryParse(_tripFeeController.text) ?? 0,
      'assessmentFee': double.tryParse(_assessmentFeeController.text) ?? 0,
      'techHours': double.tryParse(_techHoursController.text) ?? 0,
      'techRate': double.tryParse(_techRateController.text) ?? 0,
      'helperHours': double.tryParse(_helperHoursController.text) ?? 0,
      'helperRate': double.tryParse(_helperRateController.text) ?? 0,
      'parts': jsonEncode(_parts.map((p) => p.toJson()).toList()),
      'costMultiplier': _costMultiplier,
      'ourCost': _ourCost,
      'taxRate': (double.tryParse(_taxRateController.text) ?? 0) / 100,
      if (_workOrderId != null) 'workOrderId': _workOrderId,
      if (_technicianId != null) 'technicianId': _technicianId,
      if (_helperId != null) 'helperId': _helperId,
    };

    final notifier = ref.read(proposalsNotifierProvider.notifier);
    final result = isEditing
        ? await notifier.update(widget.id!, data)
        : await notifier.create(data);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      showSnackBar(
        context,
        message: isEditing ? 'Proposal updated' : 'Proposal created',
      );
      context.go('/proposals/${result.id}');
    } else if (mounted) {
      showSnackBar(
        context,
        message: 'Failed to ${isEditing ? 'update' : 'create'} proposal',
        isError: true,
      );
    }
  }
}
