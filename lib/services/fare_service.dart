class FareService {
  // Passenger fare rates
  static const Map<String, double> passengerFares = {
    'regular': 470.00,
    'student': 400.00,
    'senior': 335.00,
    'half': 235.00,
    'adult': 470.00,
    'child': 235.00,
    'senior citizen': 335.00,
    'pwd': 335.00,
    'infant': 0.00,
  };

  // Vehicle fare rates
  static const Map<String, double> vehicleFares = {
    'bicycle': 338.00,
    'bicycle with sidecar': 676.00,
    'motorcycle': 1352.00,
    'motorcycle with sidecar': 2028.00,
    'small cars': 2704.00,
    'medium vehicles': 3380.00,
    'large vehicles': 4056.00,
    'extra large vehicles': 4732.00,
    'small bus': 5408.00,
    'medium bus': 6084.00,
    'large bus': 6760.00,
    'extra large bus': 7436.00,
    'small truck': 8112.00,
    'medium truck': 8788.00,
    'large truck': 9464.00,
  };

  // Terminal fees
  static const Map<String, double> terminalFees = {
    'regular': 30.00,
    'student': 0.00,
    'senior': 0.00,
    'senior citizen': 0.00,
    'pwd': 0.00,
  };

  // Get passenger fare based on ticket type
  static double getPassengerFare(String ticketType) {
    final normalizedType = ticketType.toLowerCase().trim();

    // Direct match
    if (passengerFares.containsKey(normalizedType)) {
      return passengerFares[normalizedType]!;
    }

    // Partial matches
    for (String key in passengerFares.keys) {
      if (normalizedType.contains(key) || key.contains(normalizedType)) {
        return passengerFares[key]!;
      }
    }

    // Default to regular fare
    return passengerFares['regular']!;
  }

  // Get vehicle fare based on vehicle type
  static double getVehicleFare(String vehicleType) {
    final normalizedType = vehicleType.toLowerCase().trim();

    // Direct match
    if (vehicleFares.containsKey(normalizedType)) {
      return vehicleFares[normalizedType]!;
    }

    // Partial matches
    for (String key in vehicleFares.keys) {
      if (normalizedType.contains(key) || key.contains(normalizedType)) {
        return vehicleFares[key]!;
      }
    }

    // Default to small car fare
    return vehicleFares['small cars']!;
  }

  // Get terminal fee based on passenger type
  static double getTerminalFee(String passengerType) {
    final normalizedType = passengerType.toLowerCase().trim();

    // Direct match
    if (terminalFees.containsKey(normalizedType)) {
      return terminalFees[normalizedType]!;
    }

    // Partial matches
    for (String key in terminalFees.keys) {
      if (normalizedType.contains(key) || key.contains(normalizedType)) {
        return terminalFees[key]!;
      }
    }

    // Default to regular terminal fee
    return terminalFees['regular']!;
  }

  // Calculate total fare for a passenger (fare + terminal fee)
  static double getTotalPassengerFare(String ticketType) {
    final fare = getPassengerFare(ticketType);
    final terminalFee = getTerminalFee(ticketType);
    return fare + terminalFee;
  }
}
