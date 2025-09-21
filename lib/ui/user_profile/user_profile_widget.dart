// lib/user_profile/user_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'user_profile';
  static String routePath = '/userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isEditMode = false;
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _model.firstNameTextController ??= TextEditingController();
    _model.lastNameTextController ??= TextEditingController();
    _model.phoneNumberTextController ??= TextEditingController();
    _model.stateValueController ??= FormFieldController<String>(null);
    _model.genderValueController ??= FormFieldController<String>(null);
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('first_name, last_name, phone, state, date_of_birth, gender')
          .eq('id', currentUserUid)
          .single();

      if (mounted) {
        setState(() {
          _model.firstNameTextController!.text = userData['first_name'] ?? '';
          _model.lastNameTextController!.text = userData['last_name'] ?? '';
          _model.phoneNumberTextController!.text = userData['phone'] ?? '';
          _model.stateValueController!.value = userData['state'];
          _model.genderValueController!.value = userData['gender'];
          if (userData['date_of_birth'] != null) {
            _dateOfBirth = DateTime.parse(userData['date_of_birth']);
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.from('users').update({
        'first_name': _model.firstNameTextController!.text,
        'last_name': _model.lastNameTextController!.text,
        'phone': _model.phoneNumberTextController!.text,
        'state': _model.stateValueController!.value,
        'gender': _model.genderValueController!.value,
        'date_of_birth': _dateOfBirth?.toIso8601String(),
      }).eq('id', currentUserUid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ));
        await _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditMode = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Your Profile',
            style: theme.headlineMedium.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done_rounded : Icons.edit_rounded,
                color: Colors.white, size: 28),
            onPressed: () {
              if (_isEditMode) {
                _saveProfileChanges();
              } else {
                setState(() => _isEditMode = true);
              }
            },
            tooltip: _isEditMode ? 'Save Changes' : 'Edit Profile',
          ),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 120,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primary, width: 2),
                        ),
                        child: _getProfileIcon(theme),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _model.firstNameTextController!,
                        label: 'First Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _model.lastNameTextController!,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildDatePickerField(theme),
                      const SizedBox(height: 16),
                      _buildDropDown(
                        controller: _model.genderValueController!,
                        hint: 'Select Gender',
                        options: ['Male', 'Female'],
                        icon: Icons.wc_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _model.phoneNumberTextController!,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Phone number is required.';
                          }
                          final regExp = RegExp(r'^(05|06|07)[0-9]{8}$');
                          if (!regExp.hasMatch(val)) {
                            return 'Must be a 10-digit number starting with 05, 06, or 07.';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropDown(
                        controller: _model.stateValueController!,
                        hint: 'Select State',
                        options: const [
                          'Adrar',
                          'Chlef',
                          'Laghouat',
                          'Oum El Bouaghi',
                          'Batna',
                          'Béjaïa',
                          'Biskra',
                          'Béchar',
                          'Blida',
                          'Bouira',
                          'Tamanrasset',
                          'Tébessa',
                          'Tlemcen',
                          'Tiaret',
                          'Tizi Ouzou',
                          'Alger',
                          'Djelfa',
                          'Jijel',
                          'Sétif',
                          'Saïda',
                          'Skikda',
                          'Sidi Bel Abbès',
                          'Annaba',
                          'Guelma',
                          'Constantine',
                          'Médéa',
                          'Mostaganem',
                          'M\'Sila',
                          'Mascare',
                          'Ouargla',
                          'Oran',
                          'El Bayadh',
                          'Illizi',
                          'Bordj Bou Arreridj',
                          'Boumerdès',
                          'El Tarf',
                          'Tindouf',
                          'Tissemsilt',
                          'Oued souf',
                          'Khenchela',
                          'Souk Ahras',
                          'Tipaza',
                          'Mila',
                          'Aïn Defla',
                          'Naâma',
                          'Aïn Témouchent',
                          'Ghardaïa',
                          'Relizane',
                          'Timimoun',
                          'Bordj Badji Mokhtar',
                          'Ouled Djellal',
                          'Béni Abbès',
                          'In Salah',
                          'AIn Guezzam',
                          'Touggourt',
                          'Djanet',
                          'El M\'Ghair',
                          'El Meniaa'
                        ],
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 32),
                      if (_isEditMode)
                        FFButtonWidget(
                          onPressed: _isSaving ? null : _saveProfileChanges,
                          text: _isSaving ? 'Saving...' : 'Save Changes',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            color: theme.primary,
                            textStyle:
                                theme.titleSmall.copyWith(color: Colors.white),
                            elevation: 3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _getProfileIcon(FlutterFlowTheme theme) {
    IconData iconData;
    if (_model.genderValueController?.value == 'Male') {
      iconData = Icons.male_rounded;
    } else if (_model.genderValueController?.value == 'Female') {
      iconData = Icons.female_rounded;
    } else {
      iconData = Icons.person_rounded;
    }
    return Icon(iconData, size: 80, color: theme.secondaryText);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return TextFormField(
      controller: controller,
      readOnly: !_isEditMode,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.labelMedium,
        prefixIcon: Icon(icon, color: theme.secondaryText),
        filled: true,
        fillColor: _isEditMode ? theme.secondaryBackground : theme.alternate,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primary, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      style: theme.bodyMedium,
    );
  }

  Widget _buildDatePickerField(FlutterFlowTheme theme) {
    return InkWell(
      onTap: !_isEditMode
          ? null
          : () {
              picker.DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1920, 1, 1),
                maxTime: DateTime.now(),
                onConfirm: (date) {
                  setState(() => _dateOfBirth = date);
                },
                currentTime: _dateOfBirth ?? DateTime(2000),
                theme: picker.DatePickerTheme(
                  headerColor: theme.primary,
                  backgroundColor: theme.primaryBackground,
                  itemStyle: TextStyle(color: theme.primaryText, fontSize: 18),
                  doneStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  cancelStyle:
                      const TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            },
      child: AbsorbPointer(
        child: _buildTextField(
          controller: TextEditingController(
              text: _dateOfBirth == null
                  ? ''
                  : DateFormat.yMMMMd().format(_dateOfBirth!)),
          label: 'Date of Birth',
          icon: Icons.calendar_today_outlined,
        ),
      ),
    );
  }

  Widget _buildDropDown({
    required FormFieldController<String> controller,
    required String hint,
    required List<String> options,
    required IconData icon,
  }) {
    final theme = FlutterFlowTheme.of(context);
    // FIX: Rebuilt widget to use FlutterFlowDropDown's own styling properties
    // This is the definitive fix for the background and padding issues.
    return AbsorbPointer(
      absorbing: !_isEditMode,
      child: FlutterFlowDropDown<String>(
        controller: controller,
        options: options,
        onChanged: (val) {
          setState(() => controller.value = val);
        },
        width: double.infinity,
        height: 58,
        textStyle: theme.bodyMedium,
        hintText: hint,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _isEditMode ? theme.secondaryText : Colors.transparent,
          size: 24,
        ),
        fillColor: _isEditMode ? theme.secondaryBackground : theme.alternate,
        elevation: 2,
        borderColor: theme.alternate,
        borderWidth: 2,
        borderRadius: 8,
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        hidesUnderline: true,
      ),
    );
  }
}
