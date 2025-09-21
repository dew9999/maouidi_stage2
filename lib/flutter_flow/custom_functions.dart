List<DateTime> getAvailableTimeSlots(
  DateTime selectedDay,
  dynamic workingHours,
  int? appointmentDuration,
  List<DateTime> bookedAppointmentTimes,
  List<DateTime> closedDays,
) {
  print('--- Function Started ---');
  print('Received selectedDay: $selectedDay');
  print('Received workingHours: $workingHours');
  print('Received appointmentDuration: $appointmentDuration');
  print('Received bookedAppointmentTimes: $bookedAppointmentTimes');
  print('Received closedDays: $closedDays');
  // 1. --- Safety Checks & Initial Parsing ---
  if (workingHours == null || appointmentDuration == null) {
    return [];
  }

  // --- Check for Closed Days ---
  final normalizedSelectedDay =
      DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  for (final closedDay in closedDays) {
    final normalizedClosedDay =
        DateTime(closedDay.year, closedDay.month, closedDay.day);
    if (normalizedSelectedDay.isAtSameMomentAs(normalizedClosedDay)) {
      return [];
    }
  }

  // --- Ensure we have a Map ---
  final Map<String, dynamic> workingHoursMap =
      workingHours as Map<String, dynamic>;

  final dayOfWeek = selectedDay.weekday;
  final dayKey = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday'
  }[dayOfWeek];

  if (dayKey == null || !workingHoursMap.containsKey(dayKey)) {
    return [];
  }

  final List<dynamic> periods = workingHoursMap[dayKey];
  final List<DateTime> allPossibleSlots = [];

  // 2. --- Generate All Possible Slots based on Working Hours ---
  for (final period in periods) {
    try {
      final parts = period.split('-');
      final startTimeParts = parts[0].split(':');
      final endTimeParts = parts[1].split(':');

      DateTime slot = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );

      final endTime = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );

      while (slot.isBefore(endTime)) {
        allPossibleSlots.add(slot);
        slot = slot.add(Duration(minutes: appointmentDuration));
      }
    } catch (e) {
      print('Could not parse time period: $period');
    }
  }

  // 3. --- Filter Out Booked Slots ---
  final Set<DateTime> bookedTimes = bookedAppointmentTimes.toSet();

  // Filter out any slots that are already booked or are in the past.
  final now = DateTime.now();
  allPossibleSlots
      .removeWhere((slot) => bookedTimes.contains(slot) || slot.isBefore(now));

  // 4. --- Return the Final List ---
  return allPossibleSlots;
  print('--- Function Finished ---');
  print('Returning these slots: $allPossibleSlots');
}
