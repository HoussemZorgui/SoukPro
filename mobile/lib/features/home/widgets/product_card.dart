import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/models/product.dart';
import '../screens/product_details_screen.dart';
import '../../../core/constants/api_constants.dart';

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
            // Image Section with Hero
            Expanded(
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
                  // Overlay for Type
                  if (product.type == 'auction')
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.gavel, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('ENCHÈRE', 
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                   if (product.paymentType == 'installments')
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A24D),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.credit_card, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('FACILITÉ', 
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  if (product.status == 'sold')
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'VENDU',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w800, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF0B1C2D)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price} TND',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0B1C2D),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (product.type != 'auction') {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.title} ajouté au panier'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1C2D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            product.type == 'auction' ? Icons.gavel : Icons.add_rounded, 
                            size: 16, 
                            color: Colors.white
                          ),
                        ),
                      ),
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
}
