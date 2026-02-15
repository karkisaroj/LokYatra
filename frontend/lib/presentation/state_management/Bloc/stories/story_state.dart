abstract class StoryState {}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoriesLoaded extends StoryState {
  final List<dynamic> stories; // each is Map<String, dynamic>
  StoriesLoaded(this.stories);
}

class StoryError extends StoryState {
  final String message;
  StoryError(this.message);
}

class StoryCreateSuccess extends StoryState {}