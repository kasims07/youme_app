import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_me/features/selectContacts/repository/select_contact_repository.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(selectContactRepositoryProvider);
  return selectContactRepository.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final selectContactRepository = ref.watch(selectContactRepositoryProvider);
  return selectContactController(
      ref: ref, selectContactRepository: selectContactRepository);
});

class selectContactController {
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;
  selectContactController({
    required this.ref,
    required this.selectContactRepository,
  });
  void selectContact(Contact contact, BuildContext context) {
    selectContactRepository.selectContact(contact, context);
  }
}
