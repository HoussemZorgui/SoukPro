import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../shop/providers/shop_provider.dart';
import '../../shop/screens/shop_profile_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../../core/models/product.dart';
import '../../profile/screens/seller_profile_screen.dart';
import '../../../core/constants/api_constants.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final TextEditingController _bidController = TextEditingController();
  
  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _placeBid() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bidding implementation coming next!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isAuction = product.type == 'auction';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Gallery
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C2D)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF0B1C2D)),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Color(0xFF0B1C2D)),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   if (product.images.isNotEmpty)
                     PageView.builder(
                       itemCount: product.images.length,
                       onPageChanged: (index) => setState(() => _currentImageIndex = index),
                       itemBuilder: (context, index) {
                         final imageUrl = product.images[index].startsWith('http') 
                             ? product.images[index] 
                             : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${product.images[index]}';
                         return Hero(
                           tag: index == 0 ? 'product_image_${product.id}' : 'product_image_${product.id}_$index',
                           child: Image.network(
                             imageUrl,
                             fit: BoxFit.cover,
                           ),
                         );
                       },
                     )
                   else
                     Container(
                       decoration: const BoxDecoration(
                         gradient: LinearGradient(
                           colors: [Color(0xFF0B1C2D), Color(0xFF1E3A5F)],
                           begin: Alignment.topLeft,
                           end: Alignment.bottomRight,
                         ),
                       ),
                     ),
                  
                  // Image Index Indicator (Bottom right of image)
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 40,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1} / ${product.images.length}',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Subtle Overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Section
          SliverToBoxAdapter(
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1C2D).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0B1C2D),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        if (isAuction)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, color: Colors.red, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "ENCHERES LIVE",
                                  style: GoogleFonts.outfit(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0B1C2D),
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${product.price} TND',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFC9A24D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Seller/Shop Card (Premium)
                    Builder(
                      builder: (context) {
                        final seller = product.seller;
                        final bool isPro = seller?['role'] == 'professional';
                        final Map<String, dynamic>? shop = isPro ? (seller?['shop'] is Map<String, dynamic> ? seller!['shop'] : null) : null;

                        // Identify Name, Logo and Role Label
                        // Fallback order for pros: Shop Name -> Seller Name -> empty
                        final String displayName = isPro 
                            ? (shop?['name'] ?? seller?['name'] ?? '') 
                            : (seller?['name'] ?? '');
                        final String secondaryLabel = isPro ? 'Boutique Certifiée' : 'Vendeur Particulier';
                        
                        // Handle Logo/Avatar URL
                        String? imageUrl;
                        if (isPro && shop != null && shop['logo'] != null) {
                          final String logoPath = shop['logo'].toString();
                          imageUrl = logoPath.startsWith('http') 
                              ? logoPath 
                              : '${ApiConstants.baseUrl.replaceAll('/api', '')}/$logoPath';
                        } else if (seller != null && seller['avatar'] != null) {
                          final String avatarPath = seller['avatar'].toString();
                          imageUrl = avatarPath.startsWith('http') 
                              ? avatarPath 
                              : '${ApiConstants.baseUrl.replaceAll('/api', '')}/$avatarPath';
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFC9A24D), width: 1.5),
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                                  child: imageUrl == null ? const Icon(Icons.person, color: Color(0xFF0B1C2D)) : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            displayName,
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isPro && shop?['isVerified'] == true) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      secondaryLabel,
                                      style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (isPro && shop != null) {
                                    // Fetch FRESH and FULL shop details before navigating
                                    final shopId = shop['_id'] ?? shop['id'];
                                    if (shopId != null) {
                                      final fullShop = await Provider.of<ShopProvider>(context, listen: false).getShopById(shopId.toString());
                                      if (fullShop != null && context.mounted) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: fullShop)));
                                      } else if (context.mounted) {
                                        // Fallback to existing data if fetch fails
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: shop)));
                                      }
                                    }
                                  } else if (seller != null) {
                                    // Navigate to Seller Profile
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => SellerProfileScreen(seller: seller)));
                                  }
                                },
                                child: Text(
                                  isPro ? "BOUTIQUE" : "VOIR",
                                  style: GoogleFonts.outfit(color: const Color(0xFFC9A24D), fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'DESCRIPTION',
                      style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D), letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: GoogleFonts.outfit(
                        color: Colors.grey[700],
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Specs Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSpecChip(Icons.info_outline_rounded, "État", product.condition),
                          const SizedBox(width: 12),
                          _buildSpecChip(Icons.category_outlined, "Secteur", product.category),
                          if (isAuction) ...[
                            const SizedBox(width: 12),
                            _buildSpecChip(Icons.timer_outlined, "Mode", "Vente aux enchères"),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Payment Options
                    if (product.installmentOptions != null && (product.installmentOptions as List).isNotEmpty) ...[
                      Text(
                        'FACILITÉS DE PAIEMENT',
                        style: GoogleFonts.outfit(
                            fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D), letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.blue[50]!),
                        ),
                        child: Column(
                          children: [
                            for (var opt in (product.installmentOptions as List))
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: opt == (product.installmentOptions as List).last
                                        ? BorderSide.none
                                        : BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.credit_card_rounded, size: 20, color: Color(0xFFC9A24D)),
                                        const SizedBox(width: 12),
                                        Text('Payez en ${opt['months']} mois',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${((opt['totalPrice'] ?? product.price) / opt['months']).toStringAsFixed(2)} TND/mois',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D), fontSize: 16),
                                        ),
                                        Text('Total: ${opt['totalPrice'] ?? product.price} TND',
                                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Floating Bottom Action Bar (Ultra Modern)
      bottomNavigationBar: FadeInUp(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -10)),
            ],
          ),
          child: isAuction
              ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _bidController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'Votre offre (min ${product.currentMake + 1})',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _placeBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1C2D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('OFFRIR', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF0B1C2D)),
                        onPressed: () {
                          context.read<CartProvider>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} ajouté au panier'),
                              action: SnackBarAction(
                                label: 'VOIR',
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<CartProvider>().addToCart(product);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1C2D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: Text(
                          'ACHETER MAINTENANT',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFC9A24D)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600)),
              Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0B1C2D))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}
