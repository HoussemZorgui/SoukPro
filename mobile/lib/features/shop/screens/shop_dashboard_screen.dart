import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import '../providers/shop_provider.dart';
import 'shop_profile_screen.dart';
import 'edit_shop_screen.dart';
import 'manage_products_screen.dart';
import 'shop_orders_screen.dart';
import '../../home/screens/add_product_screen.dart';
import 'location_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  
  String? _selectedGovernorate;
  final List<String> _governorates = [
    'Ariana', 'Beja', 'Ben Arous', 'Bizerte', 'Gabes', 'Gafsa', 'Jendouba', 
    'Kairouan', 'Kasserine', 'Kebili', 'Kef', 'Mahdia', 'Manouba', 
    'Medenine', 'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana', 
    'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
  ];
  
  LatLng? _selectedLocation;
  
  File? _logo;
  File? _banner;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      await shopProvider.fetchMyShop();
      if (shopProvider.hasShop) {
        final shopId = shopProvider.shop!['_id'] ?? shopProvider.shop!['id'];
        shopProvider.fetchShopStats(shopId.toString());
      }
    });
  }

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logo = File(image.path);
        } else {
          _banner = File(image.path);
        }
      });
    }
  }

  void _createShop() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom de la boutique est requis')));
      return;
    }
    
    final success = await Provider.of<ShopProvider>(context, listen: false).createShop(
      name: _nameController.text,
      description: _descController.text,
      shopAddress: _shopAddressController.text,
      governorate: _selectedGovernorate,
      phone: _phoneController.text,
      facebook: _facebookController.text,
      instagram: _instagramController.text,
      website: _websiteController.text,
      location: _selectedLocation,
      logo: _logo,
      banner: _banner,
    );

    if (success && mounted) {
       Provider.of<AuthProvider>(context, listen: false).refreshUser();
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de la création de la boutique')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Ma Boutique', 
          style: GoogleFonts.outfit(color: const Color(0xFF0B1C2D), fontWeight: FontWeight.w800, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0B1C2D)));
          }

          if (!shopProvider.hasShop) {
             return _buildCreateShopUI();
          }

          final shop = shopProvider.shop!;
          final stats = shopProvider.shopStats ?? {};
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header Card
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Banner with refined overlay
                        Stack(
                          children: [
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1C2D),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                image: shop['banner'] != null ? DecorationImage(
                                   image: NetworkImage(shop['banner'].startsWith('http') 
                                      ? shop['banner'] 
                                      : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${shop['banner']}'),
                                   fit: BoxFit.cover,
                                ) : null,
                              ),
                            ),
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Logo with Glow
                              Container(
                                transform: Matrix4.translationValues(0, -35, 0),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white, 
                                  shape: BoxShape.circle, 
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.grey[50],
                                  backgroundImage: shop['logo'] != null 
                                      ? NetworkImage(shop['logo'].startsWith('http') 
                                          ? shop['logo'] 
                                          : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${shop['logo']}') 
                                      : null,
                                  child: shop['logo'] == null ? const Icon(Icons.store, size: 45, color: Color(0xFF0B1C2D)) : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  transform: Matrix4.translationValues(0, -15, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              shop['name'], 
                                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          if (shop['isVerified'] == true)
                                            const Icon(Icons.verified, color: Colors.blue, size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, color: Color(0xFFC9A24D), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            shop['shopAddress'] ?? 'Aucune adresse', 
                                            style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Real Stats Grid
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VOTRE ACTIVITÉ', 
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D), letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard('Revenus', '${stats['totalRevenue'] ?? '0.0'} TND', const Color(0xFFC9A24D), Icons.auto_graph_rounded),
                          const SizedBox(width: 16),
                          _buildStatCard('Commandes', '${stats['totalOrders'] ?? '0'}', const Color(0xFF0B1C2D), Icons.shopping_bag_outlined),
                        ],
                      ),
                       const SizedBox(height: 16),
                       Row(
                        children: [
                          _buildStatCard('Produits', '${stats['totalProducts'] ?? '0'}', Colors.blueGrey, Icons.inventory_2_outlined),
                          const SizedBox(width: 16),
                          _buildStatCard('Vues', '${stats['totalViews'] ?? '0'}', Colors.indigo, Icons.visibility_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Actions
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GESTION DU CATALOGUE', 
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D), letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      _buildActionTile('Gérer les commandes', 'Suivi et mise à jour des commandes', Icons.receipt_long_rounded, Colors.orange, () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopOrdersScreen()));
                      }),
                      _buildActionTile('Ajouter un produit', 'Publier une nouvelle annonce', Icons.add_rounded, const Color(0xFF0B1C2D), () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddProductScreen()));
                      }),
                      _buildActionTile('Gérer mes produits', 'Modifier ou supprimer vos articles', Icons.inventory_2_outlined, Colors.indigo, () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageProductsScreen()));
                      }),
                      _buildActionTile('Modifier la boutique', 'Mettre à jour vos informations', Icons.edit_note_rounded, const Color(0xFFC9A24D), () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditShopScreen(shop: shop)));
                      }),
                      _buildActionTile('Voir le profil public', 'Aperçu de votre boutique', Icons.remove_red_eye_outlined, Colors.blueGrey, () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: shop)));
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateShopUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Créer votre boutique',
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lancez votre activité professionnelle sur SoukPro aujourd\'hui.',
                  style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Banner Picker
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!, width: 2),
                image: _banner != null ? DecorationImage(image: FileImage(_banner!), fit: BoxFit.cover) : null,
              ),
              child: _banner == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 40),
                        const SizedBox(height: 8),
                        Text('Photo de couverture', style: GoogleFonts.outfit(color: Colors.grey[500], fontWeight: FontWeight.w600))
                      ])
                  : null,
            ),
          ),
          
          const SizedBox(height: 20),

          // Logo Picker
          Center(
            child: Stack(
              children: [
                Container(
                   decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    border: Border.all(color: Colors.white, width: 4), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)]
                   ),
                   child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: _logo != null ? FileImage(_logo!) : null,
                    child: _logo == null ? Icon(Icons.storefront_rounded, size: 45, color: Colors.grey[400]) : null,
                  ),
                ),
                Positioned(
                  bottom: 4, right: 4,
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: const CircleAvatar(
                      radius: 18, 
                      backgroundColor: Color(0xFF0B1C2D), 
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18)
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          
          _buildTextField(_nameController, "Nom commercial", Icons.store_rounded),
          const SizedBox(height: 20),
          _buildTextField(_descController, "Description de l'activité", Icons.info_outline_rounded, maxLines: 3),
          const SizedBox(height: 20),
          _buildTextField(_shopAddressController, "Adresse physique", Icons.location_on_outlined),
          const SizedBox(height: 20),
          _buildGovernorateDropdown(),
          const SizedBox(height: 20),
          _buildTextField(_phoneController, "Numéro de téléphone", Icons.phone_android_rounded),
          
          const SizedBox(height: 32),
          Text("PRÉSENCE DIGITALE", 
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B1C2D), letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildTextField(_facebookController, "Lien Facebook", Icons.facebook),
          const SizedBox(height: 12),
          _buildTextField(_instagramController, "Lien Instagram", Icons.camera_alt_outlined),
          const SizedBox(height: 12),
          _buildTextField(_websiteController, "Site Web", Icons.language_rounded),
          
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
              );
              if (result != null && result is LatLng) {
                setState(() => _selectedLocation = result);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                   const Icon(Icons.map_rounded, color: Color(0xFF0B1C2D)),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Text(
                       _selectedLocation != null 
                         ? 'Emplacement enregistré' 
                         : 'DÉFINIR L\'EMPLACEMENT SUR LA CARTE',
                       style: GoogleFonts.outfit(
                        color: _selectedLocation != null ? Colors.green[700] : Colors.grey[600],
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                       ),
                     ),
                   ),
                   const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1C2D),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: const Color(0xFF0B1C2D).withOpacity(0.3),
              ),
              child: Text('Lancer ma boutique', 
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGovernorate,
          hint: Row(
            children: [
              Icon(Icons.location_city_rounded, color: Colors.grey[500], size: 20),
              const SizedBox(width: 12),
              Text("Gouvernorat", style: GoogleFonts.outfit(color: Colors.grey[600])),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: _governorates.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.outfit()),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedGovernorate = newValue),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0B1C2D), width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), 
              child: Icon(icon, color: color, size: 22)
            ),
            const SizedBox(height: 20),
            Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF0B1C2D))),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12), 
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), 
          child: Icon(icon, color: color, size: 24)
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0B1C2D))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
        onTap: onTap,
      ),
    );
  }
}
