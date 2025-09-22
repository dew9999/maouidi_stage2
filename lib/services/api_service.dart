// lib/services/api_service.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SlotStatus { available, booked, inPast }

class TimeSlot {
  final DateTime time;
  // This can be simplified as we now only get available slots, but we keep it for UI consistency
  final SlotStatus status;
  TimeSlot({required this.time, required this.status});
}

// THIS IS THE NEW, HIGHLY-PERFORMANT VERSION
Future<List<TimeSlot>> getAvailableTimeSlots({
  required String partnerId,
  required DateTime selectedDate,
}) async {
  final supabase = Supabase.instance.client;
  // Format the date as 'YYYY-MM-DD' for the database function
  final String dayArg = DateFormat('yyyy-MM-dd').format(selectedDate);

  try {
    // Call our new, powerful database function
    final response = await supabase.rpc('get_available_slots', params: {
      'partner_id_arg': partnerId,
      'day_arg': dayArg,
    });

    // Convert the response into the TimeSlot objects our UI expects
    final List<TimeSlot> availableSlots = (response as List<dynamic>)
        .map((item) => TimeSlot(
              time: DateTime.parse(item['available_slot']),
              status: SlotStatus.available,
            ))
        .toList();

    return availableSlots;
  } catch (error) {
    debugPrint('Error fetching available slots: $error');
    return [];
  }
}
