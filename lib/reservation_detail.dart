import 'package:flutter/material.dart';

class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  const ReservationDetailsPage({Key? key, required this.reservationData})
      : super(key: key);

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
            InformationRow(label: '국적', value: '대한민국'),
            InformationRow(label: '이름', value: '홍길동'),
            InformationRow(label: '성별', value: '남자'),
            InformationRow(label: '이메일', value: 'gmltp@naver.com'),
            InformationRow(label: '여권번호', value: '0101010'),
            InformationRow(label: '여권만료일', value: '2024-03-30'),
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
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.blueAccent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
