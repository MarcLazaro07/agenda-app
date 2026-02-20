import 'package:hive/hive.dart';

enum EventPriority { high, medium, low }

class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String? time;
  final String? endTime;
  final String categoryId;
  final EventPriority priority;
  final List<String> personIds;
  final String? place;
  final String? description;
  final String? reminder;
  final String? repetition;

  const EventModel({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.endTime,
    required this.categoryId,
    this.priority = EventPriority.medium,
    this.personIds = const [],
    this.place,
    this.description,
    this.reminder,
    this.repetition,
  });

  EventModel copyWith({
    String? title,
    DateTime? date,
    String? time,
    String? endTime,
    String? categoryId,
    EventPriority? priority,
    List<String>? personIds,
    String? place,
    String? description,
    String? reminder,
    String? repetition,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      personIds: personIds ?? this.personIds,
      place: place ?? this.place,
      description: description ?? this.description,
      reminder: reminder ?? this.reminder,
      repetition: repetition ?? this.repetition,
    );
  }
}

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 1;

  @override
  EventModel read(BinaryReader reader) {
    return EventModel(
      id: reader.read(),
      title: reader.read(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      time: reader.read(),
      endTime: reader.read(),
      categoryId: reader.read(),
      priority: EventPriority.values[reader.read()],
      personIds: (reader.read() as List).cast<String>(),
      place: reader.read(),
      description: reader.read(),
      reminder: reader.read(),
      repetition: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.date.millisecondsSinceEpoch);
    writer.write(obj.time);
    writer.write(obj.endTime);
    writer.write(obj.categoryId);
    writer.write(obj.priority.index);
    writer.write(obj.personIds);
    writer.write(obj.place);
    writer.write(obj.description);
    writer.write(obj.reminder);
    writer.write(obj.repetition);
  }
}
