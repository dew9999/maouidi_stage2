// lib/partner_dashboard_page/components/dashboard_helpers.dart

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

// This function shows a styled confirmation dialog
Future<bool> showStyledConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
}) async {
  final theme = FlutterFlowTheme.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.secondaryBackground,
      title: Text(title, style: theme.titleLarge),
      content: Text(content, style: theme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.error,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Reusable function for user-friendly error messages
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: FlutterFlowTheme.of(context).error,
  ));
}
