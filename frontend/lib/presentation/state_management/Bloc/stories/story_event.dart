import 'package:file_picker/file_picker.dart';

abstract class StoryEvent {}

class LoadStories extends StoryEvent {
  final int? siteId;
  LoadStories({this.siteId});
}

class CreateStory extends StoryEvent {
  final Map<String, dynamic> fields;
  final List<PlatformFile> files;
  CreateStory({required this.fields, required this.files});
}