import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_service.dart';
import '../models/event_model.dart';
import '../services/notification_service.dart';

class EventsNotifier extends StateNotifier<List<EventModel>> {
  final DatabaseService _dbServer;

  EventsNotifier(this._dbServer) : super(_dbServer.getEvents());

  Future<void> addEvent(EventModel event) async {
    await _dbServer.saveEvent(event);
    state = _dbServer.getEvents();
    if (event.reminder != null) {
      await NotificationService().scheduleEventReminder(event);
    }
  }

  Future<void> updateEvent(EventModel event) async {
    await _dbServer.saveEvent(event);
    state = _dbServer.getEvents();
    if (event.reminder != null) {
      // Re-scheduling over the same ID updates it
      await NotificationService().scheduleEventReminder(event);
    } else {
      await NotificationService().cancelEventReminder(event.id);
    }
  }

  Future<void> deleteEvent(String id) async {
    await _dbServer.deleteEvent(id);
    state = _dbServer.getEvents();
    await NotificationService().cancelEventReminder(id);
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, List<EventModel>>((
  ref,
) {
  return EventsNotifier(DatabaseService());
});
