import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future <User?> signIn(String email, String password) async{
    try{
      //User? result = _auth.currentUser;//signInWithCredential(authCredential);
      print('hola');
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
      //print(result?.email);
    }catch (e,stacktrace) {
      print("Error de inicio de seccion: linea 11 $e");
      debugPrint("Error de inicio de sesión: $e");
      debugPrint("Stacktrace: $stacktrace");
      return null;
    }
  }
  Future <User?> register(String email, String password) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword( email: email, password: password);
      return result.user;
    }catch (e) {
      print("Error de inicio de seccion: linea 20$e");
      return null;
    }
  }
  Future <void> singOut () async{
    await _auth.signOut();
  }
}
