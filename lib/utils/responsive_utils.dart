import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  // Screen breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Responsive padding and margins
  static EdgeInsets get screenPadding => EdgeInsets.all(16.w);
  static EdgeInsets get screenPaddingLarge => EdgeInsets.all(24.w);
  static EdgeInsets get screenPaddingSmall => EdgeInsets.all(12.w);

  // Responsive spacing
  static double get spacingXS => 4.h;
  static double get spacingS => 8.h;
  static double get spacingM => 16.h;
  static double get spacingL => 24.h;
  static double get spacingXL => 32.h;
  static double get spacingXXL => 48.h;

  // Responsive font sizes
  static double get fontSizeXS => 10.sp;
  static double get fontSizeS => 12.sp;
  static double get fontSizeM => 14.sp;
  static double get fontSizeL => 16.sp;
  static double get fontSizeXL => 18.sp;
  static double get fontSizeXXL => 20.sp;
  static double get fontSizeXXXL => 24.sp;
  static double get fontSizeDisplay => 32.sp;

  // Responsive icon sizes
  static double get iconSizeS => 16.w;
  static double get iconSizeM => 24.w;
  static double get iconSizeL => 32.w;
  static double get iconSizeXL => 48.w;

  // Responsive button heights
  static double get buttonHeightS => 40.h;
  static double get buttonHeightM => 48.h;
  static double get buttonHeightL => 56.h;

  // Responsive card dimensions
  static double get cardRadius => 12.r;
  static double get cardRadiusLarge => 16.r;
  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);
  static EdgeInsets get cardPaddingLarge => EdgeInsets.all(24.w);

  // Check device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  // Get responsive width based on screen size
  static double getResponsiveWidth(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return screenWidth * mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return screenWidth * tablet;
    } else {
      return screenWidth * desktop;
    }
  }

  // Get responsive height based on screen size
  static double getResponsiveHeight(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.9,
    double desktop = 0.8,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < mobileBreakpoint) {
      return screenHeight * mobile;
    } else if (screenHeight < tabletBreakpoint) {
      return screenHeight * tablet;
    } else {
      return screenHeight * desktop;
    }
  }

  // Responsive text style
  static TextStyle responsiveTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize?.sp ?? fontSizeM,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Responsive box constraints
  static BoxConstraints getResponsiveConstraints(
    BuildContext context, {
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth?.w ?? 0,
      maxWidth: maxWidth?.w ?? double.infinity,
      minHeight: minHeight?.h ?? 0,
      maxHeight: maxHeight?.h ?? double.infinity,
    );
  }

  // Safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  // Responsive grid layout
  static int getResponsiveGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    if (isMobile(context)) return 16 / 9;
    if (isTablet(context)) return 4 / 3;
    return 3 / 2;
  }
}

// Responsive widget mixin
mixin ResponsiveWidgetMixin<T extends StatefulWidget> on State<T> {
  bool get isMobile => ResponsiveUtils.isMobile(context);
  bool get isTablet => ResponsiveUtils.isTablet(context);
  bool get isDesktop => ResponsiveUtils.isDesktop(context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  EdgeInsets get safePadding => ResponsiveUtils.getSafeAreaPadding(context);
}

// Responsive container widget
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final Alignment? alignment;
  final bool useSafeArea;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
    this.useSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height?.h,
      padding: padding ?? ResponsiveUtils.screenPadding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}

// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final TextDecoration? decoration;

  const ResponsiveText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ResponsiveUtils.responsiveTextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Responsive button widget
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const ResponsiveButton(
    this.text, {
    super.key,
    this.onPressed,
    this.height,
    this.width,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height?.h ?? ResponsiveUtils.buttonHeightM,
      width: width?.w,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(ResponsiveUtils.cardRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: 8.w),
            ],
            ResponsiveText(
              text,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
