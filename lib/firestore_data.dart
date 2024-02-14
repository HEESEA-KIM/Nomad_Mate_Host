import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReservations() {
    return _firestore.collection('reservations').snapshots();
  }
  Future<String> translateText(String text, String targetLanguage) async {
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
        return translatedText; // 여기에 return을 추가합니다.
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