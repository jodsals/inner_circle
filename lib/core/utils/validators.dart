/// Form field validators
class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte geben Sie eine E-Mail-Adresse ein';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Bitte geben Sie eine gültige E-Mail-Adresse ein';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte geben Sie ein Passwort ein';
    }

    if (value.length < 6) {
      return 'Das Passwort muss mindestens 6 Zeichen lang sein';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte geben Sie $fieldName ein';
    }
    return null;
  }
}
