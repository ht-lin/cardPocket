import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'package:card_pocket/core/auth/auth_state.dart';
import 'package:card_pocket/core/auth/auth_state_provider.dart';
import 'package:card_pocket/core/router/route_names.dart';
import 'package:card_pocket/core/router/router_provider.dart';
import 'package:card_pocket/features/cards/application/sharing_import_controller.dart';
import 'package:card_pocket/features/cards/data/barcode_image_analyzer.dart';
import 'package:card_pocket/features/cards/data/sharing_intent_service.dart';

class _MockGoRouter extends Mock implements GoRouter {}

class _FakeAnalyzer extends BarcodeImageAnalyzer {
  const _FakeAnalyzer(this.result);
  final BarcodeScanResult? result;

  @override
  Future<BarcodeScanResult?> analyze(String path) async => result;
}

class _FakeSharingIntentService extends SharingIntentService {
  _FakeSharingIntentService(this.initial);
  final List<SharedMediaFile> initial;
  final controller = StreamController<List<SharedMediaFile>>.broadcast();
  int resetCalls = 0;

  @override
  Stream<List<SharedMediaFile>> get mediaStream => controller.stream;

  @override
  Future<List<SharedMediaFile>> getInitialMedia() async => initial;

  @override
  Future<void> reset() async => resetCalls++;

  Future<void> close() => controller.close();
}

SharedMediaFile _image(String path) =>
    SharedMediaFile(path: path, type: SharedMediaType.image);

void main() {
  setUpAll(() => registerFallbackValue(<String, String>{}));

  late _MockGoRouter router;

  setUp(() {
    router = _MockGoRouter();
  });

  ProviderContainer makeContainer({
    required _FakeSharingIntentService service,
    BarcodeScanResult? analyzerResult,
    AuthState authState = const AuthState.authenticated(userId: 'u1'),
  }) {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWithValue(authState),
        sharingIntentServiceProvider.overrideWithValue(service),
        barcodeImageAnalyzerProvider
            .overrideWithValue(_FakeAnalyzer(analyzerResult)),
        routerProvider.overrideWithValue(router),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(service.close);
    return container;
  }

  test('routes to confirm screen when a shared image decodes', () async {
    final service = _FakeSharingIntentService([_image('qr.png')]);
    final container = makeContainer(
      service: service,
      analyzerResult:
          const BarcodeScanResult(barcodeContent: 'X1', barcodeType: 'QR_CODE'),
    );

    await container.read(sharingImportControllerProvider.future);

    verify(
      () => router.goNamed(
        RouteNames.cardsScanConfirm,
        extra: any(named: 'extra'),
      ),
    ).called(1);
    expect(service.resetCalls, 1);
  });

  test('routes to manual create when no barcode is found', () async {
    final service = _FakeSharingIntentService([_image('blank.png')]);
    final container = makeContainer(service: service, analyzerResult: null);

    await container.read(sharingImportControllerProvider.future);

    verify(() => router.goNamed(RouteNames.cardsCreate)).called(1);
  });

  test('does nothing when unauthenticated', () async {
    final service = _FakeSharingIntentService([_image('qr.png')]);
    final container = makeContainer(
      service: service,
      analyzerResult:
          const BarcodeScanResult(barcodeContent: 'X1', barcodeType: 'QR_CODE'),
      authState: const AuthState.unauthenticated(),
    );

    await container.read(sharingImportControllerProvider.future);

    verifyNever(() => router.goNamed(any()));
    verifyNever(
      () => router.goNamed(any(), extra: any(named: 'extra')),
    );
  });

  test('ignores shares that contain no image', () async {
    final service = _FakeSharingIntentService(
      [SharedMediaFile(path: 'note.txt', type: SharedMediaType.text)],
    );
    final container = makeContainer(service: service);

    await container.read(sharingImportControllerProvider.future);

    verifyNever(() => router.goNamed(any()));
  });
}
