// This global variable will be updated by the user stream in main.dart
BaseAuthUser? currentUser;

bool get loggedIn => currentUser?.loggedIn ?? false;

class AuthUserInfo {
  const AuthUserInfo({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
  });

  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
}

abstract class BaseAuthUser {
  bool get loggedIn;
  bool get emailVerified;
  AuthUserInfo get authUserInfo;

  Future<void> delete();
  Future<void> updateEmail(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> sendEmailVerification();
  Future<void> refreshUser();

  String? get uid => authUserInfo.uid;
  String? get email => authUserInfo.email;
  String? get displayName => authUserInfo.displayName;
  String? get photoUrl => authUserInfo.photoUrl;
  String? get phoneNumber => authUserInfo.phoneNumber;
}
