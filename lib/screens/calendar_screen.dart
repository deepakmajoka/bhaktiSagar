import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Har din ke hisab se tithi aur tyohar nikalne ka logic (Offline)
  Map<String, String> _getPpanchangDetails(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Kuch mukhya aur dynamic tyoharon/tithiyon ka local database mapping
    Map<String, Map<String, String>> specialEvents = {
      '2026-07-29': {
        'tithi': 'पूर्णिमा तिथि (आषाढ शुक्ल पक्ष)',
        'festival': 'गुरु पूर्णिमा / व्यास पूर्णिमा',
        'nakshatra': 'पूर्वाषाढ़ा',
        'yog': 'साध्य'
      },
      '2026-08-12': {
        'tithi': 'त्रयोदशी तिथि (श्रावण कृष्ण पक्ष)',
        'festival': 'प्रदोष व्रत',
        'nakshatra': 'पुनर्वसु',
        'yog': 'शिव'
      },
      '2026-08-16': {
        'tithi': 'अमावस्या तिथि (श्रावण कृष्ण पक्ष)',
        'festival': 'श्रावण अमावस्या / हरियाली अमावस्या',
        'nakshatra': 'अश्लेषा',
        'yog': 'सौभाग्य'
      },
    };

    if (specialEvents.containsKey(formattedDate)) {
      return specialEvents[formattedDate]!;
    }

    // Default panchang info agar koi bada tyohar na ho us din
    return {
      'tithi': 'शुक्ल पक्ष / कृष्ण पक्ष (सामान्य दिन)',
      'festival': 'दैनिक पंचांग - पूजा-पाठ के लिए शुभ दिन',
      'nakshatra': 'शुभ नक्षत्र',
      'yog': 'नित्य योग'
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> currentPanchang = _getPpanchangDetails(_selectedDay ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('हिंदू पंचांग व कैलेंडर', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Widget
            Card(
              margin: const EdgeInsets.all(12.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange[300],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange[800],
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Selected Date Panchang Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Text(
                            "चुनी गई तारीख: ${DateFormat('dd-MM-yyyy').format(_selectedDay ?? DateTime.now())}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Festival / Vrat info
                      _buildInfoRow(Icons.festival, "विशेष पर्व / व्रत:", currentPanchang['festival']!, Colors.red[700]!),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.brightness_2, "तिथि:", currentPanchang['tithi']!, Colors.black87),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.star, "नक्षत्र:", currentPsnchangSafe(currentPanchang, 'nakshatra'), Colors.black87),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.wb_sunny, "योग:", currentPsnchangSafe(currentPanchang, 'yog'), Colors.black87),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String currentPsnchangSafe(Map<String, String> map, String key) {
    return map[key] ?? '';
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.orange[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor)),
            ],
          ),
        ),
      ],
    );
  }
}