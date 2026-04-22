import 'package:equatable/equatable.dart';
import '../../../../data/models/site.dart';

abstract class SitesState extends Equatable {
  const SitesState();

  @override
  List<Object?> get props => [];
}

class SitesInitial extends SitesState {}

class SitesLoading extends SitesState {}

class SiteDetailLoading extends SitesState {}

class SitesLoaded extends SitesState {
  final List<CulturalSite> sites;
  const SitesLoaded(this.sites);

  @override
  List<Object?> get props => [sites];
}

class SiteDetailLoaded extends SitesState {
  final CulturalSite site;
  const SiteDetailLoaded(this.site);

  @override
  List<Object?> get props => [site];
}

class SiteCreateSuccess extends SitesState {}

class SitesError extends SitesState {
  final String message;
  const SitesError(this.message);

  @override
  List<Object?> get props => [message];
}

class SiteDetailError extends SitesState {
  final String message;
  const SiteDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
