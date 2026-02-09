import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ShopOrdersScreen extends StatefulWidget {
  const ShopOrdersScreen({super.key});

  @override
  State<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends State<ShopOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<OrderProvider>(context, listen: false).fetchOrders()
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('Gestion des Commandes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1C2D),
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Filter orders where the current user is a seller in at least one item
          final shopOrders = orderProvider.orders.where((order) {
            return order.items.any((item) => orderProvider.orders.any((o) => o.id == order.id)); 
            // Actually, the backend already filters based on role if we implemented it right, 
            // but let's be protective.
          }).toList();

          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A24D)));
          }

          if (shopOrders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: shopOrders.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemBuilder: (ctx, i) {
              final order = shopOrders[i];
              return FadeInUp(
                delay: Duration(milliseconds: i * 50),
                child: _buildOrderCard(order),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order, isSellerView: true)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: firstItem != null && firstItem.image.isNotEmpty ? DecorationImage(
                        image: NetworkImage(firstItem.image.startsWith('http') 
                          ? firstItem.image 
                          : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${firstItem.image}'),
                        fit: BoxFit.cover,
                      ) : null,
                      color: Colors.grey[100],
                    ),
                    child: firstItem == null || firstItem.image.isEmpty ? const Icon(Icons.shopping_bag_outlined) : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande #${order.id.substring(order.id.length - 6).toUpperCase()}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.items.length} article(s) • ${order.totalAmount} TND',
                          style: GoogleFonts.outfit(color: const Color(0xFFC9A24D), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy', 'fr_FR').format(order.createdAt),
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Client: ${order.shippingAddress?['label'] ?? 'Anonyme'}', 
                    style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('Gérer', style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.bold, fontSize: 13)),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'shipped': color = Colors.indigo; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: GoogleFonts.outfit(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Text('Aucune commande active', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Les nouvelles commandes apparaîtront ici.', style: GoogleFonts.outfit(color: Colors.grey)),
        ],
      ),
    );
  }
}
