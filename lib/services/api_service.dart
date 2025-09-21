// lib/services/api_service.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SlotStatus { available, booked, inPast }

class TimeSlot {
  final DateTime time;
  final SlotStatus status;
  TimeSlot({required this.time, required this.status});
}

Future<List<TimeSlot>> getAvailableTimeSlots({
  required String partnerId,
  required DateTime selectedDate,
}) async {
  final supabase = Supabase.instance.client;
  final String dayOfWeekKey = selectedDate.weekday.toString();

  try {
    final partnerData = await supabase
        .from('medical_partners')
        .select(
            'working_hours, appointment_dur, closed_days, booking_system_type')
        .eq('id', partnerId)
        .single();

    if (partnerData['booking_system_type'] == 'number_based') {
      return [];
    }

    final List<dynamic>? closedDays = partnerData['closed_days'];
    final selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);
    if (closedDays != null && closedDays.contains(selectedDateString)) {
      return [];
    }

    final Map<String, dynamic>? workingHours = partnerData['working_hours'];
    if (workingHours == null || !workingHours.containsKey(dayOfWeekKey)) {
      return [];
    }

    final List<dynamic> timeRanges = workingHours[dayOfWeekKey];
    final int duration = partnerData['appointment_dur'];

    // ==================== START: THIS IS THE FIX ====================
    // Create UTC start and end times based on the selected date's components
    // to avoid time zone conversion errors.
    final startOfDayUTC =
        DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDayUTC = DateTime.utc(
        selectedDate.year, selectedDate.month, selectedDate.day + 1);
    // ===================== END: THIS IS THE FIX =====================

    final appointmentsResponse = await supabase
        .from('appointments')
        .select('appointment_time')
        .eq('partner_id', partnerId)
        .gte('appointment_time', startOfDayUTC.toIso8601String())
        .lt('appointment_time', endOfDayUTC.toIso8601String())
        .inFilter('status', ['Pending', 'Confirmed']);

    final List<DateTime> bookedSlots = appointmentsResponse
        .map<DateTime>((item) => DateTime.parse(item['appointment_time']))
        .toList();

    final List<TimeSlot> allSlots = [];
    final nowUTC = DateTime.now().toUtc();

    for (final timeRange in timeRanges) {
      final parts = timeRange.toString().split('-');
      final startTimeStr = parts[0];
      final endTimeStr = parts[1];

      final startTimeLocal = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.parse(startTimeStr.split(':')[0]),
        int.parse(startTimeStr.split(':')[1]),
      );
      DateTime currentSlotTimeUTC = startTimeLocal.toUtc();

      final endTimeLocal = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.parse(endTimeStr.split(':')[0]),
        int.parse(endTimeStr.split(':')[1]),
      );
      DateTime workingEndTimeUTC = endTimeLocal.toUtc();

      while (currentSlotTimeUTC.isBefore(workingEndTimeUTC)) {
        final isBooked = bookedSlots.any(
            (bookedSlot) => bookedSlot.isAtSameMomentAs(currentSlotTimeUTC));
        final isInPast = currentSlotTimeUTC.isBefore(nowUTC);

        SlotStatus status;
        if (isBooked) {
          status = SlotStatus.booked;
        } else if (isInPast) {
          status = SlotStatus.inPast;
        } else {
          status = SlotStatus.available;
        }

        allSlots.add(TimeSlot(time: currentSlotTimeUTC, status: status));
        currentSlotTimeUTC =
            currentSlotTimeUTC.add(Duration(minutes: duration));
      }
    }

    return allSlots;
  } catch (error) {
    debugPrint('Error fetching available slots: $error');
    return [];
  }
}
