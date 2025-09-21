// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WorkingHoursStruct extends BaseStruct {
  WorkingHoursStruct({
    List<String>? saturday,
    List<String>? sunday,
    List<String>? monday,
    List<String>? tuesday,
    List<String>? wednesday,
    List<String>? thursday,
    List<String>? friday,
  })  : _saturday = saturday,
        _sunday = sunday,
        _monday = monday,
        _tuesday = tuesday,
        _wednesday = wednesday,
        _thursday = thursday,
        _friday = friday;

  // "Saturday" field.
  List<String>? _saturday;
  List<String> get saturday => _saturday ?? const [];
  set saturday(List<String>? val) => _saturday = val;

  void updateSaturday(Function(List<String>) updateFn) {
    updateFn(_saturday ??= []);
  }

  bool hasSaturday() => _saturday != null;

  // "Sunday" field.
  List<String>? _sunday;
  List<String> get sunday => _sunday ?? const [];
  set sunday(List<String>? val) => _sunday = val;

  void updateSunday(Function(List<String>) updateFn) {
    updateFn(_sunday ??= []);
  }

  bool hasSunday() => _sunday != null;

  // "Monday" field.
  List<String>? _monday;
  List<String> get monday => _monday ?? const [];
  set monday(List<String>? val) => _monday = val;

  void updateMonday(Function(List<String>) updateFn) {
    updateFn(_monday ??= []);
  }

  bool hasMonday() => _monday != null;

  // "Tuesday" field.
  List<String>? _tuesday;
  List<String> get tuesday => _tuesday ?? const [];
  set tuesday(List<String>? val) => _tuesday = val;

  void updateTuesday(Function(List<String>) updateFn) {
    updateFn(_tuesday ??= []);
  }

  bool hasTuesday() => _tuesday != null;

  // "Wednesday" field.
  List<String>? _wednesday;
  List<String> get wednesday => _wednesday ?? const [];
  set wednesday(List<String>? val) => _wednesday = val;

  void updateWednesday(Function(List<String>) updateFn) {
    updateFn(_wednesday ??= []);
  }

  bool hasWednesday() => _wednesday != null;

  // "Thursday" field.
  List<String>? _thursday;
  List<String> get thursday => _thursday ?? const [];
  set thursday(List<String>? val) => _thursday = val;

  void updateThursday(Function(List<String>) updateFn) {
    updateFn(_thursday ??= []);
  }

  bool hasThursday() => _thursday != null;

  // "Friday" field.
  List<String>? _friday;
  List<String> get friday => _friday ?? const [];
  set friday(List<String>? val) => _friday = val;

  void updateFriday(Function(List<String>) updateFn) {
    updateFn(_friday ??= []);
  }

  bool hasFriday() => _friday != null;

  static WorkingHoursStruct fromMap(Map<String, dynamic> data) =>
      WorkingHoursStruct(
        saturday: getDataList(data['Saturday']),
        sunday: getDataList(data['Sunday']),
        monday: getDataList(data['Monday']),
        tuesday: getDataList(data['Tuesday']),
        wednesday: getDataList(data['Wednesday']),
        thursday: getDataList(data['Thursday']),
        friday: getDataList(data['Friday']),
      );

  static WorkingHoursStruct? maybeFromMap(dynamic data) => data is Map
      ? WorkingHoursStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'Saturday': _saturday,
        'Sunday': _sunday,
        'Monday': _monday,
        'Tuesday': _tuesday,
        'Wednesday': _wednesday,
        'Thursday': _thursday,
        'Friday': _friday,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'Saturday': serializeParam(
          _saturday,
          ParamType.String,
          isList: true,
        ),
        'Sunday': serializeParam(
          _sunday,
          ParamType.String,
          isList: true,
        ),
        'Monday': serializeParam(
          _monday,
          ParamType.String,
          isList: true,
        ),
        'Tuesday': serializeParam(
          _tuesday,
          ParamType.String,
          isList: true,
        ),
        'Wednesday': serializeParam(
          _wednesday,
          ParamType.String,
          isList: true,
        ),
        'Thursday': serializeParam(
          _thursday,
          ParamType.String,
          isList: true,
        ),
        'Friday': serializeParam(
          _friday,
          ParamType.String,
          isList: true,
        ),
      }.withoutNulls;

  static WorkingHoursStruct fromSerializableMap(Map<String, dynamic> data) =>
      WorkingHoursStruct(
        saturday: deserializeParam<String>(
          data['Saturday'],
          ParamType.String,
          true,
        ),
        sunday: deserializeParam<String>(
          data['Sunday'],
          ParamType.String,
          true,
        ),
        monday: deserializeParam<String>(
          data['Monday'],
          ParamType.String,
          true,
        ),
        tuesday: deserializeParam<String>(
          data['Tuesday'],
          ParamType.String,
          true,
        ),
        wednesday: deserializeParam<String>(
          data['Wednesday'],
          ParamType.String,
          true,
        ),
        thursday: deserializeParam<String>(
          data['Thursday'],
          ParamType.String,
          true,
        ),
        friday: deserializeParam<String>(
          data['Friday'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'WorkingHoursStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is WorkingHoursStruct &&
        listEquality.equals(saturday, other.saturday) &&
        listEquality.equals(sunday, other.sunday) &&
        listEquality.equals(monday, other.monday) &&
        listEquality.equals(tuesday, other.tuesday) &&
        listEquality.equals(wednesday, other.wednesday) &&
        listEquality.equals(thursday, other.thursday) &&
        listEquality.equals(friday, other.friday);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([saturday, sunday, monday, tuesday, wednesday, thursday, friday]);
}

WorkingHoursStruct createWorkingHoursStruct() => WorkingHoursStruct();
