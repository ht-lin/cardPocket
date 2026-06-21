import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_model.freezed.dart';

@freezed
abstract class CardModel with _$CardModel {
  const factory CardModel({
    required String id,
    required String name,
    required String barcodeType,
    required String barcodeContent,
    required bool isOwner,
    String? shareId,
    String? viewerNickname,
    String? ownerUsername,
    DateTime? expiresAt,
    required DateTime updatedAt,
  }) = _CardModel;
}

extension CardModelX on CardModel {
  /// Whether the card's validity period has elapsed. Cards without an
  /// `expiresAt` never expire.
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

@freezed
abstract class CardsListState with _$CardsListState {
  const factory CardsListState({
    @Default([]) List<CardModel> items,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = _CardsListState;
}

@freezed
abstract class CardsSearchState with _$CardsSearchState {
  const factory CardsSearchState({
    @Default([]) List<CardModel> results,
    @Default(false) bool fromRemote,
    @Default('') String query,
  }) = _CardsSearchState;
}
