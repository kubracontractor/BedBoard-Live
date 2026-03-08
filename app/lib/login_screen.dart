
import 'package:flutter/material.dart';
import 'auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _auth = AuthService();

  final _emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$");

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _error = "Enter a valid email address";
      });
      _email.clear();
      _password.clear();
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _error = "Password cannot be empty";
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await _auth.signIn(email, password);
      } else {
        await _auth.register(email, password);
      }
    } catch (e) {
      setState(() {
        _error = "Authentication failed. Please check credentials.";
      });
      _email.clear();
      _password.clear();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  
Widget _buildHeader() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_hospital,
          size: 48,
          color: Colors.blue,
        ),
      ),

      const SizedBox(height: 18),

      const Text(
        "BedBoard Live",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          letterSpacing: 0.5,
        ),
      ),

      const SizedBox(height: 6),

      const Text(
        "Hospital Bed Optimisation System",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.lightBlueAccent,
        ),
      ),
    ],
  );
}

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(_isLogin ? "Sign In" : "Register"),
          ),
        ),

        const SizedBox(height: 10),

        TextButton(
          onPressed: _loading
              ? null
              : () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _error = null;
                  });
                },
          child: Text(
            _isLogin
                ? "Don't have an account? Register"
                : "Already have an account? Sign In",
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



/*class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final AuthService _auth = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLogin = true;
  String? errorText;

  Future<void> submit() async {

    setState(() {
      errorText = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {

      if (isLogin) {

        await _auth.signIn(email, password);

      } else {

        await _auth.register(email, password);

      }

    } catch (e) {

      setState(() {
        errorText = e.toString();
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    isLogin ? 'Login' : 'Register',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (errorText != null) ...[
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submit,
                      child: Text(isLogin ? 'Login' : 'Register'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Create new account'
                          : 'Already have an account? Login',
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
