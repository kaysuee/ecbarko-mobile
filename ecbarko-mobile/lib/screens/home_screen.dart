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
    BookingsScreen(),
    RFIDCardScreen(),
    ProfileScreen(),
  ];

  final List<Widget> _navItems = const <Widget>[
    Icon(Icons.home, size: 28, color: Colors.white),
    Icon(Icons.calendar_month, size: 28, color: Colors.white),
    Icon(Icons.credit_card, size: 28, color: Colors.white),
    Icon(Icons.person, size: 28, color: Colors.white),
  ];

  final List<String> _labels = ['Home', 'Bookings', 'RFID', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 70), // Pushes labels above nav bar
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_labels.length, (index) {
                  return Text(
                    _selectedIndex == index ? _labels[index] : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
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
//     BookingsScreen(),
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
//         backgroundColor: Colors.transparent,
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
//     BookingsScreen(),
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
//       extendBody: true,
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: _screens,
//       ),
//       bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor: Colors.transparent,
//         color: Ec_PRIMARY,
//         buttonBackgroundColor: Ec_PRIMARY,
//         height: 60,
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

// import 'package:EcBarko/screens/profile_screen.dart';
// import 'package:flutter/material.dart';
// import '../screens/dashboard_screen.dart';
// import 'booking_screen.dart';
// import '../screens/rates_screen.dart';
// import '../screens/RFIDCard_screen.dart'; // Assuming this becomes ProfileScreen later
// import '../constants.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController(initialPage: 0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(), // Disable swipe
//         children: const <Widget>[
//           DashboardScreen(),
//           BookingsScreen(),
//           RFIDCardScreen(), // Now ECBARKO CARD is placed 3rd
//           ProfileScreen(), // Now correctly mapped to PROFILE tab
//         ],
//       ),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Ec_PRIMARY, // Blue background
//           border: Border(top: BorderSide(color: Colors.transparent)),
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Ec_PRIMARY,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           onTap: _onTappedBar,
//           type: BottomNavigationBarType.fixed,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.calendar_month), label: 'BOOK'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.credit_card), label: 'ECBARKO CARD'),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
//           ],
//           selectedItemColor: Ec_WHITE,
//           unselectedItemColor: Ec_BG_GENTLE_BLUE,
//           selectedLabelStyle: TextStyle(
//             fontSize: 10,
//             fontFamily: 'Arial',
//             color: Colors.white,
//           ),
//           unselectedLabelStyle: TextStyle(
//             fontSize: 10,
//             fontFamily: 'Arial',
//           ),
//           currentIndex: _selectedIndex,
//         ),
//       ),
//     );
//   }

//   void _onTappedBar(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
// }
