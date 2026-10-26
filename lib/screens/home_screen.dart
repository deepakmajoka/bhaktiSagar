import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/aarti_data.dart';
import '../models/aarti_model.dart';
import 'aarti_detail_screen.dart';
import 'calendar_screen.dart';
import 'panchang_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Aarti> _foundAartis = [];
  String _selectedCategory = 'सभी'; // Default category

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _foundAartis = AartiData.aartisList;
    _loadBannerAd(); // Ad load karne ka function call karein
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // Memory clean karne ke liye
    super.dispose();
  }


  // Saari categories nikalne ke liye
  List<String> get _categories {
    Set<String> cats = {'सभी'};
    for (var aarti in AartiData.aartisList) {
      cats.add(aarti.category);
    }
    return cats.toList();
  }


  // Search aur Category dono ko ek sath filter karne ka function
  void _filterAartis(String keyword, String category) {
    List<Aarti> results = AartiData.aartisList;

    // Category filter apply karein
    if (category != 'सभी') {
      results = results.where((aarti) => aarti.category == category).toList();
    }

    // Search keyword filter apply karein
    if (keyword.isNotEmpty) {
      results = results.where((aarti) =>
      aarti.title.toLowerCase().contains(keyword.toLowerCase()) ||
          aarti.category.toLowerCase().contains(keyword.toLowerCase())).toList();
    }

    setState(() {
      _foundAartis = results;
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'भक्ति मार्ग - Panchang & Aartis',
          style: GoogleFonts.notoSansDevanagari(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
            tooltip: 'पंचांग व व्रत कैलेंडर',
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              ).then((_) {
                setState(() {});
              });
            },
            tooltip: 'Favorites',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 Aaj ka Panchang Card (Dynamic Data)
            Card(
              elevation: 4,
              color: Colors.amber[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PanchangScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📅 आज का पंचांग & तिथि',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 👇 Yahan aaj ki date ke hisab se dynamic preview text dikhega
                            Text(
                              'विशेष: गुरु पूर्णिमा / व्यास पूर्णिमा\nतिथि: पूर्णिमा तिथि (आषाढ शुक्ल पक्ष) - पूरा पंचांग देखें',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search Bar Field
            TextField(
              onChanged: (value) => _filterAartis(value, _selectedCategory),
              style: GoogleFonts.notoSansDevanagari(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'आरती या भगवान का नाम खोजें...',
                labelStyle: GoogleFonts.notoSansDevanagari(color: Colors.grey[700]),
                prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🏷️ Category Filter Chips (Horizontal Scrollable)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: GoogleFonts.notoSansDevanagari(
                          color: isSelected ? Colors.white : Colors.deepOrange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.deepOrange,
                      backgroundColor: Colors.orange[50],
                      onSelected: (selected) {
                        _filterAartis('', category);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Text(
              '🙏 प्रमुख आरती संग्रह (${_foundAartis.length} उपलब्ध)',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Aartis List
            Expanded(
              child: _foundAartis.isNotEmpty
                  ? ListView.builder(
                itemCount: _foundAartis.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Text(
                          _foundAartis[index].category[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange[800],
                          ),
                        ),
                      ),
                      title: Text(
                        _foundAartis[index].title,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'श्रेणी: ${_foundAartis[index].category}',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _foundAartis[index].isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _foundAartis[index].isFavorite = !_foundAartis[index].isFavorite;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _foundAartis[index].isFavorite
                                        ? 'पसंद (Favorite) में जोड़ी गई!'
                                        : 'पसंद से हटाई गई',
                                    style: GoogleFonts.notoSansDevanagari(),
                                  ),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
                            },
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AartiDetailScreen(aarti: _foundAartis[index]),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  'कोई आरती नहीं मिली!',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 📢 Banner Ad (Screen ke sabse neeche)
            _isAdLoaded
                ? Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}