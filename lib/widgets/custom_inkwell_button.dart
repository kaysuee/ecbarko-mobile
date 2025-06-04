import '../widgets/customfont.dart';
import '../constants.dart';
import 'package:flutter/material.dart';

class CustomInkwellButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double height;
  final double width;
  final double fontSize;
  final String buttonName;
  final IconData? icon;
  final FontWeight fontWeight;
  final Color bgColor;
  final Color fontColor;
  final bool isLoading;

  const CustomInkwellButton({
    super.key,
    required this.onTap,
    required this.height,
    required this.width,
    this.buttonName = '',
    this.bgColor = Ec_DARK_PRIMARY,
    this.fontColor = Colors.white,
    this.fontSize = 16,
    this.icon,
    this.fontWeight = FontWeight.w600,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.white24,
        child: Container(
          height: height,
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: fontSize + 2, color: fontColor),
                        const SizedBox(width: 8),
                      ],
                      CustomFont(
                        text: buttonName,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: fontColor,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// import '../widgets/customfont.dart';
// import '../constants.dart';
// import 'package:flutter/material.dart';

// class CustomInkwellButton extends StatelessWidget {
//   final VoidCallback? onTap;
//   final double height;
//   final double width;
//   final double fontSize;
//   final String buttonName;
//   final Icon? icon;
//   final FontWeight fontWeight;
//   final Color bgColor;
//   final Color fontColor;

//   const CustomInkwellButton({
//     super.key,
//     required this.onTap,
//     required this.height,
//     required this.width,
//     this.buttonName = '',
//     this.bgColor = Ec_DARK_PRIMARY,
//     this.fontColor = Colors.white,
//     this.fontSize = 14,
//     this.icon,
//     this.fontWeight = FontWeight.normal,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: bgColor,
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         splashColor: const Color.fromARGB(255, 2, 32, 75),
//         child: Container(
//           height: height,
//           width: width,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Center(
//             child: buttonName.isEmpty
//                 ? (icon ?? const SizedBox()) // only icon
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (icon != null) ...[
//                         icon!,
//                         const SizedBox(width: 8),
//                       ],
//                       CustomFont(
//                         text: buttonName,
//                         fontSize: fontSize,
//                         fontWeight: fontWeight,
//                         color: fontColor,
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import '../widgets/customfont.dart';
// import '../constants.dart';
// import 'package:flutter/material.dart';

// // ignore: must_be_immutable
// class CustomInkwellButton extends StatelessWidget {
//   final onTap;
//   final double height;
//   final double width;
//   final double fontSize;
//   final String buttonName;
//   final Icon icon;
//   FontWeight fontWeight;
//   Color bgColor;
//   Color fontColor;

//   CustomInkwellButton(
//       {super.key,
//       required this.onTap,
//       required this.height,
//       required this.width,
//       this.buttonName = '',
//       this.bgColor = Ec_DARK_PRIMARY,
//       this.fontColor = Colors.white,
//       this.fontSize = 1,
//       this.icon = const Icon(null),
//       this.fontWeight = FontWeight.normal, 
//       });

// // Suggested code may be subjecth to a license. Learn more: ~LicenseLog:1358442233.
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: bgColor,
//       elevation: 5,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: const BorderRadius.all(Radius.circular(10)),
//         splashColor: const Color.fromARGB(255, 2, 32, 75),
//         child: Container(
//           height: height,
//           width: width,
//           decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(10))),
//           child: Center(
//             child: buttonName == ''
//                 ? icon
//                 : CustomFont(
//                     text: buttonName,
//                     fontSize: fontSize,
//                     fontWeight: fontWeight,
//                     color: fontColor,
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
