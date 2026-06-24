import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sharing_intent_service.g.dart';

/// Thin wrapper over receive_sharing_intent so the import flow can be driven
/// and tested without the platform channel.
class SharingIntentService {
  const SharingIntentService();

  /// Images shared while the app is already running.
  Stream<List<SharedMediaFile>> get mediaStream =>
      ReceiveSharingIntent.instance.getMediaStream();

  /// The share that launched the app from a cold/terminated state.
  Future<List<SharedMediaFile>> getInitialMedia() =>
      ReceiveSharingIntent.instance.getInitialMedia();

  /// Clears the cached initial share so it isn't re-processed on next launch.
  Future<void> reset() => ReceiveSharingIntent.instance.reset();
}

@Riverpod(keepAlive: true)
SharingIntentService sharingIntentService(Ref ref) =>
    const SharingIntentService();
