// lib/partner_profile_page/partner_profile_page_widget.dart

import '/backend/supabase/supabase.dart';
import '/components/partner_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'partner_profile_page_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
export 'partner_profile_page_model.dart';

class PartnerProfilePageWidget extends StatefulWidget {
  const PartnerProfilePageWidget({
    super.key,
    required this.partnerId,
  });

  final String? partnerId;

  static String routeName = 'PartnerProfilePage';
  static String routePath = '/partnerProfilePage';

  @override
  State<PartnerProfilePageWidget> createState() =>
      _PartnerProfilePageWidgetState();
}

class _PartnerProfilePageWidgetState extends State<PartnerProfilePageWidget> {
  late PartnerProfilePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isEditMode = false;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _fullNameController;
  late TextEditingController _specialtyController;
  late TextEditingController _bioController;
  late TextEditingController _locationUrlController;

  String _photoUrl = '';
  double _averageRating = 0.0;
  int _reviewCount = 0;
  String _category = '';
  String? _parentClinicId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PartnerProfilePageModel());
    _initializeControllers();
    _loadPartnerData();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _specialtyController = TextEditingController();
    _bioController = TextEditingController();
    _locationUrlController = TextEditingController();
  }

  Future<void> _loadPartnerData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final partnerData = await Supabase.instance.client
          .from('medical_partners')
          .select(
              'full_name, specialty, bio, photo_url, average_rating, review_count, location_url, category, parent_clinic_id')
          .eq('id', widget.partnerId!)
          .single();

      if (mounted) {
        setState(() {
          _fullNameController.text = partnerData['full_name'] ?? '';
          _specialtyController.text = partnerData['specialty'] ?? '';
          _bioController.text = partnerData['bio'] ?? '';
          _locationUrlController.text = partnerData['location_url'] ?? '';
          _photoUrl = partnerData['photo_url'] ?? '';
          _averageRating = (partnerData['average_rating'] ?? 0.0).toDouble();
          _reviewCount = partnerData['review_count'] ?? 0;
          _category = partnerData['category'] ?? '';
          _parentClinicId = partnerData['parent_clinic_id'];
        });
      }
    } catch (e) {
      debugPrint("Error loading partner data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client.from('medical_partners').update({
        'full_name': _fullNameController.text,
        'specialty': _specialtyController.text,
        'bio': _bioController.text,
        'location_url': _locationUrlController.text,
      }).eq('id', widget.partnerId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ));
        await _loadPartnerData();
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

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location URL provided.')),
      );
      return;
    }
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link: $urlString')),
      );
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _fullNameController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    _locationUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.partnerId == null || widget.partnerId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Partner ID is missing or invalid.')),
      );
    }

    final isOwnProfile = currentUserUid == widget.partnerId;
    final theme = FlutterFlowTheme.of(context);
    final isClinic = _category == 'Clinics';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      // --- MODIFIED: The body is now a CustomScrollView for the dynamic header effect ---
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // --- NEW: The SliverAppBar that collapses ---
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  expandedHeight: 240.0,
                  backgroundColor: theme.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    if (isOwnProfile)
                      IconButton(
                        icon: Icon(
                            _isEditMode
                                ? Icons.done_rounded
                                : Icons.edit_rounded,
                            color: Colors.white,
                            size: 28),
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
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      _fullNameController.text,
                      style: theme.headlineSmall.copyWith(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: theme.primary),
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 4),
                            ),
                            child: Image.network(
                              _photoUrl.isNotEmpty
                                  ? _photoUrl
                                  : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/health-app-j75f2j/assets/7957s72h1p38/avatar-default.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                      isClinic
                                          ? Icons.local_hospital
                                          : Icons.person,
                                      size: 60,
                                      color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // --- NEW: The rest of the page content is now a sliver ---
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            children: [
                              _buildProfileTextField(
                                controller: _specialtyController,
                                label: 'Specialty',
                                style: theme.titleMedium
                                    .copyWith(color: theme.secondaryText),
                                isMultiLine: false,
                              ),
                              const SizedBox(height: 8),
                              if (_parentClinicId != null && !isClinic)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _ClinicAffiliation(
                                      clinicId: _parentClinicId!),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: theme.warning, size: 20.0),
                                  const SizedBox(width: 4),
                                  Text(_averageRating.toStringAsFixed(1),
                                      style: theme.bodyLarge),
                                  const SizedBox(width: 8),
                                  Text('($_reviewCount reviews)',
                                      style: theme.bodyMedium.copyWith(
                                          color: theme.secondaryText)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildProfileTextField(
                                controller: _bioController,
                                label: 'Bio / Description',
                                style: theme.bodyMedium,
                                isMultiLine: true,
                              ),
                              const SizedBox(height: 16),
                              _isEditMode
                                  ? _buildProfileTextField(
                                      controller: _locationUrlController,
                                      label: 'Location URL (e.g., Google Maps)',
                                      style: theme.bodyMedium,
                                      isMultiLine: false,
                                      icon: Icons.link_rounded,
                                    )
                                  : ListTile(
                                      leading: Icon(Icons.location_on_outlined,
                                          color: theme.primary),
                                      title: Text("View Location on Map",
                                          style: theme.bodyLarge),
                                      subtitle: Text(
                                        _locationUrlController.text.isNotEmpty
                                            ? _locationUrlController.text
                                            : "Not provided",
                                        style: theme.bodySmall.copyWith(
                                            color: theme.secondaryText),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () => _launchURL(
                                          _locationUrlController.text),
                                      dense: true,
                                    ),
                              const SizedBox(height: 24),
                              if (!isOwnProfile && !isClinic)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: FFButtonWidget(
                                    onPressed: () {
                                      context.pushNamed(
                                        BookingPageWidget.routeName,
                                        queryParameters: {
                                          'partnerId': widget.partnerId!
                                        }.withoutNulls,
                                      );
                                    },
                                    text: 'Book Appointment',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 50.0,
                                      color: theme.primary,
                                      textStyle: theme.titleSmall
                                          .copyWith(color: Colors.white),
                                      elevation: 2.0,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              if (isClinic)
                                _ClinicDoctorsList(clinicId: widget.partnerId!),
                              const Divider(
                                  height: 48, indent: 16, endIndent: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text('Patient Reviews',
                                    style: theme.headlineSmall),
                              ),
                              const SizedBox(height: 16),
                              _ReviewsList(partnerId: widget.partnerId!),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required TextStyle style,
    required bool isMultiLine,
    IconData? icon,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextFormField(
        controller: controller,
        readOnly: !_isEditMode,
        textAlign: TextAlign.center,
        maxLines: isMultiLine ? null : 1,
        decoration: InputDecoration(
          hintText: _isEditMode ? label : '',
          border: _isEditMode
              ? OutlineInputBorder(borderRadius: BorderRadius.circular(8))
              : InputBorder.none,
          prefixIcon: _isEditMode && icon != null ? Icon(icon) : null,
        ),
        style: style,
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({required this.partnerId});
  final String partnerId;

  Future<List<Map<String, dynamic>>> _getReviews() {
    return Supabase.instance.client.rpc('get_reviews_with_user_names', params: {
      'partner_id_arg': partnerId
    }).then((data) => List<Map<String, dynamic>>.from(data as List));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading reviews: ${snapshot.error}'),
          );
        }
        final reviewsList = snapshot.data!;
        if (reviewsList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('No reviews yet. Be the first to leave one!'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviewsList.length,
          itemBuilder: (context, index) {
            final review = reviewsList[index];
            return _ReviewCard(reviewData: review);
          },
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.reviewData});
  final Map<String, dynamic> reviewData;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final String firstName = reviewData['user_first_name'] ?? 'A Patient';
    final String gender = reviewData['user_gender'] as String? ?? '';
    final double rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;
    final String comment = reviewData['review_text'] ?? '';
    final DateTime createdAt = DateTime.parse(reviewData['created_at']);

    IconData genderIcon;
    switch (gender) {
      case 'Male':
        genderIcon = Icons.male_rounded;
        break;
      case 'Female':
        genderIcon = Icons.female_rounded;
        break;
      default:
        genderIcon = Icons.person_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.accent1.withOpacity(0.1),
                child: Icon(genderIcon, color: theme.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstName,
                        style: theme.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(DateFormat.yMMMMd().format(createdAt),
                        style: theme.bodySmall
                            .copyWith(color: theme.secondaryText)),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: rating,
                itemBuilder: (context, index) =>
                    Icon(Icons.star, color: theme.warning),
                itemCount: 5,
                itemSize: 18.0,
                direction: Axis.horizontal,
              ),
            ],
          ),
          if (comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 56, right: 8),
              child: Text(comment, style: theme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _ClinicAffiliation extends StatelessWidget {
  const _ClinicAffiliation({required this.clinicId});
  final String clinicId;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return FutureBuilder<List<MedicalPartnersRow>>(
      future: MedicalPartnersTable().queryRows(
        queryFn: (q) => q.eq('id', clinicId).select('full_name').limit(1),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final clinicName = snapshot.data!.first.fullName ?? 'a clinic';
        return InkWell(
          onTap: () => context.pushNamed(
            'PartnerProfilePage',
            queryParameters: {'partnerId': clinicId}.withoutNulls,
          ),
          child: Text(
            'Part of $clinicName',
            style: theme.bodyMedium.copyWith(
              color: theme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}

class _ClinicDoctorsList extends StatelessWidget {
  const _ClinicDoctorsList({required this.clinicId});
  final String clinicId;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        const Divider(height: 48, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Our Doctors', style: theme.headlineSmall),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<MedicalPartnersRow>>(
          future: MedicalPartnersTable().queryRows(
            queryFn: (q) => q.eq('parent_clinic_id', clinicId),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No doctors listed for this clinic yet.'),
              ));
            }
            final doctors = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return PartnerCardWidget(
                  partner: doctors[index],
                  showBookingButton: true,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
