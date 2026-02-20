import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../models/category_model.dart';
import '../models/contact_model.dart';
import '../models/event_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _eventsBoxName = 'eventsBox';
  static const String _contactsBoxName = 'contactsBox';
  static const String _categoriesBoxName = 'categoriesBox';
  static const String _settingsBoxName = 'settingsBox';

  late Box<EventModel> eventsBox;
  late Box<ContactModel> contactsBox;
  late Box<CategoryModel> categoriesBox;
  late Box settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(EventModelAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(ContactModelAdapter());
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(CategoryModelAdapter());

    // Setup Secure Storage for Encryption Key
    Uint8List? encryptionKeyUint8List;

    if (!kIsWeb) {
      const secureStorage = FlutterSecureStorage();
      final containsEncryptionKey = await secureStorage.containsKey(
        key: 'DB_SECURE_KEY',
      );
      if (!containsEncryptionKey) {
        final key = Hive.generateSecureKey();
        await secureStorage.write(
          key: 'DB_SECURE_KEY',
          value: base64UrlEncode(key),
        );
      }

      final encryptionKeyString = await secureStorage.read(
        key: 'DB_SECURE_KEY',
      );
      encryptionKeyUint8List = base64Url.decode(encryptionKeyString!);
    }

    // Open Encrypted Boxes
    eventsBox = await Hive.openBox<EventModel>(
      _eventsBoxName,
      encryptionCipher: kIsWeb ? null : HiveAesCipher(encryptionKeyUint8List!),
    );
    contactsBox = await Hive.openBox<ContactModel>(
      _contactsBoxName,
      encryptionCipher: kIsWeb ? null : HiveAesCipher(encryptionKeyUint8List!),
    );
    categoriesBox = await Hive.openBox<CategoryModel>(
      _categoriesBoxName,
      encryptionCipher: kIsWeb ? null : HiveAesCipher(encryptionKeyUint8List!),
    );

    // Unencrypted Box for Settings
    settingsBox = await Hive.openBox(_settingsBoxName);

    // Preseed Database if completely empty
    if (categoriesBox.isEmpty) {
      await saveCategory(
        const CategoryModel(
          id: 'cat_work',
          name: 'Trabajo',
          color: Colors.blue,
        ),
      );
      await saveCategory(
        const CategoryModel(
          id: 'cat_personal',
          name: 'Personal',
          color: Colors.green,
        ),
      );
      await saveCategory(
        const CategoryModel(id: 'cat_health', name: 'Salud', color: Colors.red),
      );
    }
    if (contactsBox.isEmpty) {
      await saveContact(
        const ContactModel(
          id: 'me',
          name: 'Mi Perfil',
          phone: '',
          isMyProfile: true,
        ),
      );
    }
  }

  // Basic CRUD for Events
  List<EventModel> getEvents() => eventsBox.values.toList();
  Future<void> saveEvent(EventModel event) => eventsBox.put(event.id, event);
  Future<void> deleteEvent(String id) => eventsBox.delete(id);

  // Basic CRUD for Contacts
  List<ContactModel> getContacts() => contactsBox.values.toList();
  Future<void> saveContact(ContactModel contact) =>
      contactsBox.put(contact.id, contact);
  Future<void> deleteContact(String id) => contactsBox.delete(id);

  // Basic CRUD for Categories
  List<CategoryModel> getCategories() => categoriesBox.values.toList();
  Future<void> saveCategory(CategoryModel category) =>
      categoriesBox.put(category.id, category);
  Future<void> deleteCategory(String id) => categoriesBox.delete(id);
}
