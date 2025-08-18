import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/schedule_card.dart';
import '../models/schedule_model.dart';
import '../models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000'; // Change this to your actual base URL
}

class BookingScreen extends StatefulWidget {
  final bool showBackButton;
  final int initialTab;

  const BookingScreen(
      {Key? key, this.showBackButton = false, this.initialTab = 0})
      : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  List<BookingModel> activeBookings = [];
  Timer? _bookingCheckTimer;

  List<Schedule> allSchedules = [];

  List<Schedule> displayedSchedules = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

    _loadActiveBooking();
    _loadBooking();
    // Set up periodic check for booking statuses (every 5 minutes)
    _bookingCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadActiveBooking();
      _loadBooking();
    });
  }

  @override
  void dispose() {
    _bookingCheckTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${getBaseUrl()}/api/schedule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      final List<Schedule> updatedSchedule = [];

      for (var json in jsonList) {
        final schedule = Schedule.fromJson(json as Map<String, dynamic>);

        updatedSchedule.add(schedule);
      }

      setState(() {
        allSchedules = updatedSchedule;
        displayedSchedules = updatedSchedule;
      });
    }
  }

  Future<void> _loadActiveBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final now = DateTime.now();

        // Filter and update bookings
        final List<BookingModel> updatedBookings = [];
        for (var json in jsonList) {
          final booking = BookingModel.fromJson(json as Map<String, dynamic>);

          // Parse departure date and time
          final departDate = DateTime.parse(booking.departDate);
          final departTime = DateFormat('hh:mm a').parse(booking.departTime);

          // Combine date and time
          final departureDateTime = DateTime(
            departDate.year,
            departDate.month,
            departDate.day,
            departTime.hour,
            departTime.minute,
          );

          // Check if booking is completed
          if (departureDateTime.isBefore(now)) {
            // Update booking status to completed
            await _updateBookingStatus(booking.bookingId, 'completed', token);
          } else {
            updatedBookings.add(booking);
          }
        }

        setState(() {
          activeBookings = updatedBookings;
        });
      } else {
        print('Failed to load booking data: ${response.statusCode}');
      }
    }
  }

  Future<void> _updateBookingStatus(
      String bookingId, String status, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/actbooking/$bookingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode != 200) {
        print('Failed to update booking status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }

  String formatDepartDate(String departDateString) {
    final dateTime = DateTime.parse(departDateString);
    return DateFormat('MMM dd EEE').format(dateTime);
  }

  Widget _buildActiveBookingCard(BookingModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Booking ID and Status
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Ec_PRIMARY.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: ${booking.bookingId}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Ec_PRIMARY,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status.name),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    booking.status.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Booking Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Route Information
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.departureLocation,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.departurePort,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Ec_TEXT_COLOR_GREY,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        height: 1.h,
                        color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
                      ),
                    ),
                    Icon(
                      Icons.directions_boat,
                      color: Ec_PRIMARY,
                      size: 24.sp,
                    ),
                    Expanded(
                      child: Container(
                        height: 1.h,
                        color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          booking.arrivalLocation,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.arrivalPort,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Ec_TEXT_COLOR_GREY,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Date and Time Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Ec_TEXT_COLOR_GREY,
                          ),
                        ),
                        Text(
                          '${formatDepartDate(booking.departDate)} at ${booking.departTime}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Passengers',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Ec_TEXT_COLOR_GREY,
                          ),
                        ),
                        Text(
                          '${booking.passengers} ${booking.passengers > 1 ? 'people' : 'person'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (booking.hasVehicle) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 16.sp,
                        color: Ec_PRIMARY,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Vehicle included',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Ec_PRIMARY,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 16.h),

                // Shipping Line
                Text(
                  booking.shippingLine,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Ec_TEXT_COLOR_GREY,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                SizedBox(height: 16.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewBookingDetails(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_PRIMARY.withOpacity(0.1),
                          foregroundColor: Ec_PRIMARY,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _manageBooking(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_PRIMARY,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Manage Booking',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Ec_PRIMARY;
    }
  }

  void _viewBookingDetails(BookingModel booking) {
    // Navigate to booking details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening booking details for ${booking.bookingId}'),
      ),
    );
  }

  void _manageBooking(BookingModel booking) {
    // Navigate to manage booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Managing booking ${booking.bookingId}'),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedDate = null;
      _searchController.clear();
      displayedSchedules = List.from(allSchedules);
    });
  }

  void _filterByDate(DateTime date) {
    final formatted = DateFormat('MMM dd EEE').format(date);
    setState(() {
      selectedDate = date;
      displayedSchedules = allSchedules
          .where((schedule) => schedule.departDate.contains(formatted))
          .toList();
    });
  }

  void _searchSchedules(String query) {
    setState(() {
      displayedSchedules = allSchedules.where((schedule) {
        final destination = schedule.arrivalLocation.toLowerCase();
        final shippingLine = schedule.shippingLine.toLowerCase();
        return destination.contains(query.toLowerCase()) ||
            shippingLine.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _sortByDepartureTime() {
    setState(() {
      displayedSchedules.sort((a, b) =>
          _parseTime(a.departTime).compareTo(_parseTime(b.departTime)));
    });
  }

  DateTime _parseTime(String timeStr) {
    return DateFormat('hh:mm a').parse(timeStr);
  }

  void _filterByDestination(String destination) {
    setState(() {
      displayedSchedules = allSchedules
          .where((s) =>
              s.arrivalLocation.toLowerCase() == destination.toLowerCase())
          .toList();
    });
  }

  void _filterByShippingLine(String line) {
    setState(() {
      displayedSchedules = allSchedules
          .where((s) => s.shippingLine.toLowerCase() == line.toLowerCase())
          .toList();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const Text(
                'Filter & Sort Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Sort by Departure Time'),
                onTap: () {
                  _sortByDepartureTime();
                  Navigator.pop(context);
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.place),
                title: const Text("Filter by Destination"),
                children: [
                  _buildFilterOption("Marinduque"),
                  _buildFilterOption("Banton"),
                  _buildFilterOption("Masbate"),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.directions_boat),
                title: const Text("Filter by Shipping Line"),
                children: [
                  _buildShippingLineOption("STARHORSE Shipping Lines"),
                  _buildShippingLineOption("Montenegro Shipping Lines"),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Reset Filters'),
                onTap: () {
                  _resetFilters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String destination) {
    return ListTile(
      title: Text(destination),
      onTap: () {
        _filterByDestination(destination);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildShippingLineOption(String line) {
    return ListTile(
      title: Text(line),
      onTap: () {
        _filterByShippingLine(line);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _chooseSchedule() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (pickedDate != null) {
      _filterByDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Bookings',
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
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Text(
                'Active Bookings',
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
            Tab(
              child: Text(
                'Available Schedules',
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Bookings Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeBookings.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.h),
                      child: Column(
                        children: [
                          Icon(Icons.directions_boat,
                              size: 60.sp, color: Ec_PRIMARY.withOpacity(0.7)),

                          // Icon(Icons.booking,
                          //     size: 60.sp, color: Ec_PRIMARY.withOpacity(0.7)),
                          SizedBox(height: 10.h),
                          Text(
                            "No active bookings",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Ec_TEXT_COLOR_GREY,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Book a trip to see your bookings here",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Ec_TEXT_COLOR_GREY,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeBookings.length,
                    itemBuilder: (context, index) {
                      return _buildActiveBookingCard(activeBookings[index]);
                    },
                  ),
              ],
            ),
          ),

          // Available Schedules Tab (existing content)
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                TextField(
                  controller: _searchController,
                  onChanged: _searchSchedules,
                  decoration: InputDecoration(
                    hintText: 'Search by destination, port, or shipping line',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: Ec_PRIMARY, width: 1.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildTopButtons(),
                SizedBox(height: 20.h),
                if (displayedSchedules.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.h),
                      child: Column(
                        children: [
                          Icon(Icons.search_off,
                              size: 60.sp, color: Ec_PRIMARY.withOpacity(0.7)),
                          SizedBox(height: 10.h),
                          Text(
                            "No schedules found.",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Ec_TEXT_COLOR_GREY,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = displayedSchedules[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 15.h),
                        child: ScheduleCard(
                          schedcde: schedule.scheduleId,
                          departureLocation: schedule.departureLocation,
                          arrivalLocation: schedule.arrivalLocation,
                          departDate: schedule.departDate,
                          departTime: schedule.departTime,
                          arriveDate: schedule.arriveDate,
                          arriveTime: schedule.arriveTime,
                          shippingLine: schedule.shippingLine,
                          passengerSlotsLeft: schedule.passengerCapacity -
                              schedule.passengerBooked,
                          vehicleSlotsLeft:
                              schedule.vehicleCapacity - schedule.vehicleBooked,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 5.w),
            child: ElevatedButton.icon(
              onPressed: _chooseSchedule,
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: Text('Choose Date',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: ElevatedButton.icon(
              onPressed: _showSortOptions,
              icon: const Icon(Icons.sort, color: Colors.white),
              label: Text('Filter',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
