import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/cart_provider.dart';
import '../../../core/models/shipping_address.dart';
import '../../orders/screens/order_success_screen.dart'; // I need to create this or use existing

class CheckoutScreen extends StatefulWidget {
  final ShippingAddress address;
  const CheckoutScreen({super.key, required this.address});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cash_on_delivery';

  void _handleCheckout() async {
    final success = await context.read<CartProvider>().checkout(
      shippingAddress: widget.address,
      paymentMethod: _paymentMethod,
    );
    
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        (route) => route.isFirst,
      );
    } else if (mounted) {
       final error = context.read<CartProvider>().checkoutError;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(
             error ?? 'Une erreur est survenue lors de la commande',
             style: GoogleFonts.outfit(color: Colors.white),
           ),
           backgroundColor: Colors.red,
         ),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('Paiement', 
          style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildSectionTitle('Résumé de la commande'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Produits', '${cart.totalAmount} TND'),
                  _buildSummaryRow('Livraison', 'Gratuit', isGreen: true),
                  const Divider(height: 32),
                  _buildSummaryRow('Total', '${cart.totalAmount} TND', isBold: true),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Mode de paiement'),
            const SizedBox(height: 16),
            _buildPaymentOption(
              'cash_on_delivery', 
              'Paiement à la livraison', 
              'Payez en espèces dès réception', 
              Icons.payments_outlined,
              true
            ),
            _buildPaymentOption(
              'click_to_pay', 
              'Click to Pay', 
              'Bientôt disponible', 
              Icons.credit_card_outlined,
              false
            ),
            _buildPaymentOption(
              'flouci', 
              'Flouci Wallet', 
              'Bientôt disponible', 
              Icons.account_balance_wallet_outlined,
              false
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cart.isLoading ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B1C2D),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: cart.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Confirmer la commande', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D).withOpacity(0.5), letterSpacing: 1.2));
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 15)),
          Text(value, style: GoogleFonts.outfit(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 18 : 15,
            color: isGreen ? Colors.green : (isBold ? const Color(0xFF0B1C2D) : Colors.black),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String id, String title, String subtitle, IconData icon, bool enabled) {
    final isSelected = _paymentMethod == id;
    
    return GestureDetector(
      onTap: enabled ? () => setState(() => _paymentMethod = id) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFFC9A24D) : Colors.grey[100]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? (isSelected ? const Color(0xFFC9A24D) : const Color(0xFF0B1C2D)) : Colors.grey[300]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: enabled ? Colors.black : Colors.grey[400])),
                  Text(subtitle, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (enabled)
              Radio<String>(
                value: id,
                groupValue: _paymentMethod,
                activeColor: const Color(0xFFC9A24D),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              )
            else
               const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
