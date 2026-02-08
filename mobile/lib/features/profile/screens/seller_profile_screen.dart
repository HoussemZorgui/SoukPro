import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/product_card.dart';
import '../../home/providers/product_provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/widgets/global_app_bar.dart';
import '../../home/widgets/global_drawer.dart';

class SellerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> seller;

  const SellerProfileScreen({super.key, required this.seller});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
       final sellerId = widget.seller['_id'] ?? widget.seller['id'];
       if (sellerId != null) {
         Provider.of<ProductProvider>(context, listen: false).fetchProductsBySeller(sellerId.toString());
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.seller['name'] ?? 'Seller';
    final avatar = widget.seller['avatar'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const GlobalAppBar(showMenu: false),
      drawer: const GlobalDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: (avatar != null && avatar.toString().isNotEmpty)
                              ? NetworkImage(avatar.toString().startsWith('http') 
                                  ? avatar.toString() 
                                  : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${avatar.toString()}')
                              : null,
                          child: (avatar == null || avatar.toString().isEmpty)
                              ? const Icon(Icons.person, size: 50, color: Colors.blueAccent)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Trusted Seller',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<ProductProvider>(
                    builder: (context, provider, _) {
                      String joinedDate = '2026';
                      try {
                        if (widget.seller['createdAt'] != null) {
                          joinedDate = DateTime.parse(widget.seller['createdAt'].toString()).year.toString();
                        }
                      } catch (e) {
                        joinedDate = '2026';
                      }
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Products', provider.shopProducts.length.toString()),
                          _buildStatItem('Joined', joinedDate),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Seller Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                 return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              
              final shopProducts = productProvider.shopProducts;
              
              if (shopProducts.isEmpty) {
                 return const SliverToBoxAdapter(
                   child: Center(
                     child: Padding(
                       padding: EdgeInsets.all(40), 
                       child: Column(
                         children: [
                           Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
                           SizedBox(height: 10),
                           Text('No products listed yet', style: TextStyle(color: Colors.grey)),
                         ],
                       ),
                     )
                   )
                 );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, index) {
                      return ProductCard(product: shopProducts[index]);
                    },
                    childCount: shopProducts.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}
