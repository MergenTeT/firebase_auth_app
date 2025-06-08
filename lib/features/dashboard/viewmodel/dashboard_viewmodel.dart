import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../product/model/product_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Tümü';
  final List<String> _categories = [
    'Tümü',
    'Sebze',
    'Meyve',
    'Tahıl',
    'Bakliyat',
    'Diğer'
  ];

  // Getters
  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  // Ürünleri getir
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var query = _firestore.collection('products')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true);
      
      if (_selectedCategory != 'Tümü') {
        query = query.where('category', isEqualTo: _selectedCategory);
      }

      final snapshot = await query.get();
      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      _filteredProducts = List.from(_products);
    } catch (e) {
      _error = 'Ürünler yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kategori değiştir
  void changeCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      fetchProducts();
    }
  }

  // Ürün ara
  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products')
          .where('isAvailable', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      _filteredProducts = List.from(_products);
    } catch (e) {
      _error = 'Arama yapılırken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fiyat aralığına göre filtrele
  void filterByPriceRange(double minPrice, double maxPrice) {
    _filteredProducts = _products
        .where((product) => product.price >= minPrice && product.price <= maxPrice)
        .toList();
    notifyListeners();
  }

  // Sıralama
  void sortProducts(String sortBy) {
    switch (sortBy) {
      case 'newest':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
    notifyListeners();
  }

  // Kullanıcının kendi ürünlerini getir
  Future<void> fetchUserProducts(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      _filteredProducts = List.from(_products);
    } catch (e) {
      _error = 'Ürünleriniz yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 