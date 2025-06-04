import 'package:flutter/material.dart';

const Color Ec_PRIMARY = Color(0xFF013986);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image (fills from slightly below top to middle)
          Positioned(
            top: 50, // Pushes image slightly down (you can tweak this)
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height /
                2.5, // Stops a bit lower than middle
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/aboutBg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Custom AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: topPadding),
              height: kToolbarHeight + topPadding,
              color: Ec_PRIMARY,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'About App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Blue Card at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.5,
              padding: const EdgeInsets.only(
                top: 80, // space for overlapping icon
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                color: Ec_PRIMARY,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                ),
              ),
              child: const Text(
                'ECBARKO is a mobile application designed to enhance the convenience and efficiency of sea travel for passengers and ferry operators alike. With a user-friendly interface, the app allows travelers to browse updated ferry schedules, secure reservations, and receive instant notifications on trip changes or delays. ECBARKO also offers helpful travel tips, terminal information, and digital ticketing features to eliminate long queues and paperwork. By integrating modern technology into maritime travel, ECBARKO brings safety, transparency, and ease right to your fingertips—ensuring that every journey is smooth, timely, and stress-free.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Overlapping App Icon on top of the card
          Positioned(
            bottom: screenHeight * 0.5 - 75,
            left: screenWidth / 2 - 75,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/aboutLogo.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
