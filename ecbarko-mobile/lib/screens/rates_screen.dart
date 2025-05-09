import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';

class RatesScreen extends StatefulWidget {
  final bool showBackButton;
  final bool initialVehicleTab;

  const RatesScreen({
    Key? key,
    this.showBackButton = false,
    this.initialVehicleTab = true, // <-- default value
  }) : super(key: key);

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen>
    with SingleTickerProviderStateMixin {
  // bool isVehicleSelected = true;
  late bool isVehicleSelected;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    isVehicleSelected = widget.initialVehicleTab;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(
  //     duration: const Duration(milliseconds: 500),
  //     vsync: this,
  //   )..forward();
  // }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rates',
          style: TextStyle(
            color: Ec_LIGHT_PRIMARY,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildSegmentedToggle(),
            SizedBox(height: 20.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isVehicleSelected
                      ? _buildVehicleRates()
                      : _buildPassengerRates(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          _buildSegmentButton('Vehicle', isVehicleSelected, () {
            setState(() => isVehicleSelected = true);
          }),
          _buildSegmentButton('Passengers', !isVehicleSelected, () {
            setState(() => isVehicleSelected = false);
          }),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: active ? Ec_PRIMARY : Colors.transparent,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Ec_PRIMARY,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleRates() {
    return ListView(
      key: const ValueKey('vehicle'),
      children: [
        _buildSection(
            'TYPE 1',
            [
              [Text('Bicycle'), Text('₱338.00')],
              [Text('Bicycle with Sidecar'), Text('₱676.00')],
              [Text('Motorcycle'), Text('₱1,352.00')],
              [Text('Motorcycle with Sidecar'), Text('₱2,028.00')],
            ],
            isFirst: true),
        _buildSection('TYPE 2', [
          [Text('3.1–4.0 meters'), Text('₱2,704.00')],
          [Text('4.1–5.0 meters'), Text('₱3,380.00')],
        ]),
        _buildSection('TYPE 3', [
          [Text('5.1–6.0 meters'), Text('₱4,056.00')],
          [Text('6.1–7.0 meters'), Text('₱4,732.00')],
        ]),
        _buildSection('TYPE 4', [
          [Text('7.1–8.0 meters'), Text('₱5,408.00')],
          [Text('8.1–9.0 meters'), Text('₱6,084.00')],
          [Text('9.1–10.0 meters'), Text('₱6,760.00')],
          [Text('10.1–11.0 meters'), Text('₱7,436.00')],
          [Text('11.1–12.0 meters'), Text('₱8,112.00')],
          [Text('12.1–13.0 meters'), Text('₱8,788.00')],
          [Text('13.1–14.0 meters'), Text('₱9,464.00')],
        ]),
      ],
    );
  }

  Widget _buildPassengerRates() {
    return ListView(
      key: const ValueKey('passenger'),
      children: [
        _buildSection(
            'Fare Rates',
            [
              [Text('Regular Fare'), Text('₱470.00')],
              [Text('Student Fare'), Text('₱400.00')],
              [Text('Senior Citizen Fare'), Text('₱335.00')],
              [
                Tooltip(
                  message: 'Applies to children aged 3–7 years old.',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Half Fare'),
                        SizedBox(width: 4.w),
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.grey.shade700),
                      ],
                    ),
                  ),
                ),
                Text('₱235.00', textAlign: TextAlign.right),
              ],
            ],
            isFirst: true),
        _buildSection('Terminal Fees', [
          [Text('Regular Passenger'), Text('₱30.00')],
          [Text('Student / Senior Citizen'), Text('Free')],
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<List<Widget>> rows,
      {bool isFirst = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, top: isFirst ? 0 : 16.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Ec_PRIMARY,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          margin: EdgeInsets.only(bottom: 12.h),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.r)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TYPE',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Container(
                      width: 100.w,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 12.w),
                      child: Text(
                        'RATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                final isEven = index % 2 == 0;
                final slideTween = Tween<Offset>(
                  begin: Offset(0, 0.1 * (index + 1)),
                  end: Offset.zero,
                );

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _controller,
                      child: SlideTransition(
                        position: slideTween.animate(
                          CurvedAnimation(
                              parent: _controller, curve: Curves.easeOut),
                        ),
                        child: Container(
                          color: isEven ? Colors.white : Colors.grey.shade100,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 12.w),
                          child: Row(
                            children: [
                              Expanded(child: row[0]),
                              Container(
                                width: 100.w,
                                alignment: Alignment.centerRight,
                                child: row[1],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
