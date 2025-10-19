import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _firebaseMessaging;

  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions
    await _requestPermissions();

    // Initialize Firebase Messaging (if available)
    try {
      _firebaseMessaging = FirebaseMessaging.instance;
      await _setupFirebaseMessaging();
    } catch (e) {
      print('Firebase Messaging not available: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    if (_firebaseMessaging == null) return;

    // Request permission
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Get FCM token
    String? token = await _firebaseMessaging!.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      _showNotification(
        title: message.notification?.title ?? 'KLIMA Alert',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    });

    // Handle when user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Navigate to specific screen based on message data
    });
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'klima_alerts',
      'KLIMA Alerts',
      channelDescription: 'Notifications for hazard alerts and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  // Show hazard alert
  Future<void> showHazardAlert({
    required String hazardType,
    required String location,
    required String severity,
  }) async {
    final icon = _getHazardIcon(hazardType);
    await _showNotification(
      title: '$icon ${_getHazardTitle(hazardType)}',
      body: 'Severity: $severity sa $location',
      channelId: 'hazard_alerts',
      channelName: 'Hazard Alerts',
    );
  }

  // Show smart nudge
  Future<void> showSmartNudge({
    required String message,
    String? emoji,
  }) async {
    await _showNotification(
      title: '${emoji ?? '💡'} KLIMA Reminder',
      body: message,
      channelId: 'smart_nudges',
      channelName: 'Smart Nudges',
    );
  }

  // Show report confirmation
  Future<void> showReportConfirmation() async {
    await _showNotification(
      title: '✅ Salamat!',
      body: 'Naitala na ang ulat ninyo. Nakatulong kayo sa inyong komunidad.',
      channelId: 'report_confirmations',
      channelName: 'Report Confirmations',
    );
  }

  // Show evacuation alert
  Future<void> showEvacuationAlert({
    required String centerName,
    required String distance,
  }) async {
    await _showNotification(
      title: '🚨 Evacuation Alert',
      body: 'Nearest evacuation center: $centerName ($distance away)',
      channelId: 'evacuation_alerts',
      channelName: 'Evacuation Alerts',
    );
  }

  // Show badge earned notification
  Future<void> showBadgeEarned({
    required String badgeName,
    required String badgeIcon,
  }) async {
    await _showNotification(
      title: '🏅 Badge Earned!',
      body: 'Congratulations! You earned: $badgeIcon $badgeName',
      channelId: 'achievements',
      channelName: 'Achievements',
    );
  }

  // Context-aware nudges based on conditions
  Future<void> sendContextualNudge({
    bool isRaining = false,
    bool hasIncompleteGoBag = false,
    bool nearHazard = false,
  }) async {
    if (isRaining && hasIncompleteGoBag) {
      await showSmartNudge(
        message: '⚠️ Heavy rain alert nearby — double-check your go-bag.',
        emoji: '☔',
      );
    } else if (nearHazard) {
      await showSmartNudge(
        message: '⚠️ Hazard reported near your location. Stay alert.',
        emoji: '🚨',
      );
    } else if (hasIncompleteGoBag) {
      await showSmartNudge(
        message: '🎒 Reminder: Complete your go-bag checklist.',
        emoji: '📋',
      );
    }
  }

  // Schedule daily reminders
  Future<void> scheduleDailyReminder() async {
    // This would use scheduled notifications
    // Implementation depends on the specific plugin version
    print('Daily reminder scheduled');
  }

  String _getHazardIcon(String hazardType) {
    switch (hazardType.toLowerCase()) {
      case 'flood':
        return '🌊';
      case 'earthquake':
        return '🌋';
      case 'typhoon':
        return '🌀';
      case 'landslide':
        return '⛰️';
      case 'fire':
        return '🔥';
      default:
        return '⚠️';
    }
  }

  String _getHazardTitle(String hazardType) {
    switch (hazardType.toLowerCase()) {
      case 'flood':
        return 'Baha Alert';
      case 'earthquake':
        return 'Lindol Alert';
      case 'typhoon':
        return 'Bagyo Alert';
      case 'landslide':
        return 'Landslide Alert';
      case 'fire':
        return 'Sunog Alert';
      default:
        return 'Hazard Alert';
    }
  }
}
