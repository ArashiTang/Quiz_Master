import 'package:flutter/material.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

enum _RegisterStep {
  form,
  code,
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = SupabaseAuthService.instance;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  _RegisterStep _step = _RegisterStep.form;
  bool _loading = false;

  // 密码显隐
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // 表单错误
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _codeError;

  String? _globalError;   // 底部红字
  String? _infoText;      // 底部提示（例如“已发送验证码到邮箱”）

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Color get _headerColor => const Color(0xFFB39DDB); // 和其它账号页面统一的紫色

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _headerColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: _step == _RegisterStep.form
              ? _buildStepForm()
              : _buildStepCode(),
        ),
      ),
    );
  }

  // ================= Step 1: 填写账号信息 =================

  Widget _buildStepForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User Name
        Text(
          'User Name',
          style: TextStyle(
            color: _headerColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameCtrl,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _usernameError,
          ),
        ),
        const SizedBox(height: 24),

        // Email
        Text(
          'Email',
          style: TextStyle(
            color: _headerColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 24),

        // Password
        Text(
          'Password',
          style: TextStyle(
            color: _headerColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Use 6+ characters (letters / numbers).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Confirm Password
        Text(
          'Confirm Password',
          style: TextStyle(
            color: _headerColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmCtrl,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _confirmError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 32),

        if (_globalError != null) ...[
          Text(
            _globalError!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
        ],

        if (_infoText != null) ...[
          Text(
            _infoText!,
            style: const TextStyle(color: Colors.green),
          ),
          const SizedBox(height: 12),
        ],

        Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _headerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
              onPressed: _loading ? null : _onStep1NextPressed,
              child: _loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onStep1NextPressed() async {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _globalError = null;
      _infoText = null;
    });

    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    bool hasError = false;

    if (username.isEmpty) {
      _usernameError = 'Please enter a user name.';
      hasError = true;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _emailError = 'Please enter a valid email address.';
      hasError = true;
    }

    if (password.length < 6) {
      _passwordError = 'Use at least 6 characters.';
      hasError = true;
    } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(password)) {
      _passwordError = 'Letters and numbers only (no spaces).';
      hasError = true;
    }

    if (confirm != password) {
      _confirmError = 'Passwords do not match.';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // 调用 Supabase 发送注册 OTP（确认注册）
      await _auth.sendSignupOtp(
        email: email,
        password: password,
        username: username,
      );

      setState(() {
        _step = _RegisterStep.code;
        _infoText =
        'We have sent a 6-digit verification code to your email.\n'
            'Please check your inbox and enter the code below.';
      });
    } catch (e) {
      setState(() {
        _globalError = 'Failed to send verification code: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ================= Step 2: 输入验证码完成注册 =================

  Widget _buildStepCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'You will receive an email. Please enter the verification code.',
          style: TextStyle(
            color: _headerColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _codeError,
          ),
        ),
        const SizedBox(height: 32),

        if (_globalError != null) ...[
          Text(
            _globalError!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
        ],

        if (_infoText != null) ...[
          Text(
            _infoText!,
            style: const TextStyle(color: Colors.green),
          ),
          const SizedBox(height: 12),
        ],

        Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _headerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
              onPressed: _loading ? null : _onStep2RegisterPressed,
              child: _loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Register',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onStep2RegisterPressed() async {
    setState(() {
      _codeError = null;
      _globalError = null;
      _infoText = null;
    });

    final code = _codeCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();

    if (code.length != 6) {
      setState(() {
        _codeError = 'Please enter the 6-digit code.';
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _auth.verifySignupOtpAndCreateProfile(
        email: email,
        token: code,
        username: username,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register successful!')),
      );

      Navigator.of(context).pop(); // 返回到上一页（通常是 Login / Mine）
    } catch (e) {
      setState(() {
        _codeError = 'Verification failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}