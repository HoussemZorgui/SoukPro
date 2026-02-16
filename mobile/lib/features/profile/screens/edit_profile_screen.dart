import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

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
  File? _kycDoc;

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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isPro = user?.role == 'professional';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Modifier le Profil', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: Responsive.getFontSize(context, 18))),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1C2D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0B1C2D))) 
      : SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getWidth(context, 6),
          vertical: Responsive.getHeight(context, 2)
        ),
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
                        border: Border.all(color: const Color(0xFFC9A24D).withOpacity(0.5), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: Responsive.getFontSize(context, 60),
                        backgroundColor: Colors.grey[50],
                        backgroundImage: _avatar != null 
                          ? FileImage(_avatar!) 
                          : ((user?.avatar != null && user!.avatar!.isNotEmpty)
                              ? NetworkImage(user!.avatar!.startsWith('http') 
                                  ? user.avatar! 
                                  : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${user.avatar!}') 
                              : null),
                        child: (_avatar == null && (user?.avatar == null || user!.avatar!.isEmpty)) 
                          ? Icon(Icons.camera_alt_outlined, size: Responsive.getFontSize(context, 30), color: const Color(0xFFC9A24D)) 
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
                        color: Color(0xFF0B1C2D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(context, 4)),
            
            _buildTextField(context, _nameController, 'Nom complet', Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(context, _phoneController, 'Numéro de téléphone', Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(context, _addressController, 'Adresse', Icons.location_on_outlined),
            
            if (isPro) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('VÉRIFICATION KYC', 
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.grey[400], fontSize: 11, letterSpacing: 1.5)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: _pickKYC,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A24D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.badge_outlined, color: Color(0xFFC9A24D)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _kycDoc != null ? 'Document prêt' : 'Pièce d\'identité',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: Responsive.getFontSize(context, 14)),
                              ),
                              Text(
                                _kycDoc != null ? 'Cliquez pour changer' : 'Requis pour les boutiques',
                                style: GoogleFonts.outfit(fontSize: Responsive.getFontSize(context, 11), color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        if (_kycDoc != null) const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
            ],

            SizedBox(height: Responsive.getHeight(context, 6)),
            SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B1C2D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text('ENREGISTRER', 
                    style: GoogleFonts.outfit(fontSize: Responsive.getFontSize(context, 15), fontWeight: FontWeight.w800, letterSpacing: 1)),
                )
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: Responsive.getFontSize(context, 15)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0B1C2D).withOpacity(0.5)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0B1C2D), width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: Colors.grey[600], fontWeight: FontWeight.w500),
        floatingLabelStyle: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.bold),
      ),
    );
  }
}
