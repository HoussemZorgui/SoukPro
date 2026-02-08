import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/shop_provider.dart';
import 'location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Boutique mise à jour avec succès !')));
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Modifier la Boutique', style: TextStyle(color: Color(0xFF0B1C2D), fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Logo
            _buildImagePickers(),

            const SizedBox(height: 30),
            
            _buildTextField(_nameController, "Nom de la boutique", Icons.store_mall_directory),
            const SizedBox(height: 16),
            _buildTextField(_descController, "Description", Icons.description, maxLines: 3),
             const SizedBox(height: 16),
            _buildTextField(_shopAddressController, "Adresse de la Boutique", Icons.storefront),
            const SizedBox(height: 16),
            _buildGovernorateDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, "Téléphone", Icons.phone),
            const SizedBox(height: 16),
            const Text("Réseaux Sociaux", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildTextField(_facebookController, "Facebook Link", Icons.facebook),
            const SizedBox(height: 8),
            _buildTextField(_instagramController, "Instagram Link", Icons.camera_alt),
            const SizedBox(height: 8),
            _buildTextField(_websiteController, "Site Web", Icons.language),
            
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationPickerScreen(initialLocation: _selectedLocation)),
                );
                if (result != null && result is LatLng) {
                  setState(() {
                    _selectedLocation = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                     const Icon(Icons.map, color: Color(0xFF0B1C2D)),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Text(
                         _selectedLocation != null 
                           ? 'Position: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}' 
                           : 'Sélectionner l\'emplacement sur la carte',
                         style: TextStyle(color: _selectedLocation != null ? Colors.black : Colors.grey[600]),
                       ),
                     ),
                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1C2D),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  shadowColor: const Color(0xFF0B1C2D).withOpacity(0.4),
                  elevation: 8,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Enregistrer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGovernorate,
          hint: Row(
            children: [
              Icon(Icons.location_city, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Text("Sélectionner un Gouvernorat", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          isExpanded: true,
          items: _governorates.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedGovernorate = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImagePickers() {
      return Column(children: [
             GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  image: _banner != null 
                    ? DecorationImage(image: FileImage(_banner!), fit: BoxFit.cover)
                    : (widget.shop['banner'] != null 
                      ? DecorationImage(image: NetworkImage(widget.shop['banner'].startsWith('http') ? widget.shop['banner'] : 'http://10.0.2.2:5001/${widget.shop['banner']}'), fit: BoxFit.cover) 
                      : null),
                ),
                child: (_banner == null && widget.shop['banner'] == null) 
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image, color: Colors.grey[400], size: 40), Text('Changer la bannière', style: TextStyle(color: Colors.grey[500]))])
                    : null,
              ),
            ),
            
            const SizedBox(height: 20),

            // Logo
            Center(
              child: Stack(
                children: [
                  Container(
                     decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                     child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _logo != null 
                        ? FileImage(_logo!) 
                        : (widget.shop['logo'] != null ? NetworkImage(widget.shop['logo'].startsWith('http') ? widget.shop['logo'] : 'http://10.0.2.2:5001/${widget.shop['logo']}') : null),
                      child: (_logo == null && widget.shop['logo'] == null) ? Icon(Icons.store, size: 40, color: Colors.grey[400]) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: const CircleAvatar(radius: 18, backgroundColor: Color(0xFF0B1C2D), child: Icon(Icons.camera_alt, color: Colors.white, size: 16)),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC9A24D), width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
