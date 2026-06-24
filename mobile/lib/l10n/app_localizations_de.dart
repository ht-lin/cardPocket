// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get offlineMode => 'Offline';

  @override
  String get cards => 'Karten';

  @override
  String get friends => 'Freunde';

  @override
  String get profile => 'Profil';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginEmailLabel => 'E-Mail';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginSubmitButton => 'Anmelden';

  @override
  String get loginRegisterLink => 'Noch kein Konto? Registrieren';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerUsernameLabel => 'Benutzername';

  @override
  String get registerGdprLabel =>
      'Ich stimme den Nutzungsbedingungen und der Datenschutzrichtlinie zu';

  @override
  String get registerSubmitButton => 'Konto erstellen';

  @override
  String get registerLoginLink => 'Bereits ein Konto? Anmelden';

  @override
  String get verifyPendingTitle => 'E-Mail prüfen';

  @override
  String get verifyPendingBody =>
      'Wir haben einen Bestätigungslink an Ihre E-Mail-Adresse gesendet. Bitte klicken Sie auf den Link, um Ihr Konto zu aktivieren.';

  @override
  String get resendVerificationButton => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get resendVerificationSuccess => 'Bestätigungs-E-Mail gesendet';

  @override
  String get unverifiedBannerMessage =>
      'E-Mail nicht bestätigt — einige Funktionen sind eingeschränkt.';

  @override
  String get unverifiedBannerAction => 'E-Mail erneut senden';

  @override
  String get errorInvalidCredentials => 'Falsche E-Mail oder falsches Passwort';

  @override
  String get errorNetworkTimeout => 'Netzwerkfehler — bitte Verbindung prüfen';

  @override
  String get errorServerError => 'Serverfehler — bitte später erneut versuchen';

  @override
  String get errorForbiddenUnverified =>
      'Bitte bestätigen Sie Ihre E-Mail, um diese Funktion zu nutzen';

  @override
  String get emailValidationEmpty => 'Bitte E-Mail eingeben';

  @override
  String get emailValidationInvalid => 'Bitte gültige E-Mail-Adresse eingeben';

  @override
  String get passwordValidationEmpty => 'Bitte Passwort eingeben';

  @override
  String get passwordValidationTooShort =>
      'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get usernameValidationEmpty => 'Bitte Benutzernamen eingeben';

  @override
  String get gdprValidationRequired => 'Sie müssen zustimmen, um fortzufahren';

  @override
  String get profileEditNameTitle => 'Benutzername ändern';

  @override
  String get profileChangePasswordTitle => 'Passwort ändern';

  @override
  String get profileTrashTitle => 'Papierkorb';

  @override
  String get profileExpiryPolicyTitle =>
      'Abgelaufene Karten automatisch in den Papierkorb verschieben';

  @override
  String get profileExpiryPolicySubtitle =>
      'Wenn aktiviert, werden Karten nach Ablauf in den Papierkorb verschoben. Andernfalls werden abgelaufene Karten nur markiert.';

  @override
  String get profileDiscoverableTitle => 'Anderen erlauben, mich zu finden';

  @override
  String get profileDiscoverableSubtitle =>
      'Wenn deaktiviert, können andere dich nicht über Benutzername oder E-Mail in der Freundessuche finden.';

  @override
  String get profileExportDataTitle => 'Meine Daten exportieren';

  @override
  String get profileExportDataSubtitle =>
      'Lade eine Kopie all deiner Daten als JSON-Datei herunter.';

  @override
  String get profileLogoutButton => 'Abmelden';

  @override
  String get profileDeleteAccountButton => 'Konto löschen';

  @override
  String get profileDeleteAccountConfirmTitle => 'Konto löschen';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Dadurch werden Ihr Konto und alle zugehörigen Daten dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get profileDeleteAccountConfirmAction => 'Konto löschen';

  @override
  String get profileDeleteAccountCancelAction => 'Abbrechen';

  @override
  String get profileNewUsernameLabel => 'Neuer Benutzername';

  @override
  String get profileCurrentPasswordLabel => 'Aktuelles Passwort';

  @override
  String get profileNewPasswordLabel => 'Neues Passwort';

  @override
  String get profileConfirmPasswordLabel => 'Neues Passwort bestätigen';

  @override
  String get profilePasswordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get profileSaveButton => 'Speichern';

  @override
  String get profileUsernameUpdated => 'Benutzername aktualisiert';

  @override
  String get profilePasswordUpdated => 'Passwort aktualisiert';
}
