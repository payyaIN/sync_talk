import 'package:intl/intl.dart';

class DateHelper {
  static String getDayLabel(DateTime date) {
    final now = DateTime.now();
    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return "Today";
    } else if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 1)))) {
      return "Yesterday";
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
