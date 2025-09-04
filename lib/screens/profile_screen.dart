import 'package:EcBarko/screens/account_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:EcBarko/screens/about_screen.dart' as about_screen;
import 'package:EcBarko/screens/FAQs_screen.dart';
import 'package:EcBarko/screens/notification_screen.dart';
import 'package:EcBarko/screens/help_support_screen.dart';
import 'package:EcBarko/constants.dart';
import 'edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

String getBaseUrl() {
  // return 'https://ecbarko.onrender.com'; // iOS or desktop
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
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
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to load user data: ${response.statusCode}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  // Method to handle refresh
  Future<void> _handleRefresh() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
        ),
      );
    }

    return Container(
      color: Ec_BG_SKY_BLUE,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildProfileMenu(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cover + Avatar stacked
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Cover Photo
              Container(
                height: 180, // slightly smaller cover
                width: double.infinity,
                color: Colors.grey[300],
                child: Image.network(
                  userData?['coverImageUrl'] ??
                      'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.landscape,
                          size: 64, color: Colors.grey[600]),
                    );
                  },
                ),
              ),

              // Profile Picture (overlapping bottom)
              Positioned(
                bottom: -60,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60, // smaller radius to reduce gap
                    backgroundColor: Colors.grey[200],
                    backgroundImage: userData?['profileImageUrl'] != null
                        ? NetworkImage(userData!['profileImageUrl'])
                        : const AssetImage('assets/images/default.png')
                            as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 70), // makes room for the overlapping avatar

          // User Info
          Column(
            children: [
              Text(
                userData?['name'] ?? 'User Name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'User ID: #${userData?['id'] ?? '000000'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (userData?['email'] != null) ...[
                const SizedBox(height: 2),
                Text(
                  userData?['email'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security,
            title: 'Account Security',
            subtitle: 'Manage your account settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AccountSecurityScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage your notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Frequently Asked Questions',
            subtitle: 'Find answers to common questions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQsScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get help from our support team',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Learn more about EcBarko',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const about_screen.AboutScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context),
            isDestructive: true,
          ),
          // const SizedBox(height: 30), // Add bottom padding inside the menu
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? Colors.red : Ec_PRIMARY;
    final textColor = isDestructive ? Colors.red : Colors.black87;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Logout"),
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
