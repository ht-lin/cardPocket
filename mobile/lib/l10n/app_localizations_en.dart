// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get offlineMode => 'Offline';

  @override
  String get cards => 'Cards';

  @override
  String get friends => 'Friends';

  @override
  String get profile => 'Profile';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmitButton => 'Sign In';

  @override
  String get loginRegisterLink => 'Don\'t have an account? Register';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerGdprLabel =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get registerSubmitButton => 'Create Account';

  @override
  String get registerLoginLink => 'Already have an account? Sign In';

  @override
  String get verifyPendingTitle => 'Check Your Email';

  @override
  String get verifyPendingBody =>
      'We sent a verification link to your email address. Please click the link to activate your account.';

  @override
  String get resendVerificationButton => 'Resend Verification Email';

  @override
  String get resendVerificationSuccess => 'Verification email sent';

  @override
  String get unverifiedBannerMessage =>
      'Email not verified — some features are restricted.';

  @override
  String get unverifiedBannerAction => 'Resend Email';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String get errorNetworkTimeout =>
      'Network error — please check your connection';

  @override
  String get errorServerError => 'Server error — please try again later';

  @override
  String get errorForbiddenUnverified =>
      'Please verify your email to use this feature';

  @override
  String get emailValidationEmpty => 'Please enter your email';

  @override
  String get emailValidationInvalid => 'Please enter a valid email address';

  @override
  String get passwordValidationEmpty => 'Please enter your password';

  @override
  String get passwordValidationTooShort =>
      'Password must be at least 8 characters';

  @override
  String get usernameValidationEmpty => 'Please enter a username';

  @override
  String get gdprValidationRequired => 'You must agree to continue';

  @override
  String get profileEditNameTitle => 'Edit Username';

  @override
  String get profileChangePasswordTitle => 'Change Password';

  @override
  String get profileExpiryPolicyTitle => 'Auto-move expired cards to trash';

  @override
  String get profileExpiryPolicySubtitle =>
      'When on, cards are moved to trash after they expire. When off, expired cards are only marked.';

  @override
  String get profileLogoutButton => 'Sign Out';

  @override
  String get profileDeleteAccountButton => 'Delete Account';

  @override
  String get profileDeleteAccountConfirmTitle => 'Delete Account';

  @override
  String get profileDeleteAccountConfirmBody =>
      'This will permanently delete your account and all associated data. This action cannot be undone.';

  @override
  String get profileDeleteAccountConfirmAction => 'Delete Account';

  @override
  String get profileDeleteAccountCancelAction => 'Cancel';

  @override
  String get profileNewUsernameLabel => 'New username';

  @override
  String get profileCurrentPasswordLabel => 'Current password';

  @override
  String get profileNewPasswordLabel => 'New password';

  @override
  String get profileConfirmPasswordLabel => 'Confirm new password';

  @override
  String get profilePasswordMismatch => 'Passwords do not match';

  @override
  String get profileSaveButton => 'Save';

  @override
  String get profileUsernameUpdated => 'Username updated';

  @override
  String get profilePasswordUpdated => 'Password updated';
}
