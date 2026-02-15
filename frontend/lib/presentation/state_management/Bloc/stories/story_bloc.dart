import 'package:bloc/bloc.dart';
import '../../../../data/datasources/Stories_remote_datasource.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoriesRemoteDatasource _remote = StoriesRemoteDatasource();

  StoryBloc() : super(StoryInitial()) {
    on<LoadStories>(_onLoadStories);
    on<CreateStory>(_onCreateStory);
  }

  Future<void> _onLoadStories(LoadStories event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final resp = await _remote.getStories(siteId: event.siteId);
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        emit(StoriesLoaded(data));
      } else {
        emit(StoryError('Failed to load stories: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(StoryError('Network error: $e'));
    }
  }

  Future<void> _onCreateStory(CreateStory event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final resp = await _remote.createStory(fields: event.fields, files: event.files);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        emit(StoryCreateSuccess());
      } else {
        emit(StoryError('Failed to create story: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(StoryError('Network error: $e'));
    }
  }
}