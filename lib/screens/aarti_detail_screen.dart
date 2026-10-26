import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // Audio package import kiya
import '../models/aarti_model.dart';
import '../services/aarti_tts_service.dart';
import '../services/lyria_music_service.dart';

class AartiDetailScreen extends StatefulWidget {
  final Aarti aarti;

  const AartiDetailScreen({super.key, required this.aarti});

  @override
  State<AartiDetailScreen> createState() => _AartiDetailScreenState();
}

class _AartiDetailScreenState extends State<AartiDetailScreen> {
  double _fontSize = 18.0;

  // Audio player ka instance banaya
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AartiTtsService _ttsService = AartiTtsService();
  final LyriaMusicService _lyriaService = LyriaMusicService();
  bool _isGeneratingSpeech = false;
  bool _isGeneratingSong = false;
  bool _isAiSpeechPlaying = false;
  bool _isAiSongPlaying = false;
  late final StreamSubscription<void> _playbackCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _playbackCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isAiSpeechPlaying = false;
          _isAiSongPlaying = false;
        });
      }
    });
  }

  // Ghanti bajane ka function
  void _playBellSound() async {
    if (mounted) {
      setState(() {
        _isAiSpeechPlaying = false;
        _isAiSongPlaying = false;
      });
    }
    try {
      Source urlSource = AssetSource('audio/bell_sound.mp3');
      await _audioPlayer.play(urlSource);
    } catch (e) {
      // Agar file na mile ya error aaye
      debugPrint("Audio play error: $e");
    }
  }

  Future<void> _readAartiWithAi() async {
    final lyrics = widget.aarti.lyrics.trim();
    if (lyrics.isEmpty) return;

    setState(() {
      _isGeneratingSpeech = true;
      _isAiSpeechPlaying = false;
      _isAiSongPlaying = false;
    });
    try {
      await _audioPlayer.stop();
      final wavBytes = await _ttsService.createHindiSpeech(lyrics);
      if (!mounted) return;

      await _audioPlayer.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
      setState(() => _isAiSpeechPlaying = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI आवाज़ तैयार नहीं हो सकी। Firebase/App Check सेटिंग और इंटरनेट जाँचें।',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('Aarti TTS error: $error');
    } finally {
      if (mounted) setState(() => _isGeneratingSpeech = false);
    }
  }

  Future<void> _singAartiWithAi() async {
    final lyrics = widget.aarti.lyrics.trim();
    if (lyrics.isEmpty) return;

    setState(() {
      _isGeneratingSong = true;
      _isAiSpeechPlaying = false;
      _isAiSongPlaying = false;
    });
    try {
      await _audioPlayer.stop();
      final mp3Bytes = await _lyriaService.generateAartiSong(lyrics);
      if (!mounted) return;

      await _audioPlayer.play(BytesSource(mp3Bytes, mimeType: 'audio/mpeg'));
      setState(() => _isAiSongPlaying = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI भजन तैयार नहीं हुआ: $error',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint('Lyria song error: $error');
    } finally {
      if (mounted) setState(() => _isGeneratingSong = false);
    }
  }

  Future<void> _stopAiAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isAiSpeechPlaying = false;
        _isAiSongPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    unawaited(_playbackCompleteSubscription.cancel());
    _audioPlayer.dispose(); // Memory leak bachane ke liye player release karein
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          widget.aarti.title,
          style: GoogleFonts.notoSansDevanagari(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 🔔 Mandir ki Ghanti Button
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {
              _playBellSound();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🔔 घंटी ब बजी!',
                    style: GoogleFonts.notoSansDevanagari(),
                  ),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
            tooltip: 'घंटी बजाएं (Bell)',
          ),

          // Favorite / Bookmark Button
          IconButton(
            icon: Icon(
              widget.aarti.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                widget.aarti.isFavorite = !widget.aarti.isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.aarti.isFavorite
                        ? 'आरती पसंदीदा (Favorites) में जोड़ी गई!'
                        : 'आरती पसंदीदा से हटाई गई',
                    style: GoogleFonts.notoSansDevanagari(),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Favorite mein jodein',
          ),

          // Font Decrease
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                if (_fontSize > 14.0) _fontSize -= 2.0;
              });
            },
          ),

          // Font Increase
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              setState(() {
                if (_fontSize < 28.0) _fontSize += 2.0;
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    widget.aarti.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange[800],
                    ),
                  ),
                  const Divider(
                    height: 30,
                    thickness: 1.5,
                    color: Colors.orangeAccent,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isGeneratingSpeech || _isGeneratingSong
                            ? null
                            : _readAartiWithAi,
                        icon: _isGeneratingSpeech
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.record_voice_over),
                        label: Text(
                          _isGeneratingSpeech ? 'आवाज़ बन रही है...' : 'AI से सुनें',
                          style: GoogleFonts.notoSansDevanagari(),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _isGeneratingSpeech || _isGeneratingSong
                            ? null
                            : _singAartiWithAi,
                        icon: _isGeneratingSong
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.music_note),
                        label: Text(
                          _isGeneratingSong ? 'भजन बन रहा है...' : 'AI भजन',
                          style: GoogleFonts.notoSansDevanagari(),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_isAiSpeechPlaying || _isAiSongPlaying)
                        IconButton.filledTonal(
                          onPressed: _stopAiAudio,
                          icon: const Icon(Icons.stop),
                          tooltip: 'ऑडियो रोकें',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.aarti.lyrics,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: _fontSize,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
