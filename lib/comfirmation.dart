import 'package:flutter/material.dart';
import 'package:nomad/app.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20), // 내용 주변에 패딩을 추가합니다.
          child: Column(
            mainAxisSize: MainAxisSize.min, // 사용 가능한 최소 공간만 사용하도록 설정합니다.
            children: <Widget>[
              Icon(
                Icons.check_circle_outline, // 확인 아이콘 추가
                size: 100,
                color: Colors.green, // 아이콘 색상 지정
              ),
              SizedBox(height: 20), // 아이콘과 텍스트 사이의 공간을 추가합니다.
              Text(
                ('예약 승인이 완료되어 \n고객의 이메일로 예약 정보를\n 발송하였습니다.'),
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.deepPurple, // 텍스트 색상 변경
                  fontWeight: FontWeight.bold, // 글씨 두께 변경
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40), // 텍스트와 버튼 사이의 공간을 추가합니다.
              ElevatedButton(
                onPressed: () {
                  // HostAppHomePage로 이동합니다.
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HostAppHomePage()));
                },
                child: Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}