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
  Future<void> _showInputDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InputDialog(),
    );
  }

  void loginNoAccount() async {
    await _showInputDialog();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
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
            ),
          );
        }
      },
      child: Scaffold(
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
          ),
        ),
      ),
    );
  }
}
