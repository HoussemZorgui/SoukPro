import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/shop_provider.dart';
import 'shop_profile_screen.dart';
import '../../../core/constants/api_constants.dart';

class AllShopsScreen extends StatefulWidget {
  const AllShopsScreen({super.key});

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen> {
  String _searchQuery = "";
  String _selectedGovernorate = "Tous";
  
  final List<String> _governorates = [
    'Tous', 'Ariana', 'Beja', 'Ben Arous', 'Bizerte', 'Gabes', 'Gafsa', 'Jendouba', 
    'Kairouan', 'Kasserine', 'Kebili', 'Kef', 'Mahdia', 'Manouba', 
    'Medenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana', 
    'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ShopProvider>(context, listen: false).fetchAllShops()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Découvrir les Boutiques', 
          style: TextStyle(color: Color(0xFF0B1C2D), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              // Future: Open advanced filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Consumer<ShopProvider>(
              builder: (context, shopProvider, child) {
                if (shopProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0B1C2D)));
                }

                // Filtering logic
                final filteredShops = shopProvider.shops.where((shop) {
                  final nameMatch = (shop['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
                  final govMatch = _selectedGovernorate == "Tous" || shop['governorate'] == _selectedGovernorate;
                  return nameMatch && govMatch;
                }).toList();

                if (filteredShops.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = filteredShops[index];
                    return _buildPremiumShopCard(shop);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Rechercher une boutique...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _governorates.length,
        itemBuilder: (context, index) {
          final gov = _governorates[index];
          final isSelected = _selectedGovernorate == gov;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGovernorate = gov),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0B1C2D) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0B1C2D) : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFF0B1C2D).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    gov,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumShopCard(Map<String, dynamic> shop) {
    String imageUrl(String? path) {
      if (path == null || path.isEmpty) return "";
      return path.startsWith('http') ? path : '${ApiConstants.baseUrl.replaceAll('/api', '')}/$path';
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: shop))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            // Banner Section
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    image: shop['banner'] != null && shop['banner'].toString().isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl(shop['banner'])), fit: BoxFit.cover)
                      : null,
                  ),
                  child: shop['banner'] == null || shop['banner'].toString().isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF0B1C2D), const Color(0xFF1E3A5F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                      )
                    : Container(decoration: BoxDecoration(color: Colors.black12, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)))),
                ),
                // Status Badge (Verified)
                if (shop['isVerified'] == true)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text("Vérifié", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Info Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15)],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[50],
                      backgroundImage: shop['logo'] != null && shop['logo'].toString().isNotEmpty
                        ? NetworkImage(imageUrl(shop['logo']))
                        : null,
                      child: (shop['logo'] == null || shop['logo'].toString().isEmpty) 
                        ? const Icon(Icons.store, size: 30, color: Color(0xFF0B1C2D)) 
                        : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop['name'] ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0B1C2D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFC9A24D), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${shop['governorate'] ?? 'Tunisie'}",
                              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${shop['rating'] ?? '0.0'}/5", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              " (${shop['reviewCount'] ?? '0'} avis)",
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Visit Button
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1C2D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "Aucun résultat trouvé",
            style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Essayez d'autres filtres ou mots-clés",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
