extension EmailValidatorExtension on String {
  bool emailValidator() {
    final emailValid = RegExp(
      r'^[\p{L}0-9._%+-]+@[\p{L}0-9.-]+\.[\p{L}]{2,}$',
      unicode: true,
    ).hasMatch(this);
    return emailValid;
  }
}

extension UrlValidatorExtension on String {
  bool urlValidator() {
    try {
      Uri.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }
}

extension BioValidatorExtension on String {
  bool bioValidator() {
    // Split text and check if any part is a valid URL
    final words = split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.urlValidator()) {
        return false;
      }
    }
    return true;
  }
}

extension PasswordValidatorExtension on String {
  bool passwordValidator() {
    final passwordValid = RegExp(
      r'^(?=.*[\p{Ll}])(?=.*[\p{Lu}])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
      unicode: true,
    ).hasMatch(this);
    return passwordValid;
  }

  //for testing purpose
  bool lessSecurePasswordValidator() {
    return length >= 8;
  }
}

extension NameValidatorExtension on String {
  bool nameValidator() {
    final nameValid = RegExp(
      r'^[\p{L}\s]+$', // Letters (Unicode) + spaces
      unicode: true,
    ).hasMatch(this);
    return nameValid;
  }
}

extension ExperienceValidatorExtension on String {
  bool experienceValidator() {
    final experienceValid = RegExp(
      r'^[\p{N}]+$', // Digits (Unicode-safe)
      unicode: true,
    ).hasMatch(this);
    return experienceValid;
  }
}

extension UsernameValidatorExtension on String {
  bool usernameValidator() {
    final usernameValid = RegExp(
      r'^[\p{L}0-9_-]{3,15}$', // Letters (Unicode) + digits + underscore/hyphen
      unicode: true,
    ).hasMatch(this);
    return usernameValid;
  }
}

extension AddressValidatorExtension on String {
  bool addressValidator() {
    final addressValid = RegExp(
      r"^[\p{L}0-9\s,.'\-/]+$", // Unicode letters + digits + common address symbols
      unicode: true,
    ).hasMatch(this);
    return addressValid;
  }
}

extension PhoneNumberValidatorExtension on String {
  bool phoneNumberValidator() {
    final phone = this;
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    return regex.hasMatch(phone);
  }
}

extension StripeAccountIdValidator on String {
  bool stripeAccountIdValidator() {
    final accountIdValid = RegExp(
      r'^acct_[A-Za-z0-9]{16}$', // Stripe IDs are ASCII-only
    ).hasMatch(this);
    return accountIdValid;
  }
}
