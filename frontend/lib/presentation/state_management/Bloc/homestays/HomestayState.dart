import 'package:equatable/equatable.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';

abstract class HomestayState extends Equatable {
  const HomestayState();

  @override
  List<Object> get props => [];
}

class HomestayInitial extends HomestayState {
  const HomestayInitial();
}

class HomestayLoading extends HomestayState {
  const HomestayLoading();
}

// Owner: list of owner's own homestays
class OwnerHomestaysLoaded extends HomestayState {
  final List<Homestay> homestays;
  const OwnerHomestaysLoaded(this.homestays);

  @override
  List<Object> get props => [homestays];
}

// Tourist: all visible public homestays
class TouristAllHomestaysLoaded extends HomestayState {
  final List<Homestay> homestays;
  const TouristAllHomestaysLoaded(this.homestays);

  @override
  List<Object> get props => [homestays];
}

// Tourist: homestays filtered near a specific cultural site
class TouristNearbyHomestaysLoaded extends HomestayState {
  final List<Homestay> homestays;
  final String siteName;
  const TouristNearbyHomestaysLoaded(this.homestays, this.siteName);

  @override
  List<Object> get props => [homestays, siteName];
}

class HomestayError extends HomestayState {
  final String message;
  const HomestayError(this.message);

  @override
  List<Object> get props => [message];
}