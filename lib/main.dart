import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom AppBar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data to populate the list
    final List<Map<String, dynamic>> dataList = [
      {
        'title': '확인중',
        'subtitle': '디럭스 / 1박',
        'dates': '11.07 (수) 22:00 - 11.08 (목) 12:00',
        'confirmationNumber': '1908011709320157',
      },
      // Add more entries here
      // ...
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D3E5E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back icon press
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '예약',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '리버 부티크 호텔',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Handle menu icon press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: dataList.map((data) {
            return Card(
              child: ListTile(
                title: Text(data['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(data['subtitle']),
                    Text(data['dates']),
                    Text(data['confirmationNumber']),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}