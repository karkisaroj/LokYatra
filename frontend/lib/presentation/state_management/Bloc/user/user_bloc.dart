import 'package:bloc/bloc.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';
import '../../../../data/models/user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<DeleteUsers>(_onDeleteUser);
  }

  final _datasource = UserRemoteDatasource();

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await _datasource.getUsers();
      if (response.statusCode == 200) {
        final raw = response.data is List
            ? response.data as List<dynamic>
            : response.data['users'] as List<dynamic>;
        final users = raw.map((j) => User.fromJson(j)).toList();
        emit(UserLoaded(users));
      } else {
        emit(UserError('Failed to fetch users: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Error: $e'));
    }
  }

  Future<void> _onDeleteUser(DeleteUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await _datasource.deleteUser(event.userId);
      if (response.statusCode == 200) {
        emit(UserDeleted(event.userId));
      } else {
        emit(UserError('Failed to delete user: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Error deleting user: $e'));
    }
  }
}