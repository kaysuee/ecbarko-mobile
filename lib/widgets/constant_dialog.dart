import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';

/// Constant Dialog System for EcBarko App
/// This file provides:
/// 1. All dialog types (success, error, warning, info, confirmation, action, custom)
/// 2. Usage examples for each dialog type
/// 3. Migration guide for existing dialogs
/// 4. Integration strategy for using both custom and uniform dialogs
/// 5. Complete documentation and examples

// =============================================================================
// CORE DIALOG SYSTEM
// =============================================================================

class ConstantDialog {
  // Colors for different dialog types
  static const Color _successColor = Colors.green;
  static const Color _errorColor = Colors.red;
  static const Color _warningColor = Colors.orange;
  static const Color _infoColor = Ec_PRIMARY;
  static const Color _neutralColor = Colors.grey;

  /// Success Dialog - Green theme for successful operations
  static Future<T?> showSuccessDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _SuccessDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Error Dialog - Red theme for error messages
  static Future<T?> showErrorDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _ErrorDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Warning Dialog - Orange theme for warnings
  static Future<T?> showWarningDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _WarningDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Info Dialog - Blue theme for information
  static Future<T?> showInfoDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _InfoDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Confirmation Dialog - Two buttons for user confirmation
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
      ),
    );
  }

  /// Action Dialog - Multiple action buttons
  static Future<T?> showActionDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    required List<DialogAction> actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _ActionDialog(
        title: title,
        message: message,
        actions: actions,
      ),
    );
  }

  /// Custom Dialog - For specific use cases
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    EdgeInsets? insetPadding,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _CustomDialog(
        child: child,
        insetPadding: insetPadding,
      ),
    );
  }
}

// =============================================================================
// DIALOG ACTION MODEL
// =============================================================================

/// Dialog Action Model
class DialogAction {
  final String text;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const DialogAction({
    required this.text,
    this.icon,
    this.color,
    this.onPressed,
    this.isDestructive = false,
  });
}

// =============================================================================
// BASE DIALOG IMPLEMENTATIONS
// =============================================================================

/// Base Dialog Widget with consistent styling
class _BaseDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget>? actions;
  final Color? accentColor;
  final IconData? icon;

  const _BaseDialog({
    required this.title,
    required this.message,
    this.actions,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      title: Column(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: (accentColor ?? ConstantDialog._infoColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor ?? ConstantDialog._infoColor,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black54,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
      actions: actions,
    );
  }
}

/// Success Dialog Implementation
class _SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const _SuccessDialog({
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: title,
      message: message,
      accentColor: ConstantDialog._successColor,
      icon: Icons.check_circle,
      actions: [
        _buildActionButton(
          context,
          confirmText ?? 'OK',
          ConstantDialog._successColor,
          onConfirm ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Error Dialog Implementation
class _ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const _ErrorDialog({
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: title,
      message: message,
      accentColor: ConstantDialog._errorColor,
      icon: Icons.error,
      actions: [
        _buildActionButton(
          context,
          confirmText ?? 'OK',
          ConstantDialog._errorColor,
          onConfirm ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Warning Dialog Implementation
class _WarningDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const _WarningDialog({
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: title,
      message: message,
      accentColor: ConstantDialog._warningColor,
      icon: Icons.warning,
      actions: [
        _buildActionButton(
          context,
          confirmText ?? 'OK',
          ConstantDialog._warningColor,
          onConfirm ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Info Dialog Implementation
class _InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const _InfoDialog({
    required this.title,
    required this.message,
    this.confirmText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: title,
      message: message,
      accentColor: ConstantDialog._infoColor,
      icon: Icons.info,
      actions: [
        _buildActionButton(
          context,
          confirmText ?? 'OK',
          ConstantDialog._infoColor,
          onConfirm ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Confirmation Dialog Implementation
class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor,
    this.cancelColor,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: title,
      message: message,
      accentColor: ConstantDialog._infoColor,
      icon: Icons.help,
      actions: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                cancelText,
                cancelColor ?? ConstantDialog._neutralColor,
                () => Navigator.of(context).pop(false),
                isOutlined: true,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                context,
                confirmText,
                confirmColor ?? ConstantDialog._infoColor,
                () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Action Dialog Implementation
class _ActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<DialogAction> actions;

  const _ActionDialog({
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: title,
      message: message,
      accentColor: ConstantDialog._infoColor,
      icon: Icons.touch_app,
      actions: [
        ...actions.map((action) => _buildActionButton(context, action)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, DialogAction action) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ElevatedButton.icon(
        onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
        icon: action.icon != null
            ? Icon(action.icon, size: 18.sp)
            : const SizedBox.shrink(),
        label: Text(
          action.text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: action.color ?? ConstantDialog._infoColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}

/// Custom Dialog Implementation
class _CustomDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsets? insetPadding;

  const _CustomDialog({
    required this.child,
    this.insetPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      insetPadding: insetPadding ?? EdgeInsets.symmetric(horizontal: 20.w),
      content: child,
    );
  }
}

// =============================================================================
// USAGE EXAMPLES
// =============================================================================

/// Usage Examples for Constant Dialog System
/// 
/// This section provides practical examples of how to use each dialog type
/// in your EcBarko app. Copy and modify these examples as needed.
class DialogUsageExamples {
  /// Example 1: Success Dialog
  static void showPaymentSuccess(BuildContext context) {
    ConstantDialog.showSuccessDialog(
      context: context,
      title: 'Payment Successful!',
      message:
          'Your booking has been confirmed. You will receive an e-ticket shortly.',
      confirmText: 'View E-Ticket',
      onConfirm: () {
        Navigator.of(context).pop();
        // Navigate to e-ticket screen
      },
    );
  }

  /// Example 2: Error Dialog
  static void showPaymentError(BuildContext context, String errorMessage) {
    ConstantDialog.showErrorDialog(
      context: context,
      title: 'Payment Failed',
      message: errorMessage,
      confirmText: 'Try Again',
      onConfirm: () {
        Navigator.of(context).pop();
        // Retry payment logic
      },
    );
  }

  /// Example 3: Warning Dialog
  static void showBookingWarning(BuildContext context) {
    ConstantDialog.showWarningDialog(
      context: context,
      title: 'Low Balance',
      message: 'Your account balance is low. Please top up to continue booking.',
      confirmText: 'Top Up Now',
      onConfirm: () {
        Navigator.of(context).pop();
        // Navigate to top-up screen
      },
    );
  }

  /// Example 4: Info Dialog
  static void showBookingInfo(BuildContext context) {
    ConstantDialog.showInfoDialog(
      context: context,
      title: 'Booking Information',
      message:
          'Your booking is currently being processed. Please wait for confirmation.',
      confirmText: 'Got It',
    );
  }

  /// Example 5: Confirmation Dialog
  static void showCancelConfirmation(BuildContext context) {
    ConstantDialog.showConfirmationDialog(
      context: context,
      title: 'Cancel Booking?',
      message:
          'Are you sure you want to cancel this booking? This action cannot be undone.',
      confirmText: 'Yes, Cancel',
      cancelText: 'Keep Booking',
      confirmColor: Colors.red,
    );
  }

  /// Example 6: Action Dialog
  static void showPaymentOptions(BuildContext context) {
    ConstantDialog.showActionDialog(
      context: context,
      title: 'Choose Payment Method',
      message: 'Select your preferred payment option:',
      actions: [
        DialogAction(
          text: 'Credit Card',
          icon: Icons.credit_card,
          onPressed: () {
            Navigator.of(context).pop();
            // Handle credit card payment
          },
        ),
        DialogAction(
          text: 'PayPal',
          icon: Icons.payment,
          onPressed: () {
            Navigator.of(context).pop();
            // Handle PayPal payment
          },
        ),
        DialogAction(
          text: 'Cancel',
          icon: Icons.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Example 7: Custom Dialog for Complex Content
  static void showCustomBookingDetails(
      BuildContext context, Map<String, dynamic> bookingData) {
    ConstantDialog.showCustomDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          // Add your custom booking details widget here
          Text('Custom content goes here...'),
        ],
      ),
    );
  }

  /// Example 8: Network Error Dialog
  static void showNetworkError(BuildContext context) {
    ConstantDialog.showErrorDialog(
      context: context,
      title: 'Connection Error',
      message:
          'Unable to connect to the server. Please check your internet connection and try again.',
      confirmText: 'Retry',
      onConfirm: () {
        Navigator.of(context).pop();
        // Retry network request
      },
    );
  }
}

// =============================================================================
// MIGRATION GUIDE
// =============================================================================

/// Migration Guide for Existing Dialogs
/// 
/// This section shows you how to replace existing AlertDialog implementations
/// with the new Constant Dialog system.
class DialogMigrationGuide {
  /// MIGRATION EXAMPLE 1: Replace Basic AlertDialog
  /// 
  /// BEFORE:
  /// ```dart
  /// showDialog(
  ///   context: context,
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Error'),
  ///     content: Text('Something went wrong'),
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(context),
  ///         child: Text('OK'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  /// 
  /// AFTER:
  /// ```dart
  /// ConstantDialog.showErrorDialog(
  ///   context: context,
  ///   title: 'Error',
  ///   message: 'Something went wrong',
  ///   confirmText: 'OK',
  /// );
  /// ```

  /// MIGRATION EXAMPLE 2: Replace Confirmation Dialog
  /// 
  /// BEFORE:
  /// ```dart
  /// showDialog(
  ///   context: context,
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Confirm Action'),
  ///     content: Text('Are you sure?'),
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(context, false),
  ///         child: Text('No'),
  ///       ),
  ///       ElevatedButton(
  ///         onPressed: () => Navigator.pop(context, true),
  ///         child: Text('Yes'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  /// 
  /// AFTER:
  /// ```dart
  /// final result = await ConstantDialog.showConfirmationDialog(
  ///   context: context,
  ///   title: 'Confirm Action',
  ///   message: 'Are you sure?',
  ///   confirmText: 'Yes',
  ///   cancelText: 'No',
  /// );
  /// 
  /// if (result == true) {
  ///   // User confirmed
  /// }
  /// ```

  /// MIGRATION EXAMPLE 3: Replace SnackBar with Dialog
  /// 
  /// BEFORE:
  /// ```dart
  /// ScaffoldMessenger.of(context).showSnackBar(
  ///   SnackBar(content: Text('Operation completed')),
  /// );
  /// ```
  /// 
  /// AFTER:
  /// ```dart
  /// ConstantDialog.showSuccessDialog(
  ///   context: context,
  ///   title: 'Success!',
  ///   message: 'Operation completed successfully.',
  ///   confirmText: 'Continue',
  /// );
  /// ```

  /// MIGRATION EXAMPLE 4: Replace Complex Action Dialog
  /// 
  /// BEFORE:
  /// ```dart
  /// showDialog(
  ///   context: context,
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Choose Option'),
  ///     content: Text('Select an action:'),
  ///     actions: [
  ///       ElevatedButton(
  ///         onPressed: () {
  ///           Navigator.pop(context);
  ///           // Action 1
  ///         },
  ///         child: Text('Option 1'),
  ///       ),
  ///       ElevatedButton(
  ///         onPressed: () {
  ///           Navigator.pop(context);
  ///           // Action 2
  ///         },
  ///         child: Text('Option 2'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  /// 
  /// AFTER:
  /// ```dart
  /// ConstantDialog.showActionDialog(
  ///   context: context,
  ///   title: 'Choose Option',
  ///   message: 'Select an action:',
  ///   actions: [
  ///     DialogAction(
  ///       text: 'Option 1',
  ///       icon: Icons.check,
  ///       onPressed: () {
  ///         Navigator.pop(context);
  ///         // Action 1
  ///       },
  ///     ),
  ///     DialogAction(
  ///       text: 'Option 2',
  ///       icon: Icons.edit,
  ///       onPressed: () {
  ///         Navigator.pop(context);
  ///         // Action 2
  ///       },
  ///     ),
  ///   ],
  /// );
  /// ```
}

// =============================================================================
// INTEGRATION STRATEGY
// =============================================================================

/// Integration Strategy for Using Both Dialog Systems
/// 
/// This section explains how to use your existing custom_dialog.dart
/// together with the new Constant Dialog system.
class DialogIntegrationStrategy {
  /// INTEGRATION STRATEGY: Use Both Systems!
  /// 
  /// You can use BOTH your existing custom_dialog.dart AND the new Constant Dialog:
  /// 
  /// - Use custom_dialog.dart for simple, quick dialogs
  /// - Use Constant Dialog for complex, themed dialogs
  /// 
  /// WHEN TO USE EACH SYSTEM:
  /// 
  /// Use Custom Dialogs For:
  /// - Simple OK dialogs
  /// - Basic confirmations
  /// - Quick messages
  /// - When you need your existing styling
  /// 
  /// Use Constant Dialogs For:
  /// - Success/Error/Warning dialogs
  /// - Complex action dialogs
  /// - Consistent theming across the app
  /// - When you want modern UI
  /// 
  /// QUICK START GUIDE:
  /// 
  /// 1. Keep using showCustomDialog() and showOptionDialog() for simple cases
  /// 2. Add import '../widgets/constant_dialog.dart'; to your files
  /// 3. Replace complex AlertDialogs with ConstantDialog.show*Dialog()
  /// 4. Mix and match both systems as needed
  /// 
  /// PRO TIPS:
  /// 
  /// - Don't rush - migrate dialogs one by one
  /// - Test each change before moving to the next
  /// - Use both systems - they complement each other
  /// - Customize colors in Constant Dialog to match your app theme
  /// 
  /// MIGRATION STRATEGY:
  /// 
  /// Phase 1: Keep What Works
  /// - Keep using showCustomDialog() for simple messages
  /// - Keep using showOptionDialog() for basic confirmations
  /// - Keep complex custom dialogs (like your support dialog)
  /// 
  /// Phase 2: Upgrade User Experience
  /// - Replace SnackBars with appropriate Constant Dialogs
  /// - Replace basic AlertDialogs with Constant Dialogs
  /// - Keep complex custom layouts as-is
  /// 
  /// Phase 3: Full Integration
  /// - Customize Constant Dialog colors to match your app theme
  /// - Add more dialog types as needed
  /// - Ensure consistent UX across the app
  /// 
  /// WHEN TO USE EACH SYSTEM:
  /// 
  /// | Use Case | Custom Dialog | Constant Dialog |
  /// |----------|---------------|----------------|
  /// | Simple OK message | ✅ showCustomDialog() | ❌ |
  /// | Basic confirmation | ✅ showOptionDialog() | ❌ |
  /// | Success message | ❌ | ✅ showSuccessDialog() |
  /// | Error message | ❌ | ✅ showErrorDialog() |
  /// | Warning message | ❌ | ✅ showWarningDialog() |
  /// | Info message | ❌ | ✅ showInfoDialog() |
  /// | Complex confirmation | ❌ | ✅ showConfirmationDialog() |
  /// | Multiple actions | ❌ | ✅ showActionDialog() |
  /// | Custom layout | ✅ Keep as-is | ❌ |
  /// 
  /// QUICK IMPLEMENTATION STEPS:
  /// 
  /// Step 1: Add Import
  /// ```dart
  /// import '../widgets/constant_dialog.dart';
  /// ```
  /// 
  /// Step 2: Replace SnackBars
  /// ```dart
  /// // OLD
  /// ScaffoldMessenger.of(context).showSnackBar(
  ///   SnackBar(content: Text('Message')),
  /// );
  /// 
  /// // NEW
  /// ConstantDialog.showInfoDialog(
  ///   context: context,
  ///   title: 'Title',
  ///   message: 'Message',
  ///   confirmText: 'OK',
  /// );
  /// ```
  /// 
  /// Step 3: Replace Basic AlertDialogs
  /// ```dart
  /// // OLD
  /// showDialog(
  ///   context: context,
  ///   builder: (context) => AlertDialog(
  ///     title: Text('Title'),
  ///     content: Text('Message'),
  ///     actions: [TextButton(child: Text('OK'), onPressed: () => Navigator.pop(context))],
  ///   ),
  /// );
  /// 
  /// // NEW
  /// ConstantDialog.showInfoDialog(
  ///   context: context,
  ///   title: 'Title',
  ///   message: 'Message',
  ///   confirmText: 'OK',
  /// );
  /// ```
  /// 
  /// CUSTOMIZATION:
  /// 
  /// Change Colors in constant_dialog.dart:
  /// ```dart
  /// // At the top of the file, change these colors:
  /// static const Color _successColor = Colors.green;  // Change to your brand color
  /// static const Color _errorColor = Colors.red;      // Change to your brand color
  /// static const Color _warningColor = Colors.orange; // Change to your brand color
  /// static const Color _infoColor = Ec_PRIMARY;       // Already using your brand color
  /// ```
  /// 
  /// FILES TO UPDATE:
  /// 
  /// Based on the search results, these files contain dialogs that should be migrated:
  /// 
  /// - lib/screens/payment_screen.dart
  /// - lib/screens/booking_screen.dart
  /// - lib/screens/bookingdetails_screen.dart
  /// - lib/screens/register_screen.dart
  /// - lib/screens/login_screen.dart
  /// - lib/screens/profile_screen.dart
  /// - lib/screens/edit_profile_screen.dart
  /// - lib/screens/account_security_screen.dart
  /// - lib/screens/buyload_screen.dart
  /// - lib/screens/notification_screen.dart
  /// - lib/screens/ticket_screen.dart
  /// - lib/screens/otp_screen.dart
  /// - lib/widgets/payment_card.dart
  /// - lib/widgets/schedule_card.dart
  /// 
  /// NEXT STEPS:
  /// 
  /// 1. Test the current changes in booking and payment screens
  /// 2. Choose 2-3 more files to migrate gradually
  /// 3. Customize colors in Constant Dialog to match your brand
  /// 4. Add new dialog types as needed for your app
  /// 
  /// NEED HELP?
  /// 
  /// - Check the usage examples above for more examples
  /// - Look at the migration examples above for detailed migration steps
  /// - Test each change in your app before moving to the next
  /// - Keep both systems working together - they complement each other!
}
