// lib/search/search_results_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maouidi/backend/supabase/supabase.dart';
import 'package:maouidi/components/partner_card_widget.dart';
import 'package:maouidi/components/empty_state_widget.dart'; // NEW: Import the empty state component
import 'package:maouidi/flutter_flow/flutter_flow_theme.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.searchTerm,
  });

  final String searchTerm;

  static String routeName = 'SearchResultsPage';
  static String routePath = '/searchResults';

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool _isLoading = true;
  List<MedicalPartnersRow> _partners = [];
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchTerm);
    _fetchResults(widget.searchTerm);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchResults(String term) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.rpc(
        'search_partners',
        params: {'search_term': term},
      );
      final partners =
          (response as List).map((data) => MedicalPartnersRow(data)).toList();

      if (mounted) {
        setState(() {
          _partners = partners;
        });
      }
    } catch (e) {
      debugPrint('Search failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search failed: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        iconTheme: IconThemeData(color: theme.primaryText),
        title: Text('Search Partners', style: theme.headlineSmall),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _fetchResults(value.trim());
                });
              },
              decoration: InputDecoration(
                hintText: 'Refine your search...',
                prefixIcon: Icon(Icons.search, color: theme.secondaryText),
                filled: true,
                fillColor: theme.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _partners.isEmpty
                    // --- MODIFIED: Use the new EmptyStateWidget ---
                    ? const EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'No Results Found',
                        message:
                            'We couldn\'t find any partners matching your search.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _partners.length,
                        itemBuilder: (context, index) {
                          return PartnerCardWidget(partner: _partners[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
