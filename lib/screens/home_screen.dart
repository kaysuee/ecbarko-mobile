import 'package:EcBarko/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../screens/dashboard_screen.dart';
import 'booking_screen.dart';
import '../screens/rates_screen.dart';
import '../screens/RFIDCard_screen.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = const <Widget>[
    DashboardScreen(),
    BookingScreen(),
    RFIDCardScreen(),
    ProfileScreen(),
  ];

  final List<Widget> _navItems = const <Widget>[
    Icon(Icons.home, size: 28, color: Colors.white),
    Icon(Icons.calendar_month, size: 28, color: Colors.white),
    Icon(Icons.credit_card, size: 28, color: Colors.white),
    Icon(Icons.person, size: 28, color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Keep this to make the navigation bar transparent
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Ec_WHITE,

        // backgroundColor: Colors.transparent,
        color: Ec_PRIMARY,
        buttonBackgroundColor: Ec_PRIMARY,
        height: 55, // Slightly reduced height for less intrusion
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        items: _navItems,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
