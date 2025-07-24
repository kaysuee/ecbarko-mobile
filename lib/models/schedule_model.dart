class Schedule {
  final String scheduleId;
  final String departureLocation;
  final String arrivalLocation;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final int passengerBooked;
  final int vehicleBooked;
  final int passengerCapacity;
  final int vehicleCapacity;

  const Schedule({
    required this.scheduleId,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.passengerBooked,
    required this.vehicleBooked,
    required this.passengerCapacity,
    required this.vehicleCapacity,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['schedcde'] ?? '',
      departureLocation: json['from'] ?? '',
      arrivalLocation: json['to'] ?? '',
      departDate: json['date'] ?? '',
      departTime: json['departureTime'] ?? '',
      arriveDate: json['arriveDate'] ?? '',
      arriveTime: json['arrivalTime'] ?? '',
      shippingLine: json['shippingLines'] ?? '',
      passengerBooked: json['passengerBooked'] ?? 0,
      vehicleBooked: json['vehicleBooked'] ?? 0,
      passengerCapacity: json['passengerCapacity'] ?? 0,
      vehicleCapacity: json['vehicleCapacity'] ?? 0,
    );
  }
}
