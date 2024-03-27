import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nomad/app.dart';
import 'package:nomad/registration.dart';
import 'package:nomad/reset_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

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
            : SingleChildScrollView(
              child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            AppBar().preferredSize.height -
                            MediaQuery.of(context).padding.top),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '아이디',
                            hintText: '아이디를 입력하세요',
                          ),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                        SizedBox(height: 10.0),
                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '비밀번호',
                            hintText: '비밀번호를 입력하세요',
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {},
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
                                    Size(screenWidth * 0.1, 45)),
                              ),
                              child: Text(
                                '아이디 찾기',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ResetPasswordPage()));
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    Size(screenWidth * 0.1, 45)),
                              ),
                              child: Text(
                                '비밀번호 찾기',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RegistrationPage()));
                              },
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    Size(screenWidth * 0.1, 45)),
                              ),
                              child: Text(
                                '회원가입',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    if (!EmailValidator.validate(
      _emailController.text.trim().replaceAll(' ', ''),
    )) {
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
        email: _emailController.text.trim().replaceAll(' ', ''),
        password: _passwordController.text,
      );
      // 현재 로그인된 사용자 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Firestore에서 사용자의 `isVerified` 상태 및 `subscriptionCode` 조회
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('userInformation') // 사용자 정보가 있는 적절한 컬렉션을 선택하세요
            .doc(currentUser.uid)
            .get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        // userData가 null이 아니고, 'isVerified' 키를 포함하며, 해당 값이 true일 경우 로직을 수행
        if (userData != null &&
            userData.containsKey('isVerified') &&
            userData['isVerified'] == true) {
          if (userData.containsKey('subscriptionCode')) {
            String subscriptionCode = userData['subscriptionCode'];
            await subscribeToTopic(subscriptionCode);
          }
          // 로그인 성공 시 메인 페이지로 이동
          if (mounted) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HostAppHomePage()));
          }
        } else {
          // `isVerified`가 false이거나 필드가 없는 경우
          _showWarningDialog("계정이 인증되지 않았습니다\n관리자 승인을 기다려주세요.");
        }
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
        errorMessage = "사용자를 찾을 수 없습니다.\n이메일을 확인해 주세요.";
        break;
      case 'wrong-password':
        errorMessage = "잘못된 비밀번호입니다\n다시 시도해 주세요.";
        break;
      default:
        errorMessage = "로그인에 실패했습니다.\n다시 시도해 주세요.";
    }

    _showWarningDialog(errorMessage);
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '로그인 실패',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 13,
            ),
          ),
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

  Future<void> subscribeToTopic(String subscriptionCode) async {
    await FirebaseMessaging.instance
        .subscribeToTopic("subscriptionCode_$subscriptionCode");
  }
}
