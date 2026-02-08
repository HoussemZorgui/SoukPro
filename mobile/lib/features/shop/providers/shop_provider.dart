import 'package:flutter/material.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import '../services/shop_service.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();
  
  Map<String, dynamic>? _shop;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get shop => _shop;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasShop => _shop != null;

  Future<void> fetchMyShop() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shop = await _shopService.getMyShop();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createShop({
    required String name,
    required String description,
    required String shopAddress,
    String? governorate,
    String? phone,
    String? facebook,
    String? instagram,
    String? website,
    LatLng? location,
    File? logo,
    File? banner,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shop = await _shopService.createShop(
        name: name,
        description: description,
        shopAddress: shopAddress,
        governorate: governorate,
        phone: phone,
        facebook: facebook,
        instagram: instagram,
        website: website,
        location: location,
        logo: logo,
        banner: banner,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getShopById(String id) async {
    try {
      return await _shopService.getShopById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  List<dynamic> _shops = [];
  List<dynamic> get shops => _shops;

  Future<void> fetchAllShops() async {
    _isLoading = true;
    notifyListeners();
    try {
      _shops = await _shopService.getAllShops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
