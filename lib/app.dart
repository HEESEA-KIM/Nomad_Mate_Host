import 'package:flutter/material.dart';

class HostAppHomePage extends StatelessWidget {
  const HostAppHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data to populate the list
    final List<Map<String, dynamic>> dataList = [
      {
        'Name': '홍길동',
        'statusColor': Colors.blue, // Assuming blue means 'pending'
        'statusText': '확인중', // 'Pending confirmation'
        'room': '디럭스', // 'Deluxe'
        'checkInDate': '11.07 (수) 22:00', // 'Check-in date and time'
        'confirmationNumber': '1908011157', // 'Confirmation number'
      },
      // Add more entries here
      // ...
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3E5E),
        // Custom color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            // Handle back icon press
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              '예약', // 'Reservation'
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
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
              margin: const EdgeInsets.all(8.0),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${data['room']}',
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${data['checkInDate']} ',
                      style: const TextStyle(fontSize: 13.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '예약: ${data['confirmationNumber']}',
                      style: const TextStyle(fontSize: 13.0),
                    ),
                  ],
                ),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
                ]),
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