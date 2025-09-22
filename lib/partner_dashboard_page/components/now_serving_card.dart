// lib/partner_dashboard_page/components/now_serving_card.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import 'homecare_details_view.dart';
import 'dashboard_helpers.dart'; // CORRECTED: Import from the new helper file

class NowServingCard extends StatelessWidget {
  const NowServingCard({
    super.key,
    required this.appointmentData,
    required this.onAction,
  });

  final Map<String, dynamic> appointmentData;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final client = Supabase.instance.client;
    final appointmentId = appointmentData['id'];
    final userData = appointmentData['users'] as Map<String, dynamic>? ?? {};
    final bookingUserName =
        ('${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}')
            .trim();
    final onBehalfOfName =
        appointmentData['on_behalf_of_patient_name'] as String?;
    final displayName = onBehalfOfName ??
        (bookingUserName.isNotEmpty ? bookingUserName : 'A Patient');
    final appointmentNumber = appointmentData['appointment_number'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [theme.primary, theme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Now Serving',
                style: theme.labelLarge.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text('$appointmentNumber',
                      style: theme.displaySmall.copyWith(color: theme.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayName,
                    style: theme.headlineMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            HomecareDetailsView(
                appointmentData: appointmentData, lightTheme: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      try {
                        await client.from('appointments').update(
                            {'status': 'NoShow'}).eq('id', appointmentId);
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                              context, 'Action failed: ${e.toString()}');
                        }
                      }
                    },
                    text: 'No-Show',
                    options: FFButtonOptions(
                      height: 44,
                      color: Colors.white.withAlpha(51),
                      textStyle: theme.titleSmall.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FFButtonWidget(
                    onPressed: () async {
                      try {
                        await client.from('appointments').update({
                          'status': 'Completed',
                          'completed_at': DateTime.now().toIso8601String(),
                        }).eq('id', appointmentId);
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                              context, 'Action failed: ${e.toString()}');
                        }
                      }
                    },
                    text: 'Mark as Completed',
                    icon: const Icon(Icons.check_circle, size: 20),
                    options: FFButtonOptions(
                      height: 44,
                      color: Colors.white,
                      textStyle: theme.titleSmall.copyWith(
                          color: theme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
