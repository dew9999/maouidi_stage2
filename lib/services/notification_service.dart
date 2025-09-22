// lib/services/notification_service.dart

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static const String _oneSignalAppId = 'ce5ca714-567f-4b98-8b42-3b856dd713a3';

  Future<void> initialize() async {
    OneSignal.initialize(_oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.User.pushSubscription.addObserver((state) {
      if (state.current.id != null) {
        _savePlayerIdToSupabase(state.current.id!);
      }
    });
  }

  // MODIFIED: This function is now much simpler and safer.
  // It just calls our single backend function.
  Future<void> _savePlayerIdToSupabase(String playerId) async {
    // We only proceed if a user is logged in.
    if (Supabase.instance.client.auth.currentUser == null) return;

    try {
      await Supabase.instance.client.rpc('update_player_id', params: {
        'player_id_arg': playerId,
      });
      debugPrint('OneSignal Player ID saved to Supabase: $playerId');
    } catch (e) {
      debugPrint('Error saving OneSignal Player ID: $e');
    }
  }
}
