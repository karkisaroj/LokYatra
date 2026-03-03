import 'package:equatable/equatable.dart';
import '../../../../data/models/Review.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final double averageRating;
  final int reviewCount;
  const ReviewsLoaded(this.reviews, {this.averageRating = 0.0, this.reviewCount = 0});
  @override
  List<Object?> get props => [reviews, averageRating, reviewCount];
}

class AllReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  const AllReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class ReviewActionSuccess extends ReviewState {
  final String message;
  const ReviewActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}