// File: models/booking_models.dart

class PassengerModel {
  final String name;
  final String ticketType;
  final double fare;
  final String? contactNumber;

  const PassengerModel({
    required this.name,
    required this.ticketType,
    required this.fare,
    this.contactNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ticketType': ticketType,
      'fare': fare,
      'contactNumber': contactNumber,
    };
  }

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      name: json['name'] ?? '',
      ticketType: json['ticketType'] ?? '',
      fare: (json['fare'] ?? 0).toDouble(),
      contactNumber: json['contactNumber'],
    );
  }
}

class VehicleInfoModel {
  final String vehicleType;
  final String plateNumber;
  final double fare;
  final String? owner;
  final String? customType;

  const VehicleInfoModel({
    required this.vehicleType,
    required this.plateNumber,
    required this.fare,
    this.owner,
    this.customType,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'plateNumber': plateNumber,
      'fare': fare,
      'owner': owner,
      'customType': customType,
    };
  }

  factory VehicleInfoModel.fromJson(Map<String, dynamic> json) {
    return VehicleInfoModel(
      vehicleType: json['vehicleType'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      fare: (json['fare'] ?? 0).toDouble(),
      owner: json['owner'],
      customType: json['customType'],
    );
  }
}

enum BookingStatus {
  pending,
  active,
  completed,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get name {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.active:
        return 'active';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class BookingModel {
  final String bookingId;
  final String departureLocation;
  final String arrivalLocation;
  final String departurePort;
  final String arrivalPort;

  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;

  final String? returnDate;
  final String? returnTime;
  final String? returnArriveDate;
  final String? returnArriveTime;
  final bool isRoundTrip;

  final int passengers;
  final List<PassengerModel> passengerDetails;

  final bool hasVehicle;
  final VehicleInfoModel? vehicleInfo;

  final BookingStatus status;
  final String shippingLine;
  final String bookingDate;
  final DateTime createdAt;

  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? transactionId;

  const BookingModel({
    required this.bookingId,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departurePort,
    required this.arrivalPort,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    this.returnDate,
    this.returnTime,
    this.returnArriveDate,
    this.returnArriveTime,
    this.isRoundTrip = false,
    required this.passengers,
    required this.passengerDetails,
    this.hasVehicle = false,
    this.vehicleInfo,
    required this.status,
    required this.shippingLine,
    required this.bookingDate,
    required this.createdAt,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'departureLocation': departureLocation,
      'arrivalLocation': arrivalLocation,
      'departurePort': departurePort,
      'arrivalPort': arrivalPort,
      'departDate': departDate,
      'departTime': departTime,
      'arriveDate': arriveDate,
      'arriveTime': arriveTime,
      'returnDate': returnDate,
      'returnTime': returnTime,
      'returnArriveDate': returnArriveDate,
      'returnArriveTime': returnArriveTime,
      'isRoundTrip': isRoundTrip,
      'passengers': passengers,
      'passengerDetails': passengerDetails.map((p) => p.toJson()).toList(),
      'hasVehicle': hasVehicle,
      'vehicleInfo': vehicleInfo?.toJson(),
      'status': status.name,
      'shippingLine': shippingLine,
      'bookingDate': bookingDate,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] ?? '',
      departureLocation: json['departureLocation'] ?? '',
      arrivalLocation: json['arrivalLocation'] ?? '',
      departurePort: json['departurePort'] ?? '',
      arrivalPort: json['arrivalPort'] ?? '',
      departDate: json['departDate'] ?? '',
      departTime: json['departTime'] ?? '',
      arriveDate: json['arriveDate'] ?? '',
      arriveTime: json['arriveTime'] ?? '',
      returnDate: json['returnDate'],
      returnTime: json['returnTime'],
      returnArriveDate: json['returnArriveDate'],
      returnArriveTime: json['returnArriveTime'],
      isRoundTrip: json['isRoundTrip'] ?? false,
      passengers: int.tryParse(json['passengers'].toString()) ?? 0,
      passengerDetails: (json['passengerDetails'] as List<dynamic>?)
              ?.map((p) => PassengerModel.fromJson(p))
              .toList() ??
          [],
      hasVehicle: json['hasVehicle'] ?? false,
      vehicleInfo: json['vehicleInfo'] != null
          ? VehicleInfoModel.fromJson(json['vehicleInfo'])
          : null,
      status: BookingStatusExtension.fromString(json['status'] ?? 'pending'),
      shippingLine: json['shippingLine'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
    );
  }

  BookingModel copyWith({
    String? bookingId,
    String? departureLocation,
    String? arrivalLocation,
    String? departurePort,
    String? arrivalPort,
    String? departDate,
    String? departTime,
    String? arriveDate,
    String? arriveTime,
    String? returnDate,
    String? returnTime,
    String? returnArriveDate,
    String? returnArriveTime,
    bool? isRoundTrip,
    int? passengers,
    List<PassengerModel>? passengerDetails,
    bool? hasVehicle,
    VehicleInfoModel? vehicleInfo,
    BookingStatus? status,
    String? shippingLine,
    String? bookingDate,
    DateTime? createdAt,
    double? totalAmount,
    String? paymentStatus,
    String? paymentMethod,
    String? transactionId,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      departureLocation: departureLocation ?? this.departureLocation,
      arrivalLocation: arrivalLocation ?? this.arrivalLocation,
      departurePort: departurePort ?? this.departurePort,
      arrivalPort: arrivalPort ?? this.arrivalPort,
      departDate: departDate ?? this.departDate,
      departTime: departTime ?? this.departTime,
      arriveDate: arriveDate ?? this.arriveDate,
      arriveTime: arriveTime ?? this.arriveTime,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      returnArriveDate: returnArriveDate ?? this.returnArriveDate,
      returnArriveTime: returnArriveTime ?? this.returnArriveTime,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      passengers: passengers ?? this.passengers,
      passengerDetails: passengerDetails ?? this.passengerDetails,
      hasVehicle: hasVehicle ?? this.hasVehicle,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      status: status ?? this.status,
      shippingLine: shippingLine ?? this.shippingLine,
      bookingDate: bookingDate ?? this.bookingDate,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
