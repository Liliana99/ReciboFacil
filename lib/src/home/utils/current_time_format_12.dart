import 'package:intl/intl.dart';

String getCurrentTime12HourFormat() {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('hh:mm a').format(now);
  return ' $formattedTime';
}
