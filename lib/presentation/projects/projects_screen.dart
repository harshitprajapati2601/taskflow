import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/utils/snackbar.dart';
import 'package:taskflow/core/widgets/state_views.dart';
import 'package:taskflow/data/models/project_model.dart';

import 'package:taskflow/presentation/projects/cubit/project_cubit.dart';
import 'package:taskflow/presentation/projects/widgets/create_project_dialog.dart';
import 'package:taskflow/presentation/projects/widgets/join_project_dialog.dart';
import 'package:taskflow/presentation/projects/widgets/project_card.dart';

import '../bloc/auth_bloc.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  void _create(BuildContext context) {
    final cubit = context.read<ProjectCubit>();
    showDialog<void>(
      context: context,
      builder: (_) => CreateProjectDialog(cubit: cubit),
    );
  }

  void _join(BuildContext context) {
    final cubit = context.read<ProjectCubit>();
    showDialog<void>(
      context: context,
      builder: (_) => JoinProjectDialog(cubit: cubit),
    );
  }

  Future<bool> _confirm(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmLabel,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _delete(BuildContext context, ProjectModel project) async {
    final cubit = context.read<ProjectCubit>();
    final ok = await _confirm(
      context,
      title: 'Delete project',
      message: 'Delete "${project.name}" for everyone? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!ok || !context.mounted) return;

    final error = await cubit.deleteProject(project.id);
    if (error != null && context.mounted) {
      ShowSnack(context, error, isError: true);
    }
  }

  Future<void> _leave(BuildContext context, ProjectModel project) async {
    final cubit = context.read<ProjectCubit>();
    final ok = await _confirm(
      context,
      title: 'Leave project',
      message: 'Leave "${project.name}"? You can rejoin with the invite code.',
      confirmLabel: 'Leave',
    );
    if (!ok || !context.mounted) return;

    final error = await cubit.leaveProject(project.id);
    if (error != null && context.mounted) {
      ShowSnack(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My projects'),
        actions: [
          IconButton(
            tooltip: 'Join with code',
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => _join(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          switch (state) {
            case ProjectLoading():
              return const LoadingView();
            case ProjectError(:final message):
              return ErrorView(
                message: message,
                onRetry: () => context.read<ProjectCubit>().retry(),
              );
            case ProjectLoaded(:final projects):
              if (projects.isEmpty) {
                return EmptyView(
                  icon: Icons.folder_open_outlined,
                  title: 'Start your first project',
                  message: 'Create a project, or join one with an invite code.',
                  actionLabel: 'Create project',
                  onAction: () => _create(context),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    isAdmin: project.isAdmin(uid),
                    // Phase 7 opens the Kanban board here.
                    onTap: () => ShowSnack(
                      context,
                      'The task board arrives in the next phase.',
                    ),
                    onDelete: () => _delete(context, project),
                    onLeave: () => _leave(context, project),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
