import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_exceptions.dart';
import '../providers/technicians_provider.dart';
import '../data/models/technician.dart';

class TechnicianFormScreen extends ConsumerStatefulWidget {
  final String? technicianId;

  const TechnicianFormScreen({super.key, this.technicianId});

  @override
  ConsumerState<TechnicianFormScreen> createState() =>
      _TechnicianFormScreenState();
}

class _TechnicianFormScreenState extends ConsumerState<TechnicianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _notesController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  String _selectedTrade = AppConstants.trades.first;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.technicianId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadTechnician();
    }
  }

  Future<void> _loadTechnician() async {
    final technician = await ref.read(
      technicianProvider(widget.technicianId!).future,
    );
    setState(() {
      _nameController.text = technician.name;
      _phoneController.text = technician.phone ?? '';
      _emailController.text = technician.email ?? '';
      _addressController.text = technician.address ?? '';
      _cityController.text = technician.city ?? '';
      _stateController.text = technician.state ?? '';
      _zipCodeController.text = technician.zipCode ?? '';
      _notesController.text = technician.notes ?? '';
      _hourlyRateController.text = technician.hourlyRate > 0
          ? technician.hourlyRate.toString()
          : '';
      _selectedTrade = technician.trade;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _notesController.dispose();
    _hourlyRateController.dispose();
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
            .read(techniciansNotifierProvider.notifier)
            .updateTechnician(
              widget.technicianId!,
              UpdateTechnicianRequest(
                name: _nameController.text.trim(),
                trade: _selectedTrade,
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                address: _addressController.text.trim(),
                city: _cityController.text.trim(),
                state: _stateController.text.trim(),
                zipCode: _zipCodeController.text.trim(),
                notes: _notesController.text.trim(),
                hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0,
              ),
            );
      } else {
        await ref
            .read(techniciansNotifierProvider.notifier)
            .createTechnician(
              CreateTechnicianRequest(
                name: _nameController.text.trim(),
                trade: _selectedTrade,
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                address: _addressController.text.trim(),
                city: _cityController.text.trim(),
                state: _stateController.text.trim(),
                zipCode: _zipCodeController.text.trim(),
                notes: _notesController.text.trim(),
                hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Technician' : 'Add Technician'),
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

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter technician name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
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

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Hourly Rate
            TextFormField(
              controller: _hourlyRateController,
              decoration: const InputDecoration(
                labelText: 'Hourly Rate',
                hintText: 'Enter hourly rate',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),

            // Address Section
            Text(
              'Address',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                hintText: 'Enter street address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // City, State, Zip
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'City',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      hintText: 'TX',
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Zip',
                      hintText: '12345',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notes
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
            const SizedBox(height: 32),

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
                    : Text(isEditing ? 'Update Technician' : 'Add Technician'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
