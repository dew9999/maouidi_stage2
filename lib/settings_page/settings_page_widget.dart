// lib/settings_page/settings_page_widget.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/supabase_auth/auth_util.dart';
import '../../core/constants.dart';
import '../../backend/supabase/supabase.dart';
import '../../flutter_flow/flutter_flow_drop_down.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/form_field_controller.dart';
import '../../index.dart';
import '../../main.dart';
import '../../pages/privacy_policy_page.dart';
import '../../pages/terms_of_service_page.dart';
import 'components/settings_group.dart';
import 'components/settings_item.dart';
import 'components/become_partner_dialog.dart';
import 'components/profile_card.dart';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});
  static String routeName = 'SettingsPage';
  static String routePath = '/settingsPage';

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  // --- DELETED: The Future and fetch method are no longer needed ---

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // --- MODIFIED: Read the user role directly from the AppStateNotifier ---
    final userRole = AppStateNotifier.instance.userRole;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Settings',
            style: theme.headlineMedium.override(fontFamily: 'Inter')),
        centerTitle: true,
      ),
      // --- MODIFIED: Removed the FutureBuilder ---
      body: userRole == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading if role isn't ready
          : userRole == 'Medical Partner'
              ? _PartnerSettingsView()
              : _PatientSettingsView(),
    );
  }
}

// =====================================================================
// The rest of the file (_PatientSettingsView, _PartnerSettingsView, etc.)
// remains exactly the same. Only the _SettingsPageWidgetState was modified.
// =====================================================================

// =====================================================================
//                       PATIENT SETTINGS VIEW
// =====================================================================

class _PatientSettingsView extends StatefulWidget {
  @override
  State<_PatientSettingsView> createState() => _PatientSettingsViewState();
}

class _PatientSettingsViewState extends State<_PatientSettingsView> {
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('first_name, last_name, notifications_enabled')
          .eq('id', currentUserUid)
          .single();

      if (mounted) {
        setState(() {
          _userName =
              '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
                  .trim();
          _userEmail = currentUserEmail;
          _notificationsEnabled = userData['notifications_enabled'] ?? true;
        });
      }
    } catch (e) {
      debugPrint("Error loading patient data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationPreference(bool isEnabled) async {
    try {
      await Supabase.instance.client.from('users').update(
          {'notifications_enabled': isEnabled}).eq('id', currentUserUid);
    } catch (e) {
      debugPrint('Error updating notification preference: $e');
      if (mounted) {
        setState(() => _notificationsEnabled = !isEnabled);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          ProfileCard(
            name: _userName,
            email: _userEmail,
            onTap: () => context.pushNamed(UserProfileWidget.routeName),
          ),
          SettingsGroup(
            title: 'Notifications',
            children: [
              SettingsItem(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts for your appointments',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  activeTrackColor: theme.primary,
                  onChanged: (newValue) {
                    setState(() => _notificationsEnabled = newValue);
                    _updateNotificationPreference(newValue);
                  },
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'General',
            children: [
              SettingsItem(
                icon: Icons.translate_rounded,
                title: 'Language',
                trailing: DropdownButton<String>(
                  value: Localizations.localeOf(context).languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                  ],
                  onChanged: (String? languageCode) {
                    if (languageCode != null) {
                      MyApp.of(context).setLocale(languageCode);
                    }
                  },
                  underline: const SizedBox.shrink(),
                ),
              ),
              SettingsItem(
                icon: Icons.brightness_6_outlined,
                title: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: isDarkMode,
                  activeTrackColor: theme.primary,
                  onChanged: (isDarkMode) {
                    final newMode =
                        isDarkMode ? ThemeMode.dark : ThemeMode.light;
                    MyApp.of(context).setThemeMode(newMode);
                  },
                ),
              ),
              SettingsItem(
                icon: Icons.contact_support_outlined,
                title: 'Contact Us',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showContactUsDialog(context),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Account & Legal',
            children: [
              SettingsItem(
                icon: Icons.work_outline,
                title: 'Become a Partner',
                subtitle: 'List your services on Maouidi',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => BecomePartnerDialog(
                    currentDisplayName: currentUserDisplayName,
                    currentPhoneNumber: currentPhoneNumber,
                  ),
                ),
              ),
              SettingsItem(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.pushNamed(PrivacyPolicyPage.routeName),
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.pushNamed(TermsOfServicePage.routeName),
              ),
              SettingsItem(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                iconColor: theme.error,
                iconBackgroundColor: theme.error.withAlpha(25),
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: FFButtonWidget(
              onPressed: () async {
                await authManager.signOut();
                AppStateNotifier.instance.clearRedirectLocation();
                await Future.delayed(const Duration(milliseconds: 50));
                if (context.mounted) {
                  GoRouter.of(context).go(WelcomeScreenWidget.routePath);
                }
              },
              text: 'Log Out',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: theme.error,
                textStyle: theme.titleSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//                       PARTNER SETTINGS VIEW
// =====================================================================

class _PartnerSettingsView extends StatefulWidget {
  @override
  State<_PartnerSettingsView> createState() => _PartnerSettingsViewState();
}

class _PartnerSettingsViewState extends State<_PartnerSettingsView> {
  bool _isLoading = true;
  bool _isSaving = false;
  late FormFieldController<String> _specialtyController;
  late FormFieldController<String> _clinicController;
  String _fullName = '';
  String _category = '';
  late String _confirmationMode;
  late String _bookingSystemType;
  late TextEditingController _limitController;
  late Map<String, List<String>> _workingHours;
  late List<DateTime> _closedDays;
  late bool _isActive;
  bool _notificationsEnabled = true;
  List<MedicalPartnersRow> _clinics = [];

  @override
  void initState() {
    super.initState();
    _specialtyController = FormFieldController<String>(null);
    _clinicController = FormFieldController<String>(null);
    _confirmationMode = 'auto';
    _bookingSystemType = 'time_based';
    _limitController = TextEditingController(text: '20');
    _workingHours = {};
    _closedDays = [];
    _isActive = true;
    _loadPartnerData();
    _fetchClinics();
  }

  Future<void> _fetchClinics() async {
    try {
      final clinicsData = await MedicalPartnersTable().queryRows(
        queryFn: (q) => q.eq('category', 'Clinics').select('id, full_name'),
      );
      if (mounted) {
        setState(() {
          _clinics = clinicsData;
        });
      }
    } catch (e) {
      debugPrint('Error fetching clinics: $e');
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    _specialtyController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  Future<void> _loadPartnerData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('medical_partners')
          .select(
              'full_name, specialty, category, parent_clinic_id, confirmation_mode, booking_system_type, daily_booking_limit, working_hours, closed_days, is_active, notifications_enabled')
          .eq('id', currentUserUid)
          .single();
      if (mounted) {
        setState(() {
          _fullName = data['full_name'] ?? '';
          _specialtyController.value = data['specialty'];
          _category = data['category'] ?? '';
          _clinicController.value = data['parent_clinic_id'];
          _confirmationMode = data['confirmation_mode'] ?? 'auto';

          if (_category == 'Homecare') {
            _bookingSystemType = 'number_based';
          } else {
            _bookingSystemType = data['booking_system_type'] ?? 'time_based';
          }

          _limitController.text =
              (data['daily_booking_limit'] ?? 20).toString();
          _isActive = data['is_active'] ?? true;
          _notificationsEnabled = data['notifications_enabled'] ?? true;
          if (data['working_hours'] != null) {
            final initialData = data['working_hours'];
            final Map<String, List<String>> cleanedData = {};
            final Map<String, String> dayNameToKey = {
              'Monday': '1',
              'Tuesday': '2',
              'Wednesday': '3',
              'Thursday': '4',
              'Friday': '5',
              'Saturday': '6',
              'Sunday': '7',
            };
            (initialData as Map).forEach((key, value) {
              if (int.tryParse(key) != null &&
                  int.parse(key) >= 1 &&
                  int.parse(key) <= 7) {
                cleanedData[key] = List<String>.from(value);
              } else if (dayNameToKey.containsKey(key)) {
                final correctKey = dayNameToKey[key]!;
                if (!cleanedData.containsKey(correctKey)) {
                  cleanedData[correctKey] = List<String>.from(value);
                }
              }
            });
            _workingHours = cleanedData;
          }
          if (data['closed_days'] != null) {
            _closedDays = (data['closed_days'] as List)
                .map((d) => DateTime.parse(d.toString()))
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading partner data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationPreference(bool isEnabled) async {
    try {
      await Supabase.instance.client.from('medical_partners').update(
          {'notifications_enabled': isEnabled}).eq('id', currentUserUid);
    } catch (e) {
      debugPrint('Error updating notification preference: $e');
      if (mounted) {
        setState(() => _notificationsEnabled = !isEnabled);
      }
    }
  }

  Future<void> _saveAllSettings() async {
    if (!mounted) return;
    setState(() => _isSaving = true);
    try {
      final formattedClosedDays =
          _closedDays.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();

      final finalBookingSystemType =
          _category == 'Homecare' ? 'number_based' : _bookingSystemType;

      final dynamic finalWorkingHours =
          _workingHours.isEmpty ? null : _workingHours;

      await Supabase.instance.client.from('medical_partners').update({
        'specialty': _specialtyController.value,
        'parent_clinic_id': _clinicController.value,
        'confirmation_mode': _confirmationMode,
        'booking_system_type': finalBookingSystemType,
        'daily_booking_limit': int.tryParse(_limitController.text) ?? 20,
        'working_hours': finalWorkingHours,
        'closed_days': formattedClosedDays,
        'is_active': _isActive,
      }).eq('id', currentUserUid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save settings: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final isDoctor = _category != 'Clinics' && _category != 'Charities';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          ProfileCard(
            name: _fullName,
            email: currentUserEmail,
            onTap: () => context.pushNamed(
              PartnerProfilePageWidget.routeName,
              queryParameters: {'partnerId': currentUserUid}.withoutNulls,
            ),
          ),
          if (isDoctor)
            SettingsGroup(
              title: 'Professional Details',
              children: [
                SettingsItem(
                  icon: Icons.medical_services_outlined,
                  title: 'Specialty',
                  trailing: SizedBox(
                    width: 180,
                    child: FlutterFlowDropDown<String>(
                      controller: _specialtyController,
                      options: medicalSpecialties,
                      onChanged: (val) =>
                          setState(() => _specialtyController.value = val),
                      textStyle: theme.bodyMedium
                          .copyWith(overflow: TextOverflow.ellipsis),
                      hintText: 'Select...',
                      fillColor: theme.secondaryBackground,
                      elevation: 2,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      borderRadius: 8,
                      margin: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                      hidesUnderline: true,
                    ),
                  ),
                ),
                SettingsItem(
                  icon: Icons.apartment_outlined,
                  title: 'Clinic',
                  trailing: SizedBox(
                    width: 180,
                    child: FlutterFlowDropDown<String>(
                      controller: _clinicController,
                      options: ['None', ..._clinics.map((c) => c.id)],
                      optionLabels: [
                        'None',
                        ..._clinics.map((c) => c.fullName ?? 'Unnamed Clinic')
                      ],
                      onChanged: (val) => setState(() =>
                          _clinicController.value = val == 'None' ? null : val),
                      textStyle: theme.bodyMedium
                          .copyWith(overflow: TextOverflow.ellipsis),
                      hintText: 'Select...',
                      fillColor: theme.secondaryBackground,
                      elevation: 2,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      borderRadius: 8,
                      margin: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                      hidesUnderline: true,
                    ),
                  ),
                ),
              ],
            ),
          SettingsGroup(
            title: 'Booking Configuration',
            children: [
              SettingsItem(
                icon: Icons.toggle_on_outlined,
                title: 'Accepting Appointments',
                subtitle: _isActive ? 'You are open' : 'You are closed',
                trailing: Switch.adaptive(
                  value: _isActive,
                  activeTrackColor: theme.primary,
                  onChanged: (newValue) => setState(() => _isActive = newValue),
                ),
              ),
              SettingsItem(
                icon: Icons.approval_outlined,
                title: 'Confirmation Mode',
                subtitle: _confirmationMode == 'auto'
                    ? 'Auto-Confirm'
                    : 'Manual Confirm',
                trailing: SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: theme.primaryBackground,
                  ),
                  segments: const [
                    ButtonSegment(value: 'auto', label: Text('Auto')),
                    ButtonSegment(value: 'manual', label: Text('Manual')),
                  ],
                  selected: {_confirmationMode},
                  onSelectionChanged: (newSelection) =>
                      setState(() => _confirmationMode = newSelection.first),
                ),
              ),
              SettingsItem(
                icon: Icons.people_outline,
                title: 'Booking System',
                subtitle: _bookingSystemType == 'time_based'
                    ? 'Time Slots'
                    : 'Queue Numbers',
                trailing: _category == 'Homecare'
                    ? Text(
                        'Queue (Required)',
                        style: theme.bodyMedium
                            .copyWith(color: theme.secondaryText),
                      )
                    : SegmentedButton<String>(
                        style: SegmentedButton.styleFrom(
                          backgroundColor: theme.primaryBackground,
                        ),
                        segments: const [
                          ButtonSegment(
                              value: 'time_based', label: Text('Slots')),
                          ButtonSegment(
                              value: 'number_based', label: Text('Queue')),
                        ],
                        selected: {_bookingSystemType},
                        onSelectionChanged: (newSelection) => setState(
                            () => _bookingSystemType = newSelection.first),
                      ),
              ),
              if (_bookingSystemType == 'number_based')
                SettingsItem(
                  icon: Icons.pin_outlined,
                  title: 'Daily Patient Limit',
                  trailing: SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _limitController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'e.g., 20',
                          hintStyle: theme.labelMedium),
                    ),
                  ),
                ),
            ],
          ),
          SettingsGroup(title: "Your Availability", children: [
            _WorkingHoursEditor(
              initialHours: _workingHours,
              onChanged: (newHours) => setState(() => _workingHours = newHours),
            ),
            _ClosedDaysEditor(
              initialDays: _closedDays,
              onChanged: (newDays) => setState(() => _closedDays = newDays),
            ),
          ]),
          SettingsGroup(
            title: "Actions",
            children: [_EmergencyCard()],
          ),
          SettingsGroup(
            title: 'Notifications',
            children: [
              SettingsItem(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts for new bookings',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  activeTrackColor: theme.primary,
                  onChanged: (newValue) {
                    setState(() => _notificationsEnabled = newValue);
                    _updateNotificationPreference(newValue);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
            child: FFButtonWidget(
              onPressed: _isSaving ? null : _saveAllSettings,
              text: _isSaving ? 'Saving...' : 'Save All Settings',
              options: FFButtonOptions(
                  width: double.infinity,
                  height: 50,
                  color: theme.primary,
                  textStyle: theme.titleSmall.copyWith(color: Colors.white)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: FFButtonWidget(
              onPressed: () async {
                await authManager.signOut();
                AppStateNotifier.instance.clearRedirectLocation();
                await Future.delayed(const Duration(milliseconds: 50));
                if (context.mounted) {
                  GoRouter.of(context).go(WelcomeScreenWidget.routePath);
                }
              },
              text: 'Log Out',
              options: FFButtonOptions(
                  width: double.infinity,
                  height: 50,
                  color: theme.error,
                  textStyle: theme.titleSmall.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//                       HELPER WIDGETS & DIALOGS
// =====================================================================

class _WorkingHoursEditor extends StatefulWidget {
  final Map<String, List<String>> initialHours;
  final ValueChanged<Map<String, List<String>>> onChanged;

  const _WorkingHoursEditor(
      {required this.initialHours, required this.onChanged});

  @override
  State<_WorkingHoursEditor> createState() => _WorkingHoursEditorState();
}

class _WorkingHoursEditorState extends State<_WorkingHoursEditor> {
  late Map<String, List<String>> _hours;
  final Map<String, String> _daysOfWeek = {
    'Monday': '1',
    'Tuesday': '2',
    'Wednesday': '3',
    'Thursday': '4',
    'Friday': '5',
    'Saturday': '6',
    'Sunday': '7',
  };

  @override
  void initState() {
    super.initState();
    _hours = Map<String, List<String>>.from(widget.initialHours);
  }

  Future<void> _editTimeSlot(
      BuildContext context, String dayKey, int slotIndex) async {
    final theme = FlutterFlowTheme.of(context);
    final parts = _hours[dayKey]![slotIndex].split('-');
    TimeOfDay startTime = TimeOfDay(
        hour: int.parse(parts[0].split(':')[0]),
        minute: int.parse(parts[0].split(':')[1]));
    TimeOfDay endTime = TimeOfDay(
        hour: int.parse(parts[1].split(':')[0]),
        minute: int.parse(parts[1].split(':')[1]));

    final newStartTime = await showTimePicker(
        context: context,
        initialTime: startTime,
        helpText: 'Select Start Time');
    if (newStartTime == null) return;

    final newEndTime = await showTimePicker(
        context: context, initialTime: endTime, helpText: 'Select End Time');
    if (newEndTime != null) {
      setState(() {
        final formattedStart =
            '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
        final formattedEnd =
            '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';
        _hours[dayKey]![slotIndex] = '$formattedStart-$formattedEnd';
      });
      widget.onChanged(_hours);
    }
  }

  Future<void> _addTimeSlot(BuildContext context, String dayKey) async {
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

    final newStartTime = await showTimePicker(
        context: context,
        initialTime: startTime,
        helpText: 'Select Start Time');
    if (newStartTime == null) return;

    final newEndTime = await showTimePicker(
        context: context, initialTime: endTime, helpText: 'Select End Time');
    if (newEndTime != null) {
      setState(() {
        final formattedStart =
            '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
        final formattedEnd =
            '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';
        if (!_hours.containsKey(dayKey)) {
          _hours[dayKey] = [];
        }
        _hours[dayKey]!.add('$formattedStart-$formattedEnd');
      });
      widget.onChanged(_hours);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: _daysOfWeek.entries.map((dayEntry) {
          final dayName = dayEntry.key;
          final dayKey = dayEntry.value;
          final isEnabled = _hours.containsKey(dayKey);

          return ExpansionTile(
            key: PageStorageKey(dayName),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            collapsedIconColor: FlutterFlowTheme.of(context).secondaryText,
            title: Text(dayName, style: FlutterFlowTheme.of(context).bodyLarge),
            trailing: Switch(
              value: isEnabled,
              onChanged: (enabled) {
                setState(() {
                  if (enabled) {
                    if (!_hours.containsKey(dayKey)) {
                      _hours[dayKey] = ['09:00-17:00'];
                    }
                  } else {
                    _hours.remove(dayKey);
                  }
                });
                widget.onChanged(_hours);
              },
              activeTrackColor: FlutterFlowTheme.of(context).primary,
            ),
            children: [
              if (isEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Column(
                    children: [
                      ...(_hours[dayKey] ?? []).asMap().entries.map((entry) {
                        int idx = entry.key;
                        String timeSlot = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(timeSlot, style: FlutterFlowTheme.of(context).bodyMedium),
                              Row(
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          size: 20, color: FlutterFlowTheme.of(context).secondaryText),
                                      onPressed: () =>
                                          _editTimeSlot(context, dayKey, idx)),
                                  IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          size: 20, color: FlutterFlowTheme.of(context).error),
                                      onPressed: () {
                                        setState(() {
                                          _hours[dayKey]!.removeAt(idx);
                                          if (_hours[dayKey]!.isEmpty) {
                                            _hours.remove(dayKey);
                                          }
                                        });
                                        widget.onChanged(_hours);
                                      }),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: FlutterFlowTheme.of(context).primary),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Time Slot'),
                          onPressed: () => _addTimeSlot(context, dayKey),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ClosedDaysEditor extends StatefulWidget {
  final List<DateTime> initialDays;
  final ValueChanged<List<DateTime>> onChanged;

  const _ClosedDaysEditor({required this.initialDays, required this.onChanged});

  @override
  State<_ClosedDaysEditor> createState() => _ClosedDaysEditorState();
}

class _ClosedDaysEditorState extends State<_ClosedDaysEditor> {
  late List<DateTime> _days;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _days = List<DateTime>.from(widget.initialDays);
    _days.sort();
  }

  Future<void> _addDay() async {
    final newDay = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDay != null && !_days.any((d) => d.isAtSameMomentAs(newDay))) {
      setState(() => _isCancelling = true);
      try {
        await Supabase.instance.client.rpc(
          'close_day_and_cancel_appointments',
          params: {'closed_day_arg': DateFormat('yyyy-MM-dd').format(newDay)},
        );

        if (mounted) {
          setState(() {
            _days.add(newDay);
            _days.sort();
          });
          widget.onChanged(_days);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Day closed and patients have been notified.'),
            backgroundColor: Colors.green,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error closing day: ${e.toString()}'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) {
          setState(() => _isCancelling = false);
        }
      }
    }
  }

  void _removeDay(DateTime day) {
    setState(() {
      _days.remove(day);
    });
    widget.onChanged(_days);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specific Closed Days', style: theme.titleMedium),
          const SizedBox(height: 16),
          _days.isEmpty
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('You have no specific closed days scheduled.'),
                ))
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _days
                      .map((day) => Chip(
                            label: Text(DateFormat.yMMMd().format(day)),
                            onDeleted: () => _removeDay(day),
                            deleteIconColor: theme.error,
                            backgroundColor: theme.primaryBackground,
                            labelStyle: theme.bodyMedium,
                          ))
                      .toList(),
                ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: theme.primary),
              icon: _isCancelling
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    )
                  : const Icon(Icons.add),
              label: Text(_isCancelling ? 'Processing...' : 'Add a Closed Day'),
              onPressed: _isCancelling ? null : _addDay,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      iconBackgroundColor: Colors.orange.withAlpha(25),
      title: 'Emergency',
      subtitle: 'Notify patients of an urgent cancellation',
      onTap: () => _showEmergencyConfirmation(context),
    );
  }

  void _showEmergencyConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Emergency'),
        content: const Text(
            'This will alert and cancel appointments for patients in the near future. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.rpc('handle_partner_emergency');
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Emergency alert sent successfully.'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

void _showContactUsDialog(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);
  final contactInfo = {
    'Email': 'Maouidi06@gmail.com',
    'Phone': '+213658846728',
    'Address':
        'Wilaya de Tebessa, Tebessa ville, devant la wilaya à côté de stade bestanji',
  };

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.secondaryBackground,
      title: Text('Contact Us', style: theme.headlineSmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactRow(
            icon: Icons.email_outlined,
            text: contactInfo['Email']!,
            onTap: () => launchUrl(Uri.parse('mailto:${contactInfo['Email']}')),
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.phone_outlined,
            text: contactInfo['Phone']!,
            onTap: () => launchUrl(Uri.parse('tel:${contactInfo['Phone']}')),
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.location_on_outlined,
            text: contactInfo['Address']!,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('Close', style: TextStyle(color: theme.primaryText)),
        ),
      ],
    ),
  );
}

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Account?'),
      content: const Text(
          'Are you sure? This action is permanent and cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await Supabase.instance.client.rpc('delete_user_account');
              await authManager.signOut();
              if (context.mounted) {
                AppStateNotifier.instance.clearRedirectLocation();
                await Future.delayed(const Duration(milliseconds: 50));
                if (context.mounted) {
                  GoRouter.of(context).go(WelcomeScreenWidget.routePath);
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error deleting account: ${e.toString()}'),
                      backgroundColor: Colors.red),
                );
              }
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text, this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: SelectableText(text, style: FlutterFlowTheme.of(context).bodyMedium)),
        ],
      ),
    );
  }
}