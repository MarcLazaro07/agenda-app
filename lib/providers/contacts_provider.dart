import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_service.dart';
import '../models/contact_model.dart';

class ContactsNotifier extends StateNotifier<List<ContactModel>> {
  final DatabaseService _dbServer;

  ContactsNotifier(this._dbServer) : super(_dbServer.getContacts());

  Future<void> addContact(ContactModel contact) async {
    await _dbServer.saveContact(contact);
    state = _dbServer.getContacts();
  }

  Future<void> updateContact(ContactModel contact) async {
    await _dbServer.saveContact(contact);
    state = _dbServer.getContacts();
  }

  Future<void> deleteContact(String id) async {
    await _dbServer.deleteContact(id);
    state = _dbServer.getContacts();
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, List<ContactModel>>((ref) {
      return ContactsNotifier(DatabaseService());
    });
