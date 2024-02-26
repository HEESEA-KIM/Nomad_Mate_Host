import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nomad/firestore_data.dart';
import 'package:nomad/reservation_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HostAppHomePage extends StatelessWidget {
  HostAppHomePage({super.key});

  final FirestoreData firestoreData = FirestoreData();

  @override
  Widget build(BuildContext context) {
    final firestoreData = FirestoreData();

    return Scaffold(
      appBar: AppBar(
        title: const Text(' 예약 현황 '),
        backgroundColor: const Color(0xFF2D3E5E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreData.getReservations(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text(" Loading...");
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
                      _buildTranslatedText(
                          reservationData['country'] ?? 'no Data', 'ko'),
                      SizedBox(height: 3),
                      Text(
                        "이름: ${reservationData['name'] ?? '이름 없음'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "예약날짜: ${reservationData['selectedDate'] ?? 'No Date'}",
                        style: const TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 3),
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
                          fontSize: 16,
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
                    navigateToDetailsPage(context, reservationData);
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
          return Text(
            '국적: ${snapshot.data ?? '번역 실패'}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ); // 번역된 텍스트 또는 기본값
        }
      },
    );
  }
  Future<void> navigateToDetailsPage(BuildContext context, Map<String, dynamic> reservationData) async {
    final translatedCountry = await firestoreData.translateText(reservationData['country'] ?? '', 'ko');
    final translatedSex = await firestoreData.translateText(reservationData['sex'] ?? '', 'ko');
    final translatedProductName = await firestoreData.translateText(reservationData['productName'] ?? '', 'ko');

    // 번역된 데이터를 포함하여 ReservationDetailsPage로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailsPage(
          reservationData: {
            ...reservationData,
            'country': translatedCountry,
            'sex': translatedSex,
            'productName': translatedProductName,
          },
        ),
      ),
    );
  }
}
