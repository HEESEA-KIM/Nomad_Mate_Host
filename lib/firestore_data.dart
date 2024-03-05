import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _translationCache = {};

  // 로그인한 사용자의 구독 코드에 맞는 예약 데이터를 스트림으로 반환합니다.
  Stream<QuerySnapshot> getReservationsForCode(String subscriptionCode) {
    return _firestore
        .collection('reservations')
        .where('subscriptionCode', isEqualTo: subscriptionCode)
        .snapshots();
  }

  // 현재 로그인한 사용자의 구독 코드를 가져오는 메서드입니다.
  Future<String?> getUserSubscriptionCode() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('userInformation').doc(user.uid).get();
      if (userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data()! as Map<String, dynamic>;
        String? subscriptionCode = userData['subscriptionCode'] as String?;
        return subscriptionCode;
      }
    }
    return null;
  }
  Future<String> translateText(String text, String targetLanguage) async {

    final cacheKey = '$text:$targetLanguage';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    final apiKey = dotenv.env['APP_KEY'] ?? '';
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['data']['translations'][0]['translatedText'];
        // 번역 결과를 캐시에 저장
        _translationCache[cacheKey] = translatedText;

        return translatedText;
      } else {
        print('Translation API error: ${response.statusCode}, ${response.body}');
        return 'Error: Unable to translate';
      }
    } catch (e) {
      print('Translation API exception: $e');
      return 'Exception: Unable to translate';
    }
  }
  Future<void> addUser(Map<String, dynamic> reservationData) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      reservationData['timestamp'] = FieldValue.serverTimestamp();
      // 현재 사용자의 uid를 문서 ID로 사용합니다.
      await _firestore.collection('userInformation').doc(user.uid).set(reservationData);
    }
// Add more Firestore operations here as needed
}
}