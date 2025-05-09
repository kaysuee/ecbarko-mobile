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
          Text(time,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
