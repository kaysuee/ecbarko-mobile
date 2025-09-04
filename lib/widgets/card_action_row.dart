import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import 'bounce_tap_wrapper.dart';

/// Reusable Card Action Row Widget
///
/// This widget provides a consistent action row with three buttons:
/// - Load (for adding funds)
/// - Link Card (for linking cards)
/// - History (for viewing transaction history)
class CardActionRow extends StatelessWidget {
  final VoidCallback? onLoadTap;
  final VoidCallback? onLinkCardTap;
  final VoidCallback? onHistoryTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const CardActionRow({
    super.key,
    this.onLoadTap,
    this.onLinkCardTap,
    this.onHistoryTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Ec_PRIMARY.withOpacity(0.08),
            Ec_PRIMARY.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Ec_PRIMARY.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildCardActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Load',
              onTap: onLoadTap ??
                  () {
                    debugPrint('🔄 Load button tapped!');
                  },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildCardActionButton(
              context,
              icon: Icons.credit_card,
              label: 'Link Card',
              onTap: onLinkCardTap ??
                  () {
                    debugPrint('💳 Link Card button tapped!');
                  },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildCardActionButton(
              context,
              icon: Icons.history,
              label: 'History',
              onTap: onHistoryTap ??
                  () {
                    debugPrint('📋 History button tapped!');
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return BounceTapWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Ec_PRIMARY.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Ec_PRIMARY,
                    Ec_PRIMARY.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Ec_PRIMARY.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                color: Ec_PRIMARY,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
