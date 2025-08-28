import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive_utils.dart';

// Responsive card widget with adaptive layout
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool useSafeArea;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.useSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin ?? EdgeInsets.all(8.w),
      elevation: elevation ?? 2,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(ResponsiveUtils.cardRadius),
      ),
      child: Padding(
        padding: padding ?? ResponsiveUtils.cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius:
            borderRadius ?? BorderRadius.circular(ResponsiveUtils.cardRadius),
        child: card,
      );
    }

    return useSafeArea ? SafeArea(child: card) : card;
  }
}

// Responsive grid layout widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            ResponsiveUtils.getResponsiveGridCrossAxisCount(context);
        final itemWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return GridView.builder(
          padding: padding ?? ResponsiveUtils.screenPadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: ResponsiveUtils.getResponsiveAspectRatio(context),
            crossAxisSpacing: spacing.w,
            mainAxisSpacing: runSpacing.h,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => SizedBox(
            width: itemWidth.w,
            child: children[index],
          ),
        );
      },
    );
  }
}

// Responsive list view widget
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool primary;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? ResponsiveUtils.screenPadding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      primary: primary,
      itemCount: children.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: ResponsiveUtils.spacingM),
      itemBuilder: (context, index) => children[index],
    );
  }
}

// Responsive row widget that adapts to screen size
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsets? padding;
  final bool wrapOnSmallScreen;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.padding,
    this.wrapOnSmallScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveUtils.isMobile(context) &&
            wrapOnSmallScreen &&
            constraints.maxWidth < 400) {
          // Stack vertically on small mobile screens
          return Column(
            crossAxisAlignment: crossAxisAlignment,
            children: children
                .map((child) => Padding(
                      padding:
                          EdgeInsets.only(bottom: ResponsiveUtils.spacingM),
                      child: child,
                    ))
                .toList(),
          );
        }

        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children,
        );
      },
    );
  }
}

// Responsive column widget with adaptive spacing
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsets? padding;
  final bool adaptiveSpacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.padding,
    this.adaptiveSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: adaptiveSpacing ? _addAdaptiveSpacing(children) : children,
    );
  }

  List<Widget> _addAdaptiveSpacing(List<Widget> widgets) {
    if (widgets.length <= 1) return widgets;

    final List<Widget> spacedWidgets = [];
    for (int i = 0; i < widgets.length; i++) {
      spacedWidgets.add(widgets[i]);
      if (i < widgets.length - 1) {
        spacedWidgets.add(SizedBox(height: ResponsiveUtils.spacingM));
      }
    }
    return spacedWidgets;
  }
}

// Responsive input field widget
class ResponsiveInputField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const ResponsiveInputField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;

        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          focusNode: focusNode,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: ResponsiveUtils.responsiveTextStyle(
            fontSize: isCompact ? 14 : 16,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      size: ResponsiveUtils.iconSizeM,
                      color: Colors.grey[600],
                    ),
                    child: prefixIcon!,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      size: ResponsiveUtils.iconSizeM,
                      color: Colors.grey[600],
                    ),
                    child: suffixIcon!,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacingM,
              vertical: isCompact ? 12.h : 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}

// Responsive image widget
class ResponsiveImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;

  const ResponsiveImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveWidth = width?.w ?? constraints.maxWidth;
        final responsiveHeight =
            height?.h ?? (width?.w ?? constraints.maxWidth) * 0.75;

        Widget image = Image.asset(
          imagePath,
          width: responsiveWidth,
          height: responsiveHeight,
          fit: fit,
        );

        if (borderRadius != null) {
          image = ClipRRect(
            borderRadius: borderRadius!,
            child: image,
          );
        }

        if (decoration != null) {
          image = Container(
            decoration: decoration,
            child: image,
          );
        }

        return image;
      },
    );
  }
}

// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double? width;
  final double? height;
  final bool adaptive;

  const ResponsiveSpacing({
    super.key,
    this.width,
    this.height,
    this.adaptive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (adaptive) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;
          final adaptiveWidth = width?.w ?? (isCompact ? 8.w : 16.w);
          final adaptiveHeight = height?.h ?? (isCompact ? 8.h : 16.h);

          return SizedBox(
            width: adaptiveWidth,
            height: adaptiveHeight,
          );
        },
      );
    }

    return SizedBox(
      width: width?.w,
      height: height?.h,
    );
  }
}
