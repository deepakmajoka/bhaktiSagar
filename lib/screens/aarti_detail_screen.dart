import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // Audio package import kiya
import '../models/aarti_model.dart';

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

  // Ghanti bajane ka function
  void _playBellSound() async {
    try {
      Source urlSource = AssetSource('audio/bell_sound.mp3');
      await _audioPlayer.play(urlSource);
    } catch (e) {
      // Agar file na mile ya error aaye
      debugPrint("Audio play error: $e");
    }
  }

  @override
  void dispose() {
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
                  const Divider(height: 30, thickness: 1.5, color: Colors.orangeAccent),
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