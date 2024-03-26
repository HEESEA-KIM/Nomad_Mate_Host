import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  File? _selectedImage; // 선택된 이미지 파일을 저장할 변수
  // FocusNode 인스턴스 추가 자동으로 프로프트를 비워져있는 텍스트필드로 이동
  final FocusNode _businessFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // 로딩 상태를 추적하는 변수 추가
  bool _isLoading = false;

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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(), // 로딩 인디케이터 표시
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _businessController,
                    focusNode: _businessFocusNode,
                    decoration: InputDecoration(
                      labelText: "상호명",
                      hintText: "상호명을 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {},
                  ),
                  SizedBox(height: 25),
                  TextField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    decoration: InputDecoration(
                      labelText: "주소",
                      hintText: "주소를 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {},
                  ),
                  SizedBox(height: 25),
                  TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    decoration: InputDecoration(
                      labelText: "연락처",
                      hintText: "-없이 입력해주세요",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {},
                  ),
                  SizedBox(height: 25),
                  TextField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 50),
                      labelText: "상품 설명",
                      labelStyle: TextStyle(fontSize: 15),
                      hintText: "상품에 대한 설명을 적어주세요.\n(150자 이내)",
                      hintStyle: TextStyle(fontSize: 13),
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 150,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  SizedBox(height: 10),
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
                            _isPasswordMatched =
                                _passwordController.text == value;
                          });
                        },
                        onSubmitted: (_) {},
                      ),
                      // 비밀번호 일치 여부에 따른 메시지 표시
                      Text(
                        _isPasswordMatched
                            ? "비밀번호가 일치합니다."
                            : "비밀번호가 일치하지 않습니다.",
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
    setLoading(true); // 로딩 시작
    // 비밀번호 복잡성을 검사하기 위한 정규 표현식 (영문, 숫자, 특수기호 포함 10자 이상)
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{10,}$',
    );

    // 필수 필드 검사
    if (_emailController.text.isEmpty) {
      setLoading(false);
      _showWarningDialog("이메일을 입력해 주세요.");
      return;
    } else if (!EmailValidator.validate(
      _emailController.text.trim().replaceAll(' ', ''),
    )) {
      print("검증할 이메일 주소: ${_emailController.text.trim()}");
      setLoading(false);
      _showWarningDialog("유효한 이메일 형식이 아닙니다.");
      return;
    } else if (_passwordController.text.isEmpty) {
      setLoading(false);
      _showWarningDialog("비밀번호를 입력해주세요");
      return;
    } else if (!passwordRegExp.hasMatch(_passwordController.text)) {
      setLoading(false);
      _showWarningDialog("비밀번호는 영문, 숫자, 특수기호 조합으로 10자 이상이어야 합니다.");
      return;
    } else if (_confirmPasswordController.text.isEmpty) {
      setLoading(false);
      _showWarningDialog("비밀번호 확인란을 입력해주세요.");
      return;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setLoading(false);
      _showWarningDialog("비밀번호가 일치하지 않습니다. 다시 입력해주세요.");
      return;
    } else if (_selectedImage == null) {
      // 이미지 선택 여부 검증 추가
      setLoading(false);
      _showWarningDialog("이미지를 선택해주세요.");
      return;
    }
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 사용자가 생성되면 즉시 이미지 업로드 및 Firestore에 사용자 정보 저장
      if (userCredential.user != null) {
        await _uploadImageToFirebase(userCredential.user!);
      }
    } catch (e) {
      setLoading(false);
      _showWarningDialog("회원가입 중 오류가 발생했습니다. ${e.toString()}");
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

  Future<void> _uploadImageToFirebase(User user) async {
    if (_selectedImage == null) {
      setLoading(false);
      _showWarningDialog("이미지를 선택해주세요.");
      return;
    }

    String fileName = 'user_images/${DateTime.now()}.png';
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      await storage.ref(fileName).putFile(_selectedImage!);
      final imageUrl = await storage.ref(fileName).getDownloadURL();
      print("업로드된 이미지 URL: $imageUrl");
      // Firebase Authentication으로부터 현재 사용자의 UID를 얻음
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore에 사용자 데이터 저장
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('userInformation').doc(user.uid).set({
          'timestamp': Timestamp.now(),
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'imageURL': imageUrl,
          'isVerified': false,
          'subscriptionCode': "",
        });
      }
      setLoading(false);
      _showRegistrationCompleteDialog();
      // 회원가입 프로세스가 성공적으로 완료된 후, 사용자를 로그아웃시킵니다.
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
      setLoading(false);
      _showWarningDialog("이미지 업로드에 실패했습니다.");
    }
  }

  void _showRegistrationCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '회원가입 완료',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          content: Text(
            '회원가입 요청이 접수되었습니다.\n승인 후 이메일로 안내드립니다.',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기

                // 회원가입 완료 후 로그아웃 처리
                await FirebaseAuth.instance.signOut();

                // 로그인 페이지로 돌아가기
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()));
                }
              },
            ),
          ],
        );
      },
    );
  }

  //로딩상태 관리 함수
  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}
