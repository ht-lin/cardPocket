import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('zh'),
  ];

  /// Label shown in the offline banner at the top of the screen
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineMode;

  /// Bottom nav tab label for the card wallet
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// Bottom nav tab label for the friends list
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Bottom nav tab label for user profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// Email field label on login screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Password field label on login screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Submit button on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmitButton;

  /// Link to register screen
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get loginRegisterLink;

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// Username field label on register screen
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// GDPR consent checkbox label
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get registerGdprLabel;

  /// Submit button on register screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerSubmitButton;

  /// Link to login screen from register
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get registerLoginLink;

  /// Verify pending screen title
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get verifyPendingTitle;

  /// Explanation text on verify pending screen
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email address. Please click the link to activate your account.'**
  String get verifyPendingBody;

  /// Button to resend verification email
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationButton;

  /// SnackBar message after successful resend
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get resendVerificationSuccess;

  /// Warning banner text for unverified users
  ///
  /// In en, this message translates to:
  /// **'Email not verified — some features are restricted.'**
  String get unverifiedBannerMessage;

  /// Action button in the unverified banner
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get unverifiedBannerAction;

  /// Error message for wrong login credentials
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get errorInvalidCredentials;

  /// Error message for network timeout
  ///
  /// In en, this message translates to:
  /// **'Network error — please check your connection'**
  String get errorNetworkTimeout;

  /// Error message for server errors
  ///
  /// In en, this message translates to:
  /// **'Server error — please try again later'**
  String get errorServerError;

  /// Error message when unverified user hits a restricted action
  ///
  /// In en, this message translates to:
  /// **'Please verify your email to use this feature'**
  String get errorForbiddenUnverified;

  /// Validation error when email is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailValidationEmpty;

  /// Validation error for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidationInvalid;

  /// Validation error when password is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordValidationEmpty;

  /// Validation error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordValidationTooShort;

  /// Validation error when username is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get usernameValidationEmpty;

  /// Validation error when GDPR checkbox is unchecked
  ///
  /// In en, this message translates to:
  /// **'You must agree to continue'**
  String get gdprValidationRequired;

  /// Title for the edit username screen
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get profileEditNameTitle;

  /// Title for the change password screen
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePasswordTitle;

  /// Title for the expiry policy toggle on profile screen
  ///
  /// In en, this message translates to:
  /// **'Auto-move expired cards to trash'**
  String get profileExpiryPolicyTitle;

  /// Subtitle explaining the expiry policy toggle
  ///
  /// In en, this message translates to:
  /// **'When on, cards are moved to trash after they expire. When off, expired cards are only marked.'**
  String get profileExpiryPolicySubtitle;

  /// Sign out button label on profile screen
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileLogoutButton;

  /// Delete account button label on profile screen
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccountButton;

  /// Title of the delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccountConfirmTitle;

  /// Body text of the delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data. This action cannot be undone.'**
  String get profileDeleteAccountConfirmBody;

  /// Confirm button in delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccountConfirmAction;

  /// Cancel button in delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteAccountCancelAction;

  /// Label for new username field on edit name screen
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get profileNewUsernameLabel;

  /// Label for current password field on change password screen
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPasswordLabel;

  /// Label for new password field on change password screen
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPasswordLabel;

  /// Label for confirm password field on change password screen
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmPasswordLabel;

  /// Validation error when new password and confirm password differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get profilePasswordMismatch;

  /// Save button label on edit screens
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveButton;

  /// SnackBar message after successful username update
  ///
  /// In en, this message translates to:
  /// **'Username updated'**
  String get profileUsernameUpdated;

  /// SnackBar message after successful password update
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get profilePasswordUpdated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
