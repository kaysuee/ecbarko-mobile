import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'responsive_utils.dart';

// Responsive layout builder that provides different layouts based on screen size
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveLayoutType layoutType)
      builder;
  final ResponsiveLayoutType? preferredLayout;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
    this.preferredLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutType = _getLayoutType(context, constraints);
        return builder(context, layoutType);
      },
    );
  }

  ResponsiveLayoutType _getLayoutType(
      BuildContext context, BoxConstraints constraints) {
    if (preferredLayout != null) return preferredLayout!;

    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    if (width < ResponsiveUtils.mobileBreakpoint) {
      return ResponsiveLayoutType.mobile;
    } else if (width < ResponsiveUtils.tabletBreakpoint) {
      return ResponsiveLayoutType.tablet;
    } else {
      return ResponsiveLayoutType.desktop;
    }
  }
}

enum ResponsiveLayoutType {
  mobile,
  tablet,
  desktop,
}

// Responsive scaffold that adapts to different screen sizes
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, layoutType) {
        return Scaffold(
          appBar: appBar,
          body: body,
          drawer: layoutType == ResponsiveLayoutType.mobile ? drawer : null,
          endDrawer: endDrawer,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          primary: primary,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        );
      },
    );
  }
}

// Responsive page view that adapts to screen orientation
class ResponsivePageView extends StatelessWidget {
  final List<Widget> children;
  final PageController? controller;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final bool allowImplicitScrolling;
  final bool reverse;
  final String? restorationId;
  final Clip clipBehavior;
  final ScrollBehavior? scrollBehavior;
  final bool padEnds;

  const ResponsivePageView({
    super.key,
    required this.children,
    this.controller,
    this.physics,
    this.pageSnapping = true,
    this.allowImplicitScrolling = false,
    this.reverse = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final crossAxisCount = isLandscape ? 2 : 1;

        if (crossAxisCount > 1) {
          // Use grid layout for landscape/tablet
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio:
                  ResponsiveUtils.getResponsiveAspectRatio(context),
              crossAxisSpacing: ResponsiveUtils.spacingM,
              mainAxisSpacing: ResponsiveUtils.spacingM,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        }

        // Use page view for portrait/mobile
        return PageView(
          controller: controller,
          physics: physics,
          pageSnapping: pageSnapping,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          scrollBehavior: scrollBehavior,
          padEnds: padEnds,
          children: children,
        );
      },
    );
  }
}

// Responsive bottom sheet that adapts to screen size
class ResponsiveBottomSheet extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final Clip clipBehavior;
  final ShapeBorder? shape;
  final bool enableDrag;
  final bool isDismissible;
  final bool isScrollControlled;
  final bool useSafeArea;
  final bool useRootNavigator;
  final bool isPersistent;
  final Color? barrierColor;
  final double? initialChildSize;
  final double? minChildSize;
  final double? maxChildSize;
  final bool expand;

  const ResponsiveBottomSheet({
    super.key,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.clipBehavior = Clip.none,
    this.shape,
    this.enableDrag = true,
    this.isDismissible = true,
    this.isScrollControlled = false,
    this.useSafeArea = true,
    this.useRootNavigator = true,
    this.isPersistent = false,
    this.barrierColor,
    this.initialChildSize,
    this.minChildSize,
    this.maxChildSize,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, layoutType) {
        final responsiveShape = shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUtils.cardRadiusLarge),
              ),
            );

        final responsiveInitialSize = initialChildSize ??
            (layoutType == ResponsiveLayoutType.mobile ? 0.5 : 0.4);
        final responsiveMaxSize = maxChildSize ??
            (layoutType == ResponsiveLayoutType.mobile ? 0.9 : 0.8);

        return DraggableScrollableSheet(
          initialChildSize: responsiveInitialSize,
          minChildSize: minChildSize ?? 0.3,
          maxChildSize: responsiveMaxSize,
          expand: expand,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ResponsiveUtils.cardRadiusLarge),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: ResponsiveUtils.screenPadding,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Responsive dialog that adapts to screen size
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final Clip clipBehavior;
  final ShapeBorder? shape;
  final bool insetPadding;
  final Color? barrierColor;
  final bool barrierDismissible;
  final bool useSafeArea;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;
  final Offset? anchorPoint;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.clipBehavior = Clip.none,
    this.shape,
    this.insetPadding = true,
    this.barrierColor,
    this.barrierDismissible = true,
    this.useSafeArea = true,
    this.useRootNavigator = true,
    this.routeSettings,
    this.anchorPoint,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, layoutType) {
        final responsiveShape = shape ??
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ResponsiveUtils.cardRadiusLarge),
            );

        final responsivePadding = layoutType == ResponsiveLayoutType.mobile
            ? ResponsiveUtils.screenPadding
            : ResponsiveUtils.screenPaddingLarge;

        return Dialog(
          backgroundColor: backgroundColor,
          elevation: elevation,
          clipBehavior: clipBehavior,
          shape: responsiveShape,
          insetPadding: insetPadding ? responsivePadding : null,
          child: Padding(
            padding: responsivePadding,
            child: child,
          ),
        );
      },
    );
  }
}

// Responsive navigation drawer that adapts to screen size
class ResponsiveNavigationDrawer extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final double? width;
  final bool semanticLabel;
  final TileMode? tileMode;
  final Color? shadowColor;
  final double? surfaceTintColor;

  const ResponsiveNavigationDrawer({
    super.key,
    required this.children,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.width,
    this.semanticLabel = true,
    this.tileMode,
    this.shadowColor,
    this.surfaceTintColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, layoutType) {
        final responsiveWidth =
            width?.w ?? (layoutType == ResponsiveLayoutType.mobile ? 280 : 320);

        return NavigationDrawer(
          backgroundColor: backgroundColor,
          elevation: elevation,
          shadowColor: shadowColor,
          children: children,
        );
      },
    );
  }
}
