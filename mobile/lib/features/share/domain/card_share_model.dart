import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_share_model.freezed.dart';

@freezed
abstract class CardShareModel with _$CardShareModel {
  const factory CardShareModel({
    required String id,
    required String viewerUserId,
    required String viewerUserName,
    String? viewerNickname,
    required DateTime createdAt,
  }) = _CardShareModel;
}
