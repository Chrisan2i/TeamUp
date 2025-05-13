import 'package:intl/intl.dart';

/// Retorna un string como "22:30 - 23:30"
String formatTimeRange(DateTime start, int durationMinutes) {
  final end = start.add(Duration(minutes: durationMinutes));

  String format(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  return '${format(start)} - ${format(end)}';
}

/// Retorna un string como "Wed, May 10"
String formatFullDate(DateTime date) {
  return DateFormat('EEE, MMM d').format(date);
}
