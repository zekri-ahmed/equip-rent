import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final value = email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.validEmail)));
      return;
    }
    setState(() => busy = true);
    try {
      await AuthService.instance.sendPasswordReset(value);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: value)));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.l10n.operationFailed}: $error')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.forgotPasswordTitle)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(context.l10n.forgotPasswordSubtitle, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: context.l10n.email, prefixIcon: const Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                FilledButton(onPressed: busy ? null : submit, child: busy ? const CircularProgressIndicator() : Text(context.l10n.sendCode)),
              ]),
            ),
          ),
        ),
      );
}
