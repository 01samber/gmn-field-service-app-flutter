import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_exceptions.dart';
import '../providers/work_orders_provider.dart';
import '../data/models/work_order.dart';
import '../../technicians/providers/technicians_provider.dart';

class WorkOrderFormScreen extends ConsumerStatefulWidget {
  final String? workOrderId;

  const WorkOrderFormScreen({super.key, this.workOrderId});

  @override
  ConsumerState<WorkOrderFormScreen> createState() =>
      _WorkOrderFormScreenState();
}

class _WorkOrderFormScreenState extends ConsumerState<WorkOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedTrade = AppConstants.trades.first;
  String _selectedPriority = 'normal';
  String _selectedStatus = 'waiting';
  String? _selectedTechnicianId;
  DateTime? _etaAt;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.workOrderId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadWorkOrder();
    }
  }

  Future<void> _loadWorkOrder() async {
    final workOrder = await ref.read(
      workOrderProvider(widget.workOrderId!).future,
    );
    setState(() {
      _clientController.text = workOrder.client;
      _descriptionController.text = workOrder.description ?? '';
      _nteController.text = workOrder.nte > 0 ? workOrder.nte.toString() : '';
      _addressController.text = workOrder.address ?? '';
      _cityController.text = workOrder.city ?? '';
      _stateController.text = workOrder.state ?? '';
      _notesController.text = workOrder.notes ?? '';
      _selectedTrade = workOrder.trade;
      _selectedPriority = workOrder.priority;
      _selectedStatus = workOrder.status;
      _selectedTechnicianId = workOrder.technicianId;
      _etaAt = workOrder.etaAt;
    });
  }

  @override
  void dispose() {
    _clientController.dispose();
    _descriptionController.dispose();
    _nteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (isEditing) {
        await ref
            .read(workOrdersNotifierProvider.notifier)
            .updateWorkOrder(
              widget.workOrderId!,
              UpdateWorkOrderRequest(
                client: _clientController.text.trim(),
                trade: _selectedTrade,
                description: _descriptionController.text.trim(),
                nte: double.tryParse(_nteController.text) ?? 0,
                status: _selectedStatus,
                priority: _selectedPriority,
                address: _addressController.text.trim(),
                city: _cityController.text.trim(),
                state: _stateController.text.trim(),
                notes: _notesController.text.trim(),
                etaAt: _etaAt,
                technicianId: _selectedTechnicianId,
              ),
            );
      } else {
        await ref
            .read(workOrdersNotifierProvider.notifier)
            .createWorkOrder(
              CreateWorkOrderRequest(
                client: _clientController.text.trim(),
                trade: _selectedTrade,
                description: _descriptionController.text.trim(),
                nte: double.tryParse(_nteController.text) ?? 0,
                status: _selectedStatus,
                priority: _selectedPriority,
                address: _addressController.text.trim(),
                city: _cityController.text.trim(),
                state: _stateController.text.trim(),
                etaAt: _etaAt,
                technicianId: _selectedTechnicianId,
              ),
            );
      }

      if (mounted) {
        context.pop();
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _etaAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_etaAt ?? DateTime.now()),
    );
    if (time == null || !mounted) return;

    setState(() {
      _etaAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final techniciansAsync = ref.watch(techniciansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Work Order' : 'New Work Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error Message
            if (_errorMessage != null) ...[
              ErrorMessage(message: _errorMessage!, compact: true),
              const SizedBox(height: 16),
            ],

            // Client
            TextFormField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: 'Client Name *',
                hintText: 'Enter client name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Client name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Trade
            DropdownButtonFormField<String>(
              value: _selectedTrade,
              decoration: const InputDecoration(
                labelText: 'Trade *',
                prefixIcon: Icon(Icons.build_outlined),
              ),
              items: AppConstants.trades
                  .map(
                    (trade) =>
                        DropdownMenuItem(value: trade, child: Text(trade)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTrade = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: AppConstants.priorities
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(_formatLabel(priority)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Status (only for editing)
            if (isEditing) ...[
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: AppConstants.workOrderStatuses
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_formatLabel(status)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // NTE
            TextFormField(
              controller: _nteController,
              decoration: const InputDecoration(
                labelText: 'NTE (Not To Exceed)',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),

            // Technician
            techniciansAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (response) => DropdownButtonFormField<String?>(
                value: _selectedTechnicianId,
                decoration: const InputDecoration(
                  labelText: 'Assign Technician',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Not assigned'),
                  ),
                  ...response.data.map(
                    (tech) => DropdownMenuItem(
                      value: tech.id,
                      child: Text('${tech.name} (${tech.trade})'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedTechnicianId = value);
                },
              ),
            ),
            const SizedBox(height: 16),

            // ETA
            InkWell(
              onTap: _selectDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'ETA',
                  prefixIcon: Icon(Icons.schedule),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _etaAt != null
                      ? '${_etaAt!.month}/${_etaAt!.day}/${_etaAt!.year} ${_etaAt!.hour}:${_etaAt!.minute.toString().padLeft(2, '0')}'
                      : 'Select date and time',
                  style: TextStyle(
                    color: _etaAt != null
                        ? null
                        : (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Street address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // City and State
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'City',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      hintText: 'TX',
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Work order description',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Notes (only for editing)
            if (isEditing) ...[
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Additional notes',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Work Order' : 'Create Work Order',
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
