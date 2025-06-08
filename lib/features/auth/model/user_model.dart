import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  farmer,    // Çiftçi
  buyer,     // Alıcı
  both       // Her ikisi
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final String? location;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.location,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: UserRole.values[data['role'] ?? 0],
      phoneNumber: data['phoneNumber'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.index,
      'phoneNumber': phoneNumber,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
