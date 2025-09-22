// lib/partner_list_page/partner_list_page_widget.dart

import 'package:flutter/material.dart';
import 'package:maouidi/backend/supabase/supabase.dart';
import 'package:maouidi/components/partner_card_widget.dart';
import 'package:maouidi/core/constants.dart';
import 'package:maouidi/flutter_flow/flutter_flow_drop_down.dart';
import 'package:maouidi/flutter_flow/flutter_flow_theme.dart';
import 'package:maouidi/flutter_flow/flutter_flow_util.dart';
import 'package:maouidi/flutter_flow/form_field_controller.dart';
import 'partner_list_page_model.dart';
export 'partner_list_page_model.dart';

class PartnerListPageWidget extends StatefulWidget {
  const PartnerListPageWidget({
    super.key,
    this.categoryName,
  });

  final String? categoryName;

  static String routeName = 'PartnerListPage';
  static String routePath = '/partnerListPage';

  @override
  State<PartnerListPageWidget> createState() => _PartnerListPageWidgetState();
}

class _PartnerListPageWidgetState extends State<PartnerListPageWidget> {
  late PartnerListPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  List<MedicalPartnersRow> _partners = [];
  late FormFieldController<String> _stateValueController;
  late FormFieldController<String> _specialtyValueController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PartnerListPageModel());

    _stateValueController = FormFieldController<String>(null);
    _specialtyValueController = FormFieldController<String>(null);

    _triggerSearch();
  }

  Future<void> _triggerSearch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.rpc(
        'get_filtered_partners',
        params: {
          'category_arg': widget.categoryName,
          'state_arg': _stateValueController.value,
          'specialty_arg': _specialtyValueController.value,
        },
      );

      final partners =
          (response as List).map((data) => MedicalPartnersRow(data)).toList();

      if (mounted) {
        setState(() {
          _partners = partners;
        });
      }
    } catch (e) {
      debugPrint('Error fetching partners: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load partners: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _stateValueController.value = null;
      _specialtyValueController.value = null;
    });
    _triggerSearch();
  }

  @override
  void dispose() {
    _model.dispose();
    _stateValueController.dispose();
    _specialtyValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // --- DELETED: The local 'wilayas' list is now removed ---

    final showSpecialtyFilter =
        widget.categoryName != 'Clinics' && widget.categoryName != 'Charities';
    final bool isFilterActive = _stateValueController.value != null ||
        _specialtyValueController.value != null;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: theme.primaryText),
        title:
            Text(widget.categoryName ?? 'Partners', style: theme.headlineSmall),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: theme.primaryBackground,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FlutterFlowDropDown<String>(
                        controller: _stateValueController,
                        // --- MODIFIED: Use the centralized 'algerianStates' list ---
                        options: const ['All States', ...algerianStates],
                        onChanged: (val) {
                          setState(() => _stateValueController.value =
                              val == 'All States' ? null : val);
                          _triggerSearch();
                        },
                        textStyle: theme.bodyMedium,
                        hintText: 'Filter by State',
                        fillColor: theme.primaryBackground,
                        elevation: 2,
                        borderColor: theme.alternate,
                        borderWidth: 1,
                        borderRadius: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        hidesUnderline: true,
                      ),
                    ),
                    if (showSpecialtyFilter)
                      Expanded(
                        child: FlutterFlowDropDown<String>(
                          controller: _specialtyValueController,
                          options: const [
                            'All Specialties',
                            ...medicalSpecialties
                          ],
                          onChanged: (val) {
                            setState(() => _specialtyValueController.value =
                                val == 'All Specialties' ? null : val);
                            _triggerSearch();
                          },
                          textStyle: theme.bodyMedium,
                          hintText: 'Filter by Specialty',
                          fillColor: theme.primaryBackground,
                          elevation: 2,
                          borderColor: theme.alternate,
                          borderWidth: 1,
                          borderRadius: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          hidesUnderline: true,
                        ),
                      ),
                  ],
                ),
                if (isFilterActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear Filters'),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _partners.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No partners found matching your criteria.',
                            textAlign: TextAlign.center),
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        itemCount: _partners.length,
                        itemBuilder: (context, index) {
                          final partner = _partners[index];
                          return PartnerCardWidget(partner: partner);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
