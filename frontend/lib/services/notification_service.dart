import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/hobby.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<void> scheduleForHobbies(List<Hobby> hobbies) async {
    await init();
    await _plugin.cancelAll();

    for (final hobby in hobbies) {
      if (!hobby.notification || hobby.paused) continue;
      if (hobby.reminderHour == 0 && hobby.reminderMin == 0) continue;

      final days = hobby.days.isEmpty
          ? List.generate(7, (i) => i)
          : hobby.days;

      for (final day in days) {
        final id = _notificationId(hobby.id, day);
        await _scheduleWeekly(
          id: id,
          title: hobby.emoji.isNotEmpty
              ? '${hobby.emoji} ${hobby.name}'
              : hobby.name,
          body: 'Hora do seu hobby! Meta: ${hobby.metaValue} ${hobby.unit}',
          weekday: _dartWeekday(day),
          hour: hobby.reminderHour,
          minute: hobby.reminderMin,
        );
      }
    }
  }

  static Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hobbytrack_reminders',
          'Lembretes de Hobbies',
          channelDescription: 'Lembretes para seus hobbies',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static int _notificationId(String hobbyId, int day) {
    return hobbyId.hashCode ^ (day * 1000);
  }

  // Backend days: 0=Sunday, 1=Monday, ..., 6=Saturday
  // Dart DateTime weekday: 1=Monday, ..., 7=Sunday
  static int _dartWeekday(int backendDay) {
    if (backendDay == 0) return DateTime.sunday;
    return backendDay;
  }
}
