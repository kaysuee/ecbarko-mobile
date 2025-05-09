import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/schedule_card.dart';
import '../models/schedule_model.dart';

class BookingsScreen extends StatefulWidget {
  final bool showBackButton;

  const BookingsScreen({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Schedule> allSchedules = [
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Marinduque',
      arrivalPort: 'Balanacan Port',
      departDate: 'May 10 Sat',
      departTime: '03:30 AM',
      arriveDate: 'May 10 Sat',
      arriveTime: '06:30 AM',
      shippingLine: 'STARHORSE Shipping Lines',
      passengerSlotsLeft: 32,
      vehicleSlotsLeft: 8,
    ),
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Banton',
      arrivalPort: 'Banton Port',
      departDate: 'May 10 Sat',
      departTime: '05:30 AM',
      arriveDate: 'May 10 Sat',
      arriveTime: '11:30 AM',
      shippingLine: 'STARHORSE Shipping Lines',
      passengerSlotsLeft: 18,
      vehicleSlotsLeft: 5,
    ),
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Masbate',
      arrivalPort: 'Masbate Port',
      departDate: 'May 11 Sun',
      departTime: '04:00 AM',
      arriveDate: 'May 11 Sun',
      arriveTime: '01:30 PM',
      shippingLine: 'STARHORSE Shipping Lines',
      passengerSlotsLeft: 45,
      vehicleSlotsLeft: 12,
    ),
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Marinduque',
      arrivalPort: 'Santa Cruz Port',
      departDate: 'May 12 Mon',
      departTime: '02:00 AM',
      arriveDate: 'May 12 Mon',
      arriveTime: '05:00 AM',
      shippingLine: 'Montenegro Shipping Lines',
      passengerSlotsLeft: 26,
      vehicleSlotsLeft: 7,
    ),
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Banton',
      arrivalPort: 'Banton Port',
      departDate: 'May 13 Tue',
      departTime: '03:00 AM',
      arriveDate: 'May 13 Tue',
      arriveTime: '10:00 AM',
      shippingLine: 'Montenegro Shipping Lines',
      passengerSlotsLeft: 15,
      vehicleSlotsLeft: 3,
    ),
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Masbate',
      arrivalPort: 'Masbate Port',
      departDate: 'May 14 Wed',
      departTime: '04:00 AM',
      arriveDate: 'May 14 Wed',
      arriveTime: '12:00 PM',
      shippingLine: 'FastCat',
      passengerSlotsLeft: 39,
      vehicleSlotsLeft: 10,
    ),
    const Schedule(
      departureLocation: 'Lucena',
      departurePort: 'Dalahican Port',
      arrivalLocation: 'Marinduque',
      arrivalPort: 'Balanacan Port',
      departDate: 'May 15 Thu',
      departTime: '01:30 AM',
      arriveDate: 'May 15 Thu',
      arriveTime: '04:30 AM',
      shippingLine: 'FastCat',
      passengerSlotsLeft: 29,
      vehicleSlotsLeft: 6,
    ),
  ];

  List<Schedule> displayedSchedules = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    displayedSchedules = List.from(allSchedules);
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
        final port = schedule.arrivalPort.toLowerCase();
        final shippingLine = schedule.shippingLine.toLowerCase();
        return destination.contains(query.toLowerCase()) ||
            port.contains(query.toLowerCase()) ||
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

  void _resetFilters() {
    setState(() {
      selectedDate = null;
      _searchController.clear();
      displayedSchedules = List.from(allSchedules);
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
      backgroundColor: Ec_BG_SKY_BLUE, // Added light blue background color
      appBar: AppBar(
        title: const Text(
          'Schedules',
          style: TextStyle(
            color: Colors.white, // Changed to white for better contrast
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
      ),
      body: SingleChildScrollView(
        // Add bottom padding for navigation bar
        // padding: EdgeInsets.only(bottom: 80.h),
        padding: EdgeInsets.only(bottom: 20.h),

        child: Padding(
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
                  // Add shadow to search box
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
                        departureLocation: schedule.departureLocation,
                        departurePort: schedule.departurePort,
                        arrivalLocation: schedule.arrivalLocation,
                        arrivalPort: schedule.arrivalPort,
                        departDate: schedule.departDate,
                        departTime: schedule.departTime,
                        arriveDate: schedule.arriveDate,
                        arriveTime: schedule.arriveTime,
                        shippingLine: schedule.shippingLine,
                        passengerSlotsLeft: schedule.passengerSlotsLeft,
                        vehicleSlotsLeft: schedule.vehicleSlotsLeft,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
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
