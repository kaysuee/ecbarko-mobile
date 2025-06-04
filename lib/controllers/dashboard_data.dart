import 'package:flutter/material.dart';
import '../constants.dart';

class DashboardData {
  static List<Map<String, dynamic>> getSchedules() => [
        {
          'date': 'June 3 (Monday)',
          'from': 'Lucena',
          'to': 'Marinduque',
          'time': '03:30AM',
          'color': const Color(0xFFBCCCE1),
        },
        {
          'date': 'June 3 (Monday)',
          'from': 'Lucena',
          'to': 'Marinduque',
          'time': '12:00PM',
          'color': const Color(0xFF9CABBF),
        },
        {
          'date': 'June 4 (Tuesday)',
          'from': 'Lucena',
          'to': 'Marinduque',
          'time': '03:30AM',
          'color': const Color(0xFFBCCCE1),
        },
      ];

  static List<Map<String, dynamic>> getRateItems() => [
        {
          'label': 'Vehicle',
          'imagePath': 'assets/images/vehicle1.png',
          'bgColor': const Color(0xFFF6F6F6),
          'textColor': Ec_PRIMARY,
        },
        {
          'label': 'Passenger',
          'imagePath': 'assets/images/passengers_icon3.png',
          'bgColor': Ec_PRIMARY,
          'textColor': Colors.white,
        },
      ];
}
