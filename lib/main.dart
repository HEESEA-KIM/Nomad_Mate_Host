import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        'Name' : '홍길동',
        'statusColor': Colors.blue, // Assuming blue means 'pending'
        'statusText': '확인중', // 'Pending confirmation'
        'room': '디럭스', // 'Deluxe'
        'roomType' : '숙박',
        'stayDuration': '1박', // '1 night'
        'checkInDate': '11.07 (수) 22:00', // 'Check-in date and time'
        'checkOutDate': '11.08 (목) 12:00', // 'Check-out date and time'
        'confirmationNumber': '1908011709320157', // 'Confirmation number'
      },
      // Add more entries here
      // ...
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D3E5E), // Custom color
        elevation: 0,
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
              '예약', // 'Reservation'
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '리버 부티크 호텔', // 'River Boutique Hotel'
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
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                leading: Container(
                  width: 5.0,
                  height: double.infinity,
                  color: data['statusColor'],
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['Name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text('${data['room']}',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold), ),
                    SizedBox(height: 10.0),
                    Text('${data['roomType']} / ${data['stayDuration']}'),
                    SizedBox(height: 10.0),
                    Text('${data['checkInDate']} - ${data['checkOutDate']}', style: TextStyle(fontSize: 13.0),),
                    SizedBox(height: 4.0),
                    Text('Confirmation: ${data['confirmationNumber']}', style: TextStyle(fontSize: 13.0),),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['statusText'],
                      style: TextStyle(
                        color: data['statusColor'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                      color: data['statusColor'],
                    )
                  ]
                ),
                onTap: () {
                  // Handle tap event
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}