import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  int defaultGrade = 1;
  int defaultClass = 1;

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
    });
  }

  savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultGrade', defaultGrade);
    await prefs.setInt('defaultClass', defaultClass);
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
                title: Text("Default Class and Grade"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => showClassAndGradeDialog(),
              ),
              // Add more settings options here
            ],
          ),
        ),
      ),
    );
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
    // Temporary variables to hold the values during the dialog interaction
    int tempGrade = defaultGrade;
    int tempClass = defaultClass;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Set Default Class and Grade"),
          content: StatefulBuilder( // Use StatefulBuilder to manage state in the dialog
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<int>(
                    value: tempGrade,
                    items: List<DropdownMenuItem<int>>.generate(
                      3,
                          (index) =>
                          DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}학년'),
                          ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() =>
                        tempGrade = value); // Update the temporary state
                      }
                    },
                  ),
                  DropdownButton<int>(
                    value: tempClass,
                    items: List<DropdownMenuItem<int>>.generate(
                      11,
                          (index) =>
                          DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}반'),
                          ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() =>
                        tempClass = value); // Update the temporary state
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  // Update the state of your main settings when saved
                  unsubscribeFromTopic(defaultGrade, defaultClass);
                  defaultGrade = tempGrade;
                  defaultClass = tempClass;
                  subscribeToTopic(defaultGrade, defaultClass);
                });
                savePreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

