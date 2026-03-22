import 'package:flutter/material.dart';
import 'package:greenbasket_app/config/theme.dart';

// TODO: Connect to AgentController, load profile from GET /agent/profile, save to PATCH /agent/profile

class EditAgentProfileScreen extends StatefulWidget {
  const EditAgentProfileScreen({super.key});

  @override
  State<EditAgentProfileScreen> createState() => _EditAgentProfileScreenState();
}

class _EditAgentProfileScreenState extends State<EditAgentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers — pre-filled with mock data
  final _nameController = TextEditingController(text: 'Ravi Kumar');
  final _emailController =
      TextEditingController(text: 'ravi.kumar@example.com');
  final _addressController = TextEditingController(
      text: 'Flat 3B, Sunshine Apartments, HSR Layout, Bengaluru');
  final _vehicleMakeController = TextEditingController(text: 'Honda');
  final _vehicleModelController = TextEditingController(text: 'Activa 6G');
  final _vehicleRegController = TextEditingController(text: 'KA01AB1234');
  final _vehicleYearController = TextEditingController(text: '2022');

  String _selectedVehicleType = '2-Wheeler';
  final List<String> _vehicleTypes = ['2-Wheeler', '3-Wheeler', '4-Wheeler'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleRegController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildPersonalInfoSection(),
              const SizedBox(height: AppSpacing.md),
              _buildVehicleSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSaveButton(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.person, size: 56, color: AppColors.primary),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: Open image picker
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt,
                    size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _section(
      title: 'Personal Information',
      child: Column(
        children: [
          _field(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          // Phone — read only, verified
          TextFormField(
            initialValue: '+91 98765 43210',
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Phone',
              prefixIcon: const Icon(Icons.phone_outlined),
              suffixIcon: Container(
                margin: const EdgeInsets.all(AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Verified',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
              filled: true,
              fillColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _field(
            controller: _addressController,
            label: 'Address',
            icon: Icons.home_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    return _section(
      title: 'Vehicle Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Type',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Vehicle type chips
          Wrap(
            spacing: AppSpacing.sm,
            children: _vehicleTypes.map((type) {
              final isSelected = _selectedVehicleType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedVehicleType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type == '4-Wheeler'
                            ? Icons.directions_car_outlined
                            : type == '3-Wheeler'
                                ? Icons.electric_rickshaw_outlined
                                : Icons.two_wheeler_outlined,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        type,
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: _vehicleMakeController,
                  label: 'Make (Brand)',
                  icon: Icons.directions_car_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _field(
                  controller: _vehicleModelController,
                  label: 'Model',
                  icon: Icons.two_wheeler_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  controller: _vehicleRegController,
                  label: 'Registration No.',
                  icon: Icons.confirmation_number_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _field(
                  controller: _vehicleYearController,
                  label: 'Year',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            // TODO: Call PATCH /agent/profile with form data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
        },
        child: const Text('Save Changes'),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          const Divider(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
