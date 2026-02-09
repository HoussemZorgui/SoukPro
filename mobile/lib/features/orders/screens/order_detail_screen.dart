import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order.dart';
import '../../../core/constants/api_constants.dart';
import 'package:animate_do/animate_do.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('Détails de la Commande', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1C2D),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 25),
            _buildItemsList(),
            const SizedBox(height: 25),
            _buildAddressSection(),
            const SizedBox(height: 25),
            _buildSummarySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMMANDE #', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(order.id.substring(order.id.length - 8).toUpperCase(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(),
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(order.createdAt),
                  style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ARTICLES', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D), letterSpacing: 1)),
        const SizedBox(height: 15),
        ...order.items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return FadeInLeft(
            delay: Duration(milliseconds: i * 100),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.network(
                        item.image.startsWith('http') ? item.image : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${item.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('${item.quantity} x ${item.price} TND', style: GoogleFonts.outfit(color: const Color(0xFFC9A24D), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAddressSection() {
    if (order.shippingAddress == null) return const SizedBox.shrink();
    final addr = order.shippingAddress!;
    
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADRESSE DE LIVRAISON', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D), letterSpacing: 1)),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFFC9A24D)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addr['label'] ?? 'Domicile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('${addr['street']}, ${addr['city']}', style: GoogleFonts.outfit(color: Colors.grey[600])),
                      Text('${addr['governorate']}, ${addr['zip']}', style: GoogleFonts.outfit(color: Colors.grey[600])),
                      const SizedBox(height: 5),
                      Text(addr['phone'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1C2D),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildSummaryRow('Mode de Paiement', _translatePayment(order.paymentMethod), Colors.white70),
            const SizedBox(height: 12),
            _buildSummaryRow('Sous-total', '${order.totalAmount} TND', Colors.white70),
            _buildSummaryRow('Livraison', 'Gratuit', Colors.white70),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(color: Colors.white10),
            ),
            _buildSummaryRow('TOTAL', '${order.totalAmount} TND', Colors.white, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: color, fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500, fontSize: isTotal ? 18 : 14)),
        Text(value, style: GoogleFonts.outfit(color: color, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold, fontSize: isTotal ? 20 : 14)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending': color = Colors.orange; text = 'EN ATTENTE'; break;
      case 'confirmed': color = Colors.blue; text = 'CONFIRMÉ'; break;
      case 'shipped': color = Colors.indigo; text = 'EXPÉDIÉ'; break;
      case 'delivered': color = Colors.green; text = 'LIVRÉ'; break;
      case 'cancelled': color = Colors.red; text = 'ANNULÉ'; break;
      default: color = Colors.grey; text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  String _translatePayment(String method) {
    switch (method) {
      case 'cash_on_delivery': return 'Paiement à la livraison';
      case 'click_to_pay': return 'Click to Pay';
      case 'flouci': return 'Flouci Wallet';
      default: return method;
    }
  }
}
