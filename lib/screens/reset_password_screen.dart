import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/password_strength.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final token = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool busy = false;
  PasswordStrength strength = PasswordStrength('');

  @override
  void initState() {
    super.initState();
    password.addListener(() => setState(() => strength = PasswordStrength(password.text)));
  }

  @override
  void dispose() {
    token.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (token.text.trim().length < 4 || !strength.isValid) return;
    if (password.text != confirmation.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.passwordsDoNotMatch)));
      return;
    }
    setState(() => busy = true);
    try {
      await AuthService.instance.verifyRecoveryCode(email: widget.email, token: token.text);
      await AuthService.instance.updatePassword(password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.verificationComplete)));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.l10n.operationFailed}: $error')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget criterion(bool valid, String label) => Row(children: [Icon(valid ? Icons.check_circle : Icons.cancel, size: 18, color: valid ? Colors.green : Colors.grey), const SizedBox(width: 8), Text(label)]);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.resetPassword)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(context.l10n.verificationSubtitle(widget.email), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextField(controller: token, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.l10n.verificationCode, prefixIcon: const Icon(Icons.pin_outlined))),
                const SizedBox(height: 12),
                TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: context.l10n.newPassword)),
                const SizedBox(height: 8),
                Text(context.l10n.passwordRequirements, style: Theme.of(context).textTheme.titleSmall),
                criterion(strength.hasMinLength, context.l10n.passwordMinLength),
                criterion(strength.hasUppercase, context.l10n.passwordUppercase),
                criterion(strength.hasNumber, context.l10n.passwordNumber),
                criterion(strength.hasSpecial, context.l10n.passwordSpecial),
                const SizedBox(height: 12),
                TextField(controller: confirmation, obscureText: true, decoration: InputDecoration(labelText: context.l10n.confirmPassword)),
                const SizedBox(height: 20),
                FilledButton(onPressed: busy || !strength.isValid ? null : submit, child: busy ? const CircularProgressIndicator() : Text(context.l10n.resetPassword)),
              ]),
            ),
          ),
        ),
      );
}
