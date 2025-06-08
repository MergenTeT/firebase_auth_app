import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/model/user_model.dart';

class RoleSelectionModel {
  final String userId;
  final String email;
  final String fullName;
  final UserRole selectedRole;

  RoleSelectionModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.selectedRole,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': selectedRole.index,
      'createdAt': Timestamp.now(),
    };
  }
}
