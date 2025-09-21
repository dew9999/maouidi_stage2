// lib/patient_dashboard/patient_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/components/empty_state_widget.dart'; // NEW: Import the empty state component
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'patient_dashboard_model.dart';
export 'patient_dashboard_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PatientDashboardWidget extends StatefulWidget {
  const PatientDashboardWidget({super.key});

  static String routeName = 'PatientDashboard';
  static String routePath = '/patientDashboard';
  @override
  State<PatientDashboardWidget> createState() => _PatientDashboardWidgetState();
}

class _PatientDashboardWidgetState extends State<PatientDashboardWidget>
    with TickerProviderStateMixin {
  late PatientDashboardModel _model;
  late TabController _tabController;
  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientDashboardModel());
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshNotifier.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments(List<String> statuses,
      {bool? isUpcoming}) {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return Future.value([]);

    var query = client
        .from('appointments')
        .select(
            '*, has_review, completed_at, medical_partners(full_name, specialty)')
        .eq('booking_user_id', userId)
        .inFilter('status', statuses);

    if (isUpcoming != null) {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final filterTime = startOfToday.toUtc().toIso8601String();

      if (isUpcoming) {
        query = query.gte('appointment_time', filterTime);
      } else {
        query = query.lt('appointment_time', now.toUtc().toIso8601String());
      }
    }

    return query
        .order('appointment_time', ascending: isUpcoming ?? false)
        .then((data) => List<Map<String, dynamic>>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text('My Appointments',
            style: theme.headlineMedium.override(
                fontFamily: 'Inter', color: Colors.white, fontSize: 22.0)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: theme.titleSmall.copyWith(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: theme.accent1,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'UPCOMING'),
            Tab(text: 'COMPLETED'),
            Tab(text: 'CANCELED'),
          ],
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _refreshNotifier,
        builder: (context, value, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(_fetchAppointments(
                  ['Pending', 'Confirmed', 'Rescheduled'],
                  isUpcoming: true)),
              _buildAppointmentList(_fetchAppointments(['Completed'])),
              _buildAppointmentList(_fetchAppointments(
                  ['Cancelled_ByUser', 'Cancelled_ByPartner', 'NoShow'])),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList(Future<List<Map<String, dynamic>>> future) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('An error occurred: ${snapshot.error}.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // --- MODIFIED: Use the new EmptyStateWidget ---
          return const EmptyStateWidget(
            icon: Icons.calendar_month_outlined,
            title: 'No Appointments',
            message: 'You don\'t have any appointments in this category yet.',
          );
        }

        final appointments = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointmentData = appointments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PatientAppointmentCard(
                appointmentData: appointmentData,
                onActionCompleted: () {
                  _refreshNotifier.value++;
                },
              ),
            );
          },
        );
      },
    );
  }
}

class PatientAppointmentCard extends StatelessWidget {
  const PatientAppointmentCard({
    super.key,
    required this.appointmentData,
    required this.onActionCompleted,
  });

  final Map<String, dynamic> appointmentData;
  final VoidCallback onActionCompleted;

  Color getStatusColor(BuildContext context, String? status) {
    final theme = FlutterFlowTheme.of(context);
    switch (status) {
      case 'Confirmed':
      case 'Completed':
        return theme.success;
      case 'Cancelled_ByUser':
      case 'Cancelled_ByPartner':
      case 'NoShow':
        return theme.error;
      case 'Pending':
      case 'Rescheduled':
        return theme.warning;
      default:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final status = appointmentData['status'] as String? ?? '';
    final appointmentId = appointmentData['id'];

    final bool canCancel = status == 'Pending' || status == 'Confirmed';

    bool canLeaveReview = false;
    if (status == 'Completed') {
      final hasReview = appointmentData['has_review'] as bool? ?? false;
      final completedAtStr = appointmentData['completed_at'] as String?;
      if (!hasReview && completedAtStr != null) {
        final completedAt = DateTime.parse(completedAtStr);
        if (DateTime.now()
            .isBefore(completedAt.add(const Duration(hours: 2)))) {
          canLeaveReview = true;
        }
      }
    }

    final partnerData =
        appointmentData['medical_partners'] as Map<String, dynamic>? ?? {};
    final partnerName = partnerData['full_name'] as String? ?? 'N/A';
    final specialty = partnerData['specialty'] as String? ?? 'No specialty';
    final appointmentTime =
        DateTime.parse(appointmentData['appointment_time']).toLocal();

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: theme.primaryBackground,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.alternate, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(appointmentTime).toUpperCase(),
                        style: theme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold, color: theme.primary),
                      ),
                      Text(
                        DateFormat('d').format(appointmentTime),
                        style: theme.headlineMedium.override(
                            fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        style: theme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: theme.bodyMedium
                            .copyWith(color: theme.secondaryText),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status,
                                style: theme.bodyLarge.copyWith(
                                  color: getStatusColor(context, status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('h:mm a').format(appointmentTime),
                                style: theme.bodyMedium
                                    .copyWith(color: theme.secondaryText),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            if (canLeaveReview)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FFButtonWidget(
                  onPressed: () =>
                      _showReviewDialog(context, appointmentId, partnerName),
                  text: 'Leave a Review',
                  icon: const Icon(Icons.rate_review_outlined),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44,
                    color: theme.primary,
                    textStyle: theme.titleSmall.copyWith(color: Colors.white),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (canCancel)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: FFButtonWidget(
                  onPressed: () =>
                      _showCancelDialog(context, appointmentId, partnerName),
                  text: 'Cancel Appointment',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44,
                    color: theme.secondaryBackground,
                    textStyle: theme.titleSmall.copyWith(color: theme.error),
                    elevation: 2,
                    borderSide: BorderSide(color: theme.alternate, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, int appointmentId, String partnerName) {
    final theme = FlutterFlowTheme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Cancel Appointment?', style: theme.titleLarge),
        content: Text(
          'Are you sure you want to cancel your appointment with $partnerName?',
          style: theme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Back', style: TextStyle(color: theme.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.rpc(
                  'cancel_and_reorder_queue',
                  params: {'appointment_id_arg': appointmentId},
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Appointment canceled successfully.'),
                    backgroundColor: Colors.green));
                onActionCompleted();
              } catch (e) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to cancel: ${e.toString()}'),
                    backgroundColor: theme.error));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(
      BuildContext context, int appointmentId, String partnerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReviewSheet(
        appointmentId: appointmentId,
        partnerName: partnerName,
        onSuccess: onActionCompleted,
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({
    required this.appointmentId,
    required this.partnerName,
    required this.onSuccess,
  });

  final int appointmentId;
  final String partnerName;
  final VoidCallback onSuccess;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  double _rating = 4.0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client.rpc('submit_review', params: {
        'appointment_id_arg': widget.appointmentId,
        'rating_arg': _rating,
        'review_text_arg': _reviewController.text,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thank you for your review!'),
        backgroundColor: Colors.green,
      ));
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Submission failed: ${e.toString()}'),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rate your visit with',
              style: theme.bodyMedium,
            ),
            Text(
              widget.partnerName,
              style: theme.headlineSmall,
            ),
            const SizedBox(height: 24),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: theme.warning),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Your comments (optional)',
                hintText: 'Tell us more about your experience...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: theme.primaryBackground,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FFButtonWidget(
              onPressed: _isSubmitting ? null : _submitReview,
              text: _isSubmitting ? 'Submitting...' : 'Submit Review',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: theme.primary,
                textStyle: theme.titleSmall.copyWith(color: Colors.white),
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
