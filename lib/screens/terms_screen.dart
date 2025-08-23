import 'package:flutter/material.dart';
import 'package:EcBarko/constants.dart';
import '../widgets/customfont.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Ec_DARK_PRIMARY,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Basic Information
                sectionTitle('1. Basic Information'),
                sectionText(
                    'App Name: EcBarko\nOwner/Company: [Your Company Name / Group]\nPurpose: EcBarko allows passengers to book vehicle tickets and pay port terminal fees through the app.'),

                const SizedBox(height: 20),

                // Section 2: User Account
                sectionTitle('2. User Account'),
                sectionText(
                    '• To use EcBarko, you must create an account.\n• Users must be at least 18 years old.\n• You are responsible for keeping your account information secure.\n• The developers also maintain safeguards to protect accounts.\n• Sharing, selling, or lending your card/account without permission is strictly prohibited.'),

                const SizedBox(height: 20),

                // Section 3: Usage Rules
                sectionTitle('3. Usage Rules'),
                sectionText(
                    'You agree not to:\n• Sell, lend, or share your EcBarko card unless accompanying someone.\n• Steal, misuse, or access someone else’s account.\n• Engage in illegal, fraudulent, or harmful activities.\n\nContent: Users cannot post content on the app; all functionality is limited to booking and payment services.'),

                const SizedBox(height: 20),

                // Section 4: Transactions & Payments
                sectionTitle('4. Transactions & Payments'),
                sectionText(
                    '• EcBarko handles payment for tickets and port fees.\n• For refunds or disputes, contact the port’s Help Desk directly.\n• Third-party payment services may be used and are subject to their policies.'),

                const SizedBox(height: 20),

                // Section 5: Liability & Legal
                sectionTitle('5. Liability & Legal'),
                sectionText(
                    '• EcBarko is not responsible for lost, stolen, or damaged cards.\n• Users are fully responsible for their accounts and cards.\n• Developers and the company are not liable for financial loss or inconvenience caused by user error.\n• Terms & Conditions cannot be updated without notifying users.\n• All disputes are governed by the laws of the Philippines.'),

                const SizedBox(height: 20),

                // Section 6: Privacy & Data
                sectionTitle('6. Privacy & Data'),
                sectionText(
                    '• EcBarko collects personal data such as name, contact information, and booking details.\n• Data is used strictly for account management, booking, payment, and app functionality.\n• Information will not be shared outside the scope of app functionality except as required by law or third-party payment services.'),

                const SizedBox(height: 20),

                // Section 7: Changes to Terms
                sectionTitle('7. Changes to Terms'),
                sectionText(
                    '• We reserve the right to update or modify these Terms & Conditions, with notification to users.\n• Continued use of the app after changes constitutes acceptance of the updated terms.'),

                const SizedBox(height: 20),

                // Section 8: Contact
                sectionTitle('8. Contact'),
                sectionText(
                    'For questions or concerns regarding these Terms & Conditions, please contact us at:\n[Insert company email or support contact]'),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'SF Pro',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Ec_DARK_PRIMARY,
        ),
      ),
    );
  }

  // Helper widget for section content
  Widget sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 14,
        color: Ec_TEXT_COLOR_GREY,
        height: 1.6,
      ),
    );
  }
}
