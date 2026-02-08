import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import '../../../core/constants/api_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ProductProvider>(context, listen: false).fetchProducts()
    );
  }

  void _filterByCategory(String category) {
    setState(() => _selectedCategory = category);
    if (category == 'All') {
       Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    } else {
       Provider.of<ProductProvider>(context, listen: false).searchProducts('', category: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final categories = [
      {'name': 'Tout', 'icon': Icons.grid_view_rounded},
      {'name': 'Électronique', 'icon': Icons.devices},
      {'name': 'Mode', 'icon': Icons.checkroom},
      {'name': 'Maison', 'icon': Icons.home_work_outlined},
      {'name': 'Véhicules', 'icon': Icons.directions_car},
      {'name': 'Autres', 'icon': Icons.more_horiz},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Jumia-style Banner / Carousel
          SliverToBoxAdapter(
            child: FadeInDown(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 190.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16/9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        viewportFraction: 0.88,
                        onPageChanged: (index, reason) {
                          setState(() => _currentBannerIndex = index);
                        },
                      ),
                      items: [
                        _buildBannerItem(
                          color: const Color(0xFF0B1C2D), 
                          title: 'Spécial Ramadan', 
                          subtitle: 'Jusqu\'à -50% sur l\'Électronique',
                          icon: Icons.flash_on,
                        ),
                        _buildBannerItem(
                          color: const Color(0xFFC9A24D), 
                          title: 'Nouvelles Collections', 
                          subtitle: 'Découvrez les dernières tendances Mode',
                          icon: Icons.shopping_bag,
                        ),
                        _buildBannerItem(
                          color: Colors.blueAccent, 
                          title: 'Artisanat Local', 
                          subtitle: 'Soutenez les artisans tunisiens',
                          icon: Icons.brush,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentBannerIndex == i ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentBannerIndex == i 
                                ? const Color(0xFFC9A24D) 
                                : Colors.grey[200],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Gold Circle Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = categories[i];
                    final isSelected = _selectedCategory == cat['name'];
                    return ZoomIn(
                      delay: Duration(milliseconds: i * 100),
                      child: GestureDetector(
                        onTap: () => _filterByCategory(cat['name'] as String),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 15),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFFC9A24D) : Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFC9A24D), 
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC9A24D).withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: Icon(
                                  cat['icon'] as IconData, 
                                  color: isSelected ? Colors.white : const Color(0xFFC9A24D),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? const Color(0xFFC9A24D) : Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Trending Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text(
                    'PRODUITS TENDANCE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF1E293B)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Voir tout', style: TextStyle(color: Color(0xFFC9A24D), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // Trending Horizontal Skeletons
          SliverToBoxAdapter(
            child: SizedBox(
               height: 220,
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 itemCount: 5,
                 itemBuilder: (ctx, i) {
                    return _buildTrendingSkeleton();
                 },
               ),
            ),
          ),

          // Limited Offers Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 30, bottom: 10),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.redAccent,
                       borderRadius: BorderRadius.circular(5),
                     ),
                     child: const Icon(Icons.flash_on, color: Colors.white, size: 16),
                   ),
                   const SizedBox(width: 8),
                   const Text(
                    'OFFRES LIMITÉES',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
          ),

          // Limited Horizontal List (Skeletons)
          SliverToBoxAdapter(
            child: SizedBox(
               height: 180,
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 itemCount: 5,
                 itemBuilder: (ctx, i) {
                    return _buildTrendingSkeleton(); // Reuse trending skeleton for consistency or create simpler one
                 },
               ),
            ),
          ),

          // Explore All Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
              child: Text(
                'EXPLORER LES COLLECTIONS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF1E293B)),
              ),
            ),
          ),
          
          // Product Grid
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final products = productProvider.products;
               
              if (productProvider.isLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMainSkeleton(),
                      childCount: 4,
                    ),
                  ),
                );
              }

              if (products.isEmpty) {
                 return SliverFillRemaining(
                   hasScrollBody: false,
                   child: Center(
                     child: FadeIn(
                       child: Padding(
                         padding: const EdgeInsets.symmetric(vertical: 20),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                             const SizedBox(height: 10),
                             const Text('Aucun article trouvé', style: TextStyle(color: Colors.grey)),
                           ],
                         ),
                       ),
                     ),
                   ),
                 );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: ProductCard(product: products[index]),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: user != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              backgroundColor: const Color(0xFF0B1C2D),
              elevation: 10,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Vendre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildTrendingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildMainSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }


  Widget _buildBannerItem({required Color color, required String title, required String subtitle, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Decorative Background Circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: Container(
                 width: 100,
                 height: 100,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.white.withOpacity(0.05),
                 ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -20,
              child: Icon(icon, size: 140, color: Colors.white.withOpacity(0.15)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'EXCLUSIF',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Glassmorphism-style button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Acheter',
                          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios, color: color, size: 10),
                      ],
                    ),
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
