class PasswordStrength {
  PasswordStrength(this.value)
      : hasMinLength = value.length >= 8,
        hasUppercase = value.contains(RegExp(r'[A-Z]')),
        hasNumber = value.contains(RegExp(r'[0-9]')),
        hasSpecial = value.contains(RegExp(r'[^A-Za-z0-9]'));

  final String value;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecial;

  bool get isValid => hasMinLength && hasUppercase && hasNumber && hasSpecial;
}
