import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/bill_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
    tz.initializeTimeZones();
  }

  /// Scheduled notifications for a bill.
  static Future<void> scheduleBillNotifications(BillModel bill) async {
    final dueDate = bill.nextDueDate;

    // 1. Notification on due date
    await _schedule(
      id: bill.id.hashCode,
      title: 'Bill Due Today: ${bill.name}',
      body: 'Your payment for ${bill.name} is due today.',
      scheduledDate: dueDate,
    );

    // 2. Notification 1 day before
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _schedule(
        id: bill.id.hashCode + 1,
        title: 'Bill Due Tomorrow: ${bill.name}',
        body: 'Reminder: ${bill.name} is due tomorrow.',
        scheduledDate: oneDayBefore,
      );
    }

    // 3. Notification X days before (configured)
    final xDaysBefore = dueDate.subtract(Duration(days: bill.reminderDaysBefore));
    if (xDaysBefore.isAfter(DateTime.now()) && bill.reminderDaysBefore > 1) {
      await _schedule(
        id: bill.id.hashCode + 2,
        title: 'Upcoming Bill: ${bill.name}',
        body: '${bill.name} is due in ${bill.reminderDaysBefore} days.',
        scheduledDate: xDaysBefore,
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'bill_reminders',
          'Bill Reminders',
          channelDescription: 'Notifications for upcoming bills',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotifications(int id) async {
    await _notificationsPlugin.cancel(id: id);
    await _notificationsPlugin.cancel(id: id + 1);
    await _notificationsPlugin.cancel(id: id + 2);
  }
}
