import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/auth/auth_state_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/router/router_provider.dart';
import '../data/barcode_image_analyzer.dart';
import '../data/sharing_intent_service.dart';

part 'sharing_import_controller.g.dart';

/// US-23: handles images shared into CardPocket from other apps. Decodes the
/// barcode and routes to the confirm screen (or manual entry on a miss).
/// Activated by watching it from `app.dart`.
@Riverpod(keepAlive: true)
class SharingImportController extends _$SharingImportController {
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  @override
  Future<void> build() async {
    ref.onDispose(() => _subscription?.cancel());

    final service = ref.read(sharingIntentServiceProvider);
    _subscription = service.mediaStream.listen(_handleShared);

    final initial = await service.getInitialMedia();
    if (initial.isNotEmpty) await _handleShared(initial);
  }

  Future<void> _handleShared(List<SharedMediaFile> files) async {
    final image = files
        .where((f) => f.type == SharedMediaType.image)
        .map((f) => f.path)
        .firstOrNull;
    if (image == null) return;

    // Only act when the user can create cards; otherwise the router guard would
    // bounce them to /login and the shared image would be lost mid-redirect.
    if (ref.read(authStateProvider) is! Authenticated) return;

    final result = await ref.read(barcodeImageAnalyzerProvider).analyze(image);
    final router = ref.read(routerProvider);

    if (result == null) {
      router.goNamed(RouteNames.cardsCreate);
    } else {
      router.goNamed(
        RouteNames.cardsScanConfirm,
        extra: <String, String>{
          'barcodeContent': result.barcodeContent,
          'barcodeType': result.barcodeType,
        },
      );
    }

    await ref.read(sharingIntentServiceProvider).reset();
  }
}
