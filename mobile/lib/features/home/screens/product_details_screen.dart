import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shop/providers/shop_provider.dart';
import '../../shop/screens/shop_profile_screen.dart';
import '../../../core/models/product.dart';
import '../../orders/screens/checkout_screen.dart';
import '../../profile/screens/seller_profile_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/global_app_bar.dart';
import '../widgets/global_drawer.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const GlobalAppBar(showMenu: false),
      drawer: const GlobalDrawer(),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   product.images.isNotEmpty
                      ? Image.network(
                          product.images.first.startsWith('http') 
                              ? product.images.first 
                              : 'http://10.0.2.2:5001/${product.images.first}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 50)),
                        )
                      : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50)),
                  // Gradient for text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            automaticallyImplyLeading: false,
          ),

          // Details
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.category.toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAuction ? Colors.red[50] : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isAuction ? Colors.red[100]! : Colors.green[100]!),
                        ),
                        child: Text(
                          '${product.price} TND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isAuction ? Colors.red : Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  // Seller Info
                  Row(
                    children: [
                       CircleAvatar(
                         backgroundImage: (product.seller != null && product.seller!['avatar'] != null && product.seller!['avatar'].toString().isNotEmpty)
                            ? NetworkImage(product.seller!['avatar'].startsWith('http') 
                                ? product.seller!['avatar'] 
                                : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${product.seller!['avatar']}')
                            : null,
                         child: (product.seller == null || product.seller!['avatar'] == null || product.seller!['avatar'].toString().isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                         radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sold by', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(product.seller?['name'] ?? 'Unknown Seller', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () async {
                           final isPro = product.seller?['role'] == 'professional';
                           final shopId = product.seller?['shop'];
                           
                           if (isPro && shopId != null) {
                             // Fetch full shop details and navigate
                             final shop = await Provider.of<ShopProvider>(context, listen: false).getShopById(shopId.toString());
                             if (shop != null && mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: shop)),
                                );
                             } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop details not available')));
                             }
                           } else {
                             // Regular user, navigate to seller profile
                             if (product.seller != null && mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => SellerProfileScreen(seller: product.seller!)),
                                );
                             }
                           }
                        }, 
                        icon: Icon(
                          product.seller?['role'] == 'professional' ? Icons.store : Icons.person_outline, 
                          size: 16
                        ),
                        label: Text(product.seller?['role'] == 'professional' ? 'Visit Shop' : 'Visit Seller'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: Colors.grey[300]!),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 16),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Payment Options (for Shops)
                  if (product.installmentOptions != null && (product.installmentOptions as List).isNotEmpty) ...[
                    const Text(
                      'Payment Options',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        children: [
                          for (var opt in (product.installmentOptions as List))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text('${opt['months']} Months Plan', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Text(
                                    '${((opt['totalPrice'] ?? product.price) / opt['months']).toStringAsFixed(2)} TND/mo',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  
                  // Specs
                  Row(
                    children: [
                      _buildSpecItem('Condition', product.condition),
                      const SizedBox(width: 20),
                      if (isAuction) _buildSpecItem('Status', 'Live Auction'),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: isAuction 
             ? Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _bidController,
                       keyboardType: TextInputType.number,
                       decoration: InputDecoration(
                         hintText: 'Bid Amount (min ${product.currentMake + 1})',
                         filled: true,
                         fillColor: Colors.grey[100],
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                       ),
                     ),
                   ),
                   const SizedBox(width: 12),
                   ElevatedButton(
                     onPressed: _placeBid,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.black,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     child: const Text('Place Bid', style: TextStyle(fontWeight: FontWeight.bold)),
                   ),
                 ],
               )
             : SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CheckoutScreen(product: product)),
                      );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.black,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 18),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     elevation: 0,
                   ),
                   child: const Text(
                     'Add to Cart', 
                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                 ),
               ),
        ),
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
