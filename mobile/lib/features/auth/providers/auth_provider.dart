import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> init() async {
    // Check for stored token and fetch user
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.getCurrentUser();
      _user = user;
    } catch (e) {
      // Token invalid or network error, just logout logic effectively
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      _user = User.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

   Future<bool> signInWithGoogle({String? role}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("DÉBUT: Authentification Google...");
      final googleSignIn = GoogleSignIn(
        serverClientId: '883058224975-7npqi5omptcqv7ch48n0tov24cjkgkko.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print("ANNULÉ: L'utilisateur a fermé la fenêtre Google");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print("SUCCÈS GOOGLE: Utilisateur détecté: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print("ERREUR: Impossible de récupérer le idToken");
        throw Exception("Impossible d'obtenir le token Google");
      }

      print("ENVOI AU SERVEUR: Appel API googleLogin avec role: $role");
      final data = await _authService.googleLogin(idToken, role);
      
      print("RÉPONSE SERVEUR: Authentification réussie");
      _user = User.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("ERREUR FATALE GoogleSignIn: $e");
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.register(name, email, password, role);
      _user = User.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String name, String phone, String address, File? avatar, File? kycDoc) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_user == null) throw Exception("No user logged in");
      final updatedUser = await _authService.updateProfile(
        id: _user!.id,
        name: name,
        phone: phone,
        address: address,
        avatar: avatar,
        kycDoc: kycDoc
      );
      _user = updatedUser;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.deleteToken();
    _user = null;
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _authService.getToken();
  }
}
