// lib/components/empty_state_widget.dart

import 'package:flutter/material.dart';
import 'package:maouidi/flutter_flow/flutter_flow_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: theme.secondaryText,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
