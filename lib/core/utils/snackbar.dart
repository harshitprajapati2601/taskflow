import 'package:flutter/material.dart';

void ShowSnack(BuildContext context, String message, {bool isError = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
  //cascade operator
  // You write  ScaffoldMessenger.of(context)
  // once and chain everything else with
  ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError? scheme.error : null,
        content: Text(
          message,
          style: isError ? TextStyle(
              color: scheme.onError
          )
              : null,
        ),
      ),
    );
}
