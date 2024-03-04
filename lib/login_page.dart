import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nomad/app.dart';
import 'package:nomad/registration.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 페이지'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: _isLoading
            ? Center(
                child: SpinKitFadingCircle(
                  // 로딩 인디케이터
                  color: Colors.blue,
                  size: 50.0,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'NOMAD MATE',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '아이디',
                      hintText: '아이디를 입력하세요',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: _login, // 수정된 부분
                    child: Text('Login'),
                  ),
                  SizedBox(height: 18.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                              Size(screenWidth * 0.28, 50)),
                        ),
                        child: Text('아이디 찾기'),
                      ),
                      ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                              Size(screenWidth * 0.28, 50)),
                        ),
                        child: Text('비밀번호 찾기'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RegistrationPage()));
                        },
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                              Size(screenWidth * 0.28, 50)),
                        ),
                        child: Text('회원가입'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    if (!EmailValidator.validate(_emailController.text.trim())) {
      _showWarningDialog("유효한 이메일 주소를 입력하세요.");
      setState(() {
        _isLoading = false; // 로딩 종료
      });
      return;
    }

    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 6) {
      _showWarningDialog("비밀번호는 6자리 이상이어야 합니다.");
      setState(() {
        _isLoading = false; // 로딩 종료
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 로그인 성공 시 메인 페이지로 이동
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HostAppHomePage()));
      }
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 종료
        });
      }
    }
  }

  void _handleLoginError(FirebaseAuthException e) {
    String errorMessage;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = "사용자를 찾을 수 없습니다. 이메일을 확인해 주세요.";
        break;
      case 'wrong-password':
        errorMessage = "잘못된 비밀번호입니다. 다시 시도해 주세요.";
        break;
      default:
        errorMessage = "로그인에 실패했습니다. 다시 시도해 주세요.";
    }

    _showWarningDialog(errorMessage);
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 실패'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
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
