import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemperatureAlertService {
  TemperatureAlertService();

  final Duration timerRefreshRate = const Duration(seconds: 5);
  final Duration timerPauseDuration = const Duration(minutes: 1);
  late Timer _timer;
  late SupabaseClient supabase;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await configureAppForNotifications();
    supabase = Supabase.instance.client;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(timerRefreshRate, checkTemperature);
  }

  Future<void> checkTemperature(Timer timer) async {
    dynamic res = await supabase
        .from('configuration')
        .select('led_status')
        .limit(1)
        .single();
    int ledStatus = res['led_status'];
    if (ledStatus == 3) {
      dynamic tempData = await supabase
          .from('registered_temperatures')
          .select('temperature')
          .order('id', ascending: false)
          .limit(1)
          .single();
      showNotification('Alerta de temperatura crítica!',
          'A temperatura atingiu um valor de ${tempData['temperature']} ºC!');
      delayTimer();
    }
  }

  void delayTimer() {
    _timer.cancel();
    Timer(timerPauseDuration, () {
      startTimer();
    });
  }

  Future<void> configureAppForNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification:
                (int a, String? b, String? c, String? d) {});
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse res) {});
  }

  Future<void> showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'coldserver_channel_id',
      'Local Notifications',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
