// lib/auth/auth_manager.dart

import 'package:flutter/material.dart';
import 'base_auth_user_provider.dart';

abstract class AuthManager {
  BaseAuthUser? get currentUser;

  Future<void> refreshUser();
  Future<void> signOut();
  Future<BaseAuthUser?> signInWithEmail(
      BuildContext context, String email, String password);

  // MODIFIED: Added firstName and lastName to the method signature
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password, {
    String? firstName,
    String? lastName,
  });

  Future<void> resetPassword(
      {required String email, required BuildContext context});
  Future<void> sendEmailVerification();
  Future<void> updateEmail(
      {required String email, required BuildContext context});
  Future<void> deleteUser(BuildContext context);
}
