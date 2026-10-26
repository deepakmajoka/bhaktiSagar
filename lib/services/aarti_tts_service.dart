import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class AartiTtsService {
  static const String _modelName = 'gemini-3.1-flash-tts-preview';
  static const int _sampleRate = 24000;

  Future<Uint8List> createHindiSpeech(String text) async {
    final config = GenerationConfig(
      responseModalities: [ResponseModalities.audio],
      speechConfig: SpeechConfig(
        voiceName: 'Kore',
        languageCode: 'hi-IN',
      ),
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      generationConfig: config,
    );

    final response = await model.generateContent([Content.text(text)]);

    final pcmBuilder = BytesBuilder(copy: false);
    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is InlineDataPart && part.mimeType.startsWith('audio/')) {
          pcmBuilder.add(part.bytes);
        }
      }
    }

    final pcmBytes = pcmBuilder.takeBytes();
    if (pcmBytes.isEmpty) {
      throw StateError('Gemini did not return audio for this aarti.');
    }

    return _toWav(pcmBytes);
  }

  Uint8List _toWav(Uint8List pcmBytes) {
    const channels = 1;
    const bitsPerSample = 16;
    const bytesPerSample = bitsPerSample ~/ 8;
    const byteRate = _sampleRate * channels * bytesPerSample;
    const blockAlign = channels * bytesPerSample;

    final wavBytes = Uint8List(44 + pcmBytes.length);
    final header = ByteData.sublistView(wavBytes);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        wavBytes[offset + i] = value.codeUnitAt(i);
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + pcmBytes.length, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // Linear PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, _sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, pcmBytes.length, Endian.little);
    wavBytes.setRange(44, wavBytes.length, pcmBytes);

    return wavBytes;
  }
}
