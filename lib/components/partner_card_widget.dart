// lib/components/partner_card_widget.dart

import 'package:flutter/material.dart';
import 'package:maouidi/backend/supabase/supabase.dart';
import 'package:maouidi/flutter_flow/flutter_flow_theme.dart';
import 'package:maouidi/flutter_flow/flutter_flow_util.dart';
import 'package:maouidi/flutter_flow/flutter_flow_widgets.dart';

class PartnerCardWidget extends StatelessWidget {
  const PartnerCardWidget({
    super.key,
    required this.partner,
    this.showBookingButton = false,
  });

  final MedicalPartnersRow partner;
  final bool showBookingButton;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'PartnerProfilePage',
            queryParameters: {'partnerId': partner.id}.withoutNulls,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: theme.primaryBackground,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      partner.photoUrl ??
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/health-app-j75f2j/assets/7957s72h1p38/avatar-default.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 90,
                        color: theme.alternate,
                        child: Icon(Icons.person,
                            size: 40, color: theme.secondaryText),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          partner.fullName ?? 'Unnamed Partner',
                          style: theme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          partner.specialty ?? 'No Specialty',
                          style: theme.bodySmall
                              .copyWith(color: theme.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: theme.warning, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              partner.averageRating?.toStringAsFixed(1) ??
                                  'N/A',
                              style: theme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${partner.reviewCount ?? 0})',
                              style: theme.bodySmall
                                  .copyWith(color: theme.secondaryText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showBookingButton)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FFButtonWidget(
                    onPressed: () {
                      context.pushNamed(
                        'BookingPage',
                        queryParameters: {'partnerId': partner.id}.withoutNulls,
                      );
                    },
                    text: 'Book Now',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 36,
                      color: theme.accent1,
                      textStyle:
                          theme.titleSmall.copyWith(color: theme.primary),
                      elevation: 1,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
