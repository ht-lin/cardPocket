// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get offlineMode => 'Sin conexión';

  @override
  String get cards => 'Tarjetas';

  @override
  String get friends => 'Amigos';

  @override
  String get profile => 'Perfil';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginSubmitButton => 'Iniciar sesión';

  @override
  String get loginRegisterLink => '¿No tienes cuenta? Regístrate';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerUsernameLabel => 'Nombre de usuario';

  @override
  String get registerGdprLabel =>
      'Acepto los Términos de servicio y la Política de privacidad';

  @override
  String get registerSubmitButton => 'Crear cuenta';

  @override
  String get registerLoginLink => '¿Ya tienes cuenta? Iniciar sesión';

  @override
  String get verifyPendingTitle => 'Revisa tu correo';

  @override
  String get verifyPendingBody =>
      'Hemos enviado un enlace de verificación a tu dirección de correo. Por favor, haz clic en el enlace para activar tu cuenta.';

  @override
  String get resendVerificationButton => 'Reenviar correo de verificación';

  @override
  String get resendVerificationSuccess => 'Correo de verificación enviado';

  @override
  String get unverifiedBannerMessage =>
      'Correo no verificado — algunas funciones están restringidas.';

  @override
  String get unverifiedBannerAction => 'Reenviar correo';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get errorNetworkTimeout =>
      'Error de red — por favor comprueba tu conexión';

  @override
  String get errorServerError =>
      'Error del servidor — por favor inténtalo más tarde';

  @override
  String get errorForbiddenUnverified =>
      'Por favor verifica tu correo para usar esta función';

  @override
  String get emailValidationEmpty => 'Por favor introduce tu correo';

  @override
  String get emailValidationInvalid =>
      'Por favor introduce una dirección de correo válida';

  @override
  String get passwordValidationEmpty => 'Por favor introduce tu contraseña';

  @override
  String get passwordValidationTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get usernameValidationEmpty =>
      'Por favor introduce un nombre de usuario';

  @override
  String get gdprValidationRequired => 'Debes aceptar para continuar';

  @override
  String get profileEditNameTitle => 'Editar nombre de usuario';

  @override
  String get profileChangePasswordTitle => 'Cambiar contraseña';

  @override
  String get profileExpiryPolicyTitle =>
      'Mover automáticamente las tarjetas caducadas a la papelera';

  @override
  String get profileExpiryPolicySubtitle =>
      'Cuando está activado, las tarjetas se mueven a la papelera tras caducar. Cuando está desactivado, las tarjetas caducadas solo se marcan.';

  @override
  String get profileLogoutButton => 'Cerrar sesión';

  @override
  String get profileDeleteAccountButton => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountConfirmTitle => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Esto eliminará permanentemente tu cuenta y todos los datos asociados. Esta acción no se puede deshacer.';

  @override
  String get profileDeleteAccountConfirmAction => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountCancelAction => 'Cancelar';

  @override
  String get profileNewUsernameLabel => 'Nuevo nombre de usuario';

  @override
  String get profileCurrentPasswordLabel => 'Contraseña actual';

  @override
  String get profileNewPasswordLabel => 'Nueva contraseña';

  @override
  String get profileConfirmPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get profilePasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get profileSaveButton => 'Guardar';

  @override
  String get profileUsernameUpdated => 'Nombre de usuario actualizado';

  @override
  String get profilePasswordUpdated => 'Contraseña actualizada';
}
