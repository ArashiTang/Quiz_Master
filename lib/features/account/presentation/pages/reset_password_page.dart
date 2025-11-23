import 'package:flutter/material.dart';
import 'package:quiz_master/core/remote/supabase_auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

enum _ResetStep { email, code, newPassword }

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = SupabaseAuthService.instance;

  // 三个步骤共用的一些状态
  _ResetStep _step = _ResetStep.email;
  bool _loading = false;
  String? _errorText;

  // Step1 – 输入邮箱
  final _emailCtrl = TextEditingController();
  String? _emailError;

  // Step2 – 输入验证码
  final _codeCtrl = TextEditingController();
  String? _codeError;

  // Step3 – 设置新密码
  final _pwdCtrl = TextEditingController();
  final _pwdConfirmCtrl = TextEditingController();
  String? _pwdError;
  String? _pwdConfirmError;
  bool _pwdObscure = true;
  bool _pwdConfirmObscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _pwdCtrl.dispose();
    _pwdConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 统一的顶部紫色
    final Color headerColor = const Color(0xFFB39DDB);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Reset',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        // 点空白处收起键盘
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == _ResetStep.email)
                _buildStep1(headerColor)
              else if (_step == _ResetStep.code)
                _buildStep2(headerColor)
              else
                _buildStep3(headerColor),
              const SizedBox(height: 24),
              if (_errorText != null)
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Step 1: 输入邮箱 ==========
  Widget _buildStep1(Color headerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Please enter your email address.',
          style: TextStyle(
            color: headerColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            labelText: 'Email',
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _onSendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: headerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'We will send a verification code to your email.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _onSendEmail() async {
    setState(() {
      _errorText = null;
      _emailError = null;
    });

    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email.';
      });
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.sendResetOtp(email: email);
      if (!mounted) return;
      setState(() {
        _step = _ResetStep.code;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Failed to send code: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ========== Step 2: 输入验证码 ==========
  Widget _buildStep2(Color headerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'You will receive an email. Please enter the verification code.',
          style: TextStyle(
            color: headerColor,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            labelText: 'Verification code',
            errorText: _codeError,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _onVerifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: headerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Future<void> _onVerifyCode() async {
    setState(() {
      _errorText = null;
      _codeError = null;
    });

    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (code.isEmpty) {
      setState(() {
        _codeError = 'Please enter the code.';
      });
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.verifyResetOtpAndSignIn(email: email, token: code);
      if (!mounted) return;
      setState(() {
        _step = _ResetStep.newPassword;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Verification failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ========== Step 3: 设置新密码 ==========
  Widget _buildStep3(Color headerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Please set a new password.',
          style: TextStyle(
            color: headerColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _pwdCtrl,
          obscureText: _pwdObscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            labelText: 'New password',
            helperText: 'Use 6+ characters (letters / numbers).',
            errorText: _pwdError,
            suffixIcon: IconButton(
              icon:
              Icon(_pwdObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _pwdObscure = !_pwdObscure;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pwdConfirmCtrl,
          obscureText: _pwdConfirmObscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            labelText: 'Confirm password',
            errorText: _pwdConfirmError,
            suffixIcon: IconButton(
              icon: Icon(
                  _pwdConfirmObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _pwdConfirmObscure = !_pwdConfirmObscure;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _onResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: headerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Reset',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onResetPassword() async {
    setState(() {
      _errorText = null;
      _pwdError = null;
      _pwdConfirmError = null;
    });

    final pwd = _pwdCtrl.text;
    final confirm = _pwdConfirmCtrl.text;

    if (pwd.length < 6) {
      setState(() {
        _pwdError = 'Password must be at least 6 characters.';
      });
      return;
    }
    if (pwd != confirm) {
      setState(() {
        _pwdConfirmError = 'Passwords do not match.';
      });
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.updatePassword(newPassword: pwd);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password has been reset successfully.')),
      );

      Navigator.pop(context); // 返回上一页（通常是 Login）
    } catch (e) {
      setState(() {
        _errorText = 'Reset failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}