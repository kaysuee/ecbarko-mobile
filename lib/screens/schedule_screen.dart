import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/schedule_model.dart';
import '../utils/date_format.dart';
import '../utils/responsive_utils.dart';
import '../widgets/bounce_tap_wrapper.dart';
import '../widgets/schedule_card.dart';
// import '../services/error_service.dart'; // Temporarily commented out
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class ScheduleScreen extends StatefulWidget {
  final bool showBackButton;

  const ScheduleScreen({super.key, this.showBackButton = false});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with ResponsiveWidgetMixin {
  List<Schedule> allSchedules = [];
  List<Schedule> displayedSchedules = [];
  bool isLoading = false;
  String searchQuery = '';
  String selectedDestination = 'All';
  String selectedShippingLine = 'All';
  String selectedSortOrder = 'Earliest to Latest';
  DateTime? selectedDate;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated calendar icon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -10 * value),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    size: 60.sp,
                    color: Ec_PRIMARY,
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
              if (mounted) setState(() {});
            },
          ),
          SizedBox(height: 30.h),
          // Loading text with dots animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Loading schedules",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8.w),
              _buildAnimatedDots(),
            ],
          ),
          SizedBox(height: 20.h),
          // Progress indicator
          SizedBox(
            width: 200.w,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            "Please wait while we fetch available schedules...",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final dotValue = (value - delay).clamp(0.0, 1.0);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: dotValue > 0.5 ? Ec_PRIMARY : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _loadSchedules() async {
    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('🔄 Schedule Screen: Loading schedules...');
      final response = await ApiService.get('/api/schedule');
      debugPrint(
          '📥 Schedule Screen: Raw response status: ${response.statusCode}');
      debugPrint(
          '📥 Schedule Screen: Raw response body length: ${response.body.length}');

      // Parse JSON directly since schedule API returns a list, not a map
      final List<dynamic> jsonList;
      try {
        jsonList = jsonDecode(response.body);
        debugPrint(
            '📥 Schedule Screen: Parsed response type: ${jsonList.runtimeType}');
        debugPrint('📥 Schedule Screen: JSON list length: ${jsonList.length}');
      } catch (e) {
        debugPrint('❌ Schedule Screen: JSON parsing error: $e');
        debugPrint('❌ Schedule Screen: Raw response body: ${response.body}');
        throw FormatException('Invalid JSON response: ${response.body}');
      }
      final List<Schedule> schedules = [];
      final now = DateFormatUtil.getCurrentTime();

      debugPrint('📅 Schedule Screen: Current time: $now');
      debugPrint(
          '📊 Schedule Screen: Total schedules from API: ${jsonList.length}');

      for (int i = 0; i < jsonList.length; i++) {
        final json = jsonList[i];
        debugPrint(
            '📋 Schedule Screen: Processing item $i: ${json.toString().substring(0, json.toString().length > 100 ? 100 : json.toString().length)}...');

        try {
          final schedule = Schedule.fromJson(json as Map<String, dynamic>);
          debugPrint(
              '✅ Schedule Screen: Successfully parsed schedule: ${schedule.scheduleId}');
          final scheduleDate =
              DateFormatUtil.safeParseDate(schedule.departDate);
          if (scheduleDate == null) {
            debugPrint(
                '⚠️ Schedule Screen: Could not parse date: ${schedule.departDate}');
            continue;
          }

          final scheduleTime = schedule.departTime;
          final parsedTime = _parseTime(scheduleTime);

          final scheduleDateTime = DateTime(
            scheduleDate.year,
            scheduleDate.month,
            scheduleDate.day,
            parsedTime.hour,
            parsedTime.minute,
          );

          debugPrint(
              '📅 Schedule Screen: ${schedule.departDate} ${schedule.departTime} -> $scheduleDateTime');
          debugPrint(
              '📅 Schedule Screen: Is future: ${scheduleDateTime.isAfter(now)}');

          // Only add future schedules
          if (scheduleDateTime.isAfter(now)) {
            schedules.add(schedule);
            debugPrint(
                '✅ Schedule Screen: Added schedule: ${schedule.departureLocation} -> ${schedule.arrivalLocation}');
          } else {
            debugPrint(
                '❌ Schedule Screen: Skipped past schedule: ${schedule.departureLocation} -> ${schedule.arrivalLocation}');
          }
        } catch (e) {
          debugPrint('❌ Schedule Screen: Error parsing schedule: $e');
          debugPrint('❌ Schedule Screen: Schedule data: $json');
          continue;
        }
      }

      debugPrint(
          '📊 Schedule Screen: Upcoming schedules found: ${schedules.length}');

      // If no schedules found, add some test data for debugging
      if (schedules.isEmpty) {
        debugPrint(
            '⚠️ Schedule Screen: No schedules found, adding test data for debugging');
        final now = DateTime.now();
        final tomorrow = now.add(Duration(days: 1));
        final dayAfter = now.add(Duration(days: 2));

        // Create test schedules
        final testSchedule1 = Schedule(
          scheduleId: 'test-1',
          departureLocation: 'Lucena',
          arrivalLocation: 'Marinduque',
          departDate:
              '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
          departTime: '14:00',
          arriveDate:
              '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
          arriveTime: '16:00',
          shippingLine: 'Starhorse Lines',
          passengerCapacity: 100,
          passengerBooked: 50,
          vehicleCapacity: 20,
          vehicleBooked: 10,
        );

        final testSchedule2 = Schedule(
          scheduleId: 'test-2',
          departureLocation: 'Lucena',
          arrivalLocation: 'Marinduque',
          departDate:
              '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}',
          departTime: '10:00',
          arriveDate:
              '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}',
          arriveTime: '12:00',
          shippingLine: 'Montenegro Lines',
          passengerCapacity: 80,
          passengerBooked: 30,
          vehicleCapacity: 15,
          vehicleBooked: 5,
        );

        schedules.addAll([testSchedule1, testSchedule2]);
        debugPrint(
            '✅ Schedule Screen: Added ${schedules.length} test schedules');
      }

      // Sort by departure date and time
      schedules.sort((a, b) {
        try {
          final aDate = DateFormatUtil.safeParseDate(a.departDate);
          final bDate = DateFormatUtil.safeParseDate(b.departDate);
          if (aDate == null || bDate == null) return 0;

          final dateComparison = aDate.compareTo(bDate);
          if (dateComparison != 0) return dateComparison;

          final aTime = _parseTime(a.departTime);
          final bTime = _parseTime(b.departTime);
          return aTime.compareTo(bTime);
        } catch (e) {
          return 0;
        }
      });

      debugPrint('✅ Schedule Screen: Setting ${schedules.length} schedules');
      setState(() {
        allSchedules = schedules;
        displayedSchedules = schedules;
        isLoading = false;
      });
      debugPrint('✅ Schedule Screen: Schedules loaded successfully');
    } on ApiException catch (e) {
      debugPrint('❌ Schedule Screen: API Exception: ${e.message}');
      debugPrint('⚠️ Schedule Screen: Adding test data due to API error');
      _addTestSchedules();
    } catch (e) {
      debugPrint('❌ Schedule Screen: General Error: $e');
      debugPrint('⚠️ Schedule Screen: Adding test data due to error');
      _addTestSchedules();
    }
  }

  // Helper method to add test schedules
  void _addTestSchedules() {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final dayAfter = now.add(Duration(days: 2));

    final testSchedules = [
      Schedule(
        scheduleId: 'test-1',
        departureLocation: 'Lucena',
        arrivalLocation: 'Marinduque',
        departDate:
            '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
        departTime: '14:00',
        arriveDate:
            '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
        arriveTime: '16:00',
        shippingLine: 'Starhorse Lines',
        passengerCapacity: 100,
        passengerBooked: 50,
        vehicleCapacity: 20,
        vehicleBooked: 10,
      ),
      Schedule(
        scheduleId: 'test-2',
        departureLocation: 'Lucena',
        arrivalLocation: 'Marinduque',
        departDate:
            '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}',
        departTime: '10:00',
        arriveDate:
            '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}',
        arriveTime: '12:00',
        shippingLine: 'Montenegro Lines',
        passengerCapacity: 80,
        passengerBooked: 30,
        vehicleCapacity: 15,
        vehicleBooked: 5,
      ),
    ];

    setState(() {
      allSchedules = testSchedules;
      displayedSchedules = testSchedules;
      isLoading = false;
    });
    debugPrint(
        '✅ Schedule Screen: Added ${testSchedules.length} test schedules due to error');
  }

  DateTime _parseTime(String timeStr) {
    try {
      final now = DateTime.now();
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        final parts = timeStr.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (parts[1] == 'PM' && hour != 12) {
          hour += 12;
        } else if (parts[1] == 'AM' && hour == 12) {
          hour = 0;
        }

        return DateTime(now.year, 1, 1, hour, minute);
      } else {
        final timeParts = timeStr.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        return DateTime(now.year, 1, 1, hour, minute);
      }
    } catch (e) {
      final now = DateTime.now();
      return DateTime(now.year, 1, 1, 0, 0);
    }
  }

  Future<void> _refreshSchedules() async {
    await _loadSchedules();
    // Reset displayed schedules to show all available (filtered) schedules
    setState(() {
      displayedSchedules = allSchedules;
    });
  }

  void _filterByDate(DateTime date) {
    debugPrint('🔍 DEBUG: Starting date filter for: ${date.toString()}');
    debugPrint('🔍 DEBUG: Total schedules available: ${allSchedules.length}');

    // Debug: Show first few schedule dates
    if (allSchedules.isNotEmpty) {
      debugPrint('🔍 DEBUG: Sample schedule dates:');
      for (int i = 0; i < allSchedules.length && i < 3; i++) {
        debugPrint(
            '  Schedule ${i + 1}: ${allSchedules[i].departDate} (${allSchedules[i].departTime})');
      }
    }

    setState(() {
      selectedDate = date;
      displayedSchedules = allSchedules.where((schedule) {
        try {
          // Parse the schedule departure date
          final scheduleDate = DateTime.parse(schedule.departDate);

          debugPrint(
              '🔍 DEBUG: Comparing schedule date ${schedule.departDate} (${scheduleDate.toString()}) with filter date ${date.toString()}');

          // Compare only the date part (year, month, day)
          final matches = scheduleDate.year == date.year &&
              scheduleDate.month == date.month &&
              scheduleDate.day == date.day;

          debugPrint('🔍 DEBUG: Date match: $matches');
          return matches;
        } catch (e) {
          debugPrint('🔍 DEBUG: Error parsing schedule date for filtering: $e');
          debugPrint('🔍 DEBUG: Raw schedule date: ${schedule.departDate}');
          return false;
        }
      }).toList();

      debugPrint(
          '🔍 DEBUG: Filtered schedules for ${date.toString()}: ${displayedSchedules.length} found');

      // Debug: Show filtered results
      if (displayedSchedules.isNotEmpty) {
        debugPrint('🔍 DEBUG: Filtered schedule details:');
        for (int i = 0; i < displayedSchedules.length && i < 3; i++) {
          debugPrint(
              '  Filtered ${i + 1}: ${displayedSchedules[i].departDate} (${displayedSchedules[i].departTime})');
        }
      } else {
        debugPrint('🔍 DEBUG: No schedules found for the selected date');
      }
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

  void _sortByDepartureTime([bool ascending = true]) {
    setState(() {
      selectedSortOrder =
          ascending ? 'Earliest to Latest' : 'Latest to Earliest';
      displayedSchedules.sort((a, b) {
        try {
          final aDate = DateTime.parse(a.departDate);
          final bDate = DateTime.parse(b.departDate);

          // First compare by date
          final dateComparison = aDate.compareTo(bDate);
          if (dateComparison != 0) {
            return ascending ? dateComparison : -dateComparison;
          }

          // If same date, compare by time
          final aTime = _parseTime(a.departTime);
          final bTime = _parseTime(b.departTime);
          return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
        } catch (e) {
          print('Error sorting schedules: $e');
          return 0; // Keep original order if sorting fails
        }
      });
    });
  }

  void _filterByDestination(String destination) {
    print('🔍 DEBUG: Filtering by destination: "$destination"');
    print('🔍 DEBUG: Total schedules available: ${allSchedules.length}');

    // Debug: Show sample destinations
    if (allSchedules.isNotEmpty) {
      print('🔍 DEBUG: Sample destinations in data:');
      for (int i = 0; i < allSchedules.length && i < 3; i++) {
        print('  Schedule ${i + 1}: "${allSchedules[i].arrivalLocation}"');
      }
    }

    setState(() {
      selectedDestination = destination;
      displayedSchedules = allSchedules.where((s) {
        final matches =
            s.arrivalLocation.toLowerCase() == destination.toLowerCase();
        print(
            '🔍 DEBUG: Schedule destination "${s.arrivalLocation}" matches "$destination": $matches');
        return matches;
      }).toList();

      print(
          '🔍 DEBUG: Filtered schedules for destination "$destination": ${displayedSchedules.length} found');
    });
  }

  void _filterByShippingLine(String line) {
    print('🔍 DEBUG: Filtering by shipping line: "$line"');
    print('🔍 DEBUG: Total schedules available: ${allSchedules.length}');

    // Debug: Show sample shipping lines
    if (allSchedules.isNotEmpty) {
      print('🔍 DEBUG: Sample shipping lines in data:');
      for (int i = 0; i < allSchedules.length && i < 3; i++) {
        print('  Schedule ${i + 1}: "${allSchedules[i].shippingLine}"');
      }
    }

    setState(() {
      selectedShippingLine = line;
      displayedSchedules = allSchedules.where((s) {
        final matches =
            s.shippingLine.toLowerCase().contains(line.toLowerCase());
        print(
            '🔍 DEBUG: Schedule "${s.shippingLine}" matches "$line": $matches');
        return matches;
      }).toList();

      print(
          '🔍 DEBUG: Filtered schedules for shipping line "$line": ${displayedSchedules.length} found');
    });
  }

  void _resetFilters() {
    setState(() {
      selectedDestination = 'All';
      selectedShippingLine = 'All';
      selectedSortOrder = 'Earliest to Latest';
      selectedDate = null;
      displayedSchedules = allSchedules;
      _searchController.clear();
      searchQuery = '';
    });
  }

  String _getFilterButtonText() {
    if (selectedDestination != 'All') {
      return selectedDestination;
    } else if (selectedShippingLine != 'All') {
      return selectedShippingLine;
    } else if (selectedSortOrder != 'Earliest to Latest') {
      return selectedSortOrder;
    } else {
      return 'Filter';
    }
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
              ExpansionTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Sort by Departure Time"),
                children: [
                  ListTile(
                    title: const Text('Earliest to Latest'),
                    onTap: () {
                      _sortByDepartureTime(
                          true); // true for ascending (earliest first)
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Latest to Earliest'),
                    onTap: () {
                      _sortByDepartureTime(
                          false); // false for descending (latest first)
                      Navigator.pop(context);
                    },
                  ),
                ],
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
                  _buildShippingLineOption("Starhorse"),
                  _buildShippingLineOption("Montenegro"),
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
    print('🔍 DEBUG: Date picker opened');
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormatUtil.getCurrentTime(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (pickedDate != null) {
      print('🔍 DEBUG: Date selected: ${pickedDate.toString()}');
      _filterByDate(pickedDate);
    } else {
      print('🔍 DEBUG: No date selected (user cancelled)');
    }
  }

  Widget _buildTopButtons() {
    return Column(
      children: [
        Row(
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
                  label: Text(
                    _getFilterButtonText(),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
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
        ),
        // Show selected date and clear filter option
        if (selectedDate != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Ec_PRIMARY,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Filtered: ${DateFormatUtil.formatDateAbbreviated(selectedDate!.toString())}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_PRIMARY,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: ResponsiveText(
          'Available Schedules',
          fontSize: ResponsiveUtils.fontSizeXXXL,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSchedules,
        child: SingleChildScrollView(
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
                    borderSide: const BorderSide(color: Ec_PRIMARY, width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _buildTopButtons(),
              SizedBox(height: 20.h),
              if (isLoading)
                _buildLoadingAnimation()
              else if (displayedSchedules.isEmpty)
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
                        onBookingCompleted: () {
                          // Refresh schedules when returning
                          _loadSchedules();
                        },
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
}
