// ignore_for_file: unnecessary_getters_setters

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MedicalPartnersStruct extends BaseStruct {
  MedicalPartnersStruct({
    String? id,
    String? fullName,
    String? specialty,
    String? confirmationMode,
    WorkingHoursStruct? workingHours,
    List<String>? closedDays,
    int? appointmentDur,
    double? averageRating,
    int? reviewCount,
    bool? isVerified,
    bool? isFeatured,
    String? photoUrl,
  })  : _id = id,
        _fullName = fullName,
        _specialty = specialty,
        _confirmationMode = confirmationMode,
        _workingHours = workingHours,
        _closedDays = closedDays,
        _appointmentDur = appointmentDur,
        _averageRating = averageRating,
        _reviewCount = reviewCount,
        _isVerified = isVerified,
        _isFeatured = isFeatured,
        _photoUrl = photoUrl;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "full_name" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "specialty" field.
  String? _specialty;
  String get specialty => _specialty ?? '';
  set specialty(String? val) => _specialty = val;

  bool hasSpecialty() => _specialty != null;

  // "confirmation_mode" field.
  String? _confirmationMode;
  String get confirmationMode => _confirmationMode ?? '';
  set confirmationMode(String? val) => _confirmationMode = val;

  bool hasConfirmationMode() => _confirmationMode != null;

  // "working_hours" field.
  WorkingHoursStruct? _workingHours;
  WorkingHoursStruct get workingHours => _workingHours ?? WorkingHoursStruct();
  set workingHours(WorkingHoursStruct? val) => _workingHours = val;

  void updateWorkingHours(Function(WorkingHoursStruct) updateFn) {
    updateFn(_workingHours ??= WorkingHoursStruct());
  }

  bool hasWorkingHours() => _workingHours != null;

  // "closed_days" field.
  List<String>? _closedDays;
  List<String> get closedDays => _closedDays ?? const [];
  set closedDays(List<String>? val) => _closedDays = val;

  void updateClosedDays(Function(List<String>) updateFn) {
    updateFn(_closedDays ??= []);
  }

  bool hasClosedDays() => _closedDays != null;

  // "appointment_dur" field.
  int? _appointmentDur;
  int get appointmentDur => _appointmentDur ?? 0;
  set appointmentDur(int? val) => _appointmentDur = val;

  void incrementAppointmentDur(int amount) =>
      appointmentDur = appointmentDur + amount;

  bool hasAppointmentDur() => _appointmentDur != null;

  // "average_rating" field.
  double? _averageRating;
  double get averageRating => _averageRating ?? 0.0;
  set averageRating(double? val) => _averageRating = val;

  void incrementAverageRating(double amount) =>
      averageRating = averageRating + amount;

  bool hasAverageRating() => _averageRating != null;

  // "review_count" field.
  int? _reviewCount;
  int get reviewCount => _reviewCount ?? 0;
  set reviewCount(int? val) => _reviewCount = val;

  void incrementReviewCount(int amount) => reviewCount = reviewCount + amount;

  bool hasReviewCount() => _reviewCount != null;

  // "is_verified" field.
  bool? _isVerified;
  bool get isVerified => _isVerified ?? false;
  set isVerified(bool? val) => _isVerified = val;

  bool hasIsVerified() => _isVerified != null;

  // "is_featured" field.
  bool? _isFeatured;
  bool get isFeatured => _isFeatured ?? false;
  set isFeatured(bool? val) => _isFeatured = val;

  bool hasIsFeatured() => _isFeatured != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  set photoUrl(String? val) => _photoUrl = val;

  bool hasPhotoUrl() => _photoUrl != null;

  static MedicalPartnersStruct fromMap(Map<String, dynamic> data) =>
      MedicalPartnersStruct(
        id: data['id'] as String?,
        fullName: data['full_name'] as String?,
        specialty: data['specialty'] as String?,
        confirmationMode: data['confirmation_mode'] as String?,
        workingHours: data['working_hours'] is WorkingHoursStruct
            ? data['working_hours']
            : WorkingHoursStruct.maybeFromMap(data['working_hours']),
        closedDays: getDataList(data['closed_days']),
        appointmentDur: castToType<int>(data['appointment_dur']),
        averageRating: castToType<double>(data['average_rating']),
        reviewCount: castToType<int>(data['review_count']),
        isVerified: data['is_verified'] as bool?,
        isFeatured: data['is_featured'] as bool?,
        photoUrl: data['photo_url'] as String?,
      );

  static MedicalPartnersStruct? maybeFromMap(dynamic data) => data is Map
      ? MedicalPartnersStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'full_name': _fullName,
        'specialty': _specialty,
        'confirmation_mode': _confirmationMode,
        'working_hours': _workingHours?.toMap(),
        'closed_days': _closedDays,
        'appointment_dur': _appointmentDur,
        'average_rating': _averageRating,
        'review_count': _reviewCount,
        'is_verified': _isVerified,
        'is_featured': _isFeatured,
        'photo_url': _photoUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'full_name': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'specialty': serializeParam(
          _specialty,
          ParamType.String,
        ),
        'confirmation_mode': serializeParam(
          _confirmationMode,
          ParamType.String,
        ),
        'working_hours': serializeParam(
          _workingHours,
          ParamType.DataStruct,
        ),
        'closed_days': serializeParam(
          _closedDays,
          ParamType.String,
          isList: true,
        ),
        'appointment_dur': serializeParam(
          _appointmentDur,
          ParamType.int,
        ),
        'average_rating': serializeParam(
          _averageRating,
          ParamType.double,
        ),
        'review_count': serializeParam(
          _reviewCount,
          ParamType.int,
        ),
        'is_verified': serializeParam(
          _isVerified,
          ParamType.bool,
        ),
        'is_featured': serializeParam(
          _isFeatured,
          ParamType.bool,
        ),
        'photo_url': serializeParam(
          _photoUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static MedicalPartnersStruct fromSerializableMap(Map<String, dynamic> data) =>
      MedicalPartnersStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        fullName: deserializeParam(
          data['full_name'],
          ParamType.String,
          false,
        ),
        specialty: deserializeParam(
          data['specialty'],
          ParamType.String,
          false,
        ),
        confirmationMode: deserializeParam(
          data['confirmation_mode'],
          ParamType.String,
          false,
        ),
        workingHours: deserializeStructParam(
          data['working_hours'],
          ParamType.DataStruct,
          false,
          structBuilder: WorkingHoursStruct.fromSerializableMap,
        ),
        closedDays: deserializeParam<String>(
          data['closed_days'],
          ParamType.String,
          true,
        ),
        appointmentDur: deserializeParam(
          data['appointment_dur'],
          ParamType.int,
          false,
        ),
        averageRating: deserializeParam(
          data['average_rating'],
          ParamType.double,
          false,
        ),
        reviewCount: deserializeParam(
          data['review_count'],
          ParamType.int,
          false,
        ),
        isVerified: deserializeParam(
          data['is_verified'],
          ParamType.bool,
          false,
        ),
        isFeatured: deserializeParam(
          data['is_featured'],
          ParamType.bool,
          false,
        ),
        photoUrl: deserializeParam(
          data['photo_url'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'MedicalPartnersStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MedicalPartnersStruct &&
        id == other.id &&
        fullName == other.fullName &&
        specialty == other.specialty &&
        confirmationMode == other.confirmationMode &&
        workingHours == other.workingHours &&
        listEquality.equals(closedDays, other.closedDays) &&
        appointmentDur == other.appointmentDur &&
        averageRating == other.averageRating &&
        reviewCount == other.reviewCount &&
        isVerified == other.isVerified &&
        isFeatured == other.isFeatured &&
        photoUrl == other.photoUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        fullName,
        specialty,
        confirmationMode,
        workingHours,
        closedDays,
        appointmentDur,
        averageRating,
        reviewCount,
        isVerified,
        isFeatured,
        photoUrl
      ]);
}

MedicalPartnersStruct createMedicalPartnersStruct({
  String? id,
  String? fullName,
  String? specialty,
  String? confirmationMode,
  WorkingHoursStruct? workingHours,
  int? appointmentDur,
  double? averageRating,
  int? reviewCount,
  bool? isVerified,
  bool? isFeatured,
  String? photoUrl,
}) =>
    MedicalPartnersStruct(
      id: id,
      fullName: fullName,
      specialty: specialty,
      confirmationMode: confirmationMode,
      workingHours: workingHours ?? WorkingHoursStruct(),
      appointmentDur: appointmentDur,
      averageRating: averageRating,
      reviewCount: reviewCount,
      isVerified: isVerified,
      isFeatured: isFeatured,
      photoUrl: photoUrl,
    );
