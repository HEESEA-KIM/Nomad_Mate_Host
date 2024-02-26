import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _translationCache = {}; // 캐싱을 위한 맵 추가

  Stream<QuerySnapshot> getReservations() {
    return _firestore.collection('reservations').snapshots();
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
// Add more Firestore operations here as needed
}