// lib/partner_dashboard_page/partner_dashboard_page_widget.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../components/empty_state_widget.dart';
import '../../flutter_flow/flutter_flow_calendar.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import 'partner_dashboard_page_model.dart';
import '../../backend/supabase/supabase.dart';
import 'components/homecare_details_view.dart';
import 'components/dashboard_helpers.dart';

export 'partner_dashboard_page_model.dart';

class PartnerDashboardPageWidget extends StatefulWidget {
  const PartnerDashboardPageWidget({
    super.key,
    required this.partnerId,
  });
  final String partnerId;
  static String routeName = 'PartnerDashboardPage';
  static String routePath = '/partnerDashboardPage';
  @override
  State<PartnerDashboardPageWidget> createState() =>
      _PartnerDashboardPageWidgetState();
}

class _PartnerDashboardPageWidgetState
    extends State<PartnerDashboardPageWidget> {
  late Future<Map<String, dynamic>?> _partnerDataFuture;

  @override
  void initState() {
    super.initState();
    _partnerDataFuture = Supabase.instance.client
        .from('medical_partners')
        .select('category, booking_system_type')
        .eq('id', widget.partnerId)
        .maybeSingle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text('Your Dashboard',
            style: theme.headlineMedium
                .override(fontFamily: 'Inter', color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _partnerDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                  child: Text('Could not load partner information.'));
            }

            final partnerData = snapshot.data!;
            final String category = partnerData['category'] ?? 'Doctors';

            if (category == 'Clinics') {
              return _ClinicDashboardView(partnerId: widget.partnerId);
            } else {
              return _StandardPartnerDashboardView(
                partnerId: widget.partnerId,
                bookingSystemType:
                    partnerData['booking_system_type'] ?? 'time_based',
                category: category,
              );
            }
          },
        ),
      ),
    );
  }
}

class _StandardPartnerDashboardView extends StatefulWidget {
  const _StandardPartnerDashboardView({
    required this.partnerId,
    required this.bookingSystemType,
    required this.category,
  });
  final String partnerId;
  final String bookingSystemType;
  final String category;

  @override
  State<_StandardPartnerDashboardView> createState() =>
      _StandardPartnerDashboardViewState();
}

class _StandardPartnerDashboardViewState
    extends State<_StandardPartnerDashboardView> {
  late PartnerDashboardPageModel _model;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PartnerDashboardPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showBookForPatientDialog_QueueBased(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final caseController = TextEditingController();
    final locationController = TextEditingController();
    final bool isHomecare = widget.category == 'Homecare';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Book for Patient', style: theme.titleLarge),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Patient's Full Name"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: "Patient's Phone"),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                if (isHomecare) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: caseController,
                    decoration:
                        const InputDecoration(labelText: "Case Description"),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration:
                        const InputDecoration(labelText: "Patient Location"),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ]
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await Supabase.instance.client.rpc(
                    'book_appointment',
                    params: {
                      'partner_id_arg': widget.partnerId,
                      'appointment_time_arg':
                          DateTime.now().toUtc().toIso8601String(),
                      'on_behalf_of_name_arg': nameController.text,
                      'on_behalf_of_phone_arg': phoneController.text,
                      'is_partner_override': true,
                      'case_description_arg':
                          isHomecare ? caseController.text : null,
                      'patient_location_arg':
                          isHomecare ? locationController.text : null,
                    },
                  );
                  if (!mounted) return;
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Appointment created successfully!'),
                      backgroundColor: Colors.green));
                  setState(() => _refreshCounter++);
                } catch (e) {
                  if (mounted) {
                    showErrorSnackbar(
                        context, 'Booking failed: ${e.toString()}');
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: ValueKey(_refreshCounter),
      floatingActionButton: _model.currentView != DashboardView.schedule
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (widget.bookingSystemType == 'number_based') {
                  _showBookForPatientDialog_QueueBased(context);
                } else {
                  context.pushNamed(
                    'BookingPage',
                    queryParameters: {
                      'partnerId': widget.partnerId,
                      'isPartnerBooking': 'true',
                    }.withoutNulls,
                  );
                }
              },
              backgroundColor: theme.primary,
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<DashboardView>(
              segments: const [
                ButtonSegment(
                    value: DashboardView.schedule,
                    label: Text('Schedule'),
                    icon: Icon(Icons.calendar_month)),
                ButtonSegment(
                    value: DashboardView.analytics,
                    label: Text('Analytics'),
                    icon: Icon(Icons.bar_chart)),
              ],
              selected: {_model.currentView},
              onSelectionChanged: (newSelection) {
                setState(() => _model.currentView = newSelection.first);
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: theme.secondaryBackground,
                foregroundColor: theme.primaryText,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: theme.primary,
              ),
            ),
          ),
          Expanded(
            child: _model.currentView == DashboardView.schedule
                ? _ScheduleView(
                    model: _model,
                    partnerId: widget.partnerId,
                    bookingSystemType: widget.bookingSystemType)
                : _AnalyticsView(partnerId: widget.partnerId),
          ),
        ],
      ),
    );
  }
}

class _ClinicDashboardView extends StatefulWidget {
  const _ClinicDashboardView({required this.partnerId});
  final String partnerId;

  @override
  State<_ClinicDashboardView> createState() => _ClinicDashboardViewState();
}

class _ClinicDashboardViewState extends State<_ClinicDashboardView> {
  DashboardView _currentView = DashboardView.schedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<DashboardView>(
            segments: const [
              ButtonSegment(
                  value: DashboardView.schedule,
                  label: Text('All Appointments'),
                  icon: Icon(Icons.calendar_month)),
              ButtonSegment(
                  value: DashboardView.analytics,
                  label: Text('Clinic Analytics'),
                  icon: Icon(Icons.bar_chart)),
            ],
            selected: {_currentView},
            onSelectionChanged: (newSelection) {
              setState(() => _currentView = newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              foregroundColor: FlutterFlowTheme.of(context).primaryText,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
        Expanded(
          child: _currentView == DashboardView.schedule
              ? _ClinicScheduleView(clinicId: widget.partnerId)
              : _ClinicAnalyticsView(clinicId: widget.partnerId),
        ),
      ],
    );
  }
}

class _ClinicScheduleView extends StatefulWidget {
  const _ClinicScheduleView({required this.clinicId});
  final String clinicId;

  @override
  State<_ClinicScheduleView> createState() => _ClinicScheduleViewState();
}

class _ClinicScheduleViewState extends State<_ClinicScheduleView> {
  late Future<List<MedicalPartnersRow>> _doctorsFuture;
  String? _selectedDoctorId;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = MedicalPartnersTable().queryRows(
      queryFn: (q) => q.eq('parent_clinic_id', widget.clinicId),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() {
    return Supabase.instance.client.rpc(
      'get_clinic_appointments',
      params: {
        'clinic_id_arg': widget.clinicId,
        'doctor_id_arg': _selectedDoctorId,
      },
    ).then((data) => List<Map<String, dynamic>>.from(data as List));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FutureBuilder<List<MedicalPartnersRow>>(
            future: _doctorsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 50);
              }
              final doctors = snapshot.data!;
              return DropdownButtonFormField<String>(
                initialValue: _selectedDoctorId,
                hint: const Text('Filter by Doctor'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: theme.secondaryBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Doctors'),
                  ),
                  ...doctors.map((doc) => DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc.fullName ?? 'Unnamed Doctor'),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorId = value;
                    _refreshKey++;
                  });
                },
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_refreshKey),
            future: _fetchAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.calendar_today_rounded,
                  title: 'No Appointments Found',
                  message: 'There are no appointments matching your filter.',
                );
              }

              final appointments = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final time =
                      DateTime.parse(appt['appointment_time']).toLocal();
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(appt['patient_name'] ?? 'A Patient',
                          style: theme.titleMedium),
                      subtitle: Text(
                          'With: ${appt['doctor_name'] ?? 'N/A'}\nStatus: ${appt['status']}',
                          style: theme.bodySmall),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(DateFormat.yMMMd().format(time),
                              style: theme.bodySmall),
                          Text(DateFormat.jm().format(time),
                              style: theme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClinicAnalyticsView extends StatelessWidget {
  const _ClinicAnalyticsView({required this.clinicId});
  final String clinicId;

  Future<Map<String, dynamic>> _fetchAnalytics() async {
    return await Supabase.instance.client.rpc('get_clinic_analytics', params: {
      'clinic_id_arg': clinicId
    }).then((data) => data as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Could not load analytics.'));
        }

        final summary = snapshot.data!['summary'] as Map<String, dynamic>;
        final weekly =
            List<Map<String, dynamic>>.from(snapshot.data!['weekly'] as List);

        return _AnalyticsViewContent(
          summaryStats: {
            'total': summary['total'] as int? ?? 0,
            'week_completed': summary['week_completed'] as int? ?? 0,
            'month_completed': summary['month_completed'] as int? ?? 0,
            'partner_canceled': 0,
          },
          weeklyStats: weekly,
        );
      },
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView({
    required this.model,
    required this.partnerId,
    required this.bookingSystemType,
  });
  final PartnerDashboardPageModel model;
  final String partnerId;
  final String bookingSystemType;

  @override
  Widget build(BuildContext context) {
    if (bookingSystemType == 'number_based') {
      return _NumberQueueView(model: model, partnerId: partnerId);
    } else {
      return _TimeSlotView(model: model, partnerId: partnerId);
    }
  }
}

class _TimeSlotView extends StatefulWidget {
  const _TimeSlotView({required this.model, required this.partnerId});
  final PartnerDashboardPageModel model;
  final String partnerId;

  @override
  State<_TimeSlotView> createState() => _TimeSlotViewState();
}

class _TimeSlotViewState extends State<_TimeSlotView> {
  int _refreshKey = 0;

  Future<List<Map<String, dynamic>>> _fetchTimeSlotAppointments() async {
    final client = Supabase.instance.client;
    const baseSelect = '*, users (first_name, last_name, phone)';

    var query = client
        .from('appointments')
        .select(baseSelect)
        .eq('partner_id', widget.partnerId)
        .filter('appointment_number', 'is', null);

    if (widget.model.selectedStatus == 'Canceled') {
      query = query.inFilter(
          'status', ['Cancelled_ByUser', 'Cancelled_ByPartner', 'NoShow']);
    } else {
      query = query.eq('status', widget.model.selectedStatus);
    }

    DateTime now = DateTime.now();
    DateTimeRange dateRange;

    switch (widget.model.dateFilter) {
      case DateRangeFilter.day:
        final selectedDay = widget.model.calendarSelectedDay?.start ?? now;
        dateRange = DateTimeRange(
            start: selectedDay.startOfDay, end: selectedDay.endOfDay);
        break;
      case DateRangeFilter.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        dateRange = DateTimeRange(
            start: startOfWeek.startOfDay,
            end: startOfWeek.add(const Duration(days: 6)).endOfDay);
        break;
      case DateRangeFilter.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        dateRange = DateTimeRange(
            start: startOfMonth,
            end: DateTime(now.year, now.month + 1, 0).endOfDay);
        break;
      case DateRangeFilter.today:
        dateRange = DateTimeRange(start: now.startOfDay, end: now.endOfDay);
        break;
      case DateRangeFilter.all:
        dateRange = DateTimeRange(start: DateTime(2000), end: DateTime(3000));
        break;
    }

    if (widget.model.dateFilter != DateRangeFilter.all) {
      query = query
          .gte('appointment_time', dateRange.start.toUtc().toIso8601String())
          .lt('appointment_time', dateRange.end.toUtc().toIso8601String());
    }

    final response = await query.order('appointment_time', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bool showDateFilters = widget.model.selectedStatus == 'Pending' ||
        widget.model.selectedStatus == 'Confirmed';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (showDateFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<DateRangeFilter>(
                  segments: const [
                    ButtonSegment(
                        value: DateRangeFilter.day, label: Text('Day')) ,
                    ButtonSegment(
                        value: DateRangeFilter.week, label: Text('Week')) ,
                    ButtonSegment(
                        value: DateRangeFilter.month, label: Text('Month')) ,
                    ButtonSegment(
                        value: DateRangeFilter.all, label: Text('All')) ,
                  ],
                  selected: {widget.model.dateFilter},
                  onSelectionChanged: (newSelection) => setState(
                      () => widget.model.dateFilter = newSelection.first),
                ),
              ],
            ),
          ),
        if (widget.model.dateFilter == DateRangeFilter.day)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.alternate, width: 1),
              ),
              child: FlutterFlowCalendar(
                color: theme.primary,
                weekFormat: false,
                rowHeight: 44,
                onChange: (newSelectedDate) => setState(
                    () => widget.model.calendarSelectedDay = newSelectedDate),
                initialDate: widget.model.calendarSelectedDay?.start,
                titleStyle: theme.titleLarge,
                dayOfWeekStyle:
                    theme.bodyMedium.copyWith(color: theme.secondaryText),
                dateStyle: theme.bodyMedium,
                selectedDateStyle:
                    theme.titleSmall.copyWith(color: Colors.white),
                inactiveDateStyle:
                    theme.labelMedium.copyWith(color: theme.alternate),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: ['Pending', 'Confirmed', 'Completed', 'Canceled']
                    .map((status) {
                  return ChoiceChip(
                    label: Text(status),
                    selected: widget.model.selectedStatus == status,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        setState(() {
                          widget.model.selectedStatus = status;
                          _refreshKey++;
                        });
                      }
                    },
                    selectedColor: theme.primary,
                    labelStyle: TextStyle(
                        color: widget.model.selectedStatus == status
                            ? Colors.white
                            : theme.primaryText),
                    backgroundColor: theme.secondaryBackground,
                    shape:
                        StadiumBorder(side: BorderSide(color: theme.alternate)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        FutureBuilder<List<Map<String, dynamic>>>(
          key: ValueKey(_refreshKey),
          future: _fetchTimeSlotAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('An error occurred.', style: theme.bodyMedium));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.calendar_view_day_rounded,
                title: 'No Appointments Found',
                message:
                    'There are no appointments that match your selected filters.',
              );
            }

            final appointments = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              primary: false,
              shrinkWrap: true,
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _AppointmentInfoCard(
                    appointmentData: appointments[index],
                    onAction: () => setState(() {
                      _refreshKey++;
                    }),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _NumberQueueView extends StatefulWidget {
  const _NumberQueueView({required this.model, required this.partnerId});
  final PartnerDashboardPageModel model;
  final String partnerId;

  @override
  State<_NumberQueueView> createState() => _NumberQueueViewState();
}

class _NumberQueueViewState extends State<_NumberQueueView> {
  int _refreshKey = 0;

  Future<List<Map<String, dynamic>>> _fetchNumberedAppointments() async {
    final client = Supabase.instance.client;
    final selectedDay =
        widget.model.calendarSelectedDay?.start ?? DateTime.now();
    final startOfDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await client
        .from('appointments')
        .select('*, users (first_name, last_name, phone)')
        .eq('partner_id', widget.partnerId)
        .gte('appointment_time', startOfDay.toUtc().toIso8601String())
        .lt('appointment_time', endOfDay.toUtc().toIso8601String())
        .not('status', 'in',
            ['Cancelled_ByUser', 'Cancelled_ByPartner', 'Completed', 'NoShow'])
        .order('appointment_number', ascending: true)
        .then((data) => List<Map<String, dynamic>>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final selectedDay =
        widget.model.calendarSelectedDay?.start ?? DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                setState(() {
                  widget.model.calendarSelectedDay =
                      DateTimeRange(start: pickedDate, end: pickedDate);
                  _refreshKey++;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.alternate, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMMd().format(selectedDay),
                    style: theme.titleMedium,
                  ),
                  Icon(Icons.calendar_month_outlined, color: theme.primary),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_refreshKey),
            future: _fetchNumberedAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('An error occurred: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'Queue is Empty',
                  message:
                      'There are no active appointments in the queue for this day.',
                );
              }

              final appointments = snapshot.data!;
              final nowServingAppointment = appointments.firstWhere(
                (a) => a['status'] == 'Confirmed',
                orElse: () => {},
              );
              final upNextAppointments =
                  appointments.where((a) => a['status'] == 'Pending').toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                children: [
                  if (nowServingAppointment.isNotEmpty)
                    NowServingCard(
                      appointmentData: nowServingAppointment,
                      onAction: () => setState(() => _refreshKey++),
                    ),
                  if (upNextAppointments.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(
                          top: nowServingAppointment.isNotEmpty ? 24 : 8,
                          bottom: 8),
                      child: Text('Up Next in Queue',
                          style: FlutterFlowTheme.of(context).titleLarge),
                    ),
                    ...upNextAppointments.map((appt) => _UpNextQueueCard(
                          appointmentData: appt,
                          partnerId: widget.partnerId,
                          onAction: () => setState(() => _refreshKey++),
                        )),
                  ],
                  if (nowServingAppointment.isEmpty &&
                      upNextAppointments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Text('The queue is ready.',
                              style: theme.headlineSmall),
                          const SizedBox(height: 8),
                          Text('Press "Call Next Patient" to begin.',
                              style: theme.bodyMedium),
                          const SizedBox(height: 16),
                          FFButtonWidget(
                            onPressed: () async {
                              final nextPatient = upNextAppointments.first;
                              await Supabase.instance.client
                                  .from('appointments')
                                  .update({
                                'status': 'Confirmed',
                              }).eq('id', nextPatient['id']);
                              setState(() => _refreshKey++);
                            },
                            text: 'Call Next Patient',
                            icon: const Icon(Icons.campaign_outlined),
                            options: FFButtonOptions(
                              height: 50,
                              color: theme.primary,
                              textStyle: theme.titleSmall
                                  .copyWith(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AppointmentInfoCard extends StatelessWidget {
  const _AppointmentInfoCard(
      {required this.appointmentData, required this.onAction});
  final Map<String, dynamic> appointmentData;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final client = Supabase.instance.client;
    final status = appointmentData['status'] as String;
    final appointmentId = appointmentData['id'];
    final appointmentTime =
        DateTime.parse(appointmentData['appointment_time']).toLocal();
    final userData = appointmentData['users'] as Map<String, dynamic>? ?? {};
    final bookingUserName =
        ('${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}')
            .trim();
    final bookingUserPhone = userData['phone'] as String? ?? 'No phone';
    final onBehalfOfName =
        appointmentData['on_behalf_of_patient_name'] as String?;
    final onBehalfOfPhone =
        appointmentData['on_behalf_of_patient_phone'] as String?;
    final displayName = onBehalfOfName ??
        (bookingUserName.isNotEmpty ? bookingUserName : 'Booked Patient');
    final displayPhone = onBehalfOfPhone ?? bookingUserPhone;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              blurRadius: 3,
              color: theme.primaryBackground,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: theme.titleLarge),
                    const SizedBox(height: 4),
                    Text(displayPhone,
                        style: theme.bodyMedium
                            .copyWith(color: theme.secondaryText)),
                    const SizedBox(height: 8),
                    Text(DateFormat('h:mm a').format(appointmentTime),
                        style: theme.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (status == 'Pending' || status == 'Confirmed')
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'cancel') {
                      final confirmed = await showStyledConfirmationDialog(
                        context: context,
                        title: 'Cancel Appointment?',
                        content:
                            'Are you sure you want to cancel this appointment?',
                        confirmText: 'Confirm',
                      );
                      if (confirmed == true) {
                        try {
                          await client
                              .from('appointments')
                              .update({'status': 'Cancelled_ByPartner'}).eq(
                                  'id', appointmentId);
                          onAction();
                        } catch (e) {
                          if (context.mounted) {
                            showErrorSnackbar(
                                context, 'Action failed: ${e.toString()}');
                          }
                        }
                      }
                    } else if (value == 'no-show') {
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
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (status == 'Confirmed')
                      const PopupMenuItem<String>(
                        value: 'no-show',
                        child: Text('Mark as No-Show'),
                      ),
                    const PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text('Cancel Appointment'),
                    ),
                  ],
                )
            ],
          ),
          HomecareDetailsView(appointmentData: appointmentData),
          if (status == 'Pending')
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      try {
                        await client
                            .from('appointments')
                            .update({'status': 'Cancelled_ByPartner'}).eq(
                                'id', appointmentId);
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                              context, 'Failed to decline: ${e.toString()}');
                        }
                      }
                    },
                    text: 'Decline',
                    options: FFButtonOptions(
                        height: 40,
                        color: theme.secondaryBackground,
                        textStyle:
                            theme.bodyMedium.copyWith(color: theme.error),
                        elevation: 1,
                        borderSide: BorderSide(color: theme.alternate)),
                  ),
                  const SizedBox(width: 8),
                  FFButtonWidget(
                    onPressed: () async {
                      try {
                        await client.from('appointments').update(
                            {'status': 'Confirmed'}).eq('id', appointmentId);
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                              context, 'Failed to confirm: ${e.toString()}');
                        }
                      }
                    },
                    text: 'Confirm',
                    options: FFButtonOptions(
                      height: 40,
                      color: theme.success,
                      textStyle: theme.bodyMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          if (status == 'Confirmed')
            Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    try {
                      await client.from('appointments').update({
                        'status': 'Completed',
                        // --- TIMEZONE FIX ---
                        'completed_at':
                            DateTime.now().toUtc().toIso8601String(),
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
                  icon: const Icon(Icons.check_circle_outline),
                  options: FFButtonOptions(
                      width: double.infinity,
                      height: 44,
                      color: theme.primary,
                      textStyle:
                          theme.titleSmall.copyWith(color: Colors.white)),
                )),
        ],
      ),
    );
  }
}

class _UpNextQueueCard extends StatelessWidget {
  const _UpNextQueueCard({
    required this.appointmentData,
    required this.partnerId,
    required this.onAction,
  });
  final Map<String, dynamic> appointmentData;
  final String partnerId;
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
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.accent1.withAlpha(25),
                  child: Text(
                    '$appointmentNumber',
                    style: theme.titleMedium.copyWith(color: theme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(displayName, style: theme.titleMedium),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'cancel') {
                      final confirmed = await showStyledConfirmationDialog(
                        context: context,
                        title: 'Cancel Appointment?',
                        content:
                            'Are you sure you want to cancel this request?',
                        confirmText: 'Confirm',
                      );
                      if (confirmed == true) {
                        try {
                          await client
                              .from('appointments')
                              .update({'status': 'Cancelled_ByPartner'}).eq(
                                  'id', appointmentId);
                          onAction();
                        } catch (e) {
                          if (context.mounted) {
                            showErrorSnackbar(
                                context, 'Action failed: ${e.toString()}');
                          }
                        }
                      }
                    } else if (value == 'reschedule') {
                      try {
                        await client.rpc(
                            'reschedule_appointment_to_end_of_queue',
                            params: {
                              'appointment_id_arg': appointmentId,
                              'partner_id_arg': partnerId
                            });
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                              context, 'Failed to reschedule: ${e.toString()}');
                        }
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'reschedule',
                      child: Text('Move to End of Queue'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'cancel',
                      child: Text('Cancel Appointment'),
                    ),
                  ],
                )
              ],
            ),
            HomecareDetailsView(appointmentData: appointmentData),
            const SizedBox(height: 8),
            FFButtonWidget(
              onPressed: () async {
                try {
                  await client
                      .from('appointments')
                      .update({'status': 'Confirmed'}).eq('id', appointmentId);
                  onAction();
                } catch (e) {
                  if (context.mounted) {
                    showErrorSnackbar(
                        context, 'Action failed: ${e.toString()}');
                  }
                }
              },
              text: 'Call Next',
              icon: const Icon(Icons.campaign_outlined),
              options: FFButtonOptions(
                width: double.infinity,
                height: 40,
                color: theme.primary.withAlpha(25),
                textStyle: theme.titleSmall.copyWith(color: theme.primary),
                elevation: 0,
                borderSide: BorderSide(color: theme.primary, width: 1),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView({required this.partnerId});
  final String partnerId;
  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  late Future<_AnalyticsData> _analyticsFuture;
  @override
  void initState() {
    super.initState();
    _analyticsFuture = _fetchAllAnalytics();
  }

  Future<_AnalyticsData> _fetchAllAnalytics() async {
    final results = await Future.wait([
      _fetchSummaryStats(),
      _fetchWeeklyStats(),
    ]);
    return _AnalyticsData(
      summaryStats: results[0] as Map<String, int>,
      weeklyStats: results[1] as List<Map<String, dynamic>>,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchWeeklyStats() {
    return Supabase.instance.client.rpc('get_weekly_appointment_stats',
        params: {
          'partner_id_arg': widget.partnerId
        }).then((data) => List<Map<String, dynamic>>.from(data as List));
  }

  Future<Map<String, int>> _fetchSummaryStats() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)).startOfDay;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final responses = await Future.wait([
      client
          .from('appointments')
          .select()
          .eq('partner_id', widget.partnerId)
          .not('status', 'eq', 'Cancelled_ByUser')
          .count(),
      client
          .from('appointments')
          .select()
          .eq('partner_id', widget.partnerId)
          .eq('status', 'Completed')
          .gte('appointment_time', startOfWeek.toIso8601String())
          .count(),
      client
          .from('appointments')
          .select()
          .eq('partner_id', widget.partnerId)
          .eq('status', 'Completed')
          .gte('appointment_time', startOfMonth.toIso8601String())
          .count(),
      client
          .from('appointments')
          .select()
          .eq('partner_id', widget.partnerId)
          .eq('status', 'Cancelled_ByPartner')
          .count(),
    ]);
    return {
      'total': responses[0].count,
      'week_completed': responses[1].count,
      'month_completed': responses[2].count,
      'partner_canceled': responses[3].count,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AnalyticsData>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Could not load analytics.'));
        }
        final data = snapshot.data!;
        return _AnalyticsViewContent(
          summaryStats: data.summaryStats,
          weeklyStats: data.weeklyStats,
        );
      },
    );
  }
}

class _AnalyticsViewContent extends StatelessWidget {
  const _AnalyticsViewContent({
    required this.summaryStats,
    required this.weeklyStats,
  });
  final Map<String, int> summaryStats;
  final List<Map<String, dynamic>> weeklyStats;
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final maxValue = weeklyStats
        .map((d) => d['appointment_count'] as int)
        .fold<int>(0, max)
        .toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Completed Appointments - Last 7 Days', style: theme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 5 : maxValue + 2,
                barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: theme.secondaryText,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = weeklyStats[group.x];
                    return BarTooltipItem(
                      '${day['day_of_week']}\n',
                      TextStyle(
                          color: theme.secondaryBackground,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: rod.toY.toInt().toString(),
                          style: TextStyle(
                            color: theme.secondaryBackground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                )),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= weeklyStats.length) {
                          return const SizedBox();
                        }
                        final day =
                            weeklyStats[value.toInt()]['day_of_week'] as String;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(day, style: theme.bodySmall),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0 || value > maxValue + 1) {
                          return const SizedBox();
                        }
                        return Text(value.toInt().toString(),
                            style: theme.bodySmall, textAlign: TextAlign.left);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(weeklyStats.length, (i) {
                  final dayData = weeklyStats[i];
                  final count =
                      (dayData['appointment_count'] as int).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count,
                        color: theme.primary,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }),
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.alternate,
                        strokeWidth: 1,
                      );
                    }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _AnalyticsCard(
                  label: 'Total Appointments', value: summaryStats['total']!),
              _AnalyticsCard(
                  label: 'Completed This Week',
                  value: summaryStats['week_completed']!),
              _AnalyticsCard(
                  label: 'Completed This Month',
                  value: summaryStats['month_completed']!),
              _AnalyticsCard(
                  label: 'Canceled By You',
                  value: summaryStats['partner_canceled']!),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              blurRadius: 4,
              color: theme.primaryBackground,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(value.toString(), style: theme.displaySmall),
          const SizedBox(height: 8),
          Text(label, style: theme.labelMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AnalyticsData {
  final Map<String, int> summaryStats;
  final List<Map<String, dynamic>> weeklyStats;
  _AnalyticsData({required this.summaryStats, required this.weeklyStats});
}

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
                          // --- TIMEZONE FIX ---
                          'completed_at':
                              DateTime.now().toUtc().toIso8601String(),
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
