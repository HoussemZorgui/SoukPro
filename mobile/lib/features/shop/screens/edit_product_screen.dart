import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../home/providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/constants/api_constants.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  late String _category;
  late String _condition;
  late String _status;
  late bool _isPremium;
  
  // Shop specific fields
  late List<String> _paymentType;
  final Map<int, bool> _selectedInstallments = {3: false, 6: false, 12: false};

  final List<dynamic> _existingImages = [];
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description);
    _priceController = TextEditingController(text: p.price.toString());
    _category = p.category;
    _condition = p.condition;
    _status = p.status;
    _isPremium = false; 
    _existingImages.addAll(p.images);

    // Initialize payment options
    _paymentType = List<String>.from(p.paymentType);
    if (p.installmentOptions != null) {
      for (var opt in (p.installmentOptions as List)) {
        final months = opt['months'];
        if (_selectedInstallments.containsKey(months)) {
          _selectedInstallments[months] = true;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImages.add(File(image.path));
      });
    }
  }

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez ajouter au moins une image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final isShop = user?.role == 'professional';

      List<Map<String, dynamic>> installmentOptions = [];
      if (isShop && _paymentType.contains('installments')) {
        final price = double.tryParse(_priceController.text) ?? 0.0;
        if (_selectedInstallments[3]!) installmentOptions.add({'months': 3, 'interestRate': 0, 'totalPrice': price});
        if (_selectedInstallments[6]!) installmentOptions.add({'months': 6, 'interestRate': 5, 'totalPrice': price * 1.05});
        if (_selectedInstallments[12]!) installmentOptions.add({'months': 12, 'interestRate': 10, 'totalPrice': price * 1.1});
      }

      // Prepare Form Data
      final Map<String, dynamic> data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'category': _category,
        'condition': _condition,
        'status': _status,
        'existingImages': jsonEncode(_existingImages),
        if (isShop) 'paymentType': _paymentType,
        if (isShop && _paymentType.contains('installments')) 'installmentOptions': jsonEncode(installmentOptions),
      };

      if (_newImages.isNotEmpty) {
        data['images'] = [
          for (var file in _newImages)
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)
        ];
      }

      final formData = FormData.fromMap(data);
      final success = await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(widget.product.id, formData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit mis à jour avec succès !', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Modifier le produit', 
          style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PHOTOS', 
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D).withOpacity(0.5), letterSpacing: 1.5)),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: Color(0xFFC9A24D)),
                            const SizedBox(height: 4),
                            Text('Ajouter', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    // Display existing images (read-only for now in this simple version, or can be removed)
                    ..._existingImages.map((img) {
                      final url = img.startsWith('http') ? img : '${ApiConstants.baseUrl.replaceAll('/api', '')}/$img';
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => setState(() => _existingImages.remove(img)),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.close, size: 12, color: Colors.red)),
                            ),
                          ),
                        ),
                      );
                    }),
                    // New images
                    ..._newImages.map((file) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => setState(() => _newImages.remove(file)),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.close, size: 12, color: Colors.red)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text('DÉTAILS', 
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D).withOpacity(0.5), letterSpacing: 1.5)),
              const SizedBox(height: 20),
              
              _buildTextField(_titleController, 'Titre', Icons.title_rounded),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Prix (TND)', Icons.payments_rounded, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', Icons.description_outlined, maxLines: 4),
              
              const SizedBox(height: 24),
              
              _buildDropdown('Catégorie', _category, ['Électronique', 'Mode', 'Maison', 'Véhicules', 'Autres'], (val) => setState(() => _category = val!)),
              const SizedBox(height: 16),
              _buildDropdown('État', _condition, ['Neuf', 'Utilisé - Comme Neuf', 'Utilisé - Bon État', 'Utilisé - État Correct'], (val) => setState(() => _condition = val!)),
              const SizedBox(height: 16),
              _buildDropdown('Statut', _status, ['available', 'sold'], (val) => setState(() => _status = val!)),

              // Professional fields
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final isShop = auth.user?.role == 'professional';
                  if (!isShop) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text('PAIEMENT', 
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D).withOpacity(0.5), letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      
                      CheckboxListTile(
                        title: Text('Comptant', style: GoogleFonts.outfit(fontSize: 14)),
                        value: _paymentType.contains('cash'),
                        activeColor: const Color(0xFFC9A24D),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            if (val!) {
                              _paymentType.add('cash');
                            } else {
                              _paymentType.remove('cash');
                            }
                          });
                        },
                      ),
                      
                      CheckboxListTile(
                        title: Text('Facilité de paiement', style: GoogleFonts.outfit(fontSize: 14)),
                        value: _paymentType.contains('installments'),
                        activeColor: const Color(0xFFC9A24D),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            if (val!) {
                              _paymentType.add('installments');
                            } else {
                              _paymentType.remove('installments');
                            }
                          });
                        },
                      ),
                      
                      if (_paymentType.contains('installments')) ...[
                        const SizedBox(height: 16),
                        _buildCheckbox('3 Mois (0% Intérêt)', 3),
                        _buildCheckbox('6 Mois (5% Intérêt)', 6),
                        _buildCheckbox('12 Mois (10% Intérêt)', 12),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B1C2D),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Enregistrer les modifications', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
      ),
      validator: (val) => val!.isEmpty ? 'Ce champ est requis' : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.outfit()))).toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String title, int months) {
    return CheckboxListTile(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 14)),
      value: _selectedInstallments[months],
      activeColor: const Color(0xFFC9A24D),
      contentPadding: EdgeInsets.zero,
      onChanged: (val) => setState(() => _selectedInstallments[months] = val!),
    );
  }
}
