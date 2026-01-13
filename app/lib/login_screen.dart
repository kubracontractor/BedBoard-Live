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
  String? _error;
  bool _loading = false;

  final _auth = AuthService();

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await _auth.signIn(_email.text.trim(), _password.text.trim());
      } else {
        await _auth.register(_email.text.trim(), _password.text.trim());
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(_isLogin ? 'Sign in' : 'Create account'),
                  ),
                ),
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Sign in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
