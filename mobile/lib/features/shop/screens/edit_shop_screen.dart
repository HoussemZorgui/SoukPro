import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import '../providers/shop_provider.dart';
import 'location_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_constants.dart';

class EditShopScreen extends StatefulWidget {
  final Map<String, dynamic> shop;
  const EditShopScreen({super.key, required this.shop});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _shopAddressController;
  late TextEditingController _phoneController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _websiteController;
  
  String? _selectedGovernorate;
  final List<String> _governorates = [
    'Ariana', 'Beja', 'Ben Arous', 'Bizerte', 'Gabes', 'Gafsa', 'Jendouba', 
    'Kairouan', 'Kasserine', 'Kebili', 'Kef', 'Mahdia', 'Manouba', 
    'Medenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana', 
    'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
  ];
  
  LatLng? _selectedLocation;
  
  File? _logo;
  File? _banner;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop['name']);
    _descController = TextEditingController(text: widget.shop['description']);
    _shopAddressController = TextEditingController(text: widget.shop['shopAddress'] ?? '');
    _phoneController = TextEditingController(text: widget.shop['phone'] ?? '');
    
    final social = widget.shop['socialLinks'] ?? {};
    _facebookController = TextEditingController(text: social['facebook'] ?? '');
    _instagramController = TextEditingController(text: social['instagram'] ?? '');
    _websiteController = TextEditingController(text: social['website'] ?? '');
    
    _selectedGovernorate = widget.shop['governorate'];
    
    if (widget.shop['location'] != null && widget.shop['location']['lat'] != null) {
      _selectedLocation = LatLng(
        (widget.shop['location']['lat'] as num).toDouble(),
        (widget.shop['location']['lng'] as num).toDouble(),
      );
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logo = File(image.path);
        } else {
          _banner = File(image.path);
        }
      });
    }
  }

  void _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir le nom de la boutique')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await Provider.of<ShopProvider>(context, listen: false).createShop(
        name: _nameController.text,
        description: _descController.text,
        shopAddress: _shopAddressController.text,
        governorate: _selectedGovernorate,
        phone: _phoneController.text,
        facebook: _facebookController.text,
        instagram: _instagramController.text,
        website: _websiteController.text,
        location: _selectedLocation,
        logo: _logo,
        banner: _banner,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Boutique mise à jour avec succès !', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de la mise à jour')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally { 
       if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Modifier ma Boutique', 
          style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            FadeInDown(child: _buildImagePickers()),

            const SizedBox(height: 40),
            
            FadeInUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("INFORMATIONS GÉNÉRALES", 
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D).withOpacity(0.5), letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, "Nom commercial", Icons.store_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(_descController, "Description", Icons.description_outlined, maxLines: 4),
                  const SizedBox(height: 16),
                  _buildTextField(_shopAddressController, "Adresse physique", Icons.location_on_outlined),
                  const SizedBox(height: 16),
                  _buildGovernorateDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, "Téléphone", Icons.phone_android_rounded),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("RÉSEAUX SOCIAUX", 
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D).withOpacity(0.5), letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  _buildTextField(_facebookController, "Facebook Link", Icons.facebook),
                  const SizedBox(height: 12),
                  _buildTextField(_instagramController, "Instagram Link", Icons.camera_alt_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(_websiteController, "Site Web", Icons.language_rounded),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LocationPickerScreen(initialLocation: _selectedLocation)),
                  );
                  if (result != null && result is LatLng) {
                    setState(() => _selectedLocation = result);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                       const Icon(Icons.map_rounded, color: Color(0xFFC9A24D)),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Text(
                           _selectedLocation != null 
                             ? 'Emplacement mis à jour' 
                             : 'MODIFIER L\'EMPLACEMENT SUR LA CARTE',
                           style: GoogleFonts.outfit(
                            color: _selectedLocation != null ? Colors.green[700] : Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                           ),
                         ),
                       ),
                       const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1C2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: const Color(0xFF0B1C2D).withOpacity(0.3),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                  : Text('Enregistrer les modifications', 
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGovernorate,
          hint: Row(
            children: [
              Icon(Icons.location_city_rounded, color: Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Text("Gouvernorat", style: GoogleFonts.outfit(color: Colors.grey[600])),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: _governorates.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.outfit()),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedGovernorate = newValue),
        ),
      ),
    );
  }

  Widget _buildImagePickers() {
      return Column(children: [
             GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                  image: _banner != null 
                    ? DecorationImage(image: FileImage(_banner!), fit: BoxFit.cover)
                    : (widget.shop['banner'] != null 
                      ? DecorationImage(image: NetworkImage(widget.shop['banner'].startsWith('http') ? widget.shop['banner'] : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${widget.shop['banner']}'), fit: BoxFit.cover) 
                      : null),
                ),
                child: (_banner == null && widget.shop['banner'] == null) 
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 40), Text('Changer la bannière', style: GoogleFonts.outfit(color: Colors.grey[500], fontWeight: FontWeight.w600))])
                    : null,
              ),
            ),
            
            const SizedBox(height: 20),

            // Logo with refined frame
            Center(
              child: Stack(
                children: [
                  Container(
                     decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      border: Border.all(color: Colors.white, width: 4), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)]
                     ),
                     child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: _logo != null 
                        ? FileImage(_logo!) 
                        : (widget.shop['logo'] != null ? NetworkImage(widget.shop['logo'].startsWith('http') ? widget.shop['logo'] : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${widget.shop['logo']}') : null),
                      child: (_logo == null && widget.shop['logo'] == null) ? Icon(Icons.storefront_rounded, size: 45, color: Colors.grey[400]) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: const CircleAvatar(
                        radius: 18, 
                        backgroundColor: Color(0xFF0B1C2D), 
                        child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18)
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ]);
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFC9A24D), width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
