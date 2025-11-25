import 'package:flutter/material.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = SupabaseAuthService.instance;

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscurePwd = true;
  bool _submitting = false;

  String? _emailError;
  String? _pwdError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    _emailError = null;
    _pwdError = null;

    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      _emailError = 'Please enter a valid email.';
    }
    if (pwd.isEmpty) {
      _pwdError = 'Please enter your password.';
    }
  }

  Future<void> _onLogin() async {
    setState(() {
      _validate();
    });
    if (_emailError != null || _pwdError != null) return;

    setState(() => _submitting = true);
    try {
      await _auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      if (!mounted) return;
      Navigator.pop(context); // return MinePage
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email or password is incorrect.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFB5A7FF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabeledField(
              label: 'Email',
              controller: _emailCtrl,
              errorText: _emailError,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildLabeledField(
              label: 'Password',
              controller: _pwdCtrl,
              errorText: _pwdError,
              obscureText: _obscurePwd,
              suffix: IconButton(
                icon: Icon(
                  _obscurePwd ? Icons.visibility_off : Icons.visibility,
                  color: purple,
                ),
                onPressed: () {
                  setState(() => _obscurePwd = !_obscurePwd);
                },
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _submitting ? null : _onLogin,
                  child: _submitting
                      ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/resetPassword');
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: purple,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Want to register?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: purple,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    String? errorText,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    const purple = Color(0xFFB5A7FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: purple,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: purple),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: purple, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: suffix,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}