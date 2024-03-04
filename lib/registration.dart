import 'package:flutter/material.dart';
import 'package:nomad/firestore_data.dart';
import 'login_page.dart';
import 'dart:async';

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
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  // FocusNode 인스턴스 추가 자동으로 프로프트를 비워져있는 텍스트필드로 이동
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _subscriptionFocusNode = FocusNode();
  final FocusNode _phoneNumFocusNode = FocusNode();
  final FocusNode _verificationCodeFocusNode = FocusNode();

  Timer? _timer;
  bool _showVerificationField = false;
  int _remainingTime = 10; // 3분을 초 단위로 표현
  // 비밀번호 일치 여부를 추적하는 변수
  bool _isPasswordMatched = false;

  @override
  void dispose() {
    _timer?.cancel(); // 위젯이 dispose될 때 타이머를 취소
    super.dispose();
  }

  void _startTimer() {
    _remainingTime = 10; // 3분으로 초기화
    _timer?.cancel(); // 기존 타이머가 있다면 취소
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        // 시간이 만료되었을 때의 동작을 여기에 추가
        _showWarningDialog("인증번호 입력 시간이 만료되었습니다.");
      }
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _phoneNumController,
                    focusNode: _phoneNumFocusNode,
                    decoration: InputDecoration(
                      labelText: "휴대폰번호",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {},
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 130,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // 인증번호 입력 필드를 표시하기 위해 상태 업데이트
                        _showVerificationField = true;
                      });

                      _startTimer();
                      FocusScope.of(context)
                          .requestFocus(_verificationCodeFocusNode);
                    },
                    child: Text(
                      "인증번호\n요청",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            if (_showVerificationField) SizedBox(height: 25),
            if (_showVerificationField)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _verificationCodeController,
                          focusNode: _verificationCodeFocusNode,
                          decoration: InputDecoration(
                            labelText: "인증번호",
                            hintText: "인증번호 입력",
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      Text(
                        '남은 시간: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // 남은 시간 표시
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                      width: 130,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // 인증번호 입력 필드를 표시하기 위해 상태 업데이트
                            _showVerificationField = true;
                          });
                        },
                        child: Text(
                          "인증번호\n확인",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
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
    // 이메일 유효성 검사를 위한 정규 표현식
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );

    // 비밀번호 복잡성을 검사하기 위한 정규 표현식 (영문, 숫자, 특수기호 포함 10자 이상)
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{10,}$',
    );

    // 필수 필드 검사
    if (_emailController.text.isEmpty) {
      _showWarningDialog("이메일을 입력해 주세요.");
      FocusScope.of(context).requestFocus(_emailFocusNode);
      return; // 메서드 실행 종료
    } else if (!emailRegExp.hasMatch(_emailController.text)) {
      _showWarningDialog("유효한 이메일 형식이 아닙니다.");
      FocusScope.of(context).requestFocus(_emailFocusNode);
      return; // 메서드 실행 종료
    } else if (_passwordController.text.isEmpty) {
      _showWarningDialog("비밀번호를 입력해주세요");
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      return; // 메서드 실행 종료
    } else if (!passwordRegExp.hasMatch(_passwordController.text)) {
      _showWarningDialog("비밀번호는 영문, 숫자, 특수기호 조합으로 10자 이상이어야 합니다.");
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      return; // 메서드 실행 종료
    } else if (_confirmPasswordController.text.isEmpty) {
      _showWarningDialog("비밀번호 확인란을 입력해주세요.");
      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      return; // 메서드 실행 종료
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _showWarningDialog("비밀번호가 일치하지 않습니다. 다시 입력해주세요.");
      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      return; // 메서드 실행 종료
    } else if (_subscriptionController.text.isEmpty) {
      _showWarningDialog("구독코드를 입력해주세요.");
      FocusScope.of(context).requestFocus(_subscriptionFocusNode);
      return; // 메서드 실행 종료
    } else if (_subscriptionController.text.isEmpty) {
      _showWarningDialog("구독코드를 입력해주세요.");
      FocusScope.of(context).requestFocus(_subscriptionFocusNode);
      return; // 메서드 실행 종료
    } else if (_phoneNumController.text.isEmpty) {
      _showWarningDialog("전화번호를 입력해주세요");
      FocusScope.of(context).requestFocus(_phoneNumFocusNode);
      return; // 메서드 실행 종료
    }

    // Firestore에 저장할 데이터 준비
    Map<String, dynamic> userDate = {
      'email': _emailController.text,
      'phone': _phoneNumController.text,
      'subscription': _subscriptionController.text,
    };

    final firestoreService = FirestoreData();
    try {
      await firestoreService.addReservation(userDate);
      // 저장 성공 시 'Reservation Confirmation' 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      _showSuccessDialog();
    } catch (e) {
      // 저장 실패 시 처리, 예를 들어 오류 메시지 표시
      _showWarningDialog("네트워크 상의 이유로 회원가입이 실패했습니다.\n 다시 시도해주세요.: $e");
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원가입 완료'),
          content: Text("회원가입이 완료되었습니다."),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 알림창을 닫음
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage()), // LoginPage로 이동
                );
              },
            ),
          ],
        );
      },
    );
  }
}