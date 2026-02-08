import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/shop_provider.dart';
import 'shop_profile_screen.dart';
import 'edit_shop_screen.dart';
import '../../home/screens/add_product_screen.dart';
import 'location_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

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
    Future.microtask(() => 
      Provider.of<ShopProvider>(context, listen: false).fetchMyShop()
    );
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

    if (!success && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de la création de la boutique')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ma Boutique Professionnelle', style: TextStyle(color: Color(0xFF0B1C2D), fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!shopProvider.hasShop) {
             return _buildCreateShopUI();
          }

          final shop = shopProvider.shop!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      // Banner
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1C2D),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          image: shop['banner'] != null ? DecorationImage(
                             image: NetworkImage(shop['banner'].startsWith('http') ? shop['banner'] : 'http://10.0.2.2:5001/${shop['banner']}'),
                             fit: BoxFit.cover,
                          ) : null,
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Logo
                            Container(
                              transform: Matrix4.translationValues(0, -30, 0),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                backgroundImage: shop['logo'] != null ? NetworkImage(shop['logo'].startsWith('http') ? shop['logo'] : 'http://10.0.2.2:5001/${shop['logo']}') : null,
                                child: shop['logo'] == null ? const Icon(Icons.store, size: 40, color: Color(0xFF0B1C2D)) : null,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Container(
                                transform: Matrix4.translationValues(0, -10, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(shop['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B1C2D))),
                                    const SizedBox(height: 4),
                                    Text(shop['shopAddress'] ?? 'Aucune adresse', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
                
                const SizedBox(height: 24),

                if (shop['location'] != null && shop['location']['lat'] != null)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(shop['location']['lat'], shop['location']['lng']),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Static map
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.soukpro.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(shop['location']['lat'], shop['location']['lng']),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Stats Grid
                const Text('Aperçu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C2D))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Revenus', '0.0 TND', const Color(0xFFC9A24D), Icons.wallet),
                    const SizedBox(width: 16),
                    _buildStatCard('Commandes', '0', const Color(0xFF0B1C2D), Icons.shopping_bag_outlined),
                  ],
                ),
                 const SizedBox(height: 16),
                 Row(
                  children: [
                    _buildStatCard('Produits', '0', Colors.purple, Icons.inventory_2_outlined), // Fetch real count if possible
                    const SizedBox(width: 16),
                    _buildStatCard('Vues', '0', Colors.teal, Icons.visibility_outlined),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Actions
                const Text('Gestion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C2D))),
                const SizedBox(height: 16),
                _buildActionTile('Ajouter un produit', Icons.add_circle_outline, Colors.blue, () {
                  // Navigate to Add Product (using the existing logic from Home or direct push)
                  // Assuming we can simply push the AddProductScreen
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  );
                }),
                _buildActionTile('Modifier la boutique', Icons.edit_outlined, Colors.orange, () {
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditShopScreen(shop: shop)),
                  );
                }),
                _buildActionTile('Voir le profil public', Icons.storefront, Colors.black, () {
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: shop)),
                  );
                }),
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
          const Text(
            'Créer votre boutique',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0B1C2D)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Configurez votre présence professionnelle en quelques minutes.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // Banner Picker
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                image: _banner != null ? DecorationImage(image: FileImage(_banner!), fit: BoxFit.cover) : null,
              ),
              child: _banner == null 
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image, color: Colors.grey[400], size: 40), Text('Télécharger la bannière', style: TextStyle(color: Colors.grey[500]))])
                  : null,
            ),
          ),
          
          const SizedBox(height: 20),

          // Logo Picker
          Center(
            child: Stack(
              children: [
                Container(
                   decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                   child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _logo != null ? FileImage(_logo!) : null,
                    child: _logo == null ? Icon(Icons.store, size: 40, color: Colors.grey[400]) : null,
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: const CircleAvatar(radius: 18, backgroundColor: Color(0xFF0B1C2D), child: Icon(Icons.camera_alt, color: Colors.white, size: 16)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          _buildTextField(_nameController, "Nom de la boutique", Icons.store_mall_directory),
          const SizedBox(height: 16),
          _buildTextField(_descController, "Description", Icons.description, maxLines: 3),
           const SizedBox(height: 16),
          _buildTextField(_shopAddressController, "Adresse de la Boutique", Icons.storefront),
          const SizedBox(height: 16),
          _buildGovernorateDropdown(),
          const SizedBox(height: 16),
          _buildTextField(_phoneController, "Téléphone", Icons.phone),
           const SizedBox(height: 16),
          const Text("Réseaux Sociaux", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildTextField(_facebookController, "Facebook Link", Icons.facebook),
          const SizedBox(height: 8),
          _buildTextField(_instagramController, "Instagram Link", Icons.camera_alt),
          const SizedBox(height: 8),
          _buildTextField(_websiteController, "Site Web", Icons.language),
          
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
              );
              if (result != null && result is LatLng) {
                setState(() {
                  _selectedLocation = result;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                   const Icon(Icons.map, color: Color(0xFF0B1C2D)),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       _selectedLocation != null 
                         ? 'Position sélectionnée: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}' 
                         : 'Sélectionner l\'emplacement sur la carte',
                       style: TextStyle(color: _selectedLocation != null ? Colors.black : Colors.grey[600]),
                     ),
                   ),
                   const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1C2D),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                shadowColor: const Color(0xFF0B1C2D).withOpacity(0.4),
                elevation: 8,
              ),
              child: const Text('Lancer la boutique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGovernorate,
          hint: Row(
            children: [
              Icon(Icons.location_city, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Text("Sélectionner un Gouvernorat", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          isExpanded: true,
          items: _governorates.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedGovernorate = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC9A24D), width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
        onTap: onTap,
      ),
    );
  }
}
