//       watch() called
//             |
// Cancel previous subscription
//             |
// Subscribe to Firestore stream
//            |
// Receive updated project list
//           |
// emit(ProjectLoaded(projects))

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/data/models/project_model.dart';
import 'package:taskflow/data/repositories/project_repository.dart';
import 'package:taskflow/presentation/projects/cubit/project_state.dart';

export 'package:taskflow/presentation/projects/cubit/project_state.dart';

/// Keeps the project list in sync with Firestore (a live stream) and exposes
/// the actions. The list updates by itself after every action, because the
/// stream fires whenever Firestore data changes.
///
/// Actions return `null` on success or an error message to show.
class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit(this._repository, this._uid) : super(const ProjectLoading());

  final ProjectRepository _repository;
  final String _uid;
  StreamSubscription<List<ProjectModel>>? _subscription;

  void watch() {
    _subscription?.cancel();
    _subscription = _repository.watchProjects(_uid).listen(
          (projects) => emit(ProjectLoaded(projects)),
      onError: (Object _) =>
          emit(const ProjectError('Could not load your projects.')),
    );
  }

  void retry() {
    if (state is! ProjectLoading) emit(const ProjectLoading());
    watch();
  }

  Future<String?> createProject({
    required String name,
    required String description,
  }) {
    return _run(
          () => _repository.createProject(
        name: name.trim(),
        description: description.trim(),
        ownerId: _uid,
      ),
    );
  }

  Future<String?> joinProject(String code) {
    return _run(() => _repository.joinByCode(code: code, uid: _uid));
  }

  Future<String?> deleteProject(String projectId) {
    return _run(() => _repository.deleteProject(projectId));
  }

  Future<String?> leaveProject(String projectId) {
    return _run(
          () => _repository.leaveProject(projectId: projectId, uid: _uid),
    );
  }

//This is one of the most important methods in your Cubit.
// Its purpose is to execute project operations and handle errors in one common place.
  Future<String?> _run(Future<Object?> Function() action) async {
    try {
      await action();
      return null;
    } on ProjectFailure catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Try again.';
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
