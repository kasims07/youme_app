import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authrepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({required this.authRepository, required this.ref});

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  void SignInPhone(BuildContext context, String phoneNumber) {
    authRepository.SignInWithPhoneNumber(context, phoneNumber);
  }

  void VerifyOTP(BuildContext context, String verificationId, String OTP) {
    authRepository.verifiyOTP(
        context: context, verificationId: verificationId, OTP: OTP);
  }

  void saveUserDataToFirebase(BuildContext context, String name, File? file) {
    authRepository.StoreUserDataToFirebase(
        context: context, ref: ref, name: name, profilePic: file);
  }

  Stream<UserModel> userDatabyId(String userId) {
    return authRepository.userData(userId);
  }
}
