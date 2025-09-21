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

  Future<void> _savePlayerIdToSupabase(String playerId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Step 1: Always update the central 'users' table.
      await Supabase.instance.client
          .from('users')
          .update({'onesignal_player_id': playerId}).eq('id', userId);

      // Step 2: Check if this user is also a medical partner.
      final partnerCheck = await Supabase.instance.client
          .from('medical_partners')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      // Step 3: If they are a partner, update their record as well.
      if (partnerCheck != null) {
        await Supabase.instance.client
            .from('medical_partners')
            .update({'onesignal_player_id': playerId}).eq('id', userId);
      }

      debugPrint('OneSignal Player ID saved to Supabase: $playerId');
    } catch (e) {
      debugPrint('Error saving OneSignal Player ID: $e');
    }
  }
}
