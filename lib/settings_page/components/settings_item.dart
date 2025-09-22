import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor; // <-- ADDED THIS
  final Color? iconBackgroundColor; // <-- ADDED THIS

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor, // <-- ADDED THIS
    this.iconBackgroundColor, // <-- ADDED THIS
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                // MODIFIED: Use the new color parameters with a fallback
                color: iconBackgroundColor ?? theme.accent1.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              // MODIFIED: Use the new color parameters with a fallback
              child: Icon(icon, color: iconColor ?? theme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.bodyLarge),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        subtitle!,
                        style: theme.labelMedium
                            .copyWith(color: theme.secondaryText),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}