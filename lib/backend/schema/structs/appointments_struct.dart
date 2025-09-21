// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AppointmentsStruct extends BaseStruct {
  AppointmentsStruct({
    int? id,
    String? partnerId,
    String? bookingUserId,
    String? onBehalfOfPatientName,
    String? appointmentTime,
    String? status,
  })  : _id = id,
        _partnerId = partnerId,
        _bookingUserId = bookingUserId,
        _onBehalfOfPatientName = onBehalfOfPatientName,
        _appointmentTime = appointmentTime,
        _status = status;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "partner_id" field.
  String? _partnerId;
  String get partnerId => _partnerId ?? '';
  set partnerId(String? val) => _partnerId = val;

  bool hasPartnerId() => _partnerId != null;

  // "booking_user_id" field.
  String? _bookingUserId;
  String get bookingUserId => _bookingUserId ?? '';
  set bookingUserId(String? val) => _bookingUserId = val;

  bool hasBookingUserId() => _bookingUserId != null;

  // "on_behalf_of_patient_name" field.
  String? _onBehalfOfPatientName;
  String get onBehalfOfPatientName => _onBehalfOfPatientName ?? '';
  set onBehalfOfPatientName(String? val) => _onBehalfOfPatientName = val;

  bool hasOnBehalfOfPatientName() => _onBehalfOfPatientName != null;

  // "appointment_time" field.
  String? _appointmentTime;
  String get appointmentTime => _appointmentTime ?? '';
  set appointmentTime(String? val) => _appointmentTime = val;

  bool hasAppointmentTime() => _appointmentTime != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  set status(String? val) => _status = val;

  bool hasStatus() => _status != null;

  static AppointmentsStruct fromMap(Map<String, dynamic> data) =>
      AppointmentsStruct(
        id: castToType<int>(data['id']),
        partnerId: data['partner_id'] as String?,
        bookingUserId: data['booking_user_id'] as String?,
        onBehalfOfPatientName: data['on_behalf_of_patient_name'] as String?,
        appointmentTime: data['appointment_time'] as String?,
        status: data['status'] as String?,
      );

  static AppointmentsStruct? maybeFromMap(dynamic data) => data is Map
      ? AppointmentsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'partner_id': _partnerId,
        'booking_user_id': _bookingUserId,
        'on_behalf_of_patient_name': _onBehalfOfPatientName,
        'appointment_time': _appointmentTime,
        'status': _status,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'partner_id': serializeParam(
          _partnerId,
          ParamType.String,
        ),
        'booking_user_id': serializeParam(
          _bookingUserId,
          ParamType.String,
        ),
        'on_behalf_of_patient_name': serializeParam(
          _onBehalfOfPatientName,
          ParamType.String,
        ),
        'appointment_time': serializeParam(
          _appointmentTime,
          ParamType.String,
        ),
        'status': serializeParam(
          _status,
          ParamType.String,
        ),
      }.withoutNulls;

  static AppointmentsStruct fromSerializableMap(Map<String, dynamic> data) =>
      AppointmentsStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        partnerId: deserializeParam(
          data['partner_id'],
          ParamType.String,
          false,
        ),
        bookingUserId: deserializeParam(
          data['booking_user_id'],
          ParamType.String,
          false,
        ),
        onBehalfOfPatientName: deserializeParam(
          data['on_behalf_of_patient_name'],
          ParamType.String,
          false,
        ),
        appointmentTime: deserializeParam(
          data['appointment_time'],
          ParamType.String,
          false,
        ),
        status: deserializeParam(
          data['status'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'AppointmentsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AppointmentsStruct &&
        id == other.id &&
        partnerId == other.partnerId &&
        bookingUserId == other.bookingUserId &&
        onBehalfOfPatientName == other.onBehalfOfPatientName &&
        appointmentTime == other.appointmentTime &&
        status == other.status;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        partnerId,
        bookingUserId,
        onBehalfOfPatientName,
        appointmentTime,
        status
      ]);
}

AppointmentsStruct createAppointmentsStruct({
  int? id,
  String? partnerId,
  String? bookingUserId,
  String? onBehalfOfPatientName,
  String? appointmentTime,
  String? status,
}) =>
    AppointmentsStruct(
      id: id,
      partnerId: partnerId,
      bookingUserId: bookingUserId,
      onBehalfOfPatientName: onBehalfOfPatientName,
      appointmentTime: appointmentTime,
      status: status,
    );
