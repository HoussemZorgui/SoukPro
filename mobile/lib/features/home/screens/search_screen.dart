import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/product_provider.dart';
import '../../home/widgets/product_card.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory = 'Tout';
  double _minPrice = 0;
  double _maxPrice = 10000;
  
  final List<Map<String, dynamic>> _categoriesList = [
    {'name': 'Tout', 'icon': Icons.grid_view_rounded},
    {'name': 'Électronique', 'icon': Icons.devices},
    {'name': 'Mode', 'icon': Icons.checkroom},
    {'name': 'Maison', 'icon': Icons.home_work_outlined},
    {'name': 'Véhicules', 'icon': Icons.directions_car},
    {'name': 'Bureautique', 'icon': Icons.print},
    {'name': 'Autres', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ProductProvider>(context, listen: false).searchProducts('', status: 'all')
    );
  }

  void _performSearch() {
    Provider.of<ProductProvider>(context, listen: false).searchProducts(
      _searchController.text,
      category: _selectedCategory == 'Tout' ? null : _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      status: 'all',
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
            ),
            padding: EdgeInsets.only(
              top: 15, left: 24, right: 24, 
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 30
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50, 
                    height: 5, 
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))
                  )
                ),
                const SizedBox(height: 30),
                Text('Filtres', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D))),
                const SizedBox(height: 25),
                
                Text('Plage de Prix (TND)', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 10),
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0,
                  max: 20000,
                  divisions: 40,
                  activeColor: const Color(0xFFC9A24D),
                  inactiveColor: Colors.grey[100],
                  labels: RangeLabels('${_minPrice.round()}', '${_maxPrice.round()}'),
                  onChanged: (values) {
                    setModalState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Min: ${_minPrice.round()} TND', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                    Text('Max: ${_maxPrice.round()} TND', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setModalState(() {
                            _minPrice = 0;
                            _maxPrice = 10000;
                            _selectedCategory = 'Tout';
                          });
                        },
                        child: Text('Réinitialiser', style: GoogleFonts.outfit(color: Colors.grey[600], fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _performSearch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1C2D),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: Text('Appliquer', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoriesBar(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Découvrir', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {}); // Update suffix icon
                        if (val.isEmpty) _performSearch();
                      },
                      onSubmitted: (_) => _performSearch(),
                      decoration: InputDecoration(
                        hintText: 'Que cherchez-vous ?',
                        hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 15),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFC9A24D)),
                        suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () {
                              _searchController.clear();
                              _performSearch();
                              setState(() {});
                            }) 
                          : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1C2D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(top: 10, bottom: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categoriesList.length,
          itemBuilder: (ctx, i) {
            final cat = _categoriesList[i];
            final isSel = _selectedCategory == cat['name'];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat['name']);
                _performSearch();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF0B1C2D) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? Colors.transparent : Colors.grey[200]!),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(cat['icon'], size: 16, color: isSel ? const Color(0xFFC9A24D) : Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      cat['name'],
                      style: GoogleFonts.outfit(
                        color: isSel ? Colors.white : Colors.grey[600],
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoadingGrid();
        }
        
        if (provider.searchResults.isEmpty) {
           return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.searchResults.length,
          itemBuilder: (ctx, i) => FadeInUp(
            delay: Duration(milliseconds: i * 50),
            child: ProductCard(product: provider.searchResults[i]),
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (ctx, i) => Shimmer.fromColors(
        baseColor: Colors.grey[100]!,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: FadeInUp(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               padding: const EdgeInsets.all(30),
               decoration: BoxDecoration(
                 color: Colors.white,
                 shape: BoxShape.circle,
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]
               ),
               child: Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[200]),
             ),
             const SizedBox(height: 24),
             Text('Oups ! Aucun résultat', style: GoogleFonts.outfit(fontSize: 20, color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w900)),
             const SizedBox(height: 10),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 40),
               child: Text('Nous n\'avons pas trouvé de produits correspondant à votre recherche. Essayez d\'autres filtres !', 
                 textAlign: TextAlign.center,
                 style: GoogleFonts.outfit(color: Colors.grey[500], height: 1.5)),
             ),
             const SizedBox(height: 30),
             TextButton(
               onPressed: () {
                 setState(() {
                   _selectedCategory = 'Tout';
                   _searchController.clear();
                 });
                 _performSearch();
               },
               child: Text('Voir tous les produits', style: GoogleFonts.outfit(color: const Color(0xFFC9A24D), fontWeight: FontWeight.w800)),
             )
           ],
         ),
       ),
     );
  }
}
