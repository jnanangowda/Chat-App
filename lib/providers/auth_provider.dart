import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _userModel;
  String? _error;
  bool _isLoading = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        _firebaseUser = user;
        _loadUserData();
      } else {
        _firebaseUser = null;
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      _userModel = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _firebaseUser = null;
      _userModel = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    if (_firebaseUser == null) return;
    try {
      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
