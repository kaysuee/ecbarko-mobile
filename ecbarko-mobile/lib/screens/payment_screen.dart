import 'package:flutter/material.dart';
import 'package:EcBarko/constants.dart';
import 'package:EcBarko/screens/ticket_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String departureLocation;
  final String arrivalLocation;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final String selectedCardType;
  final List<Map<String, String>> passengers;
  final bool hasVehicle;
  final String plateNumber;
  final String carType;

  const PaymentScreen({
    super.key,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.selectedCardType,
    required this.passengers,
    required this.hasVehicle,
    required this.plateNumber,
    required this.carType,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "EcBarko Card"; // Default payment method
  double totalAmount = 0.0;
  double passengerFare = 500; // Fixed fare per passenger
  double vehicleFare = 1000; // Fixed fare for vehicle

  @override
  void initState() {
    super.initState();
    calculateTotalAmount();
  }

  // Function to calculate the total amount
  void calculateTotalAmount() {
    totalAmount = (widget.passengers.length * passengerFare) +
        (widget.hasVehicle ? vehicleFare : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Ec_PRIMARY,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 PAYMENT METHOD SELECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // EcBarko Card
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = "EcBarko Card";
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: selectedPaymentMethod == "EcBarko Card"
                            ? Ec_PRIMARY
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(Icons.credit_card, color: Ec_PRIMARY),
                      title: const Text("EcBarko Card",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Radio<String>(
                        value: "EcBarko Card",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: Ec_PRIMARY,
                      ),
                    ),
                  ),
                ),

                // GCash
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = "GCash";
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: selectedPaymentMethod == "GCash"
                            ? Ec_PRIMARY
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet,
                          color: Ec_PRIMARY),
                      title: const Text("GCash",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Radio<String>(
                        value: "GCash",
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: Ec_PRIMARY,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📌 DETAILS SUMMARY IN ONE CARD
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Title
                        Row(
                          children: [
                            const Icon(Icons.directions_boat,
                                color: Ec_PRIMARY),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${widget.departureLocation} ➝ ${widget.arrivalLocation}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dates and Times
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Depart: ${widget.departDate} at ${widget.departTime}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.event_available,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Arrive: ${widget.arriveDate} at ${widget.arriveTime}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Shipping Line: ${widget.shippingLine}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30, thickness: 1),

                        // Passenger Details
                        const Text(
                          "👥 Passengers:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(widget.passengers.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "- ${widget.passengers[index]["name"]}: ₱${passengerFare.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }),
                        ),

                        // Vehicle Details
                        if (widget.hasVehicle) ...[
                          const Divider(height: 30, thickness: 1),
                          const Text(
                            "🚗 Vehicle Details:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text("Plate Number: ${widget.plateNumber}",
                              style: const TextStyle(fontSize: 16)),
                          Text("Car Type: ${widget.carType}",
                              style: const TextStyle(fontSize: 16)),
                          Text(
                              "Vehicle Fare: ₱${vehicleFare.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📌 TOTAL AMOUNT & PAY NOW BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Total Amount with Label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      "₱${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Pay Now Button with Icon
                ElevatedButton.icon(
                  label: const Text(
                    "Pay Now",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Ec_DARK_PRIMARY,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2)),
                  onPressed: () {
                    // Passing data to TicketScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketScreen(
                          departureLocation: widget.departureLocation,
                          arrivalLocation: widget.arrivalLocation,
                          departDate: widget.departDate,
                          departTime: widget.departTime,
                          arriveDate: widget.arriveDate,
                          arriveTime: widget.arriveTime,
                          shippingLine: widget.shippingLine,
                          selectedCardType: widget.selectedCardType,
                          passengers: widget.passengers,
                          hasVehicle: widget.hasVehicle,
                          // Correcting the vehicleDetails structure if a vehicle is present
                          vehicleDetails: widget.hasVehicle
                              ? [
                                  {
                                    "vehicleOwner": TextEditingController(
                                        text:
                                            ""), // Add necessary controller for owner
                                    "plateNumber": TextEditingController(
                                        text: widget.plateNumber),
                                    "carType": TextEditingController(
                                        text: widget.carType),
                                  }
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:EcBarko/constants.dart';

// class PaymentScreen extends StatefulWidget {
//   final String departureLocation;
//   final String arrivalLocation;
//   final String departDate;
//   final String departTime;
//   final String arriveDate;
//   final String arriveTime;
//   final String shippingLine;
//   final String selectedCardType;
//   final List<Map<String, String>> passengers;
//   final bool hasVehicle;
//   final String plateNumber;
//   final String carType;

//   const PaymentScreen({
//     super.key,
//     required this.departureLocation,
//     required this.arrivalLocation,
//     required this.departDate,
//     required this.departTime,
//     required this.arriveDate,
//     required this.arriveTime,
//     required this.shippingLine,
//     required this.selectedCardType,
//     required this.passengers,
//     required this.hasVehicle,
//     required this.plateNumber,
//     required this.carType,
//   });

//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   String selectedPaymentMethod = "EcBarko Card"; // Default payment method
//   double totalAmount = 0.0;
//   List<double> passengerFares = [];
//   double vehicleFare = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     generateFixedFares();
//   }

//   void generateFixedFares() {
//     // Set fixed fare for passengers (₱500 each)
//     passengerFares = List.generate(widget.passengers.length, (_) {
//       return 500; // Fixed fare of ₱500 per passenger
//     });

//     // Set fixed fare for vehicle (₱1000)
//     if (widget.hasVehicle) {
//       vehicleFare = 1000; // Fixed fare for vehicle
//     }

//     // Compute total
//     totalAmount = passengerFares.fold<double>(0.0, (sum, fare) => sum + fare) +
//         vehicleFare;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           'Payment',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: Ec_PRIMARY,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 📌 PAYMENT METHOD SELECTION
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Payment Method",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // EcBarko Card
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedPaymentMethod = "EcBarko Card";
//                     });
//                   },
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       side: BorderSide(
//                         color: selectedPaymentMethod == "EcBarko Card"
//                             ? Ec_PRIMARY
//                             : Colors.grey.shade300,
//                         width: 2,
//                       ),
//                     ),
//                     elevation: 4,
//                     shadowColor: Colors.black.withOpacity(0.1),
//                     child: ListTile(
//                       leading: const Icon(Icons.credit_card, color: Ec_PRIMARY),
//                       title: const Text("EcBarko Card",
//                           style: TextStyle(fontWeight: FontWeight.w600)),
//                       trailing: Radio<String>(
//                         value: "EcBarko Card",
//                         groupValue: selectedPaymentMethod,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedPaymentMethod = value!;
//                           });
//                         },
//                         activeColor: Ec_PRIMARY,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // GCash
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedPaymentMethod = "GCash";
//                     });
//                   },
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       side: BorderSide(
//                         color: selectedPaymentMethod == "GCash"
//                             ? Ec_PRIMARY
//                             : Colors.grey.shade300,
//                         width: 2,
//                       ),
//                     ),
//                     elevation: 4,
//                     shadowColor: Colors.black.withOpacity(0.1),
//                     child: ListTile(
//                       leading: const Icon(Icons.account_balance_wallet,
//                           color: Ec_PRIMARY),
//                       title: const Text("GCash",
//                           style: TextStyle(fontWeight: FontWeight.w600)),
//                       trailing: Radio<String>(
//                         value: "GCash",
//                         groupValue: selectedPaymentMethod,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedPaymentMethod = value!;
//                           });
//                         },
//                         activeColor: Ec_PRIMARY,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // 📌 DETAILS SUMMARY IN ONE CARD
//             Expanded(
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 6,
//                 shadowColor: Colors.black.withOpacity(0.1),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Route Title
//                         Row(
//                           children: [
//                             const Icon(Icons.directions_boat,
//                                 color: Ec_PRIMARY),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 "${widget.departureLocation} ➝ ${widget.arrivalLocation}",
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),

//                         // Dates and Times
//                         Row(
//                           children: [
//                             const Icon(Icons.calendar_today,
//                                 size: 18, color: Colors.grey),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 "Depart: ${widget.departDate} at ${widget.departTime}",
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             const Icon(Icons.event_available,
//                                 size: 18, color: Colors.grey),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 "Arrive: ${widget.arriveDate} at ${widget.arriveTime}",
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             const Icon(Icons.local_shipping,
//                                 size: 18, color: Colors.grey),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 "Shipping Line: ${widget.shippingLine}",
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Divider(height: 30, thickness: 1),

//                         // Passenger Details
//                         const Text(
//                           "👥 Passengers:",
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 5),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children:
//                               List.generate(widget.passengers.length, (index) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 2),
//                               child: Text(
//                                 "- ${widget.passengers[index]["name"]}: ₱${passengerFares[index].toStringAsFixed(2)}",
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             );
//                           }),
//                         ),

//                         // Vehicle Details
//                         if (widget.hasVehicle) ...[
//                           const Divider(height: 30, thickness: 1),
//                           const Text(
//                             "🚗 Vehicle Details:",
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 5),
//                           Text("Plate Number: ${widget.plateNumber}",
//                               style: const TextStyle(fontSize: 16)),
//                           Text("Car Type: ${widget.carType}",
//                               style: const TextStyle(fontSize: 16)),
//                           Text(
//                               "Vehicle Fare: ₱${vehicleFare.toStringAsFixed(2)}",
//                               style: const TextStyle(fontSize: 16)),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // 📌 TOTAL AMOUNT & PAY NOW BUTTON
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Total Amount with Label
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Total Amount",
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     Text(
//                       "₱${totalAmount.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Pay Now Button with Icon
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // TODO: Add Payment Logic
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           "Paid ₱${totalAmount.toStringAsFixed(2)} successfully!",
//                         ),
//                         backgroundColor: Colors.green[600],
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.payment, color: Colors.white),
//                   label: const Text(
//                     "Pay Now",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Ec_DARK_PRIMARY,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 14, horizontal: 24),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     elevation: 8,
//                     shadowColor: Colors.black.withOpacity(0.2),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
