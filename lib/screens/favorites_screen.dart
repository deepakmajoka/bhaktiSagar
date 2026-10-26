import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/aarti_data.dart';
import '../models/aarti_model.dart';
import 'aarti_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    List<Aarti> favoriteAartis = AartiData.aartisList
        .where((aarti) => aarti.isFavorite)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          '❤️ पसंदीदा आरती (Favorites)',
          style: GoogleFonts.notoSansDevanagari(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: favoriteAartis.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: favoriteAartis.length,
          itemBuilder: (context, index) {
            final aarti = favoriteAartis[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Text(
                    aarti.category[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange[800],
                    ),
                  ),
                ),
                title: Text(
                  aarti.title,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'श्रेणी: ${aarti.category}',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      aarti.isFavorite = false; // Favorite se hata dena
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'पसंद से हटाई गई',
                          style: GoogleFonts.notoSansDevanagari(),
                        ),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AartiDetailScreen(aarti: aarti),
                    ),
                  ).then((_) {
                    setState(() {}); // Wapas aane par list refresh karne ke liye
                  });
                },
              ),
            );
          },
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'कोई पसंदीदा आरती नहीं जोड़ी गई है!',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'आरती के सामने दिए गए ❤️ आइकॉन पर क्लिक करें।',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}