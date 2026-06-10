// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get offlineMode => '离线模式';

  @override
  String get cards => '卡包';

  @override
  String get friends => '好友';

  @override
  String get profile => '我的';

  @override
  String get loginTitle => '登录';

  @override
  String get loginEmailLabel => '邮箱';

  @override
  String get loginPasswordLabel => '密码';

  @override
  String get loginSubmitButton => '登录';

  @override
  String get loginRegisterLink => '没有账号？立即注册';

  @override
  String get registerTitle => '创建账号';

  @override
  String get registerUsernameLabel => '用户名';

  @override
  String get registerGdprLabel => '我同意服务条款和隐私政策';

  @override
  String get registerSubmitButton => '创建账号';

  @override
  String get registerLoginLink => '已有账号？立即登录';

  @override
  String get verifyPendingTitle => '请验证邮箱';

  @override
  String get verifyPendingBody => '我们已向您的邮箱发送了验证链接，请点击链接激活账号。';

  @override
  String get resendVerificationButton => '重新发送验证邮件';

  @override
  String get resendVerificationSuccess => '验证邮件已发送';

  @override
  String get unverifiedBannerMessage => '邮箱未验证 — 部分功能暂不可用。';

  @override
  String get unverifiedBannerAction => '重新发送';

  @override
  String get errorInvalidCredentials => '邮箱或密码错误';

  @override
  String get errorNetworkTimeout => '网络错误，请检查网络连接';

  @override
  String get errorServerError => '服务器异常，请稍后再试';

  @override
  String get errorForbiddenUnverified => '请先完成邮箱验证才能使用此功能';

  @override
  String get emailValidationEmpty => '请输入邮箱';

  @override
  String get emailValidationInvalid => '请输入有效的邮箱地址';

  @override
  String get passwordValidationEmpty => '请输入密码';

  @override
  String get passwordValidationTooShort => '密码至少需要 8 个字符';

  @override
  String get usernameValidationEmpty => '请输入用户名';

  @override
  String get gdprValidationRequired => '需要同意才能继续';
}
