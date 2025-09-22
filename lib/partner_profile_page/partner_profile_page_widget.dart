import '../../backend/supabase/supabase.dart';
import '../../components/partner_card_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../index.dart';
import 'package:flutter/material.dart';
import '../../auth/supabase_auth/auth_util.dart';
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

  bool _isLoading = true;
  MedicalPartnersRow? _partnerData;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PartnerProfilePageModel());
    _loadPartnerData();
  }

  Future<void> _loadPartnerData() async {
    if (widget.partnerId == null) return;
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await MedicalPartnersTable().queryRows(
        queryFn: (q) => q.eq('id', widget.partnerId!).limit(1),
      );
      if (mounted && data.isNotEmpty) {
        setState(() {
          _partnerData = data.first;
        });
      }
    } catch (e) {
      debugPrint("Error loading partner data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
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

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: _isLoading || _partnerData == null
          ? Center(
              child: CircularProgressIndicator(
                  color: FlutterFlowTheme.of(context).primary))
          : _ProfileBody(
              partnerData: _partnerData!,
              onProfileUpdated: _loadPartnerData,
            ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final MedicalPartnersRow partnerData;
  final Future<void> Function() onProfileUpdated;

  const _ProfileBody(
      {required this.partnerData, required this.onProfileUpdated});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditMode = false;
  bool _isSaving = false;
  late TextEditingController _fullNameController;
  late TextEditingController _specialtyController;
  late TextEditingController _bioController;
  late TextEditingController _locationUrlController;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.partnerData.fullName ?? '');
    _specialtyController =
        TextEditingController(text: widget.partnerData.specialty ?? '');
    _bioController = TextEditingController(text: widget.partnerData.bio ?? '');
    _locationUrlController =
        TextEditingController(text: widget.partnerData.locationUrl ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    _locationUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client.from('medical_partners').update({
        'full_name': _fullNameController.text,
        'specialty': _specialtyController.text,
        'bio': _bioController.text,
        'location_url': _locationUrlController.text,
      }).eq('id', widget.partnerData.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ));
        await widget.onProfileUpdated();
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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 16),
                _buildDetailsCard(context),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 16),
                _buildLocationCard(context),
                if (_bioController.text.isNotEmpty || _isEditMode)
                  _buildAboutCard(context),
                _buildReviewsSection(context),
                if (widget.partnerData.category == 'Clinics')
                  _ClinicDoctorsList(clinicId: widget.partnerData.id),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isClinic = widget.partnerData.category == 'Clinics';
    final photoUrl = widget.partnerData.photoUrl ?? '';
    final isPhotoValid =
        photoUrl.startsWith('https://jtoeizfokgydtsqdciuu.supabase.co');
    final isOwnProfile = currentUserUid == widget.partnerData.id;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 220.0,
      backgroundColor: theme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (isOwnProfile)
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ))
                : Icon(_isEditMode ? Icons.done_rounded : Icons.edit_rounded,
                    color: Colors.white, size: 28),
            onPressed: _isSaving
                ? null
                : () {
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
        titlePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
        title: _isEditMode
            ? TextFormField(
                controller: _fullNameController,
                textAlign: TextAlign.center,
                style: theme.headlineSmall.copyWith(color: Colors.white),
                decoration: const InputDecoration.collapsed(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Colors.white54)),
              )
            : Text(
                _fullNameController.text,
                style: theme.headlineSmall.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (isPhotoValid)
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(77),
                colorBlendMode: BlendMode.darken,
              ),
            Center(
              child: Container(
                width: 100,
                height: 100,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withAlpha(204), width: 3),
                  image: isPhotoValid
                      ? DecorationImage(
                          image: NetworkImage(photoUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: !isPhotoValid
                    ? Icon(isClinic ? Icons.local_hospital : Icons.person,
                        size: 50, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shadowColor: theme.primaryBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileTextField(
                controller: _specialtyController,
                style: theme.titleLarge,
                isMultiLine: false,
                hintText: 'Specialty',
              ),
              if (widget.partnerData.parentClinicId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _ClinicAffiliation(
                      clinicId: widget.partnerData.parentClinicId!),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBarIndicator(
                    rating: widget.partnerData.averageRating?.toDouble() ?? 0.0,
                    itemBuilder: (context, index) =>
                        Icon(Icons.star, color: theme.warning),
                    itemCount: 5,
                    itemSize: 22.0,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.partnerData.reviewCount ?? 0} Reviews)',
                    style:
                        theme.bodyMedium.copyWith(color: theme.secondaryText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isOwnProfile = currentUserUid == widget.partnerData.id;

    if (isOwnProfile || widget.partnerData.category == 'Clinics') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FFButtonWidget(
        onPressed: () {
          context.pushNamed(
            BookingPageWidget.routeName,
            queryParameters: {'partnerId': widget.partnerData.id}.withoutNulls,
          );
        },
        text: 'Book Appointment',
        icon: const Icon(Icons.calendar_month_rounded),
        options: FFButtonOptions(
          width: double.infinity,
          height: 50.0,
          color: theme.primary,
          textStyle: theme.titleSmall.copyWith(color: Colors.white),
          elevation: 2.0,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_locationUrlController.text.isEmpty && !_isEditMode) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shadowColor: theme.primaryBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: _isEditMode
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildProfileTextField(
                  controller: _locationUrlController,
                  style: theme.bodyMedium,
                  isMultiLine: false,
                  hintText: 'Location URL (e.g. Google Maps)',
                  icon: Icons.link,
                  alignLeft: true,
                ),
              )
            : ListTile(
                leading: Icon(Icons.location_on_outlined, color: theme.primary),
                title: Text("View Location on Map", style: theme.bodyLarge),
                subtitle: Text(
                  _locationUrlController.text,
                  style: theme.bodySmall.copyWith(color: theme.secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  final urlString = _locationUrlController.text;
                  if (await canLaunchUrl(Uri.parse(urlString))) {
                    await launchUrl(Uri.parse(urlString));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Could not open location link.')));
                  }
                },
                dense: true,
              ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 48, indent: 16, endIndent: 16),
          Text(
            'About ${_fullNameController.text}',
            style: theme.headlineSmall,
          ),
          const SizedBox(height: 8),
          _buildProfileTextField(
            controller: _bioController,
            style: theme.bodyMedium,
            isMultiLine: true,
            hintText: 'Your Bio / Description',
            alignLeft: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required TextStyle style,
    required bool isMultiLine,
    required String hintText,
    IconData? icon,
    bool alignLeft = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !_isEditMode,
      textAlign: alignLeft ? TextAlign.start : TextAlign.center,
      maxLines: isMultiLine ? 5 : 1,
      minLines: 1,
      decoration: InputDecoration(
        hintText: _isEditMode ? hintText : '',
        border: _isEditMode ? const UnderlineInputBorder() : InputBorder.none,
        prefixIcon: _isEditMode && icon != null ? Icon(icon) : null,
        contentPadding: _isEditMode ? const EdgeInsets.all(8) : EdgeInsets.zero,
      ),
      style: style,
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 48, indent: 16, endIndent: 16),
          Text('Patient Reviews', style: theme.headlineSmall),
          const SizedBox(height: 16),
          _ReviewsList(partnerId: widget.partnerData.id),
        ],
      ),
    );
  }

  Widget _ClinicDoctorsList({required String clinicId}) {
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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No reviews yet.')));
        }
        final reviewsList = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.zero,
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

    final String firstName = reviewData['first_name'] ?? 'A Patient';
    final String gender = reviewData['gender'] as String? ?? '';
    final double rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;
    final String comment = reviewData['review_text'] ?? '';
    final DateTime createdAt = DateTime.parse(reviewData['created_at']);

    IconData genderIcon = gender == 'Male'
        ? Icons.male
        : (gender == 'Female' ? Icons.female : Icons.person);

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
                radius: 20,
                backgroundColor: theme.accent1.withAlpha(25),
                child: Icon(genderIcon, color: theme.primary, size: 24),
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
                itemSize: 16.0,
              ),
            ],
          ),
          if (comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 52, right: 8),
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