import 'package:flutter/material.dart';

///// Reusable loading / empty / error views. Use them on every screen
// /// that loads data (projects, tasks, comments...).

class LoadingView  extends StatelessWidget {
  const LoadingView ({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color:theme.colorScheme.outline ,
            ),

            const SizedBox(height: 16,),

            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
              //To modify one property without rewriting the entire text style.
                ?.copyWith(fontWeight: FontWeight.w600),
            ),
            //Normally, an if statement inside a widget list can only add one widget.
            // The three dots (...) unpack the list [SizedBox, Text] and insert both widgets
            // directly into your parent widget.
            if(message != null) ...[
              const SizedBox(height: 8,),
              Text(
                  message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              )
      ],


            if(actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16,),
              FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!)
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyView(
        icon: Icons.error_outline,
        title: "Something Went Wrong",
      message: message,
      actionLabel: onRetry == null ? null : "Try Again",
      onAction: onRetry,
    );
  }
}


