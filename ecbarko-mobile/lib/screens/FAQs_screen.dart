import 'package:flutter/material.dart';
import '../constants.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What is EcBarko Card?',
      'answer':
          'The EcBarko Card is designed for car owners, allowing them to seamlessly manage ferry bookings and payments through the EcBarko system.'
    },
    {
      'question': 'How do I buy EcBarko Card?',
      'answer':
          'You can buy an EcBarko Card at Dalahican Port and Balanacan Port.'
    },
    {
      'question': 'How do I buy an EcBarko Card?',
      'answer':
          'You can retrieve your ticket by logging into your account on our platform or contact our support team for assistance.'
    },
    {
      'question': 'What should I do if I lose my EcBarko Card?',
      'answer':
          'If you lose your EcBarko Card, please report it immediately through the EcBarko App or visit the nearest port assistance desk. Our team will help you block the lost card and issue a replacement.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: faqs.map((faq) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text(
                    faq['question'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Ec_PRIMARY,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        faq['answer'] ?? '',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
