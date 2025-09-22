// lib/settings_page/components/profile_card.dart

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.primary,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                    style: theme.titleLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isNotEmpty ? name : 'User Profile',
                          style: theme.titleLarge),
                      Text(email,
                          style: theme.bodyMedium
                              .copyWith(color: theme.secondaryText)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: theme.secondaryText, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
