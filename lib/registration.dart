import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _selectedImage; // 선택된 이미지 파일을 저장할 변수
  // FocusNode 인스턴스 추가 자동으로 프로프트를 비워져있는 텍스트필드로 이동
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

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
                  onSubmitted: (_) {},
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
                SizedBox(height: 25),
                OutlinedButton(
                  onPressed: _pickImage,
                  child: Text('이미지 선택'),
                ),
                SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 350,
                        height: 330,
                        fit: BoxFit.cover,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('사업자등록증을 업로드해 주세요.'),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '사업자등록증은 인증을 위한 용도 이외에\n사용되지 않습니다.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
    await _uploadImageToFirebase();
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _selectedImage = File(image.path);
      } else {
        print('이미지가 선택되지 않았습니다.');
      }
    });
  }

  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) {
      _showWarningDialog("이미지를 선택해주세요.");
      return;
    }

    String fileName = 'user_images/${DateTime.now()}.png';
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      await storage.ref(fileName).putFile(_selectedImage!);
      final imageUrl = await storage.ref(fileName).getDownloadURL();
      print("업로드된 이미지 URL: $imageUrl");

      // 업로드 성공 후 회원가입 완료 메시지를 보여주고, "OK"를 누르면 LoginPage로 돌아갑니다.
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('회원가입 완료'),
              content: Text('회원가입 요청이 정상적으로 접수되었습니다. 승인 후 이메일로 안내드리겠습니다.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    // 여기서 Navigator.pop을 두 번 호출하여, AlertDialog와 RegistrationPage 둘 다를 pop합니다.
                    // LoginPage로 돌아가기 위함입니다.
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e);
      _showWarningDialog("이미지 업로드에 실패했습니다.");
    }
  }
}
