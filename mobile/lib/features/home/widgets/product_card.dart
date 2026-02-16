import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/models/product.dart';
import '../screens/product_details_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: product.images.isNotEmpty
                            ? Image.network(
                                product.images.first.startsWith('http')
                                    ? product.images.first
                                    : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${product.images.first}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey[50], child: const Icon(Icons.broken_image, color: Colors.grey)),
                              )
                            : Container(
                                color: Colors.grey[50],
                                child: const Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  // Badges
                  if (product.type == 'auction')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildBadge(context, 'ENCHÈRE', Colors.red, Icons.gavel),
                    ),
                  if (product.paymentType == 'installments')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildBadge(context, 'FACILITÉ', const Color(0xFFC9A24D), Icons.credit_card),
                    ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: Responsive.getFontSize(context, 8), 
                            color: Colors.grey[500], 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: 1.0
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, 
                            fontSize: Responsive.getFontSize(context, 14), 
                            color: const Color(0xFF0B1C2D)
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${product.price} TND',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0B1C2D),
                              fontWeight: FontWeight.w900,
                              fontSize: Responsive.getFontSize(context, 16),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            if (product.type != 'auction') {
                              context.read<CartProvider>().addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.title} ajouté'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0B1C2D),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              product.type == 'auction' ? Icons.gavel : Icons.add_rounded, 
                              size: 14, 
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text, 
            style: GoogleFonts.outfit(
              color: Colors.white, 
              fontSize: Responsive.getFontSize(context, 8), 
              fontWeight: FontWeight.w800
            )
          ),
        ],
      ),
    );
  }
}
