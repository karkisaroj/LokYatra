import 'package:file_picker/file_picker.dart';

abstract class SitesEvent {}

class LoadSites extends SitesEvent {
  final String? query;
  LoadSites({this.query});
}

class CreateSite extends SitesEvent {
  final Map<String, dynamic> fields;
  final List<PlatformFile> files;
  CreateSite({required this.fields, required this.files});
}