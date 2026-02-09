import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/cart_provider.dart';
import '../../../core/models/shipping_address.dart';
import 'add_address_screen.dart';
import 'checkout_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  ShippingAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CartProvider>().fetchAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('Adresse de livraison', 
          style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isLoading) return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (cart.addresses.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.location_on_outlined, size: 80, color: Colors.grey[200]),
                            const SizedBox(height: 16),
                            Text('Aucune adresse enregistrée', style: GoogleFonts.outfit(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      ...cart.addresses.map((addr) => _buildAddressCard(addr)),
                    
                    const SizedBox(height: 16),
                    _buildAddAddressButton(),
                  ],
                ),
              ),
              if (_selectedAddress != null)
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(address: _selectedAddress!))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1C2D),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text('Confirmer l\'adresse', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress addr) {
    final isSelected = _selectedAddress?.id == addr.id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = addr),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFFC9A24D) : Colors.grey[100]!, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
             Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC9A24D).withOpacity(0.1) : Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                addr.label.toLowerCase() == 'home' ? Icons.home_outlined : Icons.work_outline,
                color: isSelected ? const Color(0xFFC9A24D) : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(addr.label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${addr.street}, ${addr.city}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  Text('${addr.governorate}, ${addr.zip}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFC9A24D)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Color(0xFF0B1C2D)),
            const SizedBox(width: 8),
            Text('Ajouter une nouvelle adresse', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
