import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../auth/model/user_model.dart';
import '../model/role_model.dart';

class RoleViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> saveUserRole(RoleSelectionModel model) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(model.userId).set(
            model.toFirestore(),
            SetOptions(merge: true),
          );

      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = 'Rol kaydedilirken bir hata oluştu: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
