import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/emergency_report.dart';
import '../models/evacuation_center.dart';

class FirebaseService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool get _hasFirebase => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  String? fcmToken;
  bool isConnected = false;

  Future<void> initializeNotifications(BuildContext context) async {
    try {
      // Configure local notification display
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotifications.initialize(initSettings);

      if (!_hasFirebase) {
        debugPrint("Firebase not configured yet; running ALERTA in offline UI mode.");
        return;
      }

      // Request FCM permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        fcmToken = await _fcm.getToken();
        debugPrint("FCM Device Token: $fcmToken");

        // Subscribe to municipal disaster broadcasts
        await _fcm.subscribeToTopic('drrmo_disaster_alerts');
        await _fcm.subscribeToTopic('pagasa_weather_warnings');
      }

      // Listen for foreground alerts
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalAlertNotification(message);
      });

      isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint("FCM notification setup note: $e");
    }
  }

  void _showLocalAlertNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'emergency_disaster_channel',
      'Disaster Emergency Alerts',
      channelDescription: 'High priority alerts from MDRRMO and PAGASA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'URGENT DISASTER ALERT',
      message.notification?.body ?? 'PAGASA / MDRRMO Advisory Issued',
      notificationDetails,
    );
  }

  // Stream live emergency reports from Firestore
  Stream<List<EmergencyReport>> streamIncidentReports() {
    if (!_hasFirebase) return Stream.value([]);
    return _firestore
        .collection('emergency_reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EmergencyReport.fromFirestore(doc)).toList());
  }

  // Submit emergency incident report
  Future<String> submitReport(EmergencyReport report) async {
    if (!_hasFirebase) {
      return "OFFLINE_QUEUED_${DateTime.now().millisecondsSinceEpoch}";
    }
    try {
      final docRef = await _firestore.collection('emergency_reports').add(report.toMap());
      notifyListeners();
      return docRef.id;
    } catch (e) {
      debugPrint("Offline or submission note: $e");
      return "OFFLINE_QUEUED_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // Stream live evacuation centers
  Stream<List<EvacuationCenter>> streamEvacuationCenters() {
    if (!_hasFirebase) return Stream.value([]);
    return _firestore.collection('evacuation_centers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EvacuationCenter.fromMap(doc.id, doc.data())).toList();
    });
  }
}
