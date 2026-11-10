import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/language_controller.dart';
import '../services/password_strength.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  bool register = false;
  bool busy = false;
  PasswordStrength strength = PasswordStrength('');

  @override
  void initState() {
    super.initState();
    password.addListener(() => setState(() => strength = PasswordStrength(password.text)));
  }

  String? _validate() {
    final emailValue = email.text.trim();
    if (register && name.text.trim().isEmpty) return context.l10n.enterFullName;
    if (register && phone.text.trim().isEmpty) return context.l10n.enterPhone;
    if (emailValue.isEmpty ||
      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailValue)) {
      return context.l10n.validEmail;
    }
    if (!strength.isValid) return context.l10n.passwordLength;
    return null;
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final validationError = _validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    setState(() => busy = true);
    try {
      if (register) {
        final hasSession = await AuthService.instance.signUp(
          email: email.text,
          password: password.text,
          fullName: name.text,
          phone: phone.text,
        );

        if (!hasSession && mounted) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email.text.trim())));
        }

        // Show welcome bonus message
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.welcomeBonus), backgroundColor: Colors.green));
      } else {
        await AuthService.instance.signIn(email.text, password.text);
      }

    } catch (error) {
      if (mounted) {
        final message = error.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message == '\u064A\u0631\u062C\u0649 \u0627\u0644\u0627\u0646\u062A\u0638\u0627\u0631 \u0628\u0636\u0639 \u062B\u0648\u0627\u0646\u064D \u0642\u0628\u0644 \u0625\u0639\u0627\u062F\u0629 \u0627\u0644\u0645\u062D\u0627\u0648\u0644\u0629'
                ? message
              : '${context.l10n.operationFailed}: $message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DropdownButton<String>(
                value: LanguageController.instance.languageCode,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('AR')),
                  DropdownMenuItem(value: 'fr', child: Text('FR')),
                  DropdownMenuItem(value: 'en', child: Text('EN')),
                ],
                onChanged: (value) {
                  if (value != null) LanguageController.instance.setLanguage(value);
                },
              ),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF4F0FF), Color(0xFFE9E5F7)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 20 : 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 24 : 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(radius: 30, backgroundColor: Color(0xFF6200EE), child: Icon(Icons.handyman, color: Colors.white, size: 30)),
                        const SizedBox(height: 14),
                        const Text('Rento', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF6200EE))),
                        const SizedBox(height: 6),
                        Text(context.l10n.loginSubtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 28),
                        SegmentedButton<bool>(
                          segments: [ButtonSegment(value: false, label: Text(context.l10n.login)), ButtonSegment(value: true, label: Text(context.l10n.register))],
                          selected: {register},
                          onSelectionChanged: busy ? null : (selection) => setState(() => register = selection.first),
                        ),
                        const SizedBox(height: 24),
                        if (register) ...[
                          TextField(controller: name, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: context.l10n.fullName, prefixIcon: const Icon(Icons.person_outline))),
                          const SizedBox(height: 12),
                          TextField(controller: phone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: context.l10n.phoneNumber, prefixIcon: const Icon(Icons.phone_outlined))),
                          const SizedBox(height: 12),
                        ],
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: context.l10n.email,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  if (register) ...[
                    const SizedBox(height: 8),
                    _passwordCriterion(context.l10n.passwordMinLength, strength.hasMinLength),
                    _passwordCriterion(context.l10n.passwordUppercase, strength.hasUppercase),
                    _passwordCriterion(context.l10n.passwordNumber, strength.hasNumber),
                    _passwordCriterion(context.l10n.passwordSpecial, strength.hasSpecial),
                  ],
                  if (register) ...[
                    const SizedBox(height: 16),
                  ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: busy ? null : submit,
                          child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(register ? context.l10n.createAccount : context.l10n.signIn),
                        ),
                        if (!register) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: busy ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: Text(context.l10n.forgotPassword),
                          ),
                        ],
                        if (register) ...[
                          const SizedBox(height: 14),
                          Text(context.l10n.registerBonus, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF4A35A6))),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordCriterion(String label, bool valid) => Row(
        children: [
          Icon(valid ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: valid ? Colors.green : Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: valid ? Colors.green.shade700 : Colors.grey.shade700)),
        ],
      );
}
