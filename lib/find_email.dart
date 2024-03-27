import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindEmailPage extends StatefulWidget {
  const FindEmailPage({Key? key}) : super(key: key);

  @override
  _FindEmailPageState createState() => _FindEmailPageState();
}

class _FindEmailPageState extends State<FindEmailPage> {
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _findEmail() async {
    final String businessName = _businessController.text.trim();
    final String phoneNumber = _phoneController.text.trim();

    if (businessName.isEmpty || phoneNumber.isEmpty) {
      _showDialog("상호명과 연락처를 모두\n입력해주세요.");
      return;
    }

    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('userInformation')
          .where('business', isEqualTo: businessName)
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (result.docs.isNotEmpty) {
        // 이메일 주소 가져오기
        final String email = result.docs.first.get('email');
        _showDialog("귀하의 이메일 주소는\n\n$email");
      } else {
        _showDialog("해당 정보와 일치하는 사용자를 찾을 수 없습니다.");
      }
    } catch (e) {
      _showDialog("이메일 찾기에 실패했습니다. 다시 시도해주세요.");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("알림",style: TextStyle(fontSize: 17),),
        content: Text(message,style: TextStyle(fontSize: 12),),
        actions: <Widget>[
          TextButton(
            child: Text('확인'),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("이메일 찾기"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("회원가입 시 등록한 상호명과 연락처를 모두 입력해주세요."),
                SizedBox(height: 20),
                TextField(
                  controller: _businessController,
                  decoration: InputDecoration(labelText: "상호명"),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "연락처",hintText: " - 없이 입력해주세요."),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _findEmail,
                  child: Text("이메일 찾기"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
