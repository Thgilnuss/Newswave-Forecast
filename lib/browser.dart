import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  final String url;

  WebViewScreen(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarTextStyle: TextStyle(),
        title: Text('App browser'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding( // Thêm thuộc tính này
        padding: EdgeInsets.only(top: 90.0), // Đặt khoảng cách mong muốn
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
