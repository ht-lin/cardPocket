import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_offline_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<bool> isOffline(Ref ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield initial.every((r) => r == ConnectivityResult.none);
  yield* connectivity.onConnectivityChanged.map(
    (results) => results.every((r) => r == ConnectivityResult.none),
  );
}
