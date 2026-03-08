
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// structure presenation of user
class userProfile {
  final String uid;
  final String role;
  final String position;

  userProfile({
    required this.uid,
    required this.role,
    required this.position,
  });

  factory userProfile.fromMap(String uid, Map<String, dynamic> data) {
    return userProfile(
      uid: uid,
      role: data['role'] ?? 'readonly',
      position: data['position'] ?? 'Unregistered',
    );
  }

  factory userProfile.readOnly(String uid) {
    return userProfile(
      uid: uid,
      role: 'readonly',
      position: 'Unregistered',
    );
  }
}

class userService {
  final _authentication = FirebaseAuth.instance;
  final _database = FirebaseFirestore.instance;

  //used to continously watch user profile changes in firestore listen to firestore and update the app
  Stream<userProfile> watchProfile() async* {
    final user = _authentication.currentUser;

    if (user == null) {
      throw Exception('User unauthenticated');
    }

    final ref = _database.collection('users').doc(user.uid);

    await for (final snap in ref.snapshots()) {
      if (!snap.exists) {

        yield userProfile.readOnly(user.uid);
      } else {
        yield userProfile.fromMap(user.uid, snap.data()!);
      }
    }
  }
}

