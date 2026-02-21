import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class SitesEvent extends Equatable {
  const SitesEvent();

  @override
  List<Object> get props => [];
}

class LoadSites extends SitesEvent {
  final String? query;
  const LoadSites({this.query});

  @override
  List<Object> get props => [query ?? ''];
}

class RefreshSites extends SitesEvent {
  const RefreshSites();
}

class LoadSiteById extends SitesEvent {
  final int id;
  const LoadSiteById(this.id);

  @override
  List<Object> get props => [id];
}

class CreateSite extends SitesEvent {
  final Map<String, dynamic> fields;
  final List<PlatformFile> files;

  const CreateSite({required this.fields, required this.files});

  @override
  List<Object> get props => [fields, files];
}