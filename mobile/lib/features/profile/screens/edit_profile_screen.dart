import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../auth/providers/auth_provider.dart';
import 'package:dio/dio.dart'; // For upload
import '../../../core/constants/api_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  File? _avatar;
  File? _kycDoc; // Simpler single doc for basic version

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

    Future<void> _pickKYC() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _kycDoc = File(picked.path));
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
       final success = await Provider.of<AuthProvider>(context, listen: false).updateProfile(
         _nameController.text,
         _phoneController.text,
         _addressController.text,
         _avatar,
         _kycDoc
       );

       if (success && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
           Navigator.pop(context);
       } else if (mounted) {
           final error = Provider.of<AuthProvider>(context, listen: false).errorMessage;
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Échec de la mise à jour')));
       }

    } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is professional
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isPro = user?.role == 'professional';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Modifier le Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                   GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: _avatar != null 
                          ? FileImage(_avatar!) 
                          : ((user?.avatar != null && user!.avatar!.isNotEmpty)
                              ? NetworkImage(user!.avatar!.startsWith('http') 
                                  ? user.avatar! 
                                  : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${user.avatar!}') 
                              : null),
                        child: (_avatar == null && (user?.avatar == null || user!.avatar!.isEmpty)) 
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.blueAccent) 
                          : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            _buildTextField(_nameController, 'Nom complet', Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Numéro de téléphone', Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(_addressController, 'Adresse', Icons.location_on_outlined),
            
            if (isPro) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('VÉRIFICATION KYC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickKYC,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.file_present_outlined, color: Colors.blueAccent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _kycDoc != null ? 'Document sélectionné' : 'Télécharger une pièce d\'identité ou licence',
                            style: TextStyle(color: _kycDoc != null ? Colors.black : Colors.grey[600]),
                          ),
                        ),
                        if (_kycDoc != null) const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 48),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  child: const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}
