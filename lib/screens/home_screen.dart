import 'package:EcBarko/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../screens/dashboard_screen.dart';
import '../screens/active_booking_screen.dart';
import '../screens/schedule_screen.dart';
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
    ActiveBookingScreen(),
    ScheduleScreen(),
    RFIDCardScreen(),
    ProfileScreen(),
  ];

  final List<Widget> _navItems = const <Widget>[
    Icon(Icons.home, size: 28, color: Colors.white),
    Icon(Icons.book_online, size: 28, color: Colors.white),
    Icon(Icons.schedule, size: 28, color: Colors.white),
    Icon(Icons.credit_card, size: 28, color: Colors.white),
    Icon(Icons.person, size: 28, color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // keeps navigation bar floating effect
      body: Stack(
        children: [
          // Main PageView
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),

          // Bottom Navigation (fixed)
          Align(
            alignment: Alignment.bottomCenter,
            child: CurvedNavigationBar(
              backgroundColor: Colors.white, // see body behind
              color: Ec_PRIMARY,
              buttonBackgroundColor: Ec_PRIMARY,
              height: 55,
              animationDuration: const Duration(milliseconds: 300),
              index: _selectedIndex,
              items: _navItems,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                _pageController.jumpToPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:EcBarko/screens/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import '../screens/dashboard_screen.dart';
// import 'booking_screen.dart';
// import '../screens/rates_screen.dart';
// import '../screens/RFIDCard_screen.dart';
// import '../constants.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController(initialPage: 0);

//   final List<Widget> _screens = const <Widget>[
//     DashboardScreen(),
//     BookingScreen(),
//     RFIDCardScreen(),
//     ProfileScreen(),
//   ];

//   final List<Widget> _navItems = const <Widget>[
//     Icon(Icons.home, size: 28, color: Colors.white),
//     Icon(Icons.calendar_month, size: 28, color: Colors.white),
//     Icon(Icons.credit_card, size: 28, color: Colors.white),
//     Icon(Icons.person, size: 28, color: Colors.white),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true, // Keep this to make the navigation bar transparent
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: _screens,
//       ),
//       bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor: Ec_WHITE,

//         // backgroundColor: Colors.transparent,
//         color: Ec_PRIMARY,
//         buttonBackgroundColor: Ec_PRIMARY,
//         height: 55, // Slightly reduced height for less intrusion
//         animationDuration: const Duration(milliseconds: 300),
//         index: _selectedIndex,
//         items: _navItems,
//         onTap: (index) {
//           setState(() => _selectedIndex = index);
//           _pageController.jumpToPage(index);
//         },
//       ),
//     );
//   }
// }
