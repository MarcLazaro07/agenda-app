import 'package:hive/hive.dart';

class ContactModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? note;
  final String? avatarUrl;
  final bool isMyProfile;

  const ContactModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.note,
    this.avatarUrl,
    this.isMyProfile = false,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  ContactModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? note,
    String? avatarUrl,
  }) {
    return ContactModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      note: note ?? this.note,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMyProfile: isMyProfile,
    );
  }
}

class ContactModelAdapter extends TypeAdapter<ContactModel> {
  @override
  final int typeId = 2;

  @override
  ContactModel read(BinaryReader reader) {
    return ContactModel(
      id: reader.readString(),
      name: reader.readString(),
      phone: reader
          .readString(), // We can just use readString/writeString for nullables if we check or use type casts, wait reader.read() gives dynamic.
      email: reader.readString(),
      note: reader.readString(),
      avatarUrl: reader.readString(),
      isMyProfile: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ContactModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.phone ?? '');
    writer.writeString(obj.email ?? '');
    writer.writeString(obj.note ?? '');
    writer.writeString(obj.avatarUrl ?? '');
    writer.writeBool(obj.isMyProfile);
  }
}
