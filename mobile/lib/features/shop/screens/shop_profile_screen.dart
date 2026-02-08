import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/product_card.dart';
import '../../home/providers/product_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildShopInfo(),
                _buildShopLocation(),
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
  }

  Widget _buildSliverAppBar() {
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
                  child: widget.shop['banner'] != null && widget.shop['banner'].toString().isNotEmpty
                      ? Image.network(
                          widget.shop['banner'].startsWith('http')
                              ? widget.shop['banner']
                              : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${widget.shop['banner']}',
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
                    backgroundImage: widget.shop['logo'] != null && widget.shop['logo'].toString().isNotEmpty
                        ? NetworkImage(
                            widget.shop['logo'].startsWith('http')
                                ? widget.shop['logo']
                                : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${widget.shop['logo']}',
                          )
                        : null,
                    child: (widget.shop['logo'] == null || widget.shop['logo'].toString().isEmpty) 
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

  Widget _buildShopInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.shop['name'] ?? 'Nom de la Boutique',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C2D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              if (widget.shop['isVerified'] == true)
                const Icon(Icons.verified, color: Colors.blue, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.shop['governorate'] ?? ''}${widget.shop['governorate'] != null ? ', ' : ''}${widget.shop['shopAddress'] ?? 'Tunisie'}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          if (widget.shop['description'] != null && widget.shop['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.shop['description'],
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          _buildSocials(),
          const SizedBox(height: 24),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildSocials() {
    final social = widget.shop['socialLinks'] ?? {};
    final phone = widget.shop['phone'];
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

  Widget _buildStatsRow() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
       final owner = widget.shop['owner'];
       String joinedDate = '2026';
       try {
         final dateStr = owner is Map ? owner['createdAt'] : null;
         if (dateStr != null) {
           joinedDate = DateTime.parse(dateStr.toString()).year.toString();
         }
       } catch (e) { joinedDate = '2026'; }

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
              _buildStatItem(provider.shopProducts.length.toString(), 'Articles'),
              Container(height: 30, width: 1, color: Colors.grey[300]),
              _buildStatItem('4.9', 'Note'), // Static or computed
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

  Widget _buildShopLocation() {
    if (widget.shop['location'] == null || widget.shop['location']['lat'] == null) {
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
                (widget.shop['location']['lat'] as num).toDouble(), 
                (widget.shop['location']['lng'] as num).toDouble()
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
                      (widget.shop['location']['lat'] as num).toDouble(), 
                      (widget.shop['location']['lng'] as num).toDouble()
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
                  Text(widget.shop['shopAddress'] ?? 'Emplacement', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
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

