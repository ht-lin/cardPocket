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
    String? viewerNickname,
    String? ownerUsername,
    required DateTime updatedAt,
  }) = _CardModel;
}

@freezed
abstract class CardsListState with _$CardsListState {
  const factory CardsListState({
    @Default([]) List<CardModel> items,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = _CardsListState;
}
