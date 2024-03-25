import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _subscriptionController = TextEditingController();

  // FocusNode 인스턴스 추가 자동으로 프로프트를 비워져있는 텍스트필드로 이동
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _subscriptionFocusNode = FocusNode();
  final FocusNode _phoneNumFocusNode = FocusNode();

  // 비밀번호 일치 여부를 추적하는 변수
  bool _isPasswordMatched = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원가입"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                labelText: "이메일",
                hintText: "이메일을 입력하세요",
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "비밀번호",
                    hintText: "비밀번호를 입력하세요",
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode);
                  },
                ),
                Text(
                  "비밀번호는 영문+숫자+특수기호 조합으로 10자 이상",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "비밀번호 확인",
                    hintText: "비밀번호를 다시 입력하세요",
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    // 비밀번호 일치 여부를 검사
                    setState(() {
                      _isPasswordMatched = _passwordController.text == value;
                    });
                  },
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_subscriptionFocusNode);
                  },
                ),
                // 비밀번호 일치 여부에 따른 메시지 표시
                Text(
                  _isPasswordMatched ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isPasswordMatched ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            TextField(
              controller: _subscriptionController,
              focusNode: _subscriptionFocusNode,
              decoration: InputDecoration(
                labelText: "구독코드",
                hintText: "구독코드를 입력하세요",
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_phoneNumFocusNode);
              },
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    // 비밀번호 복잡성을 검사하기 위한 정규 표현식 (영문, 숫자, 특수기호 포함 10자 이상)
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{10,}$',
    );

    // 필수 필드 검사
    if (_emailController.text.isEmpty) {
      _showWarningDialog("이메일을 입력해 주세요.");
      return;
    } else if (!EmailValidator.validate(
      _emailController.text.trim().replaceAll(' ', ''),
    )) {
      print("검증할 이메일 주소: ${_emailController.text.trim()}");
      _showWarningDialog("유효한 이메일 형식이 아닙니다.");
      return;
    } else if (_passwordController.text.isEmpty) {
      _showWarningDialog("비밀번호를 입력해주세요");
      return;
    } else if (!passwordRegExp.hasMatch(_passwordController.text)) {
      _showWarningDialog("비밀번호는 영문, 숫자, 특수기호 조합으로 10자 이상이어야 합니다.");
      return;
    } else if (_confirmPasswordController.text.isEmpty) {
      _showWarningDialog("비밀번호 확인란을 입력해주세요.");
      return;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _showWarningDialog("비밀번호가 일치하지 않습니다. 다시 입력해주세요.");
      return;
    }
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
