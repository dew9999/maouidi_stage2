// lib/booking_page/booking_page_widget.dart

import 'package:flutter/material.dart';
import 'package:maouidi/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

export 'booking_page_model.dart';

Future<Map<String, String>?> showHomecareDetailsDialog(
    BuildContext context) async {
  final theme = FlutterFlowTheme.of(context);
  final formKey = GlobalKey<FormState>();
  final caseController = TextEditingController();
  final locationController = TextEditingController();

  return await showDialog<Map<String, String>?>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Homecare Details', style: theme.headlineSmall),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: caseController,
                  decoration: InputDecoration(
                    labelText: "Brief Case Description",
                    labelStyle: theme.labelMedium,
                    hintText:
                        "e.g., Blood pressure check for elderly patient...",
                    hintStyle: theme.labelMedium,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'This field is required.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: "Your Full Address",
                    labelStyle: theme.labelMedium,
                    hintText: "Your full address for the home visit...",
                    hintStyle: theme.labelMedium,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 2,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'This field is required.' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop({
                  'case_description': caseController.text,
                  'patient_location': locationController.text,
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: const Text('Submit Request'),
          ),
        ],
      );
    },
  );
}

class BookingPageWidget extends StatefulWidget {
  const BookingPageWidget({
    super.key,
    required this.partnerId,
    this.isPartnerBooking = false,
  });

  static String routeName = 'BookingPage';
  static String routePath = '/bookingPage';

  final String partnerId;
  final bool isPartnerBooking;

  @override
  State<BookingPageWidget> createState() => _BookingPageWidgetState();
}

class _BookingPageWidgetState extends State<BookingPageWidget> {
  late Future<Map<String, dynamic>?> _partnerDataFuture;

  @override
  void initState() {
    super.initState();
    _partnerDataFuture = Supabase.instance.client
        .from('medical_partners')
        .select(
            'booking_system_type, full_name, closed_days, category, working_hours')
        .eq('id', widget.partnerId)
        .maybeSingle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 60.0,
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 30.0),
          onPressed: () => context.safePop(),
        ),
        title: Text('Book an Appointment',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter', color: Colors.white, fontSize: 22.0)),
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
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Center(
                  child: Text('This partner is not configured for bookings.'));
            }

            final partnerData = snapshot.data!;
            final bookingType =
                partnerData['booking_system_type'] ?? 'time_based';
            final partnerName = partnerData['full_name'] ?? 'this partner';
            final partnerCategory = partnerData['category'];
            final closedDaysRaw =
                partnerData['closed_days'] as List<dynamic>? ?? [];
            final closedDays = closedDaysRaw
                .map((day) => DateTime.parse(day.toString()))
                .toList();
            final workingHours =
                partnerData['working_hours'] as Map<String, dynamic>? ?? {};

            if (bookingType == 'number_based') {
              return _NumberQueueBookingView(
                partnerId: widget.partnerId,
                partnerName: partnerName,
                partnerCategory: partnerCategory,
                isPartnerBooking: widget.isPartnerBooking,
                closedDays: closedDays,
                workingHours: workingHours,
              );
            } else {
              return _TimeSlotBookingView(
                partnerId: widget.partnerId,
                isPartnerBooking: widget.isPartnerBooking,
              );
            }
          },
        ),
      ),
    );
  }
}

class _NumberQueueBookingView extends StatefulWidget {
  const _NumberQueueBookingView({
    required this.partnerId,
    required this.partnerName,
    required this.isPartnerBooking,
    required this.closedDays,
    this.partnerCategory,
    required this.workingHours,
  });
  final String partnerId;
  final String partnerName;
  final bool isPartnerBooking;
  final List<DateTime> closedDays;
  final String? partnerCategory;
  final Map<String, dynamic> workingHours;

  @override
  State<_NumberQueueBookingView> createState() =>
      __NumberQueueBookingViewState();
}

class __NumberQueueBookingViewState extends State<_NumberQueueBookingView> {
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _bookAppointment(
      {String? onBehalfOfName, String? onBehalfOfPhone}) async {
    Map<String, String>? homecareDetails;
    if (widget.partnerCategory == 'Homecare' && !widget.isPartnerBooking) {
      homecareDetails = await showHomecareDetailsDialog(context);
      if (homecareDetails == null) return;
    }

    setState(() => _isLoading = true);
    try {
      final appointmentDateUTC = DateTime.utc(
          _selectedDate.year, _selectedDate.month, _selectedDate.day);

      await Supabase.instance.client.rpc(
        'book_appointment',
        params: {
          'partner_id_arg': widget.partnerId,
          'appointment_time_arg': appointmentDateUTC.toIso8601String(),
          'on_behalf_of_name_arg': onBehalfOfName,
          'on_behalf_of_phone_arg': onBehalfOfPhone,
          'is_partner_override': widget.isPartnerBooking,
          'case_description_arg': homecareDetails?['case_description'],
          'patient_location_arg': homecareDetails?['patient_location'],
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.partnerCategory == 'Homecare'
              ? 'Request sent! Waiting for confirmation.'
              : 'Successfully got a number!'),
          backgroundColor: Colors.green));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Booking failed. Please try again.';
      if (e is PostgrestException && e.message.isNotEmpty) {
        errorMessage = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: FlutterFlowTheme.of(context).error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showBookForPatientDialog() {
    final theme = FlutterFlowTheme.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Book for Patient', style: theme.titleLarge),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Patient's Full Name"),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: "Patient's Phone Number"),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child:
                  Text('Cancel', style: TextStyle(color: theme.secondaryText))),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                await _bookAppointment(
                    onBehalfOfName: nameController.text,
                    onBehalfOfPhone: phoneController.text);
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

    final isDateInClosedDays =
        widget.closedDays.any((d) => isSameDay(d, _selectedDate));

    final dayOfWeekKey = _selectedDate.weekday.toString();
    final isWorkingDay = widget.workingHours.containsKey(dayOfWeekKey);

    final bool isButtonDisabled =
        _isLoading || isDateInClosedDays || !isWorkingDay;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlutterFlowCalendar(
            color: theme.primary,
            iconColor: theme.secondaryText,
            weekFormat: false,
            weekStartsMonday: false,
            rowHeight: 44.0,
            initialDate: _selectedDate,
            onChange: (newSelectedDate) {
              if (newSelectedDate != null) {
                setState(() {
                  _selectedDate = newSelectedDate.start;
                });
              }
            },
            titleStyle: theme.titleLarge,
            dayOfWeekStyle: theme.bodyLarge,
            dateStyle: theme.bodyMedium,
            selectedDateStyle: theme.titleSmall.copyWith(color: Colors.white),
            inactiveDateStyle: theme.labelMedium,
            locale: FFLocalizations.of(context).languageCode,
          ),
        ),
        const Divider(thickness: 1, indent: 16, endIndent: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                    widget.partnerCategory == 'Homecare'
                        ? Icons.medical_services_outlined
                        : Icons.confirmation_number_outlined,
                    size: 60,
                    color: theme.primary),
                const SizedBox(height: 16),
                Text(
                  '${widget.partnerCategory == 'Homecare' ? 'Request a Visit' : 'Get a Number'} for\n${DateFormat.yMMMMd().format(_selectedDate)}',
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "at ${widget.partnerName}",
                  textAlign: TextAlign.center,
                  style: theme.bodyLarge,
                ),
                const Spacer(),
                if (isDateInClosedDays)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'This partner is closed on the selected date.',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.copyWith(color: theme.error),
                    ),
                  )
                else if (!isWorkingDay)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'This partner does not work on the selected day.',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.copyWith(color: theme.error),
                    ),
                  ),
                FFButtonWidget(
                  onPressed: isButtonDisabled
                      ? null
                      : () async {
                          if (widget.isPartnerBooking) {
                            _showBookForPatientDialog();
                          } else {
                            await _bookAppointment();
                          }
                        },
                  text: _isLoading
                      ? 'Submitting...'
                      : (widget.isPartnerBooking
                          ? 'Book for Patient'
                          : (widget.partnerCategory == 'Homecare'
                              ? 'Submit Homecare Request'
                              : 'Get My Number')),
                  options: FFButtonOptions(
                    height: 50,
                    color: theme.primary,
                    textStyle: theme.titleSmall
                        .override(fontFamily: 'Inter', color: Colors.white),
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    disabledColor: theme.alternate,
                    disabledTextColor: theme.secondaryText,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeSlotBookingView extends StatefulWidget {
  const _TimeSlotBookingView(
      {required this.partnerId, required this.isPartnerBooking});
  final String partnerId;
  final bool isPartnerBooking;

  @override
  State<_TimeSlotBookingView> createState() => __TimeSlotBookingViewState();
}

class __TimeSlotBookingViewState extends State<_TimeSlotBookingView> {
  DateTime _selectedDate = DateTime.now();
  int _refreshCounter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlutterFlowCalendar(
            color: theme.primary,
            iconColor: theme.secondaryText,
            weekFormat: false,
            weekStartsMonday: false,
            rowHeight: 44.0,
            initialDate: _selectedDate,
            onChange: (newSelectedDate) {
              if (newSelectedDate != null) {
                setState(() {
                  _selectedDate = newSelectedDate.start;
                });
              }
            },
            titleStyle: theme.titleLarge,
            dayOfWeekStyle: theme.bodyLarge,
            dateStyle: theme.bodyMedium,
            selectedDateStyle: theme.titleSmall.copyWith(color: Colors.white),
            inactiveDateStyle: theme.labelMedium,
            locale: FFLocalizations.of(context).languageCode,
          ),
        ),
        const Divider(thickness: 1, indent: 16, endIndent: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _TimeSlotGrid(
              key: ValueKey(_refreshCounter),
              partnerId: widget.partnerId,
              selectedDate: _selectedDate,
              isPartnerBooking: widget.isPartnerBooking,
              // --- THE FIX: Add a short delay before refreshing the UI ---
              onBookingComplete: () async {
                // This delay gives the database time to commit the transaction
                // before the UI asks for the new list of slots.
                await Future.delayed(const Duration(milliseconds: 400));
                if (mounted) {
                  setState(() => _refreshCounter++);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeSlotGrid extends StatefulWidget {
  const _TimeSlotGrid({
    super.key,
    required this.partnerId,
    required this.selectedDate,
    required this.onBookingComplete,
    required this.isPartnerBooking,
  });

  final String partnerId;
  final DateTime selectedDate;
  final VoidCallback onBookingComplete;
  final bool isPartnerBooking;

  @override
  State<_TimeSlotGrid> createState() => _TimeSlotGridState();
}

class _TimeSlotGridState extends State<_TimeSlotGrid> {
  late Future<List<TimeSlot>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  @override
  void didUpdateWidget(_TimeSlotGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _fetchSlots();
    }
  }

  void _fetchSlots() {
    setState(() {
      _slotsFuture = getAvailableTimeSlots(
        partnerId: widget.partnerId,
        selectedDate: widget.selectedDate,
      );
    });
  }

  void _showBookForPatientDialog(BuildContext context, TimeSlot slot) {
    final theme = FlutterFlowTheme.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Book for Patient', style: theme.titleLarge),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Patient's Full Name"),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: "Patient's Phone Number"),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child:
                  Text('Cancel', style: TextStyle(color: theme.secondaryText))),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                await _bookAppointment(slot,
                    onBehalfOfName: nameController.text,
                    onBehalfOfPhone: phoneController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookAppointment(TimeSlot slot,
      {String? onBehalfOfName, String? onBehalfOfPhone}) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await Supabase.instance.client.rpc(
        'book_appointment',
        params: {
          'partner_id_arg': widget.partnerId,
          'appointment_time_arg': slot.time.toIso8601String(),
          'on_behalf_of_name_arg': onBehalfOfName,
          'on_behalf_of_phone_arg': onBehalfOfPhone,
          'is_partner_override': widget.isPartnerBooking,
          'case_description_arg': null,
          'patient_location_arg': null,
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green));

      widget.onBookingComplete();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      String errorMessage = 'Booking failed. Please try again.';
      if (e is PostgrestException && e.message.isNotEmpty) {
        errorMessage = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: FlutterFlowTheme.of(context).error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimeSlot>>(
      future: _slotsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary)));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Could not load time slots: ${snapshot.error}',
                  style: FlutterFlowTheme.of(context).bodyMedium));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('No available slots for this day.',
                  style: FlutterFlowTheme.of(context).bodyMedium));
        }

        final availableSlots = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 2.5,
          ),
          itemCount: availableSlots.length,
          itemBuilder: (context, index) {
            final slot = availableSlots[index];
            bool isTappable = slot.status == SlotStatus.available;
            Color buttonColor;
            switch (slot.status) {
              case SlotStatus.available:
                buttonColor = FlutterFlowTheme.of(context).primary;
                break;
              case SlotStatus.booked:
                buttonColor = FlutterFlowTheme.of(context).alternate;
                break;
              case SlotStatus.inPast:
                buttonColor = FlutterFlowTheme.of(context).secondaryText;
                break;
            }

            return FFButtonWidget(
              onPressed: isTappable
                  ? () async {
                      if (widget.isPartnerBooking) {
                        _showBookForPatientDialog(context, slot);
                      } else {
                        await _bookAppointment(slot);
                      }
                    }
                  : null,
              text: DateFormat('HH:mm').format(slot.time.toLocal()),
              options: FFButtonOptions(
                height: 40.0,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                iconPadding: const EdgeInsets.all(0),
                color: buttonColor,
                textStyle: FlutterFlowTheme.of(context)
                    .titleSmall
                    .override(fontFamily: 'Inter', color: Colors.white),
                elevation: 2.0,
                borderRadius: BorderRadius.circular(8.0),
                disabledColor: buttonColor,
              ),
            );
          },
        );
      },
    );
  }
}
