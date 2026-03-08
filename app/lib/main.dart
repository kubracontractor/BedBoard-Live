import 'package:flutter/material.dart'; // library for UI components
import 'package:firebase_core/firebase_core.dart'; // Firebase core initialization
import 'firebase_options.dart'; // Firebase configuration

import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'bed_board_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BedBoard Live Hospital Optimization System',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {

        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snap.data;

        if (user == null) {
          return const LoginScreen();
        }

        // User signed in
        return const BedBoardScreen();
      },
    );
  }
}