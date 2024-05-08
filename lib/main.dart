import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'timetable.dart';
import 'lunch.dart';
import 'setting.dart';
import 'notification_service.dart'; // Adjust the path according to your project structure if needed
import 'firebase_options.dart'; // Adjust the path according to your project structure if needed

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupMessagingListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupMessagingListeners();

  NotificationService.initialize(); // Initialize the notification service
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: '시간표',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_dining),
              label: '급식',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return TimeTableTab();
            case 1:
              return LunchTab();
            case 2:
              return SettingsTab();
            default:
              return TimeTableTab();
          }
        },
      ),
    );
  }
}
