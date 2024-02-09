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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D3E5E), // Replace with your desired color
        elevation: 0, // Removes shadow below the AppBar
        leading: IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.white),
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
              '리버 부티크 호텔', // 'River Boutique Hotel' in Korean
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        centerTitle: true, // This centers the title column
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Handle menu icon press
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Your main content goes here'),
      ),
    );
  }
}