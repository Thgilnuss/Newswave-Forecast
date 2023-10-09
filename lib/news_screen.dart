import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'browser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsInfo {
  final String title;
  final String image;
  final String link;

  NewsInfo({required this.title, required this.image, required this.link});
}

void openLinkInWebView(BuildContext context, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => WebViewScreen(url)),
  );
}

class CustomDrawer extends StatelessWidget {
  final void Function(NewsInfo) onRssMenuSelected;

  CustomDrawer({required this.onRssMenuSelected});

  ListTile buildMenuTile(String title, String rssUrl, BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Color(0xFFffffe6), fontSize: 18),
      ),
      onTap: () {
        onRssMenuSelected(NewsInfo(title: title, image: '', link: rssUrl));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final drawerWidth = min(230.0, deviceWidth * 0.7);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.75),
        border: Border.all(color: Colors.blue.withOpacity(0.6)),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(100.0),
          bottomRight: Radius.circular(100.0),
          bottomLeft: Radius.circular(100.0),
        ),
      ),
      width: drawerWidth,
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                buildMenuTile(
                    'Trang chủ', 'https://vnexpress.net/rss/tin-moi-nhat.rss', context),
                buildMenuTile(
                    'Thế giới', 'https://vnexpress.net/rss/the-gioi.rss', context),
                buildMenuTile(
                    'Thời sự', 'https://vnexpress.net/rss/thoi-su.rss', context),
                buildMenuTile(
                    'Kinh doanh', 'https://vnexpress.net/rss/kinh-doanh.rss', context),
                buildMenuTile(
                    'Ý kiến', 'https://vnexpress.net/rss/y-kien.rss', context),
                buildMenuTile(
                    'Giải trí', 'https://vnexpress.net/rss/giai-tri.rss', context),
                buildMenuTile(
                    'Thể thao', 'https://vnexpress.net/rss/the-thao.rss', context),
                buildMenuTile(
                    'Pháp luật', 'https://vnexpress.net/rss/phap-luat.rss', context),
                buildMenuTile(
                    'Giáo dục', 'https://vnexpress.net/rss/giao-duc.rss', context),
                buildMenuTile(
                    'Sức khỏe', 'https://vnexpress.net/rss/suc-khoe.rss', context),
                buildMenuTile(
                    'Đời sống', 'https://vnexpress.net/rss/gia-dinh.rss', context),
                buildMenuTile(
                    'Du lịch', 'https://vnexpress.net/rss/du-lich.rss', context),
                buildMenuTile(
                    'Khoa học', 'https://vnexpress.net/rss/khoa-hoc.rss', context),
                buildMenuTile(
                    'Số hóa', 'https://vnexpress.net/rss/so-hoa.rss', context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String selectedRssUrl = 'https://vnexpress.net/rss/tin-moi-nhat.rss';
  List<NewsInfo> selectedNewsInfoList = [];

  @override
  void initState() {
    super.initState();
    fetchRssData(selectedRssUrl);
  }

  Future<void> fetchRssData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final xmlDoc = XmlDocument.parse(utf8.decode(response.bodyBytes));
        List<NewsInfo> newsList = [];
        for (var item in xmlDoc.findAllElements('item')) {
          var title = item.getElement('title')?.text ?? '';
          var image = 'assets/images/VnExpress.jpg';
          var link = item.getElement('link')?.text ?? '';
          newsList.add(NewsInfo(title: title, image: image, link: link));
        }
        setState(() {
          selectedNewsInfoList = newsList;
        });
      } else {
        throw Exception('Failed to load RSS data');
      }
    } finally {
      // Kết thúc quá trình làm mới
      // Đảm bảo rằng RefreshIndicator đã kết thúc quá trình làm mới
      // Việc này sẽ ẩn đi hiệu ứng làm mới
    }
  }


  void handleMenuSelected(NewsInfo newsInfo) async {
    setState(() {
      selectedRssUrl = newsInfo.link;
    });
    Navigator.pop(context);
    await fetchRssData(newsInfo.link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF140029).withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.wb_sunny,
                        size: 38.0,
                        color: Colors.yellow,
                      ),
                      onPressed: () {
                        // Navigate to Weather screen
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 100),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.newspaper,
                        size: 38.0,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Do nothing (already on News screen)
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Weather',
                    style: TextStyle(
                      color: Color(0xFFffffe6),
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 100),
                  Text(
                    'News',
                    style: TextStyle(
                      color: Color(0xFFffffe6),
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // ... (nút bấm bên phải nếu cần)
        ],
      ),
      drawer: CustomDrawer(onRssMenuSelected: handleMenuSelected),
      body: RefreshIndicator(
        onRefresh: () async{
          await fetchRssData(selectedRssUrl);
        },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: selectedNewsInfoList.length,
          itemBuilder: (context, index) {
            var newsInfo = selectedNewsInfoList[index];
            return Card(
              color: Colors.blue.withOpacity(0.27),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                contentPadding: EdgeInsets.all(10.0),
                leading: Container(
                  width: 80.0,
                  child: Image.asset(
                    newsInfo.image,
                  ),
                ),
                title: SizedBox(
                  width: MediaQuery.of(context).size.width - 200,
                  child: Text(
                    newsInfo.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  openLinkInWebView(context, newsInfo.link);
                },
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

void launchURL(String url) async {
  try {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    print('Error launching URL: $e');
  }
}