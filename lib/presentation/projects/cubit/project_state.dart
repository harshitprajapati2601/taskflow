import 'package:equatable/equatable.dart';
import 'package:taskflow/data/models/project_model.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

final class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

final class ProjectLoaded extends ProjectState {
  const ProjectLoaded(this.projects);

  final List<ProjectModel> projects;

  @override
  List<Object?> get props => [projects];
}

final class ProjectError extends ProjectState {
  const ProjectError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}