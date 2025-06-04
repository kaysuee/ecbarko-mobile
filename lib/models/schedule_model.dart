class Schedule {
  final String departureLocation;
  final String departurePort;
  final String arrivalLocation;
  final String arrivalPort;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final int passengerSlotsLeft;
  final int vehicleSlotsLeft;

  const Schedule({
    required this.departureLocation,
    required this.departurePort,
    required this.arrivalLocation,
    required this.arrivalPort,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.passengerSlotsLeft,
    required this.vehicleSlotsLeft,
  });
}

// class Schedule {
//   final String departureLocation;
//   final String departurePort;
//   final String arrivalLocation;
//   final String arrivalPort;
//   final String departDate;
//   final String departTime;
//   final String arriveDate;
//   final String arriveTime;
//   final String shippingLine;

//   const Schedule({
//     required this.departureLocation,
//     required this.departurePort,
//     required this.arrivalLocation,
//     required this.arrivalPort,
//     required this.departDate,
//     required this.departTime,
//     required this.arriveDate,
//     required this.arriveTime,
//     required this.shippingLine,
//   });
// }
