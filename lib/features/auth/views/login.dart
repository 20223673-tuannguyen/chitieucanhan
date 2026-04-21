// ignore_for_file: use_build_context_synchronously

import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/views/nameInputDialog.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
<<<<<<< HEAD
=======
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

>>>>>>> ae1ad2d (Add firebase_options.dart and initialize Firebase)
  Future<void> _showInputDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
<<<<<<< HEAD
      builder: (context) => InputDialog(),
=======
      builder: (context) => const InputDialog(),
>>>>>>> ae1ad2d (Add firebase_options.dart and initialize Firebase)
    );
  }

  void loginNoAccount() async {
    await _showInputDialog();
  }

<<<<<<< HEAD
=======
  void _loginWithFirebase() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ Email và Mật khẩu')),
      );
      return;
    }

    context.read<Authcubit>().loginWithFirebase(email, password);
  }

  void _signUpWithFirebase() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu để đăng ký')),
      );
      return;
    }
    
    context.read<Authcubit>().signUpWithFirebase(email, password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

>>>>>>> ae1ad2d (Add firebase_options.dart and initialize Firebase)
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
<<<<<<< HEAD
    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) {
        // Avoid double navigation when a dialog (e.g., guest flow) is open
        if (Navigator.of(context).canPop()) {
          return;
        }
        if (state.authStatus == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (state.authStatus == AuthStatus.error) {
          final message = state.errorMessage ?? 'Authentication failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: theme.primaryColor,
=======
    
    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (state.authStatus == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Lỗi đăng nhập'),
              backgroundColor: Colors.red,
>>>>>>> ae1ad2d (Add firebase_options.dart and initialize Firebase)
            ),
          );
        }
      },
      child: Scaffold(
<<<<<<< HEAD
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/icon/rounded-in-photoretrica.png',
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                appLocal?.hello ?? 'Hello',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  appLocal?.loginToAccess ?? 'Login to access',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: loginNoAccount,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    appLocal?.continue_without_account ??
                        'Continue without account',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Text(
                  appLocal?.agree_terms ??
                      'I agree to the terms and conditions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
=======
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon/rounded-in-photoretrica.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  appLocal?.hello ?? 'Chào mừng!',
                  style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Firebase Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loginWithFirebase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Firebase Sign Up Button
                TextButton(
                  onPressed: _signUpWithFirebase,
                  child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('HOẶC', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

                // Guest Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: loginNoAccount,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      appLocal?.continue_without_account ?? 'Tiếp tục không cần tài khoản',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
>>>>>>> ae1ad2d (Add firebase_options.dart and initialize Firebase)
          ),
        ),
      ),
    );
  }
}
