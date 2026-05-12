import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomestayReviews extends ReviewEvent {
  final int homestayId;
  const LoadHomestayReviews(this.homestayId);
  @override
  List<Object?> get props => [homestayId];
}

class LoadSiteReviews extends ReviewEvent {
  final int siteId;
  const LoadSiteReviews(this.siteId);
  @override
  List<Object?> get props => [siteId];
}

class LoadAllReviews extends ReviewEvent {
  final String? type;
  final int? rating;
  const LoadAllReviews({this.type, this.rating});
  @override
  List<Object?> get props => [type, rating];
}

class DeleteReview extends ReviewEvent {
  final int id;
  final String? reloadType;   // 'homestay' | 'site' | null = admin reload all
  final int? reloadId;
  const DeleteReview(this.id, {this.reloadType, this.reloadId});
  @override
  List<Object?> get props => [id];
}