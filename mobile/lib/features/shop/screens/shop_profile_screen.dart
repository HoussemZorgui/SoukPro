import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/product_card.dart';
import '../../home/providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../../../core/constants/api_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class ShopProfileScreen extends StatefulWidget {
  final Map<String, dynamic> shop;

  const ShopProfileScreen({super.key, required this.shop});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
       final sellerId = widget.shop['owner'];
       final id = sellerId is Map ? sellerId['_id'] ?? sellerId['id'] : sellerId;
       
       if (id != null) {
         Provider.of<ProductProvider>(context, listen: false).fetchProductsBySeller(id.toString());
       }
       
       final shopId = widget.shop['_id'] ?? widget.shop['id'];
       if (shopId != null) {
         Provider.of<ShopProvider>(context, listen: false).setSelectedShop(widget.shop);
         Provider.of<ShopProvider>(context, listen: false).fetchShopReviews(shopId.toString());
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        final shop = shopProvider.selectedShop ?? widget.shop;
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(shop),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildShopInfo(shop),
                    _buildShopLocation(shop),
                    const SizedBox(height: 20),
                    _buildReviewsSection(shop),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, height: 1),
                    _buildSectionTitle('Collection'),
                  ],
                ),
              ),
              _buildProductGrid(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> shop) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0B1C2D),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: const BackButton(color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner Image
            Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: shop['banner'] != null && shop['banner'].toString().isNotEmpty
                      ? Image.network(
                          shop['banner'].startsWith('http')
                              ? shop['banner']
                              : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${shop['banner']}',
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF0B1C2D), const Color(0xFF1E3A5F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                ),
                Expanded(child: Container(color: Colors.white)), // Bottom part for logo overlap background
              ],
            ),
            // Logo
            Positioned(
              top: 150, // Starts 50px into banner
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46, // Slightly smaller to fit better
                    backgroundColor: Colors.grey[100],
                    backgroundImage: shop['logo'] != null && shop['logo'].toString().isNotEmpty
                        ? NetworkImage(
                            shop['logo'].startsWith('http')
                                ? shop['logo']
                                : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${shop['logo']}',
                          )
                        : null,
                    child: (shop['logo'] == null || shop['logo'].toString().isEmpty) 
                        ? const Icon(Icons.store, size: 40, color: Color(0xFF0B1C2D)) 
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfo(Map<String, dynamic> shop) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                shop['name'] ?? 'Nom de la Boutique',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C2D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              if (shop['isVerified'] == true)
                const Icon(Icons.verified, color: Colors.blue, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${shop['governorate'] ?? ''}${shop['governorate'] != null ? ', ' : ''}${shop['shopAddress'] ?? 'Tunisie'}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          if (shop['description'] != null && shop['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              shop['description'],
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          _buildSocials(shop),
          const SizedBox(height: 24),
          _buildStatsRow(shop),
        ],
      ),
    );
  }

  Widget _buildSocials(Map<String, dynamic> shop) {
    final social = shop['socialLinks'] ?? {};
    final phone = shop['phone'];
    final facebook = social['facebook'];
    final instagram = social['instagram'];
    final website = social['website']; // handled at top level or inside socialLinks depending on how backend sends it, previously I put it in socialLinks

    List<Widget> icons = [];
    if (phone != null && phone.toString().isNotEmpty) icons.add(_socialIcon(Icons.phone, Colors.green, 'tel:$phone'));
    if (facebook != null && facebook.toString().isNotEmpty) icons.add(_socialIcon(Icons.facebook, Colors.blue, facebook));
    if (instagram != null && instagram.toString().isNotEmpty) icons.add(_socialIcon(Icons.camera_alt, Colors.purple, instagram));
    if (website != null && website.toString().isNotEmpty) icons.add(_socialIcon(Icons.language, Colors.orange, website));

    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons.map((icon) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: icon)).toList(),
    );
  }

  Widget _socialIcon(IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () {
        // Implement launch url here
        debugPrint('Launching $url');
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildShopLocation(Map<String, dynamic> shop) {
    if (shop['location'] == null || shop['location']['lat'] == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                (shop['location']['lat'] as num).toDouble(), 
                (shop['location']['lng'] as num).toDouble()
              ),
              initialZoom: 14,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.soukpro.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      (shop['location']['lat'] as num).toDouble(), 
                      (shop['location']['lng'] as num).toDouble()
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: Row(
                children: [
                  const Icon(Icons.store, size: 14, color: Color(0xFF0B1C2D)),
                  const SizedBox(width: 5),
                  Text(shop['shopAddress'] ?? 'Emplacement', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> shop) {
    return Consumer2<ProductProvider, ShopProvider>(
      builder: (context, productProvider, shopProvider, _) {
       final owner = shop['owner'];
       String joinedDate = '2026';
       try {
         final dateStr = owner is Map ? owner['createdAt'] : shop['createdAt'];
         if (dateStr != null) {
           joinedDate = DateTime.parse(dateStr.toString()).year.toString();
         }
       } catch (e) { joinedDate = '2026'; }

       final rating = shop['rating']?.toString() ?? '0.0';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(productProvider.shopProducts.length.toString(), 'Articles'),
              Container(height: 30, width: 1, color: Colors.grey[300]),
              _buildStatItem(rating, 'Note'),
              Container(height: 30, width: 1, color: Colors.grey[300]),
              _buildStatItem(joinedDate, 'Depuis'),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0B1C2D))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> shop) {
    return Consumer<ShopProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AVIS CLIENTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final currentUser = authProvider.user;
                      final ownerId = shop['owner'] is Map ? shop['owner']['_id'] : shop['owner'];
                      
                      // Don't show button if user is not logged in OR is the shop owner
                      if (!authProvider.isAuthenticated || (currentUser != null && currentUser.id == ownerId.toString())) {
                        return const SizedBox.shrink();
                      }
                      
                      return TextButton(
                        onPressed: () => _showAddReviewModal(shop),
                        child: const Text('Donner mon avis', style: TextStyle(color: Color(0xFFC9A24D), fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (provider.reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Aucun avis pour le moment', style: TextStyle(color: Colors.grey[400])),
              )
            else
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: provider.reviews.length,
                  itemBuilder: (context, index) {
                    final review = provider.reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['user'];
    final userName = user is Map ? user['name'] ?? 'Client' : 'Client';
    
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 15, backgroundColor: Colors.grey[200], child: const Icon(Icons.person, size: 15, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1)),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star, 
                  size: 12, 
                  color: index < (review['rating'] ?? 0) ? Colors.orange : Colors.grey[200]
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              review['comment'] ?? '',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReviewModal(Map<String, dynamic> shop) {
    double selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VOTRE AVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => IconButton(
                    icon: Icon(Icons.star, size: 40, color: index < selectedRating ? Colors.orange : Colors.grey[300]),
                    onPressed: () => setModalState(() => selectedRating = index + 1.0),
                  )),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final shopId = shop['_id'] ?? shop['id'];
                      if (shopId != null) {
                        final success = await Provider.of<ShopProvider>(context, listen: false).addReview(
                          shopId: shopId.toString(),
                          rating: selectedRating,
                          comment: commentController.text,
                        );
                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merci pour votre avis !')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1C2D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('PUBLIER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
           return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        
        final shopProducts = productProvider.shopProducts;
        
        if (shopProducts.isEmpty) {
           return const SliverToBoxAdapter(
             child: Padding(
               padding: EdgeInsets.all(40), 
               child: Center(
                 child: Column(
                   children: [
                     Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
                     SizedBox(height: 10),
                     Text('Aucun produit disponible', style: TextStyle(color: Colors.grey)),
                   ],
                 ),
               ),
             )
           );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ProductCard(product: shopProducts[index]);
              },
              childCount: shopProducts.length,
            ),
          ),
        );
      },
    );
  }
}

