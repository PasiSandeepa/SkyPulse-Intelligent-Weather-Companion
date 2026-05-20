import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyBriefingId = 1;
  static const int _rainAlertId = 2;
  static const int _extremeWeatherAlertId = 3;
  static const int _aqiAlertId = 4;
  static const int _uvAlertId = 5;

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyBriefing({
    required String cityName,
    required double temp,
    required String condition,
  }) async {
    await _plugin.cancel(_dailyBriefingId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyBriefingId,
      'Good Morning! Daily Weather',
      '$cityName today: ${temp.toStringAsFixed(1)} C, $condition',
      scheduledDate,
      _notificationDetails(
        channelId: 'daily_briefing',
        channelName: 'Daily Weather Briefing',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showRainAlert({required String cityName}) async {
    await _plugin.show(
      _rainAlertId,
      'Rain Alert!',
      'Rain expected in $cityName! Carry an umbrella.',
      _notificationDetails(
        channelId: 'rain_alert',
        channelName: 'Rain Alert',
      ),
    );
  }

  Future<void> showExtremeWeatherAlert({
    required String cityName,
    required double feelsLike,
    required bool isHot,
  }) async {
    final title = isHot ? 'Heat Alert!' : 'Cold Alert!';
    final body = isHot
        ? 'Feels like ${feelsLike.toStringAsFixed(1)} C in $cityName. Stay hydrated!'
        : 'Feels like ${feelsLike.toStringAsFixed(1)} C in $cityName. Dress warmly!';

    await _plugin.show(
      _extremeWeatherAlertId,
      title,
      body,
      _notificationDetails(
        channelId: 'extreme_weather',
        channelName: 'Extreme Weather Warning',
      ),
    );
  }

  Future<void> showAqiAlert({
    required String cityName,
    required int aqi,
  }) async {
    if (aqi <= 100) {
      return;
    }

    String label;
    if (aqi <= 150) {
      label = 'Moderate';
    } else if (aqi <= 200) {
      label = 'Poor';
    } else {
      label = 'Very Poor';
    }

    await _plugin.show(
      _aqiAlertId,
      'Air Quality Alert!',
      'Air quality is $label in $cityName. AQI: $aqi',
      _notificationDetails(
        channelId: 'aqi_alert',
        channelName: 'Air Quality Alert',
      ),
    );
  }

  Future<void> showUvAlert({
    required String cityName,
    required double uvIndex,
  }) async {
    if (uvIndex < 6) {
      return;
    }

    String label;
    if (uvIndex < 8) {
      label = 'High';
    } else if (uvIndex < 11) {
      label = 'Very High';
    } else {
      label = 'Extreme';
    }

    await _plugin.show(
      _uvAlertId,
      'UV Index Warning!',
      '$label UV ($uvIndex) in $cityName. Apply sunscreen!',
      _notificationDetails(
        channelId: 'uv_alert',
        channelName: 'UV Index Warning',
      ),
    );
  }

  Future<void> checkAndShowWeatherAlerts({
    required String cityName,
    required double temp,
    required double feelsLike,
    required String condition,
    required int aqi,
    required double uvIndex,
  }) async {
    final c = condition.toLowerCase();

    if (c.contains('rain') ||
        c.contains('drizzle') ||
        c.contains('thunder')) {
      await showRainAlert(cityName: cityName);
    }

    if (feelsLike > 38) {
      await showExtremeWeatherAlert(
        cityName: cityName,
        feelsLike: feelsLike,
        isHot: true,
      );
    }

    if (feelsLike < 10) {
      await showExtremeWeatherAlert(
        cityName: cityName,
        feelsLike: feelsLike,
        isHot: false,
      );
    }

    await showAqiAlert(cityName: cityName, aqi: aqi);
    await showUvAlert(cityName: cityName, uvIndex: uvIndex);
  }

  NotificationDetails _notificationDetails({
    required String channelId,
    required String channelName,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
