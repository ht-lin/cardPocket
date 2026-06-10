// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authTokenStorage)
final authTokenStorageProvider = AuthTokenStorageProvider._();

final class AuthTokenStorageProvider
    extends
        $FunctionalProvider<
          AuthTokenStorage,
          AuthTokenStorage,
          AuthTokenStorage
        >
    with $Provider<AuthTokenStorage> {
  AuthTokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenStorageHash();

  @$internal
  @override
  $ProviderElement<AuthTokenStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthTokenStorage create(Ref ref) {
    return authTokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenStorage>(value),
    );
  }
}

String _$authTokenStorageHash() => r'43de8bce28b56fb5f8a4773b8884b583d4d19fc3';
