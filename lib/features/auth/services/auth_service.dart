import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// INICIAR SESIÓN
  /// Esta función ya es compatible con el nuevo modelo gracias al factory 'fromMap' robusto.
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _db.collection('users').doc(result.user!.uid).get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!, result.user!.uid);
      }

      return null;
    } catch (e, stacktrace) {
      debugPrint('Error en login: $e');
      debugPrint('Stack: $stacktrace');
      return null;
    }
  }

  /// REGISTRARSE
  /// --- ESTA FUNCIÓN HA SIDO ACTUALIZADA ---
  Future<UserModel?> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        uid: result.user!.uid,
        fullName: fullName,
        username: username,
        email: email,
        phone: phone,
        profileImageUrl: '',
        isVerified: false,
        blocked: false,
        banReason: null,
        reports: 0,
        totalGamesCreated: 0,
        totalGamesJoined: 0,
        ratingCount: 0,
        ratingSum: 0.0,
        position: '',
        skillLevel: '',
        lastLoginAt: DateTime.now(),
        createdAt: DateTime.now(),
        notesByAdmin: '',
        verification: VerificationData(
          idCardFrontUrl: '',
          idCardBackUrl: '',
          faceWithIdUrl: '',
          status: 'pending',
          rejectionReason: null,
        ),
        friends: [],
        friendRequestsSent: [],
        friendRequestsReceived: [],
        blockedUsers: [],
      );

      await _db.collection('users').doc(result.user!.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      debugPrint('Error en registro: $e');
      return null;
    }
  }

  /// CERRAR SESIÓN
  Future<void> signOut() async {
    await _auth.signOut();
  }
}