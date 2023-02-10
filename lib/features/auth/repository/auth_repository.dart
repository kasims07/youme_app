import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_me/common/repository/firebase_storage_repository.dart';
import 'package:you_me/common/utils/utils.dart';
import 'package:you_me/features/auth/screen/otp_screen.dart';
import 'package:you_me/features/auth/screen/user_information_screen.dart';
import 'package:you_me/models/user_model.dart';
import 'package:you_me/screens/mobile_layout_screen.dart';

final authrepositoryProvider =
    Provider((ref) => AuthRepository(auth: FirebaseAuth.instance, fireStore: FirebaseFirestore.instance));

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;
  AuthRepository({
    required this.auth,
    required this.fireStore,
  });

  void SignInWithPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            throw Exception(e.message);
          },
          codeSent: ((String verificationId, int? resendToken) async {
            Navigator.pushNamed(context, OTPScreen.routeName, arguments: verificationId);
          }),
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void verifiyOTP({
    required BuildContext context,
    required String verificationId,
    required String OTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: OTP);
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void StoreUserDataToFirebase({
    required BuildContext context,
    required ProviderRef ref,
    required String name,
    required File? profilePic,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      if (profilePic != null) {
        photoUrl = await ref.read(commonFirebaseStorageRepositoryProvider).storeFileToFirebase('profilePic/$uid', profilePic);
      }
      var user =
          UserModel(name: name, uid: uid, profilePic: photoUrl, isOnline: true, phoneNumber: auth.currentUser!.uid, groupId: []);
      await fireStore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => const MobileLayoutScreen()), (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
