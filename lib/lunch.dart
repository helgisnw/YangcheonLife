import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LunchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: null,
      child: SafeArea(
        child: WebView(
          initialUrl: 'https://lunch.dkqq.me',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
