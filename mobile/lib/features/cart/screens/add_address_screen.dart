import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';
import '../../../core/models/shipping_address.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  String _governorate = 'Tunis';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Nouvelle adresse', 
          style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_labelController, 'Libellé (Ex: Domicile, Bureau)', Icons.label_outline),
              const SizedBox(height: 16),
              _buildTextField(_streetController, 'Rue / Quartier', Icons.location_on_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildTextField(_cityController, 'Ville', Icons.location_city)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildTextField(_zipController, 'Code Postal', Icons.numbers, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              _buildGovernorateDropdown(),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Téléphone de livraison', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B1C2D),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Enregistrer l\'adresse', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    final addr = ShippingAddress(
      label: _labelController.text,
      street: _streetController.text,
      city: _cityController.text,
      governorate: _governorate,
      zip: _zipController.text,
      phone: _phoneController.text,
    );

    final success = await context.read<CartProvider>().addAddress(addr);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (val) => val!.isEmpty ? 'Champ requis' : null,
    );
  }

  Widget _buildGovernorateDropdown() {
    final list = ['Tunis', 'Ariana', 'Ben Arous', 'Mannouba', 'Bizerte', 'Nabeul', 'Sousse', 'Monastir', 'Mahdia', 'Sfax', 'Kairouan', 'Kasserine', 'Sidi Bouzid', 'Gabès', 'Medenine', 'Tataouine', 'Gafsa', 'Tozeur', 'Kebili', 'Jendouba', 'Béja', 'Le Kef', 'Siliana', 'Zaghouan'];
    return DropdownButtonFormField<String>(
      value: _governorate,
      decoration: InputDecoration(
        labelText: 'Gouvernorat',
        prefixIcon: const Icon(Icons.map_outlined, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: list.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) => setState(() => _governorate = val!),
    );
  }
}
