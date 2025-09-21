// lib/auth/supabase_auth/auth_util.dart

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:maouidi/backend/supabase/supabase.dart';
import '../base_auth_user_provider.dart';
import '../auth_manager.dart';
import 'supabase_auth_manager.dart';

final AuthManager authManager = SupabaseAuthManager();

String get currentUserEmail => currentUser?.email ?? '';
String get currentUserUid => currentUser?.uid ?? '';
String get currentUserDisplayName => currentUser?.displayName ?? '';
String get currentUserPhoto => currentUser?.photoUrl ?? '';
String get currentPhoneNumber => currentUser?.phoneNumber ?? '';
bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

String get currentJwtToken =>
    (currentUser is MaouidiSupabaseUser
        ? (currentUser as MaouidiSupabaseUser).jwtToken
        : null) ??
    '';

// THIS IS THE CORRECTED, REAL-TIME STREAM
Stream<BaseAuthUser?> maouidiSupabaseUserStream() {
  final supabaseAuthStream = SupaFlow.client.auth.onAuthStateChange.debounce(
      (authState) => authState.event == AuthChangeEvent.tokenRefreshed
          ? TimerStream(authState, const Duration(seconds: 1))
          : Stream.value(authState));
  return (!loggedIn
          ? Stream<AuthState?>.value(null).concatWith([supabaseAuthStream])
          : supabaseAuthStream)
      .map<BaseAuthUser?>(
    (authState) {
      // Set the global variable
      currentUser = authState?.session?.user == null
          ? null
          : MaouidiSupabaseUser(authState!.session!.user);
      // Return the user for the stream
      return currentUser;
    },
  );
}

final jwtTokenStream = SupaFlow.client.auth.onAuthStateChange
    .map((authState) => authState.session?.accessToken);
