import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/company_profile.dart';
import '../services/company_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _gstController;
  late TextEditingController _panController;
  String? _logoPath;
  String? _signaturePath;
  int? _profileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await CompanyService.instance.getCompany();
    setState(() {
      _profileId = profile.id;
      _nameController = TextEditingController(text: profile.companyName);
      _addressController = TextEditingController(text: profile.address ?? '');
      _cityController = TextEditingController(text: profile.city ?? '');
      _stateController = TextEditingController(text: profile.state ?? '');
      _pincodeController = TextEditingController(text: profile.pincode ?? '');
      _phoneController = TextEditingController(text: profile.phone ?? '');
      _emailController = TextEditingController(text: profile.email ?? '');
      _websiteController = TextEditingController(text: profile.website ?? '');
      _gstController = TextEditingController(text: profile.gstNumber ?? '');
      _panController = TextEditingController(text: profile.panNumber ?? '');
      _logoPath = profile.logoPath;
      _signaturePath = profile.signaturePath;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _gstController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoPath = pickedFile.path;
        } else {
          _signaturePath = pickedFile.path;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = CompanyProfile(
      id: _profileId,
      companyName: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteController.text.trim(),
      gstNumber: _gstController.text.trim(),
      panNumber: _panController.text.trim(),
      logoPath: _logoPath,
      signaturePath: _signaturePath,
    );

    if (_profileId == null) {
      await CompanyService.instance.saveCompany(profile);
    } else {
      await CompanyService.instance.updateCompany(profile);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company profile saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Company Information'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter company name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Contact Information'),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Business Information'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gstController,
                      decoration: const InputDecoration(
                        labelText: 'GST Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _panController,
                      decoration: const InputDecoration(
                        labelText: 'PAN Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Branding'),
              Row(
                children: [
                  Expanded(
                    child: _buildImagePicker(
                      'Company Logo',
                      _logoPath,
                      () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImagePicker(
                      'Signature',
                      _signaturePath,
                      () => _pickImage(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text(
                    'SAVE COMPANY PROFILE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, String? imagePath, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(imagePath), fit: BoxFit.contain),
                  )
                : const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
          ),
        ),
        if (imagePath != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() {
                if (label == 'Company Logo') {
                  _logoPath = null;
                } else {
                  _signaturePath = null;
                }
              }),
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
              label: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ),
      ],
    );
  }
}
