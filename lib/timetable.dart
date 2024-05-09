import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TimeTableTab extends StatefulWidget {
  @override
  _TimeTableTabState createState() => _TimeTableTabState();
}

class _TimeTableTabState extends State<TimeTableTab> {
  late List<List<Map<String, dynamic>>> scheduleData = [];
  int defaultGrade = 1;
  int defaultClass = 1;
  int currentGrade = 1;
  int currentClass = 1;

  final List<Map<String, String>> periodTimes = [
    {"start": "08:20", "end": "09:20"},
    {"start": "09:20", "end": "10:20"},
    {"start": "10:20", "end": "11:20"},
    {"start": "11:20", "end": "14:10"},
    {"start": "13:10", "end": "14:10"},
    {"start": "14:10", "end": "15:10"},
    {"start": "15:10", "end": "16:10"}
  ];

  final List<DropdownMenuItem<int>> gradeItems = List.generate(3, (index) =>
      DropdownMenuItem(value: index + 1, child: Text('${index + 1}학년')));
  final List<DropdownMenuItem<int>> classItems = List.generate(11, (index) =>
      DropdownMenuItem(value: index + 1, child: Text('${index + 1}반')));

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    int grade = prefs.getInt('defaultGrade') ?? 1;
    int classNumber = prefs.getInt('defaultClass') ?? 1;
    setState(() {
      defaultGrade = grade;
      defaultClass = classNumber;
      currentGrade = grade;
      currentClass = classNumber;
    });
    fetchSchedule(grade, classNumber);
  }

  savePreferences(int grade, int classNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultGrade', grade);
    await prefs.setInt('defaultClass', classNumber);
  }

  fetchSchedule(int grade, int classNumber) async {
    var url = Uri.parse('https://comsi.helgisnw.me/$grade/$classNumber');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          scheduleData = List<List<Map<String, dynamic>>>.from(
              data.map((i) => List<Map<String, dynamic>>.from(
                  i.map((j) => j as Map<String, dynamic>)))
          );
        });
      } else {
        print('Failed to load schedule');
      }
    } catch (e) {
      print('Failed to make HTTP request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: null,
      child: SafeArea(
        child: Column(
          children: [
            Material(child: buildClassSelector(currentGrade, currentClass, updateViewClass: true)),  // Selector for schedule viewing
            Expanded(
              child: Center(
                child: scheduleData.isNotEmpty ? buildGridView() : CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClassSelector(int selectedGrade, int selectedClass, {bool updateViewClass = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 30),
        DropdownButton<int>(
          value: selectedGrade,
          items: gradeItems,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                if (updateViewClass) {
                  currentGrade = value;
                } else {
                  defaultGrade = value;
                }
              });
              if (!updateViewClass) {
                savePreferences(defaultGrade, defaultClass);
              } else {
                fetchSchedule(currentGrade, currentClass);
              }
            }
          },
        ),
        SizedBox(width: 20),
        DropdownButton<int>(
          value: selectedClass,
          items: classItems,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                if (updateViewClass) {
                  currentClass = value;
                } else {
                  defaultClass = value;
                }
              });
              if (!updateViewClass) {
                savePreferences(defaultGrade, defaultClass);
              } else {
                fetchSchedule(currentGrade, currentClass);
              }
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            fetchSchedule(currentGrade, currentClass);
          },
        ),
      ],
    );
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 6,
      childAspectRatio: 1,
      children: List.generate(
        48, // 6 columns x 8 rows
            (index) => _buildGridCell(index),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    BoxDecoration cellDecoration = BoxDecoration(
      border: Border.all(color: Colors.grey),
    );

    if (index == 0) {
      return Container(decoration: cellDecoration);
    } else if (index < 6) {
      return Container(
        decoration: cellDecoration,
        child: Center(
          child: Text(
            getDayOfWeek(index),
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.black),
          ),
        ),
      );
    } else if (index % 6 == 0) {
      int periodIndex = (index / 6).toInt() - 1;
      return Container(
        decoration: cellDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${periodIndex + 1}교시',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.black),
            ),
            Text(
              '${periodTimes[periodIndex]["start"]}',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black),
            ),
          ],
        ),
      );
    } else {
      int day = index % 6 - 1;
      int period = (index / 6).floor();
      return createScheduleCell(day, period, cellDecoration);
    }
  }

  Widget createScheduleCell(int weekday, int classTime, BoxDecoration decoration) {
    DateTime now = DateTime.now();
    int todayWeekday = now.weekday - 1; // 월요일: 0, 화요일: 1, ...

    // 각 교시의 시작 및 종료 시간 계산
    DateFormat format = DateFormat("HH:mm");
    DateTime? startTime, endTime;

    if (classTime > 0 && classTime <= periodTimes.length) {
      var period = periodTimes[classTime - 1];
      startTime = format.parse(period["start"]!);
      startTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);

      endTime = format.parse(period["end"]!);
      endTime = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
    }

    // 셀 배경색 결정 (현재 시간과 요일을 고려)
    bool isCurrentClass = weekday == todayWeekday &&
        startTime != null &&
        now.isAfter(startTime) &&
        now.isBefore(endTime!);

    var data = scheduleData.isNotEmpty ? scheduleData[weekday].firstWhere(
          (element) => element['classTime'] == classTime,
      orElse: () => {"subject": "", "teacher": ""},
    ) : {"subject": "", "teacher": ""};

    print(data);
    print(startTime);
    print(endTime);
    print(isCurrentClass);

    return Container(
      decoration: decoration.copyWith(
        color: isCurrentClass ? Colors.yellow.shade100 : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(data['subject'], style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black)),
          Text(data['teacher'], style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black)),
        ],
      ),
    );
  }

  String getDayOfWeek(int index) {
    switch (index) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      default:
        return '';
    }
  }
}
