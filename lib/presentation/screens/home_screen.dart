import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/di/service_locator.dart';
import 'package:taskflow/presentation/projects/cubit/project_cubit.dart';
import 'package:taskflow/presentation/projects/projects_screen.dart';
import '../bloc/auth_bloc.dart';
import '../projects/profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late final ProjectCubit _projectCubit;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final uid = state is Authenticated ? state.user.uid : '';
    _projectCubit = sl<ProjectCubit>(param1: uid)..watch();
  }

  @override
  void dispose() {
    _projectCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectCubit>.value(
      value: _projectCubit,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            ProjectsScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
