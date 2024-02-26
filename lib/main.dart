import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nomad/app.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nomad/LoginPage.dart';

void setupNotificationChannel() async {
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      '4504943277337370923', // 채널 ID
      '레스토랑 예약', // 채널 이름
      description: 'This channel is used for important notifications.', // 채널 설명
      importance: Importance.high, // 중요도
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Notification channel set up');
  }
}
// 알림을 초기화하기 위한 객체 생성
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// 백그라운드에서 알림을 처리하기 위한 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 알림 설정
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 알림 채널 설정 호출
  setupNotificationChannel();


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FCM 초기화
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 사용자에게 알림 권한 요청
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
  // FCM 등록 토큰 얻기
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // "reservations" 주제 구독
  await messaging.subscribeToTopic("reservations");

  // 포그라운드 알림 설정
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            '4504943277337370923', // 앞서 설정한 채널 ID
            '레스토랑 예약',
            channelDescription: 'This channel is used for important notifications.',
            icon: android.smallIcon,
            // 기타 알림 세부 설정
          ),
        ),
      );
    }
  });

  runApp(const HostApp());
}

class HostApp extends StatelessWidget {
  const HostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom AppBar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginPage();
          } else {
            return HostAppHomePage(); // 로그인 성공 시 이동페이지
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
        },
      ),
    );
  }
}
