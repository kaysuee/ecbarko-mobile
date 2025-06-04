import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String amount;
  final String paymentMethod;

  const PaymentCard({super.key, required this.amount, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF013986),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          paymentMethod,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: paymentMethod == "Credit Card"
            ? CreditCardPayment(amount: amount)
            : EWalletPayment(amount: amount),
      ),
    );
  }
}

// ==================== Credit Card Payment Widget ====================
class CreditCardPayment extends StatefulWidget {
  final String amount;
  const CreditCardPayment({super.key, required this.amount});

  @override
  State<CreditCardPayment> createState() => _CreditCardPaymentState();
}

class _CreditCardPaymentState extends State<CreditCardPayment> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    cvvController.dispose();
    cardHolderController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Card Number",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "XXXXX XXXX XXX",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Amount",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "₱${widget.amount}",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildForm(), // Extracted form widget for better readability
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print('Proceeding with payment of ${widget.amount}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF013986),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Confirm Payment',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildForm() {
  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Card Number",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "XXXX XXXX XXXX XXXX",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            prefixIcon: const Icon(Icons.credit_card, color: Colors.blue),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 16) {
              return "Enter a valid card number";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildExpiryAndCVV(),
        const SizedBox(height: 20),
        const Text(
          "Cardholder Name",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: cardHolderController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: "John Doe",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter cardholder name";
            }
            return null;
          },
        ),
      ],
    ),
  );
}

Widget _buildExpiryAndCVV() {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Expiration Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: expiryMonthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "MM",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) > 12) {
                        return "Invalid";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: expiryYearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "YY",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return "Invalid";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 20),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CVV/CVC",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: cvvController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "XXX",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 3) {
                  return "Invalid";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    ],
  );
}
}


// ==================== E-Wallet Payment Widget ====================
class EWalletPayment extends StatelessWidget {
  final String amount;
  const EWalletPayment({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/gcashLogo.jpg',
              width: 100,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Securely complete the payment with your GCash app",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Open in GCash",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Or log in to GCash and scan this QR with the QR Scanner.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 15),

                Image.asset(
                  'assets/images/QRCode.png',
                  width: 150,
                  height: 150,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
