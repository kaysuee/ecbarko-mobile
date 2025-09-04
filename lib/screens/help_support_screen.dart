import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../screens/FAQs_screen.dart';

/// Help & Support Screen
///
/// A comprehensive help and support screen that provides:
/// - Detailed help content for all app features
/// - FAQ access and common questions
/// - Support contact information
/// - Step-by-step guides
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 20.h),
              _buildQuickHelp(context),
              SizedBox(height: 20.h),
              _buildBookingHelp(context),
              SizedBox(height: 20.h),
              _buildAccountHelp(context),
              SizedBox(height: 20.h),
              _buildPaymentHelp(context),
              SizedBox(height: 20.h),
              _buildContactSupport(context),
              SizedBox(height: 20.h),
              _buildFaqSection(context),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Ec_PRIMARY,
            Ec_PRIMARY.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Ec_PRIMARY.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Welcome to EcBarko Help Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Find answers to your questions, get step-by-step guides, and learn how to make the most of your EcBarko experience.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelp(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Help',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 16.h),
          _buildHelpItem(
            'How to Book a Ferry Ticket',
            'Step-by-step guide to booking your ferry journey',
            Icons.directions_boat,
            () => _showBookingGuide(context),
          ),
          SizedBox(height: 12.h),
          _buildHelpItem(
            'Managing Your Account',
            'Learn how to update your profile and settings',
            Icons.person,
            () => _showAccountGuide(context),
          ),
          SizedBox(height: 12.h),
          _buildHelpItem(
            'Payment Methods',
            'Understanding payment options and billing',
            Icons.payment,
            () => _showPaymentGuide(context),
          ),
          SizedBox(height: 12.h),
          _buildHelpItem(
            'View All FAQs',
            'Browse frequently asked questions',
            Icons.quiz,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FAQsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHelp(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_boat, color: Ec_PRIMARY, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Booking & Reservations',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            'How to Book',
            '1. Select your route and date\n2. Choose passengers and vehicle\n3. Enter passenger details\n4. Select payment method\n5. Confirm your booking',
            Icons.book_online,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Booking Management',
            '• View booking details\n• Modify passenger information\n• Cancel bookings\n• Download e-tickets\n• Track booking status',
            Icons.manage_accounts,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Important Notes',
            '• Book at least 2 hours before departure\n• Arrive 30 minutes before boarding\n• Bring valid ID for all passengers\n• Vehicle registration required for vehicles',
            Icons.info,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountHelp(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Ec_PRIMARY, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Account & Profile',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            'Profile Management',
            '• Update personal information\n• Change profile picture\n• Manage contact details\n• Set preferences',
            Icons.edit,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Account Security',
            '• Change password\n• Enable two-factor authentication\n• Manage login sessions\n• Update security questions',
            Icons.security,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Notifications',
            '• Booking confirmations\n• Schedule updates\n• Payment receipts\n• Important announcements',
            Icons.notifications,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHelp(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Ec_PRIMARY, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Payment & Billing',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            'Accepted Payment Methods',
            '• Credit/Debit Cards (Visa, Mastercard)\n• GCash\n• PayPal\n• Bank Transfer\n• Cash on Board (limited routes)',
            Icons.credit_card,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Pricing Structure',
            '• Passenger fares vary by route\n• Vehicle charges based on length\n• Senior citizen discounts available\n• Group booking discounts',
            Icons.attach_money,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Refunds & Cancellations',
            '• Free cancellation up to 2 hours before departure\n• Refunds processed within 3-5 business days\n• No-show policies apply\n• Weather-related cancellations fully refunded',
            Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: Ec_PRIMARY, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildContactInfo(
            Icons.phone,
            'Phone Support',
            '+63 912 345 6789',
            'Available 24/7 for immediate assistance',
          ),
          SizedBox(height: 16.h),
          _buildContactInfo(
            Icons.email,
            'Email Support',
            'support@ecbarko.com',
            'Send detailed inquiries and get responses within 24 hours',
          ),
          SizedBox(height: 16.h),
          _buildContactInfo(
            Icons.location_on,
            'Port Assistance',
            'Dalahican & Balanacan Ports',
            'Visit our customer service desk at the ports',
          ),
          SizedBox(height: 16.h),
          _buildContactInfo(
            Icons.access_time,
            'Support Hours',
            '24/7 Customer Support',
            'We\'re always here to help you with your travel needs',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Ec_PRIMARY, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Find quick answers to the most common questions about booking, payments, and using EcBarko.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FAQsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.quiz, size: 20.sp),
              label: Text('View All FAQs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Ec_PRIMARY.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Ec_PRIMARY.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Ec_PRIMARY,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Ec_PRIMARY,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Ec_PRIMARY,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Ec_PRIMARY,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_PRIMARY,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
    IconData icon,
    String label,
    String value,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Ec_PRIMARY,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Ec_PRIMARY,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBookingGuide(BuildContext context) {
    _showInfoDialog(
      context,
      'How to Book a Ferry Ticket',
      '1. Open the EcBarko app\n2. Tap "Book Now" on the home screen\n3. Select your departure and arrival ports\n4. Choose your travel date and time\n5. Enter the number of passengers\n6. Add vehicle details if needed\n7. Fill in passenger information\n8. Select your payment method\n9. Review and confirm your booking\n10. Receive your e-ticket via email',
    );
  }

  void _showAccountGuide(BuildContext context) {
    _showInfoDialog(
      context,
      'Managing Your Account',
      '1. Go to Profile from the main menu\n2. Tap "Edit Profile" to update information\n3. Change your profile picture by tapping the camera icon\n4. Update contact details and personal information\n5. Go to "Account Security" to change password\n6. Manage notification preferences\n7. View your booking history\n8. Update payment methods if needed',
    );
  }

  void _showPaymentGuide(BuildContext context) {
    _showInfoDialog(
      context,
      'Payment Methods & Billing',
      'Accepted Payment Methods:\n• Credit/Debit Cards (Visa, Mastercard)\n• GCash mobile wallet\n• PayPal account\n• Bank transfer\n• Cash on board (limited routes)\n\nPricing:\n• Passenger fares vary by route\n• Vehicle charges based on length\n• Senior citizen discounts available\n• Group booking discounts\n\nRefunds:\n• Free cancellation up to 2 hours before departure\n• Refunds processed within 3-5 business days',
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Ec_PRIMARY,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: Ec_PRIMARY),
            ),
          ),
        ],
      ),
    );
  }
}
