// lib/auth/auth_manager.dart

import 'package:flutter/material.dart';
import 'base_auth_user_provider.dart';

// This is the abstract class that defines the contract for any auth system.
abstract class AuthManager {
  // CORRECTED: Abstract getters do not have a body.
  BaseAuthUser? get currentUser;

  Future<void> refreshUser();
  Future<void> signOut();
  Future<BaseAuthUser?> signInWithEmail(
      BuildContext context, String email, String password);
  Future<BaseAuthUser?> createAccountWithEmail(
      BuildContext context, String email, String password);
  Future<void> resetPassword(
      {required String email, required BuildContext context});
  Future<void> sendEmailVerification();
  Future<void> updateEmail(
      {required String email, required BuildContext context});
  Future<void> deleteUser(BuildContext context);
}
