import '../database.dart';

class ReviewsTable extends SupabaseTable<ReviewsRow> {
  @override
  String get tableName => 'reviews';

  @override
  ReviewsRow createRow(Map<String, dynamic> data) => ReviewsRow(data);
}

class ReviewsRow extends SupabaseDataRow {
  ReviewsRow(super.data);

  @override
  SupabaseTable get table => ReviewsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get partnerId => getField<String>('partner_id')!;
  set partnerId(String value) => setField<String>('partner_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int get appointmentId => getField<int>('appointment_id')!;
  set appointmentId(int value) => setField<int>('appointment_id', value);

  double get rating => getField<double>('rating')!;
  set rating(double value) => setField<double>('rating', value);

  String? get reviewText => getField<String>('review_text');
  set reviewText(String? value) => setField<String>('review_text', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
