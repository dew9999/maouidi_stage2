// lib/backend/supabase/database/tables/medical_partners.dart

import '../database.dart';

class MedicalPartnersTable extends SupabaseTable<MedicalPartnersRow> {
  @override
  String get tableName => 'medical_partners';

  @override
  MedicalPartnersRow createRow(Map<String, dynamic> data) =>
      MedicalPartnersRow(data);
}

class MedicalPartnersRow extends SupabaseDataRow {
  MedicalPartnersRow(super.data);

  @override
  SupabaseTable get table => MedicalPartnersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get specialty => getField<String>('specialty');
  set specialty(String? value) => setField<String>('specialty', value);

  String get confirmationMode => getField<String>('confirmation_mode')!;
  set confirmationMode(String value) =>
      setField<String>('confirmation_mode', value);

  // --- CORRECTED: Kept as 'dynamic' for consistency with the app ---
  dynamic get workingHours => getField<dynamic>('working_hours');
  set workingHours(dynamic value) => setField<dynamic>('working_hours', value);

  // --- CORRECTED: Changed from List<String> to List<DateTime> for type safety ---
  List<DateTime> get closedDays => getListField<DateTime>('closed_days');
  set closedDays(List<DateTime>? value) =>
      setListField<DateTime>('closed_days', value);

  int? get appointmentDur => getField<int>('appointment_dur');
  set appointmentDur(int? value) => setField<int>('appointment_dur', value);

  double? get averageRating => getField<double>('average_rating');
  set averageRating(double? value) => setField<double>('average_rating', value);

  int? get reviewCount => getField<int>('review_count');
  set reviewCount(int? value) => setField<int>('review_count', value);

  bool? get isVerified => getField<bool>('is_verified');
  set isVerified(bool? value) => setField<bool>('is_verified', value);

  bool? get isFeatured => getField<bool>('is_featured');
  set isFeatured(bool? value) => setField<bool>('is_featured', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get address => getField<String>('address');
  set address(String? value) => setField<String>('address', value);

  String? get nationalIdNumber => getField<String>('national_id_number');
  set nationalIdNumber(String? value) =>
      setField<String>('national_id_number', value);

  String? get medicalLicenseNumber =>
      getField<String>('medical_license_number');
  set medicalLicenseNumber(String? value) =>
      setField<String>('medical_license_number', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  String? get locationUrl => getField<String>('location_url');
  set locationUrl(String? value) => setField<String>('location_url', value);

  String? get bookingSystemType => getField<String>('booking_system_type');
  set bookingSystemType(String? value) =>
      setField<String>('booking_system_type', value);

  int? get dailyBookingLimit => getField<int>('daily_booking_limit');
  set dailyBookingLimit(int? value) =>
      setField<int>('daily_booking_limit', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get parentClinicId => getField<String>('parent_clinic_id');
  set parentClinicId(String? value) =>
      setField<String>('parent_clinic_id', value);

  bool? get notificationsEnabled => getField<bool>('notifications_enabled');
  set notificationsEnabled(bool? value) =>
      setField<bool>('notifications_enabled', value);

  String? get onesignalPlayerId => getField<String>('onesignal_player_id');
  set onesignalPlayerId(String? value) =>
      setField<String>('onesignal_player_id', value);
}
