import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/review_remote_datasource.dart';
import '../../../../data/models/Review.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRemoteDatasource _datasource = ReviewRemoteDatasource();

  ReviewBloc() : super(ReviewInitial()) {
    on<LoadHomestayReviews>(_onLoadHomestayReviews);
    on<LoadSiteReviews>(_onLoadSiteReviews);
    on<LoadAllReviews>(_onLoadAllReviews);
    on<DeleteReview>(_onDeleteReview);
  }

  Future<void> _onLoadHomestayReviews(
      LoadHomestayReviews event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    try {
      final resp = await _datasource.getHomestayReviews(event.homestayId);
      if (resp.statusCode == 200) {
        final reviews = (resp.data as List<dynamic>)
            .map((j) => Review.fromJson(j as Map<String, dynamic>))
            .toList();
        final avg = reviews.isEmpty
            ? 0.0
            : reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
        emit(ReviewsLoaded(reviews,
            averageRating: double.parse(avg.toStringAsFixed(1)),
            reviewCount: reviews.length));
      } else {
        emit(ReviewError('Failed: ${resp.statusCode}'));
      }
    } catch (e) {
      debugPrint('ReviewBloc homestay error: $e');
      emit(const ReviewError('Failed to load reviews'));
    }
  }

  Future<void> _onLoadSiteReviews(
      LoadSiteReviews event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    try {
      final resp = await _datasource.getSiteReviews(event.siteId);
      if (resp.statusCode == 200) {
        final reviews = (resp.data as List<dynamic>)
            .map((j) => Review.fromJson(j as Map<String, dynamic>))
            .toList();
        final avg = reviews.isEmpty
            ? 0.0
            : reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
        emit(ReviewsLoaded(reviews,
            averageRating: double.parse(avg.toStringAsFixed(1)),
            reviewCount: reviews.length));
      } else {
        emit(ReviewError('Failed: ${resp.statusCode}'));
      }
    } catch (e) {
      debugPrint('ReviewBloc site error: $e');
      emit(const ReviewError('Failed to load reviews'));
    }
  }

  Future<void> _onLoadAllReviews(
      LoadAllReviews event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    try {
      final resp = await _datasource.getAllReviews(type: event.type, rating: event.rating);
      if (resp.statusCode == 200) {
        final reviews = (resp.data as List<dynamic>)
            .map((j) => Review.fromJson(j as Map<String, dynamic>))
            .toList();
        emit(AllReviewsLoaded(reviews));
      } else {
        emit(ReviewError('Failed: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(ReviewError('Failed to load reviews: $e'));
    }
  }

  Future<void> _onDeleteReview(
      DeleteReview event, Emitter<ReviewState> emit) async {
    try {
      final resp = await _datasource.deleteReview(event.id);
      if (resp.statusCode == 200) {
        if (event.reloadType == 'homestay' && event.reloadId != null) {
          add(LoadHomestayReviews(event.reloadId!));
        } else if (event.reloadType == 'site' && event.reloadId != null) {
          add(LoadSiteReviews(event.reloadId!));
        } else {
          add(const LoadAllReviews());
        }
      } else {
        emit(ReviewError('Failed to delete: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(ReviewError('Failed to delete review'));
    }
  }
}