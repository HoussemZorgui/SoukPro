import 'package:flutter/material.dart';
import 'package:mobile/core/models/product.dart';
import '../services/product_service.dart';
import 'package:dio/dio.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search State
  List<Product> _searchResults = [];
  List<Product> get searchResults => _searchResults;

  Future<void> searchProducts(String query, {String? category, double? minPrice, double? maxPrice, String? condition}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final filters = {
        if (query.isNotEmpty) 'search': query,
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
         if (condition != null) 'condition': condition,
      };
      
      _searchResults = await _productService.getProducts(filters: filters);
      // For Home Screen category filter, update main list too
      if (query.isEmpty) {
          _products = _searchResults;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seller/Shop Products
  List<Product> _shopProducts = [];
  List<Product> get shopProducts => _shopProducts;

  Future<void> fetchProductsBySeller(String sellerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _shopProducts = await _productService.getProductsBySeller(sellerId);
    } catch (e) {
      _errorMessage = e.toString();
      _shopProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> addProduct(FormData formData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.createProduct(formData);
      await fetchProducts(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String id, FormData formData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedProduct = await _productService.updateProduct(id, formData);
      // Update local lists
      int shopIdx = _shopProducts.indexWhere((p) => p.id == id);
      if (shopIdx != -1) _shopProducts[shopIdx] = updatedProduct;
      
      int mainIdx = _products.indexWhere((p) => p.id == id);
      if (mainIdx != -1) _products[mainIdx] = updatedProduct;
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.deleteProduct(id);
      _shopProducts.removeWhere((p) => p.id == id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
