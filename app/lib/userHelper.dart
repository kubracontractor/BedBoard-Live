
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//created to handle the crashes when the user isn't registered in firebase
//thus, doesn't have  auto-uid
class UserRole {
  static Future<Map<String, String>> getRoleNPosition() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = snap.data() ?? {};

    return {
      'role': data['role'] ?? 'unknown',
      'position': data['position'] ?? 'unknown',
    };
  }
}

