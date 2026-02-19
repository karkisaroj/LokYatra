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

class HomestaysLoaded extends HomestayState {
  final List<Homestay> homestays;

  const HomestaysLoaded(this.homestays);

  @override
  List<Object> get props => [homestays];
}

class HomestayError extends HomestayState {
  final String message;

  const HomestayError(this.message);

  @override
  List<Object> get props => [message];
}