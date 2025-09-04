# Booking Summary Components

This directory contains reusable booking summary components extracted from your existing design.

## Components

### 1. BookingSummaryWidget (`booking_summary_widget.dart`)

A reusable widget that displays a comprehensive booking summary.

**Features:**
- ✅ Booking header with ID and status
- ✅ Trip details with visual route
- ✅ Passenger details
- ✅ Vehicle details (if applicable)
- ✅ Payment summary
- ✅ Booking information
- ✅ Action buttons (optional)
- ✅ Help functionality (optional)
- ✅ Contextual help for each section
- ✅ Customizable callbacks
- ✅ Responsive design

**Usage:**
```dart
BookingSummaryWidget(
  booking: myBooking,
  showActionButtons: true,
  onManageBooking: () {
    // Handle manage booking action
  },
  onShareBooking: () {
    // Handle share booking action
  },
  padding: EdgeInsets.all(16.w),
  margin: EdgeInsets.symmetric(vertical: 8.h),
)
```

**Parameters:**
- `booking` (required): The BookingModel to display
- `showActionButtons` (optional): Whether to show action buttons (default: true)
- `showHelpButton` (optional): Whether to show help functionality (default: true)
- `onManageBooking` (optional): Callback for manage booking action
- `onShareBooking` (optional): Callback for share booking action
- `onGetHelp` (optional): Callback for help action
- `padding` (optional): Custom padding around the widget
- `margin` (optional): Custom margin around the widget

### 2. BookingSummaryScreen (`booking_summary_screen.dart`)

A standalone screen that wraps the BookingSummaryWidget with an app bar.

**Features:**
- ✅ App bar with title, help button, and share button
- ✅ Pull-to-refresh functionality
- ✅ Back button (optional)
- ✅ Uses BookingSummaryWidget internally
- ✅ Integrated help functionality
- ✅ Responsive design

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingSummaryScreen(
      booking: myBooking,
      showBackButton: true,
      onRefresh: () async {
        // Refresh booking data
      },
      onManageBooking: () {
        // Handle manage booking action
      },
      onShareBooking: () {
        // Handle share booking action
      },
    ),
  ),
);
```

**Parameters:**
- `booking` (required): The BookingModel to display
- `showBackButton` (optional): Whether to show back button (default: true)
- `onRefresh` (optional): Callback for pull-to-refresh
- `onManageBooking` (optional): Callback for manage booking action
- `onShareBooking` (optional): Callback for share booking action

### 3. BookingHelpWidget (`booking_help_widget.dart`)

A comprehensive help system for booking-related features.

**Features:**
- ✅ Contextual help for different sections
- ✅ FAQ integration
- ✅ Support contact functionality
- ✅ Help tooltips and explanations
- ✅ Booking management guidance
- ✅ Multiple help dialog types

**Usage:**
```dart
// Show main help dialog
BookingHelpWidget.showBookingHelpDialog(context);

// Show section-specific help
BookingHelpWidget.showSectionHelp(
  context,
  'Trip Details',
  'This section shows your departure and arrival locations...',
);
```

## Design Features

### Visual Elements
- **Status Badges**: Color-coded status indicators
- **Route Visualization**: Visual dots and lines showing departure/arrival
- **Card Layout**: Clean white cards with subtle shadows
- **Icons**: Contextual icons for different sections
- **Color Scheme**: Uses your app's Ec_PRIMARY color theme

### Responsive Design
- Uses `flutter_screenutil` for responsive sizing
- Adapts to different screen sizes
- Consistent spacing and typography

### Interactive Elements
- **Manage Booking**: Modal bottom sheet with options
- **Share Details**: Built-in sharing functionality
- **Cancel Booking**: Confirmation dialog
- **Pull-to-Refresh**: Refresh data functionality

## Integration Examples

### 1. Use as Widget in Existing Screen
```dart
class MyBookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Other content
            BookingSummaryWidget(
              booking: booking,
              showActionButtons: false, // Hide buttons if not needed
            ),
            // More content
          ],
        ),
      ),
    );
  }
}
```

### 2. Use as Standalone Screen
```dart
// Navigate to booking summary screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BookingSummaryScreen(
      booking: booking,
      onRefresh: () async {
        // Refresh booking data
        await refreshBookingData();
      },
    ),
  ),
);
```

### 3. Customize Actions
```dart
BookingSummaryWidget(
  booking: booking,
  onManageBooking: () {
    // Custom manage booking logic
    showCustomManageDialog();
  },
  onShareBooking: () {
    // Custom share logic
    shareBookingViaEmail();
  },
  onGetHelp: () {
    // Custom help logic
    showCustomHelpDialog();
  },
)
```

### 4. Help Functionality
```dart
// Show comprehensive help dialog
BookingHelpWidget.showBookingHelpDialog(context);

// Show section-specific help
BookingHelpWidget.showSectionHelp(
  context,
  'Payment Summary',
  'This section shows the cost breakdown...',
);

// Widget with help buttons in each section
BookingSummaryWidget(
  booking: booking,
  showHelpButton: true, // Shows help buttons in section headers
  onGetHelp: () => BookingHelpWidget.showBookingHelpDialog(context),
)
```

## Dependencies

- `flutter/material.dart`
- `flutter_screenutil`
- `../models/booking_model.dart`
- `../constants.dart`

## Notes

- The components use your existing BookingModel structure
- All styling follows your app's design system
- Components are fully responsive and accessible
- Easy to customize and extend
- Reusable across different parts of your app
