// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get offlineMode => 'Hors ligne';

  @override
  String get cards => 'Cartes';

  @override
  String get friends => 'Amis';

  @override
  String get profile => 'Profil';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmitButton => 'Se connecter';

  @override
  String get loginRegisterLink => 'Pas encore de compte ? S\'inscrire';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get registerGdprLabel =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité';

  @override
  String get registerSubmitButton => 'Créer un compte';

  @override
  String get registerLoginLink => 'Déjà un compte ? Se connecter';

  @override
  String get verifyPendingTitle => 'Vérifiez votre e-mail';

  @override
  String get verifyPendingBody =>
      'Nous avons envoyé un lien de vérification à votre adresse e-mail. Veuillez cliquer sur le lien pour activer votre compte.';

  @override
  String get resendVerificationButton => 'Renvoyer l\'e-mail de vérification';

  @override
  String get resendVerificationSuccess => 'E-mail de vérification envoyé';

  @override
  String get unverifiedBannerMessage =>
      'E-mail non vérifié — certaines fonctionnalités sont restreintes.';

  @override
  String get unverifiedBannerAction => 'Renvoyer l\'e-mail';

  @override
  String get errorInvalidCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get errorNetworkTimeout =>
      'Erreur réseau — veuillez vérifier votre connexion';

  @override
  String get errorServerError =>
      'Erreur serveur — veuillez réessayer plus tard';

  @override
  String get errorForbiddenUnverified =>
      'Veuillez vérifier votre e-mail pour utiliser cette fonctionnalité';

  @override
  String get emailValidationEmpty => 'Veuillez saisir votre e-mail';

  @override
  String get emailValidationInvalid =>
      'Veuillez saisir une adresse e-mail valide';

  @override
  String get passwordValidationEmpty => 'Veuillez saisir votre mot de passe';

  @override
  String get passwordValidationTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get usernameValidationEmpty => 'Veuillez saisir un nom d\'utilisateur';

  @override
  String get gdprValidationRequired => 'Vous devez accepter pour continuer';

  @override
  String get profileEditNameTitle => 'Modifier le nom d\'utilisateur';

  @override
  String get profileChangePasswordTitle => 'Modifier le mot de passe';

  @override
  String get profileTrashTitle => 'Corbeille';

  @override
  String get profileExpiryPolicyTitle =>
      'Déplacer automatiquement les cartes expirées vers la corbeille';

  @override
  String get profileExpiryPolicySubtitle =>
      'Si activé, les cartes sont déplacées vers la corbeille après leur expiration. Sinon, les cartes expirées sont seulement marquées.';

  @override
  String get profileDiscoverableTitle => 'Permettre aux autres de me trouver';

  @override
  String get profileDiscoverableSubtitle =>
      'Si désactivé, les autres ne peuvent pas vous trouver par nom d\'utilisateur ou e-mail dans la recherche d\'amis.';

  @override
  String get profileExportDataTitle => 'Exporter mes données';

  @override
  String get profileExportDataSubtitle =>
      'Téléchargez une copie de toutes vos données sous forme de fichier JSON.';

  @override
  String get profileLogoutButton => 'Se déconnecter';

  @override
  String get profileDeleteAccountButton => 'Supprimer le compte';

  @override
  String get profileDeleteAccountConfirmTitle => 'Supprimer le compte';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Cela supprimera définitivement votre compte et toutes les données associées. Cette action est irréversible.';

  @override
  String get profileDeleteAccountConfirmAction => 'Supprimer le compte';

  @override
  String get profileDeleteAccountCancelAction => 'Annuler';

  @override
  String get profileNewUsernameLabel => 'Nouveau nom d\'utilisateur';

  @override
  String get profileCurrentPasswordLabel => 'Mot de passe actuel';

  @override
  String get profileNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get profileConfirmPasswordLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get profilePasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get profileSaveButton => 'Enregistrer';

  @override
  String get profileUsernameUpdated => 'Nom d\'utilisateur mis à jour';

  @override
  String get profilePasswordUpdated => 'Mot de passe mis à jour';
}
