import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'timetable.dart';
import 'lunch.dart';
import 'setting.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
