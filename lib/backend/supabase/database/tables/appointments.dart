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
}
