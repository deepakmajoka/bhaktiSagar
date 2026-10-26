import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class LyriaMusicService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static final Uri _endpoint = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/interactions',
  );

  Future<Uint8List> generateAartiSong(String lyrics) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'Gemini API key missing. Run with --dart-define=GEMINI_API_KEY=YOUR_KEY.',
      );
    }

    final prompt = '''
Create a complete Hindi devotional bhajan song using the supplied aarti lyrics.
Sing in a traditional, peaceful North Indian bhajan style with a warm lead vocal,
harmonium, tabla, and manjira at a moderate, steady tempo. Use the supplied
lyrics as written; do not translate them or invent replacement lyrics. Keep the
full song continuous from beginning to end.

Lyrics:
$lyrics
''';

    final response = await http.post(
      _endpoint,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey,
      },
      body: jsonEncode({
        'model': 'lyria-3.5',
        'input': prompt,
      }),
    ).timeout(const Duration(minutes: 5));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final audioBase64 = _findAudioData(responseJson);
    if (audioBase64 == null || audioBase64.isEmpty) {
      throw StateError('Lyria returned no song audio.');
    }

    return base64Decode(audioBase64);
  }

  String? _findAudioData(Map<String, dynamic> response) {
    final outputAudio = response['output_audio'];
    if (outputAudio is Map<String, dynamic> && outputAudio['data'] is String) {
      return outputAudio['data'] as String;
    }

    final steps = response['steps'];
    if (steps is List) {
      for (final step in steps) {
        if (step is! Map<String, dynamic>) continue;
        final content = step['content'];
        if (content is! List) continue;

        for (final block in content) {
          if (block is Map<String, dynamic> &&
              block['type'] == 'audio' &&
              block['data'] is String) {
            return block['data'] as String;
          }
        }
      }
    }

    return null;
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'];
      if (error is Map<String, dynamic> && error['message'] is String) {
        return 'Lyria request failed (${response.statusCode}): ${error['message']}';
      }
    } catch (_) {
      // Fall back to the HTTP status if the API returned a non-JSON body.
    }
    return 'Lyria request failed (${response.statusCode}).';
  }
}
