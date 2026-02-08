import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart'; // For FormData
import '../providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _category = 'Électronique';
  String _condition = 'Neuf';
  String _type = 'fixed'; // fixed or auction
  String _paymentType = 'cash'; // cash or installments
  final Map<int, bool> _selectedInstallments = {3: false, 6: false, 12: false};
  bool _isPremium = false;
  
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une image')),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final isShop = user?.role == 'professional';

    List<Map<String, dynamic>> installmentOptions = [];
    if (isShop && _paymentType == 'installments') {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      if (_selectedInstallments[3]!) installmentOptions.add({'months': 3, 'interestRate': 0, 'totalPrice': price});
      if (_selectedInstallments[6]!) installmentOptions.add({'months': 6, 'interestRate': 5, 'totalPrice': price * 1.05});
      if (_selectedInstallments[12]!) installmentOptions.add({'months': 12, 'interestRate': 10, 'totalPrice': price * 1.1});
      
      if (installmentOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner au moins un plan de paiement')));
        return;
      }
    }

    // Prepare Form Data
    final formData = FormData.fromMap({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'category': _category,
      'condition': _condition,
      'type': isShop ? 'fixed' : _type,
      'paymentType': isShop ? _paymentType : 'cash',
      'installmentOptions': installmentOptions.isNotEmpty ? installmentOptions : null,
      'isPremium': _isPremium,
      'startingBid': !isShop && _type == 'auction' ? _priceController.text : null,
      // Add multiple files
      'images': [
        for (var file in _images)
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)
      ],
    });

    final success = await Provider.of<ProductProvider>(context, listen: false).addProduct(formData);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit ajouté avec succès !')));
        Navigator.pop(context);
      }
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de l\'ajout du produit')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Vendre un article', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section
              const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor),
                              const SizedBox(height: 5),
                              const Text('Ajouter Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_images[i - 1]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 14,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(i - 1)),
                            child: const CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.close, size: 14, color: Colors.red)),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Details
               Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Détails de l\'article', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Titre', Icons.title),
                      validator: (val) => val!.isEmpty ? 'Entrez le titre' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _priceController,
                      decoration: _inputDecoration('Prix (TND)', Icons.attach_money),
                      keyboardType: TextInputType.number,
                       validator: (val) => val!.isEmpty ? 'Entrez le prix' : null,
                    ),
                     const SizedBox(height: 16),
      
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('Description', Icons.description).copyWith(alignLabelWithHint: true),
                      maxLines: 4,
                       validator: (val) => val!.isEmpty ? 'Entrez la description' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Categories & Condition
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                     DropdownButtonFormField(
                      value: _category,
                      items: ['Électronique', 'Mode', 'Maison', 'Véhicules', 'Autres']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _category = val.toString()),
                      decoration: _inputDecoration('Catégorie', Icons.category),
                    ),
                    const SizedBox(height: 16),
      
                     DropdownButtonFormField(
                      value: _condition,
                      items: ['Neuf', 'Utilisé - Comme Neuf', 'Utilisé - Bon État', 'Utilisé - État Correct']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _condition = val.toString()),
                      decoration: _inputDecoration('État', Icons.check_circle_outline),
                    ),
                    const SizedBox(height: 16),
      
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isShop = auth.user?.role == 'professional';
                        
                        if (isShop) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField(
                                value: _paymentType,
                                items: [
                                  const DropdownMenuItem(value: 'cash', child: Text('Comptant')),
                                  const DropdownMenuItem(value: 'installments', child: Text('Facilité de paiement')),
                                ],
                                onChanged: (val) => setState(() => _paymentType = val.toString()),
                                decoration: _inputDecoration('Mode de paiement', Icons.payments_outlined),
                              ),
                              if (_paymentType == 'installments') ...[
                                const SizedBox(height: 16),
                                const Text('Sélectionnez les plans de paiement :', style: TextStyle(fontWeight: FontWeight.bold)),
                                CheckboxListTile(
                                  title: const Text('3 Mois (0% Intérêt)'),
                                  value: _selectedInstallments[3],
                                  onChanged: (val) => setState(() => _selectedInstallments[3] = val!),
                                ),
                                CheckboxListTile(
                                  title: const Text('6 Mois (5% Intérêt)'),
                                  value: _selectedInstallments[6],
                                  onChanged: (val) => setState(() => _selectedInstallments[6] = val!),
                                ),
                                CheckboxListTile(
                                  title: const Text('12 Mois (10% Intérêt)'),
                                  value: _selectedInstallments[12],
                                  onChanged: (val) => setState(() => _selectedInstallments[12] = val!),
                                ),
                              ],
                            ],
                          );
                        } else {
                          return DropdownButtonFormField(
                            value: _type,
                            items: [
                              const DropdownMenuItem(value: 'fixed', child: Text('Prix Fixe')),
                              const DropdownMenuItem(value: 'auction', child: Text('Enchère en Direct')),
                            ],
                            onChanged: (val) => setState(() => _type = val.toString()),
                            decoration: _inputDecoration('Type de vente', Icons.gavel),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Promote
               Container(
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo[100]!),
                ),
                child: CheckboxListTile(
                  title: const Text('Promouvoir le produit (Premium)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  subtitle: const Text('Augmentez la visibilité pour 10 TND', style: TextStyle(fontSize: 12, color: Colors.indigo)),
                  value: _isPremium,
                  activeColor: Colors.indigo,
                  onChanged: (val) => setState(() => _isPremium = val!),
                  secondary: const Icon(Icons.star, color: Colors.indigo),
                ),
              ),
      
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ), 
                  child: const Text('Publier l\'article', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
      filled: true,
      fillColor: Colors.grey[50], 
    );
  }
}
