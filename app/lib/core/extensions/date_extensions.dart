import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  String get formatted => DateFormat('MMM d, yyyy').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String get timeFormatted => DateFormat('h:mm a').format(this);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
