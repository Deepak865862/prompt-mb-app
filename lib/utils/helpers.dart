import 'package:intl/intl.dart';

class Helpers {
  // Date ko readable format mein badalne ke liye (e.g., 06 Sep 2026)
  static String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Agar date galat ho, toh wapas wahi text de do
    }
  }

  // Lambe text ko chota karne ke liye (e.g., "Hello World..." )
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
