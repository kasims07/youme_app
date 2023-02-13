import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_me/common/utils/utils.dart';
import 'package:you_me/models/user_model.dart';

final selectContactRepositoryProvider = Provider((ref) =>
    SelectContactRepository(firebaseFirestore: FirebaseFirestore.instance));

class SelectContactRepository {
  final FirebaseFirestore firebaseFirestore;
  SelectContactRepository({required this.firebaseFirestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firebaseFirestore.collection('users').get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectPhone =
            selectedContact.phones[0].number.replaceAll(' ', '');
        if (selectPhone == userData.phoneNumber) {
          isFound = true;
        }
      }
      if (!isFound) {
        showSnackBar(
            context: context,
            content: 'This number does not exits in this app');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
