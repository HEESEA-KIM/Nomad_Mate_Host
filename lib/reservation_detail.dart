import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nomad/comfirmation.dart';
import 'firestore_data.dart';

class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;
  final FirestoreData firestoreData = FirestoreData();

  ReservationDetailsPage({Key? key, required this.reservationData})
      : super(key: key);

  Future<void> sendApprovalEmail() async {
    final url = Uri.parse(
        'https://us-central1-nomadmate.cloudfunctions.net/sendApprovalEmail'); // Firebase Function의 실제 URL로 대체
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to': reservationData['email'], // Firestore에서 받아온 이메일 주소
        'subject': '예약 승인 알림', // 메일 제목
        'body': '예약이 승인되었습니다. 감사합니다.', // 메일 본문
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예약고객정보'),
        backgroundColor: Color(0xFF2D3E5E),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InformationRow(
              label: '국적',
              value: reservationData['country'] ?? '정보 없음',
            ),
            InformationRow(
              label: '이름',
              value: reservationData['name'] ?? '정보 없음',
            ),
            InformationRow(
              label: '성별',
              value: reservationData['sex'] ?? '정보 없음',
            ),
            InformationRow(
              label: '이메일',
              value: reservationData['email'] ?? '정보 없음',
            ),
            InformationRow(
              label: '여권번호',
              value: reservationData['passportNumber'] ?? '정보 없음',
            ),
            InformationRow(
              label: '여권만료일',
              value: reservationData['passportExpirationDate'] ?? '정보 없음',
            ),
            InformationRow(
              label: '인원',
              value:
                  '${(reservationData['entries'] as List<dynamic>?)?.length ?? '정보 없음'}',
            ),
            InformationRow(
              label: '이용상품',
              value: reservationData['productName'] ?? '정보 없음',
            ),
            SizedBox(height: 40), // 텍스트와 버튼 사이의 공간을 추가합니다.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendApprovalEmail();
                    // HostAppHomePage로 이동합니다.
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmationPage()));
                  },
                  child: Text('승인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InformationRow extends StatelessWidget {
  final String label;
  final String value;

  const InformationRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 121, // label에 대한 고정된 너비
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          // valueWidget 또는 value를 표시하는 부분은 Expanded를 사용하여 나머지 공간을 차지하도록 합니다.
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.blueAccent,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
