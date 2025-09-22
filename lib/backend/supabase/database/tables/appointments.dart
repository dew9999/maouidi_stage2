// lib/backend/supabase/database/tables/appointments.dart

import '../database.dart';

class AppointmentsTable extends SupabaseTable<AppointmentsRow> {
  @override
  String get tableName => 'appointments';

  @override
  AppointmentsRow createRow(Map<String, dynamic> data) => AppointmentsRow(data);
}

class AppointmentsRow extends SupabaseDataRow {
  AppointmentsRow(super.data);

  @override
  SupabaseTable get table => AppointmentsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get partnerId => getField<String>('partner_id')!;
  set partnerId(String value) => setField<String>('partner_id', value);

  String get bookingUserId => getField<String>('booking_user_id')!;
  set bookingUserId(String value) => setField<String>('booking_user_id', value);

  String? get onBehalfOfPatientName =>
      getField<String>('on_behalf_of_patient_name');
  set onBehalfOfPatientName(String? value) =>
      setField<String>('on_behalf_of_patient_name', value);

  DateTime get appointmentTime => getField<DateTime>('appointment_time')!;
  set appointmentTime(DateTime value) =>
      setField<DateTime>('appointment_time', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  // --- ADDED MISSING FIELDS ---
  String? get onBehalfOfPatientPhone =>
      getField<String>('on_behalf_of_patient_phone');
  set onBehalfOfPatientPhone(String? value) =>
      setField<String>('on_behalf_of_patient_phone', value);

  int? get appointmentNumber => getField<int>('appointment_number');
  set appointmentNumber(int? value) =>
      setField<int>('appointment_number', value);

  bool? get isRescheduled => getField<bool>('is_rescheduled');
  set isRescheduled(bool? value) => setField<bool>('is_rescheduled', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  bool? get hasReview => getField<bool>('has_review');
  set hasReview(bool? value) => setField<bool>('has_review', value);

  String? get caseDescription => getField<String>('case_description');
  set caseDescription(String? value) =>
      setField<String>('case_description', value);

  String? get patientLocation => getField<String>('patient_location');
  set patientLocation(String? value) =>
      setField<String>('patient_location', value);
  // -------------------------
}
