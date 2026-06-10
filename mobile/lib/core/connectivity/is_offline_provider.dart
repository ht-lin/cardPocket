import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_offline_provider.g.dart';

// Stub — always online until FE-SYNC-04 replaces this with real connectivity detection.
@Riverpod(keepAlive: true)
bool isOffline(Ref ref) => false;
