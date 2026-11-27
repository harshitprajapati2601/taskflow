import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskflow/core/utils/snackbar.dart';
import 'package:taskflow/data/models/project_model.dart';

class ProjectCard extends StatelessWidget {

  final ProjectModel project;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onLeave;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial = project.name.isEmpty ? '?' : project.name[0].toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      //Clips the card's child content to the card's shape,
      // using anti-aliasing for smoother edges.
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuButton<String>(
                    //Displays the tooltip "More" when the user interacts with the menu icon.
                    tooltip: 'More',
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                      if (value == 'leave') onLeave();
                    },
                    itemBuilder: (_) => [
                      if (isAdmin)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete project'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'leave',
                          child: Text('Leave project'),
                        ),
                    ],
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.group_outlined, size: 18, color: scheme.outline),
                  const SizedBox(width: 4),

                  //Member count
                  Text(
                    '${project.memberCount} '
                        '${project.memberCount == 1 ? 'member' : 'members'}',
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(width: 12),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAdmin ? 'Admin' : 'Member',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),

                  const Spacer(),
                  Text(
                    project.inviteCode,
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy invite code',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: project.inviteCode),
                      );
                      if (context.mounted) {
                        ShowSnack(context, 'Invite code copied');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
