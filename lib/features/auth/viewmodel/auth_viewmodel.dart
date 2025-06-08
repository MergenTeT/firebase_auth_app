import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? errorMessage;

  // Giriş yapma işlemi
  Future<bool> signIn(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'Kullanıcı bulunamadı';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Yanlış şifre';
      } else {
        errorMessage = 'Bir hata oluştu: ${e.message}';
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Kayıt olma işlemi
  Future<bool> signUp(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'Şifre çok zayıf';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu email zaten kullanımda';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz email adresi';
      } else {
        errorMessage = 'Bir hata oluştu: ${e.message}';
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Çıkış yapma işlemi
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı durumu kontrolü
  bool get isUserLoggedIn => _auth.currentUser != null;
  
  // Mevcut kullanıcı bilgisi
  User? get currentUser => _auth.currentUser;
}
