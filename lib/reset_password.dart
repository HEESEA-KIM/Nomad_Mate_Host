import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() async {
    if (_emailController.text.isEmpty ||
        !EmailValidator.validate(
          _emailController.text.trim().replaceAll(' ', ''),
        )) {
      _showDialog("유효한 이메일 주소를 입력하세요.");
    } else {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        _showDialog("비밀번호 재설정 링크가 이메일로 전송되었습니다. 이메일을 확인해주세요.");
      } catch (e) {
        _showDialog("비밀번호 재설정 이메일 전송에 실패했습니다. 다시 시도해주세요.");
      }
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("알림",style: TextStyle(fontSize: 17),),
        content: Text(message,style: TextStyle(fontSize: 13),),
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
        title: Text("비밀번호 재설정"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center( // Center 위젯 추가
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("비밀번호 재설정을 위해 \n가입하신 이메일 주소를 입력해주세요."),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "이메일"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text("비밀번호 재설정 링크 보내기"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
