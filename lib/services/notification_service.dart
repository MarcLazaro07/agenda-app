import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/event_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );
  }

  Future<void> scheduleEventReminder(EventModel event) async {
    if (event.reminder == null || event.reminder == 'Sin recordatorio') return;
    if (event.time == null) return;

    // Parse date and time
    final timeParts = event.time!.split(':');
    if (timeParts.length != 2) return;

    final hour = int.tryParse(timeParts[0]) ?? 0;
    final min = int.tryParse(timeParts[1]) ?? 0;

    var eventDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      hour,
      min,
    );

    // Calculate reminder offset
    Duration offset = Duration.zero;
    if (event.reminder == 'A la hora del evento') {
      offset = Duration.zero;
    } else if (event.reminder == '5 minutos antes') {
      offset = const Duration(minutes: 5);
    } else if (event.reminder == '15 minutos antes') {
      offset = const Duration(minutes: 15);
    } else if (event.reminder == '30 minutos antes') {
      offset = const Duration(minutes: 30);
    } else if (event.reminder == '1 hora antes') {
      offset = const Duration(hours: 1);
    } else if (event.reminder == '1 día antes') {
      offset = const Duration(days: 1);
    }

    final scheduledDate = eventDateTime.subtract(offset);

    // Don't schedule if it's in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    final id = event.id.hashCode;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'agenda_reminders',
          'Recordatorios de Eventos',
          channelDescription: 'Notificaciones sobre tus eventos próximos',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: event.title,
      body: 'Próximo evento en ${event.reminder}',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelEventReminder(String eventId) async {
    await flutterLocalNotificationsPlugin.cancel(id: eventId.hashCode);
  }
}
