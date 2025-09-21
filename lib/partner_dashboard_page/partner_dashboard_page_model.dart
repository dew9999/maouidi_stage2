// lib/partner_dashboard_page/partner_dashboard_page_model.dart

import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'partner_dashboard_page_widget.dart' show PartnerDashboardPageWidget;
import 'package:flutter/material.dart';

// Enums to manage the state of the UI filters
enum DashboardView { schedule, analytics }

enum DateRangeFilter { day, week, month, all, today }

class PartnerDashboardPageModel
    extends FlutterFlowModel<PartnerDashboardPageWidget> {
  // Local state fields for this page
  String selectedStatus = 'Pending';
  DashboardView currentView = DashboardView.schedule;
  DateRangeFilter dateFilter = DateRangeFilter.day;

  // State fields for stateful widgets in this page
  DateTimeRange? calendarSelectedDay;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {}
}
