import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages - timezone 是 flutter_local_notifications 的传递依赖，zonedSchedule 需要 TZDateTime
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages - 同上
import 'package:timezone/timezone.dart' as tz;

/// 通知服务抽象（§11：Reminder → Notification 最后两环）。
///
/// 由 [ReminderDispatcher] 消费：到期提醒在这里落成系统通知。
/// 测试用 [FakeNotificationService] 注入，生产用 [LocalNotificationService]。
abstract class NotificationService {
  /// 初始化（幂等）：创建通知渠道、请求系统权限。
  Future<void> init();

  /// 在 [when] 时刻展示一条通知（标题 + 正文）。
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  });

  /// 取消（未展示的）通知。
  Future<void> cancel(int id);
}

/// flutter_local_notifications 真实实现。
///
/// Android：'zhiheng_tasks' 高优先级渠道；iOS：请求 alert/badge/sound 权限。
/// 定时用 zonedSchedule（v22 已移除旧 schedule 方法），
/// AndroidScheduleMode.inexactAllowWhileIdle 无需精确闹钟权限。
class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _channelId = 'zhiheng_tasks';
  static const String _channelName = '任务提醒';
  static const String _channelDescription = '任务到期提醒';

  @override
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    // Android 13+ 需要运行时授权，否则通知被系统静默丢弃。
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _initialized = true;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}

/// 测试用假实现：内存记录所有 schedule / cancel 调用，供断言。
class FakeNotificationService implements NotificationService {
  final List<ScheduledNotification> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    scheduled.add(
      ScheduledNotification(id: id, title: title, body: body, when: when),
    );
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }
}

/// [FakeNotificationService.schedule] 的单条调用记录。
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
  });

  final int id;
  final String title;
  final String body;
  final DateTime when;
}
