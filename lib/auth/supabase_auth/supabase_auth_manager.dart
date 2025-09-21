// lib/auth/supabase_auth/supabase_auth_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../base_auth_user_provider.dart' as baseAuthUserProvider;
import '../auth_manager.dart';
import '../../backend/supabase/supabase.dart';
import 'auth_util.dart';

class MaouidiSupabaseUser extends baseAuthUserProvider.BaseAuthUser {
  MaouidiSupabaseUser(this.user);
  final User user;

  @override
  bool get loggedIn => true;

  @override
  baseAuthUserProvider.AuthUserInfo get authUserInfo =>
      baseAuthUserProvider.AuthUserInfo(
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
  Future<void> delete() =>
      authManager.deleteUser(GlobalKey<ScaffoldState>().currentContext!);

  @override
  Future<void> updateEmail(String email) => authManager.updateEmail(
      email: email, context: GlobalKey<ScaffoldState>().currentContext!);

  @override
  Future<void> updatePassword(String newPassword) =>
      SupaFlow.client.auth.updateUser(UserAttributes(password: newPassword));

  @override
  Future<void> sendEmailVerification() => authManager.sendEmailVerification();

  @override
  Future<void> refreshUser() => authManager.refreshUser();
}

class SupabaseAuthManager implements AuthManager {
  GoTrueClient get auth => SupaFlow.client.auth;

  @override
  baseAuthUserProvider.BaseAuthUser? get currentUser =>
      baseAuthUserProvider.currentUser;

  @override
  Future<void> refreshUser() async {
    final response = await auth.refreshSession();
    if (response.user != null) {
      baseAuthUserProvider.currentUser = MaouidiSupabaseUser(response.user!);
    }
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
    baseAuthUserProvider.currentUser = null;
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    try {
      if (currentUser?.uid == null) {
        throw Exception('User is not signed in.');
      }
      await SupaFlow.client.functions.invoke('delete-user');
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
  Future<baseAuthUserProvider.BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    final authResponse =
        await auth.signInWithPassword(email: email, password: password);
    if (authResponse.user != null) {
      baseAuthUserProvider.currentUser =
          MaouidiSupabaseUser(authResponse.user!);
      return baseAuthUserProvider.currentUser;
    }
    return null;
  }

  @override
  Future<baseAuthUserProvider.BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    final authResponse = await auth.signUp(email: email, password: password);
    if (authResponse.user != null) {
      baseAuthUserProvider.currentUser =
          MaouidiSupabaseUser(authResponse.user!);
      return baseAuthUserProvider.currentUser;
    }
    return null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (currentUser?.email == null) return;
    await auth.resend(type: OtpType.email, email: currentUser!.email!);
  }
}
