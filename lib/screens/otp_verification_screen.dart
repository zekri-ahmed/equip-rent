import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});
  final String email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final code = TextEditingController();
  Timer? timer;
  int seconds = 60;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    setState(() => seconds = 60);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (seconds <= 1) {
        timer?.cancel();
        setState(() => seconds = 0);
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    code.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    if (code.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.invalidVerificationCode)));
      return;
    }
    setState(() => busy = true);
    try {
      await AuthService.instance.verifyCode(email: widget.email, token: code.text);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.l10n.operationFailed}: $error')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resend() async {
    await AuthService.instance.sendVerificationCode(widget.email);
    if (mounted) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.codeSent)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.verificationTitle)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(context.l10n.verificationSubtitle(widget.email), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextField(controller: code, autofocus: true, maxLength: 6, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: InputDecoration(labelText: context.l10n.verificationCode, counterText: '')),
                const SizedBox(height: 16),
                FilledButton(onPressed: busy ? null : verify, child: busy ? const CircularProgressIndicator() : Text(context.l10n.verify)),
                const SizedBox(height: 12),
                TextButton(onPressed: seconds == 0 ? resend : null, child: Text(seconds == 0 ? context.l10n.resendCode : context.l10n.resendIn(seconds))),
              ]),
            ),
          ),
        ),
      );
}
