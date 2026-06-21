import 'package:freezed_annotation/freezed_annotation.dart';

part 'trash_card_model.freezed.dart';

/// A soft-deleted card living in the owner's trash. Mirrors the backend
/// `CardTrashOutput` (owner-only; shared cards never appear in trash).
@freezed
abstract class TrashCard with _$TrashCard {
  const factory TrashCard({
    required String id,
    required String name,
    required String barcodeType,
    required String barcodeContent,
    required DateTime deletedAt,
    DateTime? expiresAt,
  }) = _TrashCard;
}

extension TrashCardX on TrashCard {
  /// Whether the card's validity period had elapsed. Cards without an
  /// `expiresAt` never expire.
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

@freezed
abstract class TrashListState with _$TrashListState {
  const factory TrashListState({
    @Default([]) List<TrashCard> items,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = _TrashListState;
}
