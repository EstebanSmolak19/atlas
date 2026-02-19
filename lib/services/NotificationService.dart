import 'package:flutter/animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Sur le Web, les notifications locales planifiées ne fonctionnent pas
    if (kIsWeb) {
      print('⚠️ Les notifications planifiées ne sont pas supportées sur Web');
      return;
    }

    // Initialiser les timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    // Configuration Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    print('✅ Service de notifications initialisé');
  }

  /// Planifier la notification quotidienne à 12h00
  Future<void> scheduleDailyLunchNotification() async {
    if (kIsWeb) {
      print('⚠️ Impossible de planifier des notifications sur Web');
      return;
    }

    const Color yellowColor = Color.fromARGB(255, 242, 202, 80);

    await _localNotifications.zonedSchedule(
      0, // ID unique de la notification
      '🍔 C\'est l\'heure du déjeuner !',
      'Nos burgers vous attendent ! Profitez de -20% sur votre commande du midi 😋',
      _nextInstanceOfNoon(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lunch_reminder', // ID du canal
          'Rappel déjeuner', // Nom du canal
          channelDescription: 'Notification quotidienne pour rappeler de commander',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: yellowColor,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Répéter tous les jours
    );

    print('✅ Notification quotidienne planifiée pour 12h00 tous les jours');
  }

  /// Calculer le prochain midi (12h00)
  tz.TZDateTime _nextInstanceOfNoon() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      12, // 12h00
      0,  // 0 minutes
      0,  // 0 secondes
    );

    // Si on a dépassé midi aujourd'hui, planifier pour demain
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('📅 Prochaine notification : $scheduledDate');
    return scheduledDate;
  }

  /// Gérer le tap sur la notification
  void _onNotificationTap(NotificationResponse response) {
    print('👆 Notification tappée : ${response.payload}');
    // Navigation automatique vers la page d'accueil
    // Vous pouvez ajouter une navigation personnalisée ici
  }

  /// Annuler toutes les notifications (utile lors de la déconnexion)
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;

    await _localNotifications.cancelAll();
    print('🔕 Toutes les notifications annulées');
  }

  /// Test : Envoyer une notification immédiatement
  Future<void> sendTestNotification() async {
    if (kIsWeb) {
      print('⚠️ Notifications de test non disponibles sur Web');
      return;
    }

    const Color yellowColor = Color.fromARGB(255, 242, 202, 80);

    await _localNotifications.show(
      999, // ID de test
      '🧪 Test de notification',
      'Cette notification est un test. La vraie notification arrivera à 12h tous les jours !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test',
          channelDescription: 'Canal de test',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: yellowColor,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    print('✅ Notification de test envoyée');
  }
}