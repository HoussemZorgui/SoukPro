import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
  
  // Filter States
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 5000;
  String? _selectedCondition;

  final List<String> _categories = ['Tout', 'Électronique', 'Mode', 'Maison', 'Véhicules', 'Autres'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ProductProvider>(context, listen: false).searchProducts('')
    );
  }

  void _performSearch() {
    Provider.of<ProductProvider>(context, listen: false).searchProducts(
      _searchController.text,
      category: _selectedCategory == 'Tout' ? null : _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      condition: _selectedCondition,
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.only(
              top: 20, left: 24, right: 24, 
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 30
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Affiner la recherche', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0B1C2D))),
                const SizedBox(height: 20),
                
                const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (v) => setModalState(() => _selectedCategory = v ? cat : null),
                      selectedColor: const Color(0xFFC9A24D),
                      labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Plage de prix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_maxPrice.round()} TND', style: const TextStyle(color: Color(0xFFC9A24D), fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _maxPrice,
                  min: 0,
                  max: 10000,
                  activeColor: const Color(0xFFC9A24D),
                  inactiveColor: Colors.grey[200],
                  onChanged: (val) => setModalState(() => _maxPrice = val),
                ),
                
                const SizedBox(height: 30),
                Row(
                  children: [
                     Expanded(child: OutlinedButton(
                       onPressed: () {
                           setState(() {
                               _selectedCategory = 'Tout';
                               _maxPrice = 5000;
                           });
                           Navigator.pop(ctx);
                           _performSearch();
                       },
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                       ),
                       child: const Text('Réinitialiser')
                     )),
                     const SizedBox(width: 15),
                     Expanded(child: ElevatedButton(
                       onPressed: () {
                           Navigator.pop(ctx);
                           _performSearch();
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF0B1C2D),
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                       ),
                       child: const Text('Appliquer les filtres')
                     )),
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
    return SafeArea(
      child: Column(
        children: [
          _buildSearchHeader(),
          _buildCategoriesBar(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Rechercher électronique, mode...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFC9A24D)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C2D),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            )
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
        margin: const EdgeInsets.only(bottom: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (ctx, i) {
            final cat = _categories[i];
            final isSel = (_selectedCategory ?? 'Tout') == cat;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
                _performSearch();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFC9A24D) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? Colors.transparent : Colors.grey[200]!),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSel ? Colors.white : Colors.grey[600],
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (ctx, i) => _buildSkeleton(),
            ),
          );
        }
        
        if (provider.searchResults.isEmpty) {
           return FadeIn(
             child: Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[200]),
                   const SizedBox(height: 16),
                   Text('Aucun article trouvé', style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('Essayez d\'ajuster votre recherche ou vos filtres', style: TextStyle(color: Colors.grey[500])),
                 ],
               ),
             ),
           );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
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

  Widget _buildSkeleton() {
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
}

