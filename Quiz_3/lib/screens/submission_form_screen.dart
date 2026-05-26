import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submission_model.dart';
import '../services/supabase_service.dart';

class SubmissionFormScreen extends StatefulWidget {
  final SubmissionModel? submission;

  const SubmissionFormScreen({super.key, this.submission});

  @override
  State<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends State<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  bool get _isEditing => widget.submission != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.submission?.fullName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.submission?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.submission?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.submission?.address ?? '',
    );
    _selectedGender = widget.submission?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Input Validation Logic
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    // Simple Email Regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    // Simple digits and formatting symbols regex
    final phoneRegex = RegExp(r'^\+?[0-9\-\s\(\)]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your address';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters long';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || !_genders.contains(value)) {
      return 'Please select your gender';
    }
    return null;
  }

  // Handle Form Submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final submissionData = SubmissionModel(
      id: widget.submission?.id,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      gender: _selectedGender!,
      createdAt: widget.submission?.createdAt,
    );

    try {
      if (_isEditing) {
        await SupabaseService.updateSubmission(submissionData);
        if (!mounted) return;
        _showSnackBar('Submission updated successfully!', Colors.green);
      } else {
        await SupabaseService.createSubmission(submissionData);
        if (!mounted) return;
        _showSnackBar('Submission recorded successfully!', Colors.green);
      }
      if (mounted) {
        Navigator.pop(context, true); // Pop with results to reload list screen
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Error: ${e.toString()}',
        Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(
            context,
          ).unfocus(), // Dismiss keyboard on tapping background
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form header card with styling
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                theme.colorScheme.primary.withOpacity(0.15),
                                theme.colorScheme.secondary.withOpacity(0.05),
                              ]
                            : [
                                theme.colorScheme.primary.withOpacity(0.08),
                                theme.colorScheme.secondary.withOpacity(0.03),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isEditing
                                ? Icons.edit_note_rounded
                                : Icons.assignment_rounded,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing
                                    ? 'Update Records'
                                    : 'Share Information',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEditing
                                    ? 'Modify any field below to update details in Supabase'
                                    : 'Please fill in details below to store your submission',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Fields Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Full Name Input
                          TextFormField(
                            controller: _nameController,
                            validator: _validateName,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Number Input
                          TextFormField(
                            controller: _phoneController,
                            validator: _validatePhone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(
                                Icons.phone_android_rounded,
                                size: 22,
                              ),
                              hintText: 'e.g. +92 300 1234567',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Address Input
                          TextFormField(
                            controller: _addressController,
                            validator: _validateAddress,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Residential Address',
                              prefixIcon: Icon(
                                Icons.home_rounded,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Gender Selection
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            validator: _validateGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.wc_rounded, size: 22),
                            ),
                            items: _genders.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: GoogleFonts.outfit(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            dropdownColor:
                                theme.cardTheme.color ??
                                theme.colorScheme.surface,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Submit Entry',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
