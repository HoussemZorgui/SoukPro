import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(36.8065, 10.1815); // Default to Tunis
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _currentCenter = widget.initialLocation!;
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    setState(() {
      _currentCenter = camera.center;
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    
    try {
      final url = Uri.parse('https://photon.komoot.io/api/?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['features'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de recherche: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectSearchResult(dynamic feature) {
    final coords = feature['geometry']['coordinates'];
    final lat = coords[1];
    final lng = coords[0];
    final newLocation = LatLng(lat as double, lng as double);
    
    _mapController.move(newLocation, 15);
    setState(() {
      _currentCenter = newLocation;
      _searchResults = [];
      _searchController.clear(); 
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir l\'emplacement', style: TextStyle(color: Color(0xFF0B1C2D))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0B1C2D)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _currentCenter);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13,
              onPositionChanged: _onMapPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.soukpro.app', 
              ),
            ],
          ),
          
          // Center Marker
          const Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),

          // Search Bar
          Positioned(
            top: 10, left: 10, right: 10,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une adresse...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching 
                          ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))) 
                          : IconButton(icon: const Icon(Icons.clear), onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            }),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final feature = _searchResults[index];
                          final props = feature['properties'];
                          return ListTile(
                            title: Text(props['name'] ?? 'Inconnu'),
                            subtitle: Text('${props['city'] ?? ''}, ${props['country'] ?? ''}'),
                            onTap: () => _selectSearchResult(feature),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Confirm Button at bottom
          Positioned(
             bottom: 30, left: 20, right: 20,
             child: SafeArea(
               child: ElevatedButton(
                 onPressed: () => Navigator.pop(context, _currentCenter),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF0B1C2D),
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   elevation: 5,
                 ),
                 child: const Text('Confirmer cette position', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
               ),
             ),
          ),
        ],
      ),
    );
  }
}
