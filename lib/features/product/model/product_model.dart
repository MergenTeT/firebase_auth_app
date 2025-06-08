import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit; // kg, ton, adet vb.
  final int quantity;
  final String sellerId;
  final String sellerName;
  final List<String> images;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isAvailable;
  final String location;
  final Map<String, dynamic>? specifications; // Ek özellikler (organik, kalite sınıfı vb.)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
    required this.images,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.isAvailable = true,
    required this.location,
    this.specifications,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      quantity: data['quantity'] ?? 0,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isAvailable: data['isAvailable'] ?? true,
      location: data['location'] ?? '',
      specifications: data['specifications'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'images': images,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isAvailable': isAvailable,
      'location': location,
      'specifications': specifications,
    };
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    String? unit,
    int? quantity,
    List<String>? images,
    String? category,
    bool? isAvailable,
    String? location,
    Map<String, dynamic>? specifications,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      sellerId: sellerId,
      sellerName: sellerName,
      images: images ?? this.images,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      specifications: specifications ?? this.specifications,
    );
  }
}
