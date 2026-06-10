class AppConfig {
  final String apiBaseUrl;
  final String sentryDsn;
  final String flavorName;

  const AppConfig({
    required this.apiBaseUrl,
    required this.sentryDsn,
    required this.flavorName,
  });

  static const dev = AppConfig(
    apiBaseUrl: 'https://localhost:8000',
    sentryDsn: '',
    flavorName: 'dev',
  );

  static const prod = AppConfig(
    apiBaseUrl: 'https://PLACEHOLDER_PROD_DOMAIN',
    sentryDsn: 'PLACEHOLDER_SENTRY_DSN_PROD',
    flavorName: 'prod',
  );

  bool get isDevFlavor => flavorName == 'dev';
}
