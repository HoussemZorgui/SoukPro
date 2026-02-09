import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../home/widgets/product_card.dart';
import '../../home/providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../../../core/constants/api_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';

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
      expandedHeight: 300.0,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0B1C2D),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner with Overlay
            Hero(
              tag: 'shop_banner_${shop['_id'] ?? shop['id']}',
              child: shop['banner'] != null && shop['banner'].toString().isNotEmpty
                  ? Image.network(
                      shop['banner'].startsWith('http')
                          ? shop['banner']
                          : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${shop['banner']}',
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B1C2D), Color(0xFF1E3A5F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // Floating Logo in Expanded State
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: shop['logo'] != null && shop['logo'].toString().isNotEmpty
                          ? NetworkImage(
                              shop['logo'].startsWith('http')
                                  ? shop['logo']
                                  : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${shop['logo']}',
                            )
                          : null,
                      child: (shop['logo'] == null || shop['logo'].toString().isEmpty)
                          ? const Icon(Icons.store, size: 50, color: Color(0xFF0B1C2D))
                          : null,
                    ),
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
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  shop['name'] ?? 'Boutique',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B1C2D),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(width: 8),
                if (shop['isVerified'] == true)
                  const Icon(Icons.verified, color: Color(0xFF2196F3), size: 24),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A24D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFC9A24D), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "${shop['governorate'] ?? 'Tunisie'}",
                    style: GoogleFonts.outfit(color: const Color(0xFFC9A24D), fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (shop['description'] != null && shop['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                shop['description'],
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            _buildSocials(shop),
            const SizedBox(height: 30),
            _buildStatsRow(shop),
          ],
        ),
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
    return Consumer2<ProductProvider, ShopProvider>(builder: (context, productProvider, shopProvider, _) {
      final owner = shop['owner'];
      String joinedDate = '2026';
      try {
        final dateStr = owner is Map ? owner['createdAt'] : shop['createdAt'];
        if (dateStr != null) {
          joinedDate = DateTime.parse(dateStr.toString()).year.toString();
        }
      } catch (e) {
        joinedDate = '2026';
      }

      final rating = shop['rating']?.toString() ?? '0.0';

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(productProvider.shopProducts.length.toString(), 'Articles', Icons.inventory_2_outlined),
            _buildStatItem('$rating/5', 'Note', Icons.star_outline_rounded),
            _buildStatItem(joinedDate, 'Depuis', Icons.calendar_today_outlined),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFC9A24D), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0B1C2D)),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> shop) {
    return Consumer<ShopProvider>(
      builder: (context, provider, _) {
        return FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AVIS CLIENTS',
                            style: GoogleFonts.outfit(
                                fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D), letterSpacing: 0.5)),
                        if (provider.reviews.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showAllReviewsModal(provider.reviews),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Voir tout (${provider.reviews.length})",
                                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFC9A24D), fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final currentUser = authProvider.user;
                        final ownerId = shop['owner'] is Map ? shop['owner']['_id'] : shop['owner'];

                        if (!authProvider.isAuthenticated || (currentUser != null && currentUser.id == ownerId.toString())) {
                          return const SizedBox.shrink();
                        }

                        return OutlinedButton.icon(
                          onPressed: () => _showAddReviewModal(shop),
                          icon: const Icon(Icons.star_rate_rounded, size: 18),
                          label: const Text('Noter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0B1C2D),
                            side: const BorderSide(color: Color(0xFF0B1C2D)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (provider.reviews.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Aucun avis pour le moment',
                        style: GoogleFonts.outfit(color: Colors.grey[400], fontWeight: FontWeight.w500)),
                  ),
                )
              else
                SizedBox(
                  height: 160,
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
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['user'];
    final userName = user is Map ? user['name'] ?? 'Client' : 'Client';

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF0B1C2D).withOpacity(0.05),
                  child: const Icon(Icons.person, size: 18, color: Color(0xFF0B1C2D))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                    Row(
                      children: List.generate(
                          5,
                          (index) => Icon(Icons.star_rounded,
                              size: 14, color: index < (review['rating'] ?? 0) ? const Color(0xFFC9A24D) : Colors.grey[200])),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '',
            style: GoogleFonts.outfit(color: Colors.grey[700], fontSize: 13, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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

  void _showAllReviewsModal(List<dynamic> reviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('TOUS LES AVIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('(${reviews.length})', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const Divider(height: 30),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  final user = review['user'];
                  final userName = user is Map ? user['name'] ?? 'Client' : 'Client';
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18, 
                            backgroundColor: Colors.grey[100], 
                            child: const Icon(Icons.person, size: 20, color: Colors.grey)
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: List.generate(5, (sIndex) => Icon(
                                    Icons.star, 
                                    size: 14, 
                                    color: sIndex < (review['rating'] ?? 0) ? Colors.orange : Colors.grey[200]
                                  )),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            review['createdAt'] != null 
                              ? DateTime.parse(review['createdAt']).toString().substring(0, 10)
                              : '',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review['comment'] ?? '',
                        style: TextStyle(color: Colors.grey[800], height: 1.4),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(color: const Color(0xFFC9A24D), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: const Color(0xFF0B1C2D)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[50]!,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, __) => Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
          );
        }

        final shopProducts = productProvider.shopProducts;

        if (shopProducts.isEmpty) {
          return SliverToBoxAdapter(
            child: FadeInUp(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                        child: Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 20),
                      Text('Aucun produit disponible',
                          style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
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
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: ProductCard(product: shopProducts[index]),
                );
              },
              childCount: shopProducts.length,
            ),
          ),
        );
      },
    );
  }
}

