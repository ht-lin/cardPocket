import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/domain/auth_models.dart';
import '../data/user_repository.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<User> build() =>
      ref.read(userRepositoryProvider).getProfile();

  Future<void> refresh() {
    ref.invalidateSelf();
    return future;
  }
}
