// lib/home_page/home_page_widget.dart

import 'dart:async'; // NEW: Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // NEW: Timer for debouncing the search
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    _debounce?.cancel(); // NEW: Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'Maouidi',
            style: theme.headlineLarge.override(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: TextFormField(
                    controller: _model.textController,
                    focusNode: _model.textFieldFocusNode,
                    obscureText: false,
                    // MODIFIED: Use onChanged for live search
                    onChanged: (value) {
                      // If a timer is already active, cancel it
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      // Start a new timer
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        // This code runs after the user has stopped typing for 500ms
                        if (value.trim().isNotEmpty) {
                          context.pushNamed(
                            'SearchResultsPage',
                            queryParameters:
                                {'searchTerm': value.trim()}.withoutNulls,
                          );
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search by name...',
                      labelStyle: theme.labelMedium,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: theme.alternate, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.secondaryBackground,
                      prefixIcon: Icon(Icons.search_rounded,
                          color: theme.secondaryText),
                    ),
                    style: theme.bodyMedium,
                  ),
                ).animate(effects: [
                  FadeEffect(
                      delay: 100.ms,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                      begin: 0,
                      end: 1),
                  MoveEffect(
                      delay: 100.ms,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                      begin: const Offset(0, 20),
                      end: const Offset(0, 0)),
                ]),

                // --- Categories Section ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text('Categories', style: theme.titleLarge),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3,
                    ),
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      _CategoryCard(
                        icon: FontAwesomeIcons.userDoctor,
                        label: 'Doctors',
                        onTap: () => context.pushNamed('PartnerListPage',
                            queryParameters: {'categoryName': 'Doctors'}),
                      ),
                      _CategoryCard(
                        icon: FontAwesomeIcons.hospital,
                        label: 'Clinics',
                        onTap: () => context.pushNamed('PartnerListPage',
                            queryParameters: {'categoryName': 'Clinics'}),
                      ),
                      _CategoryCard(
                        icon: FontAwesomeIcons.stethoscope,
                        label: 'Nurses',
                        onTap: () => context.pushNamed('PartnerListPage',
                            queryParameters: {'categoryName': 'Nurses'}),
                      ),
                      _CategoryCard(
                        icon: FontAwesomeIcons.handHoldingHeart,
                        label: 'Charities',
                        onTap: () => context.pushNamed('PartnerListPage',
                            queryParameters: {'categoryName': 'Charities'}),
                      ),
                    ],
                  ),
                ).animate(effects: [
                  FadeEffect(
                      delay: 200.ms,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                      begin: 0,
                      end: 1),
                ]),

                // --- Featured Partners Section ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text('Featured Partners', style: theme.titleLarge),
                ),
                SizedBox(
                  height: 220,
                  child: FutureBuilder<List<MedicalPartnersRow>>(
                    future: MedicalPartnersTable().queryRows(
                      queryFn: (q) => q
                          .eq('is_verified', true)
                          .eq('is_featured', true)
                          .limit(10),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('No featured partners available.',
                                style: theme.bodyMedium));
                      }
                      final partners = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: partners.length,
                        itemBuilder: (context, index) {
                          final partner = partners[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _FeaturedPartnerCard(partner: partner),
                          );
                        },
                      );
                    },
                  ),
                ).animate(effects: [
                  FadeEffect(
                      delay: 300.ms,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                      begin: 0,
                      end: 1),
                  MoveEffect(
                      delay: 300.ms,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                      begin: const Offset(0, 40),
                      end: const Offset(0, 0)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: theme.titleSmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedPartnerCard extends StatelessWidget {
  const _FeaturedPartnerCard({
    required this.partner,
  });

  final MedicalPartnersRow partner;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: theme.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => context.pushNamed(
            'PartnerProfilePage',
            queryParameters: {'partnerId': partner.id}.withoutNulls,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  partner.photoUrl ??
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/health-app-j75f2j/assets/7957s72h1p38/avatar-default.png',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.alternate,
                      child: Icon(Icons.person,
                          size: 60, color: theme.secondaryText),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.fullName ?? 'Unnamed Partner',
                      style: theme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      partner.specialty ?? 'No Specialty',
                      style: theme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: theme.warning, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          partner.averageRating?.toStringAsFixed(1) ?? 'N/A',
                          style: theme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
