import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nomad/firestore_data.dart';

class HostAppHomePage extends StatelessWidget {
  HostAppHomePage({super.key});
  final FirestoreData firestoreData = FirestoreData();
  @override
  Widget build(BuildContext context) {
    final firestoreData = FirestoreData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: const Color(0xFF2D3E5E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreData.getReservations(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var reservation = data.docs[index];
              var reservationData = reservation.data() as Map<String, dynamic>;

              // Firestore 'timestamp'를 DateTime 객체로 변환
              DateTime dateTime =
              (reservationData['timestamp'] as Timestamp).toDate();

              // 사용자가 읽기 쉬운 형식으로 날짜 포맷 변경
              String formattedDate =
              DateFormat('yyyy/MM/dd HH:mm').format(dateTime);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    width: 5.0,
                    height: double.infinity,
                    color: Colors.blue, // Example, adjust based on your data
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTranslatedText(reservationData['country'] ?? '', 'ko'),
                      Text(
                        "이름: ${reservationData['name'] ?? '이름 없음'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "예약날짜: ${reservationData['selectedDate'] ?? 'No Date'}",
                        style: const TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 13.0),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reservationData['statusText'] ?? '접수중',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Colors.blue,
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReservationDetailsPage(reservationData: reservationData)),
                    );
                    // Handle tap event
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildTranslatedText(String text, String targetLanguage) {
    return FutureBuilder<String>(
      future: firestoreData.translateText(text, targetLanguage),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...'); // 로딩 텍스트 또는 위젯
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Text('국적: ${snapshot.data ?? '번역 실패'}',style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),); // 번역된 텍스트 또는 기본값
        }
      },
    );
  }
}

class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;
  const ReservationDetailsPage({Key? key, required this.reservationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reservationData['name'] ?? 'Reservation Details'),
        backgroundColor: Color(0xFF2D3E5E),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("이름 : ${reservationData['name'] ?? 'N/A'}"),
            Text('성별 ?'),
            Text('나이 ?'),
            Text("국가 : ${reservationData['country'] ?? 'N/A'}"),
            Text("예약 날짜: ${reservationData['selectedDate'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }
}
