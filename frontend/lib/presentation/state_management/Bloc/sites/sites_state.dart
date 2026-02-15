abstract class SitesState {}

class SitesInitial extends SitesState {}

class SitesLoading extends SitesState {}

class SitesLoaded extends SitesState {
  final List<dynamic> sites; // each is Map<String, dynamic>
  SitesLoaded(this.sites);
}

class SitesError extends SitesState {
  final String message;
  SitesError(this.message);
}

class SiteCreateSuccess extends SitesState {}