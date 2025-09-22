// lib/auth/supabase_auth/supabase_auth_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../backend/supabase/supabase.dart';
import '../auth_manager.dart';
import '../base_auth_user_provider.dart' as base_auth_user_provider;
import 'auth_util.dart';

class MaouidiSupabaseUser extends base_auth_user_provider.BaseAuthUser {
  MaouidiSupabaseUser(this.user);
  final User user;

  @override
  bool get loggedIn => true;

  @override
  base_auth_user_provider.AuthUserInfo get authUserInfo =>
      base_auth_user_provider.AuthUserInfo(
        uid: user.id,
        email: user.email,
        displayName: user.userMetadata?['full_name'],
        photoUrl: user.userMetadata?['avatar_url'],
        phoneNumber: user.phone,
      );

  @override
  bool get emailVerified => user.emailConfirmedAt != null;

  String? get jwtToken => SupaFlow.client.auth.currentSession?.accessToken;

  @override
  Future<void> updatePassword(String newPassword) =>
      SupaFlow.client.auth.updateUser(UserAttributes(password: newPassword));

  // --- ADDED: The missing refreshUser method ---
  @override
  Future<void> refreshUser() => authManager.refreshUser();
  // ---------------------------------------------

  @override
  Future<void> sendEmailVerification() async {
    if (user.email == null) return;
    await SupaFlow.client.auth.resend(type: OtpType.email, email: user.email!);
  }
}

class SupabaseAuthManager implements AuthManager {
  GoTrueClient get auth => SupaFlow.client.auth;

  @override
  base_auth_user_provider.BaseAuthUser? get currentUser =>
      base_auth_user_provider.currentUser;

  @override
  Future<void> refreshUser() async {
    final response = await auth.refreshSession();
    if (response.user != null) {
      base_auth_user_provider.currentUser = MaouidiSupabaseUser(response.user!);
    }
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
    base_auth_user_provider.currentUser = null;
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    try {
      if (currentUser?.uid == null) {
        throw Exception('User is not signed in.');
      }
      await SupaFlow.client.rpc('delete_user_account');
      await signOut();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await auth.updateUser(UserAttributes(email: email));
      await refreshUser();
    } on AuthException catch (e) {
      debugPrint('Error updating email: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await auth.resetPasswordForEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } on AuthException catch (e) {
      debugPrint('Error sending password reset email: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Future<base_auth_user_provider.BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    final authResponse =
        await auth.signInWithPassword(email: email, password: password);
    if (authResponse.user != null) {
      base_auth_user_provider.currentUser =
          MaouidiSupabaseUser(authResponse.user!);
      return base_auth_user_provider.currentUser;
    }
    return null;
  }

  @override
  Future<base_auth_user_provider.BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password, {
    String? firstName,
    String? lastName,
  }) async {
    final authResponse = await auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    if (authResponse.user?.lastSignInAt == null) {
      return null;
    }
    if (authResponse.user != null) {
      base_auth_user_provider.currentUser =
          MaouidiSupabaseUser(authResponse.user!);
      return base_auth_user_provider.currentUser;
    }
    return null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (currentUser?.email == null) return;
    await auth.resend(type: OtpType.email, email: currentUser!.email!);
  }
}
