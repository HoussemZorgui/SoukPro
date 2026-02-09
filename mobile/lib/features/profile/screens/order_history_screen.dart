import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../../../core/constants/api_constants.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    Future.microtask(() => 
      Provider.of<OrderProvider>(context, listen: false).fetchOrders()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text('Mes Commandes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1C2D),
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A24D)));
          }

          if (orderProvider.orders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: orderProvider.orders.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (ctx, i) {
              final order = orderProvider.orders[i];
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
    final otherItemsCount = order.items.length - 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                   // Small image of the first product
                  if (firstItem != null && firstItem.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.network(
                          firstItem.image.startsWith('http')
                            ? firstItem.image
                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${firstItem.image}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 20),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 24),
                    ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.title ?? 'Articles variés',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        if (otherItemsCount > 0)
                          Text('+ $otherItemsCount autres articles', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                        Text(
                          DateFormat('dd MMM yyyy', 'fr_FR').format(order.createdAt),
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order.totalAmount} TND',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D)),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'ID: ${order.id.substring(order.id.length - 8).toUpperCase()}',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text('Détails', style: GoogleFonts.outfit(color: const Color(0xFFC9A24D), fontWeight: FontWeight.bold, fontSize: 13)),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFC9A24D)),
                    ],
                  ),
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
    String text;
    switch (status) {
      case 'pending': color = Colors.orange; text = 'En attente'; break;
      case 'confirmed': color = Colors.blue; text = 'Confirmé'; break;
      case 'shipped': color = Colors.indigo; text = 'Expédié'; break;
      case 'delivered': color = Colors.green; text = 'Livré'; break;
      case 'cancelled': color = Colors.red; text = 'Annulé'; break;
      default: color = Colors.grey; text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: FadeInUp(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               padding: const EdgeInsets.all(30),
               decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
               child: Icon(Icons.shopping_bag_outlined, size: 70, color: Colors.grey[200]),
             ),
             const SizedBox(height: 24),
             Text('Aucune commande', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D))),
             const SizedBox(height: 10),
             Text('Vous n\'avez pas encore passé de commande.', style: GoogleFonts.outfit(color: Colors.grey)),
             const SizedBox(height: 30),
             ElevatedButton(
               onPressed: () => Navigator.pop(context),
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFF0B1C2D),
                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
               ),
               child: Text('Commencer mes achats', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
             )
           ],
         ),
       ),
     );
  }
}

