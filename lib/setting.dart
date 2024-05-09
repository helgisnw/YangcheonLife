import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  int defaultGrade = 1;
  int defaultClass = 1;
  bool notificationsEnabled = true;
  String selectedSubjectB = "탐구B";
  String selectedSubjectC = "탐구C";
  String selectedSubjectD = "탐구D";

  final List<String> subjects = [
    "없음",
    "물리",
    "화학",
    "생명과학",
    "지구과학",
    "윤사",
    "정치와 법",
    "경제",
    "세계사",
    "한국지리",
    "탐구B",
    "탐구C",
    "탐구D"
  ];

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      defaultGrade = prefs.getInt('defaultGrade') ?? 1;
      defaultClass = prefs.getInt('defaultClass') ?? 1;
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      selectedSubjectB = prefs.getString('selectedSubjectB') ?? "탐구B";
      selectedSubjectC = prefs.getString('selectedSubjectC') ?? "탐구C";
      selectedSubjectD = prefs.getString('selectedSubjectD') ?? "탐구D";
    });

    if (notificationsEnabled) {
      subscribeToTopic(defaultGrade, defaultClass);
    } else {
      unsubscribeFromTopic(defaultGrade, defaultClass);
    }
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultGrade', defaultGrade);
    await prefs.setInt('defaultClass', defaultClass);
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setString('selectedSubjectB', selectedSubjectB);
    await prefs.setString('selectedSubjectC', selectedSubjectC);
    await prefs.setString('selectedSubjectD', selectedSubjectD);
  }

  void subscribeToTopic(int a, int b) {
    FirebaseMessaging.instance.subscribeToTopic('${a}-${b}').then((_) {
      print('Subscription to "${a}-${b}" topic successful!');
    }).catchError((error) {
      print('Subscription to "${a}-${b}" topic failed: $error');
    });
  }

  void unsubscribeFromTopic(int a, int b) {
    FirebaseMessaging.instance.unsubscribeFromTopic('${a}-${b}').then((_) {
      print('Unsubscription from "${a}-${b}" topic successful!');
    }).catchError((error) {
      print('Unsubscription from "${a}-${b}" topic failed: $error');
    });
  }

  void showClassAndGradeDialog() {
    int tempGrade = defaultGrade;
    int tempClass = defaultClass;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("학년 반 설정"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<int>(
                    value: tempGrade,
                    items: List<DropdownMenuItem<int>>.generate(
                      3,
                          (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}학년'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => tempGrade = value);
                      }
                    },
                  ),
                  DropdownButton<int>(
                    value: tempClass,
                    items: List<DropdownMenuItem<int>>.generate(
                      11,
                          (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}반'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => tempClass = value);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                unsubscribeFromTopic(defaultGrade, defaultClass);
                setState(() {
                  defaultGrade = tempGrade;
                  defaultClass = tempClass;
                });
                if (notificationsEnabled) {
                  subscribeToTopic(defaultGrade, defaultClass);
                }
                savePreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSubjectSelectionDialogB() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSelectedSubjectB = selectedSubjectB;

        return AlertDialog(
          title: Text("탐구B 과목 선택"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: tempSelectedSubjectB,
                items: subjects
                    .map((subject) =>
                    DropdownMenuItem(value: subject, child: Text(subject)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => tempSelectedSubjectB = value);
                  }
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                setState(() => selectedSubjectB = tempSelectedSubjectB);
                savePreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSubjectSelectionDialogC() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSelectedSubjectC = selectedSubjectC;

        return AlertDialog(
          title: Text("탐구C 과목 선택"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: tempSelectedSubjectC,
                items: subjects
                    .map((subject) =>
                    DropdownMenuItem(value: subject, child: Text(subject)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => tempSelectedSubjectC = value);
                  }
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                setState(() => selectedSubjectC = tempSelectedSubjectC);
                savePreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void showSubjectSelectionDialogD() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSelectedSubjectD = selectedSubjectD;

        return AlertDialog(
          title: Text("탐구D 과목 선택"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: tempSelectedSubjectD,
                items: subjects
                    .map((subject) =>
                    DropdownMenuItem(value: subject, child: Text(subject)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => tempSelectedSubjectD = value);
                  }
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                setState(() => selectedSubjectD = tempSelectedSubjectD);
                savePreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void sendEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      print('Could not launch $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Settings"),
      ),
      child: SafeArea(
        child: Material(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("학년 반 설정"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => showClassAndGradeDialog(),
              ),
              ListTile(
                title: Text("탐구B 과목 선택 (2학년만 해당)"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => showSubjectSelectionDialogB(),
              ),
              ListTile(
                title: Text("탐구C 과목 선택 (2학년만 해당)"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => showSubjectSelectionDialogC(),
              ),
              ListTile(
                title: Text("탐구D 과목 선택 (2학년만 해당)"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => showSubjectSelectionDialogD(),
              ),
              ListTile(
                title: Text("개인정보처리방침"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => launchURL(
                    'https://yangcheon.sen.hs.kr/dggb/module/policy/selectPolicyDetail.do?policyTypeCode=PLC002&menuNo=75574'),
              ),
              ListTile(
                title: Text("학교 웹사이트 바로가기"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => launchURL('https://yangcheon.sen.hs.kr'),
              ),
              ListTile(
                title: Text("알림 설정"),
                trailing: CupertinoSwitch(
                  value: notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      notificationsEnabled = value;
                      if (notificationsEnabled) {
                        subscribeToTopic(defaultGrade, defaultClass);
                      } else {
                        unsubscribeFromTopic(defaultGrade, defaultClass);
                      }
                      savePreferences();
                    });
                  },
                ),
              ),
              ListTile(
                title: Text("개발자 문의하기"),
                trailing: Icon(Icons.email),
                onTap: () => sendEmail('help@helgisnw.me'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
