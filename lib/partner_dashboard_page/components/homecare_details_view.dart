// lib/partner_dashboard_page/components/homecare_details_view.dart

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class HomecareDetailsView extends StatelessWidget {
  const HomecareDetailsView({
    super.key,
    required this.appointmentData,
    this.lightTheme = false,
  });

  final Map<String, dynamic> appointmentData;
  final bool lightTheme;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final caseDescription = appointmentData['case_description'] as String?;
    final location = appointmentData['patient_location'] as String?;

    if (caseDescription == null || caseDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = lightTheme ? Colors.white : theme.primaryText;
    final secondaryTextColor =
        lightTheme ? Colors.white70 : theme.secondaryText;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lightTheme
              ? Colors.white.withOpacity(0.1)
              : theme.primaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 16, color: secondaryTextColor),
                const SizedBox(width: 8),
                Text('Case Description',
                    style:
                        theme.labelMedium.copyWith(color: secondaryTextColor)),
              ],
            ),
            const SizedBox(height: 4),
            Text(caseDescription,
                style: theme.bodyMedium.copyWith(color: textColor)),
            if (location != null && location.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: secondaryTextColor),
                  const SizedBox(width: 8),
                  Text('Patient Location',
                      style: theme.labelMedium
                          .copyWith(color: secondaryTextColor)),
                ],
              ),
              const SizedBox(height: 4),
              Text(location,
                  style: theme.bodyMedium.copyWith(color: textColor)),
            ]
          ],
        ),
      ),
    );
  }
}
