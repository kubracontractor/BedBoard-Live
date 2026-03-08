
//handle login, logout , registration
//TALK TO FIREBASE AUTHENTICATION SERVICE

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; //kept the _auth private to prevent misuse from other files

  Stream<User?> get authStateChanges => _auth.authStateChanges();  //Firebase’s authentication stream to reactively control navigation

  Future<void> signOut() async => _auth.signOut();

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }
}

