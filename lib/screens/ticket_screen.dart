import 'package:EcBarko/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class TicketScreen extends StatelessWidget {
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
  final List<Map<String, String>> vehicleDetail;
  final String bookingReference;

  TicketScreen({
    Key? key,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.selectedCardType,
    required this.passengers,
    this.hasVehicle = false,
    required this.vehicleDetail,
    required this.bookingReference,
  }) : super(key: key);

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    "E-Ticket",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("Booking Reference: $bookingReference",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text("Route",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("$departureLocation to $arrivalLocation"),
                pw.SizedBox(height: 8),
                pw.Text("Departure",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("$departDate at $departTime"),
                pw.SizedBox(height: 4),
                pw.Text("Arrival",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("$arriveDate at $arriveTime"),
                pw.SizedBox(height: 8),
                pw.Text("Shipping Line",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(shippingLine),
                pw.SizedBox(height: 4),
                pw.Text("Card Type",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(selectedCardType),
                pw.SizedBox(height: 12),
                pw.Text("Passengers",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 4),
                ...passengers.map((p) => pw.Bullet(
                      text: "${p["name"]} (Contact: ${p["contact"]})",
                      bulletColor: PdfColors.indigo,
                    )),
                if (hasVehicle && vehicleDetail != null) ...[
                  pw.SizedBox(height: 12),
                  pw.Text("Vehicle Information",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.SizedBox(height: 4),
                  ...vehicleDetail!.asMap().entries.map((entry) {
                    final i = entry.key;
                    final vehicle = entry.value;
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Vehicle ${i + 1}",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          if (vehicle['vehicleOwner'] != null &&
                              vehicle['vehicleOwner']!.isNotEmpty)
                            pw.Text(
                              "Driver: ${vehicle['vehicleOwner']}",
                              style: pw.TextStyle(fontSize: 14.sp),
                            ),
                          pw.Text(
                              "Plate: ${vehicle['plateNumber'] ?? ""}"),
                          pw.Text("Type: ${vehicle['carType'] ?? ""}"),
                        ],
                      ),
                    );
                  }),
                ],
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.Center(
                  child: pw.Text("Thank you for booking with us!",
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey)),
                )
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String label,
      required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(content,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'E-Ticket',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Ec_PRIMARY,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Exit Ticket'),
                  content: const Text('What would you like to do?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _generatePdf(context);
                      },
                      child: const Text('Print Ticket'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text('Go to Dashboard'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("E-Ticket",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  const SizedBox(height: 4),
                  Text("Booking Ref: $bookingReference",
                      style: TextStyle(color: Colors.grey[700])),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoCard(
                  icon: Icons.directions_boat,
                  label: "Shipping Line",
                  content: shippingLine),
              const SizedBox(height: 12),
              _buildInfoCard(
                  icon: Icons.location_on,
                  label: "Route",
                  content: "$departureLocation → $arrivalLocation"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildInfoCard(
                          icon: Icons.calendar_today,
                          label: "Departure",
                          content: "$departDate\n$departTime")),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildInfoCard(
                          icon: Icons.event,
                          label: "Arrival",
                          content: "$arriveDate\n$arriveTime")),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                  icon: Icons.credit_card,
                  label: "Card Type",
                  content: selectedCardType),
              const SizedBox(height: 20),
              const Text("Passengers",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...passengers.map((p) => Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(p["name"] ?? ""),
                      subtitle: Text("Contact: ${p["contact"] ?? ""}"),
                    ),
                  )),
              if (hasVehicle && vehicleDetail != null) ...[
                const SizedBox(height: 20),
                const Text("Vehicle Information",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...vehicleDetail!.asMap().entries.map((entry) {
                  final i = entry.key;
                  final vehicle = entry.value;
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text("Vehicle ${i + 1}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Driver: ${vehicle["vehicleOwner"] ?? ""}"),
                          Text("Plate: ${vehicle["plateNumber"] ?? ""}"),
                          Text("Type: ${vehicle["carType"] ?? ""}"),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              Center(
                  child: Text("Thank you for booking with us!",
                      style: TextStyle(color: Colors.grey[600]))),
            ],
          ),
        ),
      ),
    );
  }
}
