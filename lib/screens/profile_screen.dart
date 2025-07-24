import 'package:flutter/material.dart';
import 'package:EcBarko/screens/about_screen.dart' as about_screen;
import 'package:EcBarko/screens/login_screen.dart';
import 'package:EcBarko/screens/FAQs_screen.dart';
import 'package:EcBarko/screens/notification_screen.dart';
import 'package:EcBarko/constants.dart';
import 'edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String getBaseUrl() {
  return 'https://ecbarko.onrender.com'; // iOS or desktop
  // return 'http://localhost:3000';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      print("userId is $userId");
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSectionHeight = 350.0;
    final navBarHeight = 10.0;

    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Use Stack to overlay the profile header and options
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          userData?['coverImageUrl'] ??
                              'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              width: double.infinity,
                              height: 200,
                              child: Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 58,
                                backgroundImage: NetworkImage(
                                  userData?['profileImageUrl'] ??
                                      'assets/images/default.png',
                                ),
                              ),
                            ),
                            // Positioned(
                            //   bottom: 0,
                            //   right: 0,
                            //   child: CircleAvatar(
                            //     radius: 15,
                            //     backgroundColor: Colors.grey[300],
                            //     child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  userData?['name'] ?? 'Loading...',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Chip(
                  backgroundColor: Ec_PRIMARY,
                  label: Text(
                    'User ID: #${userData?['id'] ?? '...'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Options
          Positioned(
            top: topSectionHeight,
            left: 0,
            right: 0,
            bottom: navBarHeight,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildOptionTile(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditProfileScreen()));
                      }),
                  _buildDivider(),
                  _buildOptionTile(
                      icon: Icons.notifications,
                      label: 'Notifications',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen()));
                      }),
                  _buildDivider(),
                  _buildOptionTile(
                      icon: Icons.help,
                      label: 'FAQs',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FAQsScreen()));
                      }),
                  _buildDivider(),
                  _buildOptionTile(
                      icon: Icons.info,
                      label: 'About App',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const about_screen.AboutScreen()));
                      }),
                  _buildDivider(),
                  _buildOptionTile(
                    icon: Icons.logout,
                    label: 'Logout',
                    iconColor: Colors.red,
                    trailingColor: Colors.red,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color trailingColor = Colors.black,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration:
            BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: trailingColor),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
}

// import 'package:flutter/material.dart';
// import 'package:EcBarko/screens/about_screen.dart' as about_screen;
// import 'package:EcBarko/screens/login_screen.dart';
// import 'package:EcBarko/screens/FAQs_screen.dart';
// import 'package:EcBarko/screens/notification_screen.dart';
// import 'package:EcBarko/constants.dart';
// import 'edit_profile_screen.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final appBarHeight = AppBar().preferredSize.height;
//     final statusBarHeight = MediaQuery.of(context).padding.top;
//     final topSectionHeight = 350.0; // reduced from 370.0
//     final navBarHeight = 10.0;

//     final availableHeight = screenHeight -
//         appBarHeight -
//         statusBarHeight -
//         topSectionHeight -
//         navBarHeight;

//     return Scaffold(
//       backgroundColor: Ec_BG_SKY_BLUE,
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontFamily: 'Arial',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Ec_PRIMARY,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Stack(
//         children: [
//           // Profile header
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Column(
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.network(
//                           'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: 200,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey[300],
//                               width: double.infinity,
//                               height: 200,
//                               child: Icon(Icons.broken_image,
//                                   size: 50, color: Colors.grey[600]),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: -40,
//                       left: 0,
//                       right: 0,
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             const CircleAvatar(
//                               radius: 60,
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius: 58,
//                                 backgroundImage: NetworkImage(
//                                   'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg',
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: CircleAvatar(
//                                 radius: 15,
//                                 backgroundColor: Colors.grey[300],
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   size: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40), // reduced from 60
//                 const Text(
//                   'Vicky Jang',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 Chip(
//                   backgroundColor: Ec_PRIMARY,
//                   label: Text(
//                     'User ID: #${DateTime.now().millisecondsSinceEpoch % 1000000}',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),

//           // Options section
//           Positioned(
//             top: topSectionHeight,
//             left: 0,
//             right: 0,
//             bottom: navBarHeight,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 physics: const BouncingScrollPhysics(),
//                 children: [
//                   _buildOptionTile(
//                     icon: Icons.edit,
//                     label: 'Edit Profile',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => EditProfileScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.notifications,
//                     label: 'Notifications',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const NotificationsScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.help,
//                     label: 'FAQs',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const FAQsScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.info,
//                     label: 'About App',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const about_screen.AboutScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.logout,
//                     label: 'Logout',
//                     iconColor: Colors.red,
//                     trailingColor: Colors.red,
//                     onTap: () => _showLogoutDialog(context),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOptionTile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color iconColor = Colors.black,
//     Color trailingColor = Colors.black,
//   }) {
//     return ListTile(
//       dense: false,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       leading: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 20, color: iconColor),
//       ),
//       title: Text(
//         label,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//       trailing: Icon(Icons.arrow_forward_ios, size: 16, color: trailingColor),
//       onTap: onTap,
//     );
//   }

//   Widget _buildDivider() {
//     return const Divider(
//       height: 1,
//       thickness: 0.5,
//       indent: 20,
//       endIndent: 20,
//     );
//   }
// }

// void _showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _logout(context);
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       );
//     },
//   );
// }

// void _logout(BuildContext context) {
//   Navigator.pushAndRemoveUntil(
//     context,
//     MaterialPageRoute(builder: (context) => const LoginScreen()),
//     (route) => false,
//   );
// }

// import 'package:flutter/material.dart';
// import 'package:EcBarko/screens/about_screen.dart' as about_screen;
// import 'package:EcBarko/screens/login_screen.dart';
// import 'package:EcBarko/screens/FAQs_screen.dart';
// import 'package:EcBarko/screens/notification_screen.dart';
// import 'package:EcBarko/constants.dart';
// import 'edit_profile_screen.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Calculate the position and height of the options container
//     final screenHeight = MediaQuery.of(context).size.height;
//     final appBarHeight = AppBar().preferredSize.height;
//     final statusBarHeight = MediaQuery.of(context).padding.top;
//     final topSectionHeight = 370.0; // Height to the bottom of User ID chip
//     final navBarHeight = 10.0; // Height reserved for navigation bar

//     // Calculate the available height for the options container
//     final availableHeight = screenHeight -
//         appBarHeight -
//         statusBarHeight -
//         topSectionHeight -
//         navBarHeight;

//     return Scaffold(
//       backgroundColor: Ec_BG_SKY_BLUE,
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontFamily: 'Arial',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Ec_PRIMARY,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Stack(
//         children: [
//           // Profile header info
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Column(
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.network(
//                           'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: 200,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey[300],
//                               width: double.infinity,
//                               height: 200,
//                               child: Icon(Icons.broken_image,
//                                   size: 50, color: Colors.grey[600]),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: -40,
//                       left: 0,
//                       right: 0,
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             const CircleAvatar(
//                               radius: 60,
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius: 58,
//                                 backgroundImage: NetworkImage(
//                                   'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg',
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: CircleAvatar(
//                                 radius: 15,
//                                 backgroundColor: Colors.grey[300],
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   size: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 60),
//                 const Text(
//                   'Vicky Jang',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 Chip(
//                   backgroundColor: Ec_PRIMARY,
//                   label: Text(
//                     'User ID: #${DateTime.now().millisecondsSinceEpoch % 1000000}',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),

//           // Options card - positioned from User ID to bottom of screen (excluding nav bar)
//           Positioned(
//             top: topSectionHeight,
//             left: 0,
//             right: 0,
//             bottom: navBarHeight, // Leave space for navigation bar
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ListView(
//                 // Use ListView to ensure options are scrollable if they don't fit
//                 padding: EdgeInsets.zero, // Remove padding
//                 physics:
//                     const NeverScrollableScrollPhysics(), // Disable scrolling
//                 children: [
//                   _buildOptionTile(
//                     icon: Icons.edit,
//                     label: 'Edit Profile',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => EditProfileScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.notifications,
//                     label: 'Notifications',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const NotificationsScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.help,
//                     label: 'FAQs',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const FAQsScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.info,
//                     label: 'About App',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const about_screen.AboutScreen()),
//                       );
//                     },
//                   ),
//                   _buildDivider(),
//                   _buildOptionTile(
//                     icon: Icons.logout,
//                     label: 'Logout',
//                     iconColor: Colors.red,
//                     trailingColor: Colors.red,
//                     onTap: () => _showLogoutDialog(context),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOptionTile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color iconColor = Colors.black,
//     Color trailingColor = Colors.black,
//   }) {
//     return ListTile(
//       dense: false, // Make non-dense for more space
//       contentPadding: const EdgeInsets.symmetric(
//           horizontal: 24, vertical: 8), // Add vertical padding
//       leading: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 20, color: iconColor),
//       ),
//       title: Text(
//         label,
//         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//       ),
//       trailing: Icon(Icons.arrow_forward_ios, size: 16, color: trailingColor),
//       onTap: onTap,
//     );
//   }

//   Widget _buildDivider() {
//     return const Divider(
//       height: 1,
//       thickness: 0.5,
//       indent: 20,
//       endIndent: 20,
//     );
//   }
// }

// void _showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _logout(context);
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       );
//     },
//   );
// }

// void _logout(BuildContext context) {
//   Navigator.pushAndRemoveUntil(
//     context,
//     MaterialPageRoute(builder: (context) => const LoginScreen()),
//     (route) => false,
//   );
// }
