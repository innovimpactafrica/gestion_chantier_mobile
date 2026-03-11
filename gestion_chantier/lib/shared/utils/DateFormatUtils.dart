import 'package:intl/intl.dart';


class DateFormatUtils {
  /// 1️⃣ Formate une date simple → 10 dec 2025
  static String formatShort(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'fr_FR');
    return formatter.format(date);
  }

  /// 2️⃣ Formate une date simple → 10/12/2025
  static String formatNumeric(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  /// 3️⃣ Formate une période de tâche → 10 dec 2025 - 15 dec 2025
  static String formatPeriod(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return '';

    final start = formatShort(startDate);
    final end = formatShort(endDate);

    return '$start au $end';
  }

  /// 4️⃣ Formate une tâche → Aujourd'hui • 08:00 - 12:00
  static String formatTaskPeriodWithTime(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return '';

    final now = DateTime.now();
    final isToday = startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;

    final dateLabel = isToday
        ? "Aujourd'hui"
        : DateFormat('dd MMM', 'fr_FR').format(startDate);
    final startTime = DateFormat('HH:mm').format(startDate);
    final endTime = DateFormat('HH:mm').format(endDate);

    return '$dateLabel • $startTime - $endTime';
  }

}
