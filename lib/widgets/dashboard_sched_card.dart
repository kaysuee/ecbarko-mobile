import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String date, from, to, time;
  final Color bgColor;

  const ScheduleCard(
      {super.key,
      required this.date,
      required this.from,
      required this.to,
      required this.time,
      required this.bgColor});

  String _formatTime(String timeStr) {
    try {
      // Handle different time formats
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        // Format: "03:30 AM" or "3:30 PM" - already in 12-hour format
        return timeStr;
      } else {
        // Format: "15:30" (24-hour) - convert to 12-hour format
        final timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          
          String period = 'AM';
          if (hour >= 12) {
            period = 'PM';
            if (hour > 12) {
              hour -= 12;
            }
          }
          if (hour == 0) {
            hour = 12;
          }
          
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      }
      return timeStr;
    } catch (e) {
      print('Error formatting time: $e');
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      padding: const EdgeInsets.all(16.0),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black, fontFamily: 'Arial')),
              const SizedBox(height: 5),
              Text('$from to $to',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF013986),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial')),
            ],
          ),
          Text(_formatTime(time),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
