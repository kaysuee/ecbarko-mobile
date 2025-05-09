import 'package:EcBarko/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/customfont.dart';

void showCustomDialog(
  BuildContext context, {
  required String title,
  required String content,
  String buttonText = 'Okay',
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Ec_LIGHT_PRIMARY,
        title: CustomFont(
          text: title,
          fontSize: 22.sp,
          color: Ec_DARK_PRIMARY,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CustomFont(
            text: content,
            fontSize: 16.sp,
            color: Ec_TEXT_COLOR_GREY,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Ec_DARK_PRIMARY,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onClose?.call();
            },
            child: CustomFont(
              text: buttonText,
              fontSize: 16.sp,
              color: Ec_DARK_PRIMARY,
            ),
          ),
        ],
      );
    },
  );
}

void showOptionDialog(
  BuildContext context, {
  required String title,
  required String content,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Ec_LIGHT_PRIMARY,
        title: CustomFont(
          text: title,
          fontSize: 22.sp,
          color: Ec_DARK_PRIMARY,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CustomFont(
            text: content,
            fontSize: 16.sp,
            color: Ec_TEXT_COLOR_GREY,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
            child: CustomFont(
              text: cancelText,
              fontSize: 16.sp,
              color: Ec_LIGHT_BLUE_1,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Ec_DARK_PRIMARY,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: CustomFont(
              text: confirmText,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ],
      );
    },
  );
}

// import 'package:EcBarko/constants.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter/material.dart';
// import '../widgets/customfont.dart';

// customDialog(BuildContext context,
//     {required String title, required String content}) {
//   AlertDialog alertDialog = AlertDialog(
//     backgroundColor: Ec_LIGHT_PRIMARY,
//     title: CustomFont(
//       text: title,
//       fontSize: 22.sp,
//       color: Ec_DARK_PRIMARY,
//     ),
//     content: CustomFont(
//       text: content,
//       fontSize: 16.sp,
//       color: Ec_TEXT_COLOR_GREY,
//     ),
//     actions: <Widget>[
//       TextButton(
//         style: TextButton.styleFrom(
//           foregroundColor: Ec_DARK_PRIMARY,
//         ),
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//         child: CustomFont(
//           text: 'Okay',
//           fontSize: 16.sp,
//           color: Ec_DARK_PRIMARY,
//         ),
//       ),
//     ],
//   );

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alertDialog;
//     },
//   );
// }

// CustomOptionDialog(BuildContext context,
//     {required String title, required String content, required Function onYes}) {
//   AlertDialog alertDialog = AlertDialog(
//     backgroundColor: Ec_LIGHT_PRIMARY,
//     title: CustomFont(
//       text: title,
//       fontSize: 22.sp,
//       color: Ec_DARK_PRIMARY,
//     ),
//     content: CustomFont(
//       text: content,
//       fontSize: 16.sp,
//       color: Ec_TEXT_COLOR_GREY,
//     ),
//     actions: <Widget>[
//       TextButton(
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//         child: CustomFont(
//           text: 'No',
//           fontSize: 16.sp,
//           color: Ec_LIGHT_BLUE_1,
//         ),
//       ),
//       ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Ec_DARK_PRIMARY,
//           foregroundColor: Colors.white,
//         ),
//         onPressed: () {
//           Navigator.of(context).pop();
//           onYes();
//         },
//         child: CustomFont(
//           text: 'Yes',
//           fontSize: 16.sp,
//           color: Colors.white,
//         ),
//       ),
//     ],
//   );

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alertDialog;
//     },
//   );
// }

// import 'package:EcBarko/constants.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter/material.dart';
// import '../widgets/customfont.dart';

// customDialog(BuildContext context, {required title, required content}) {
//   AlertDialog alertDialog = AlertDialog(
//     title: Text(title),
//     content: Text(content),
//     actions: <Widget>[
//       ElevatedButton(
//         style: ElevatedButton.styleFrom(
//             backgroundColor: Ec_DARK_PRIMARY, foregroundColor: Colors.white),
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//         child: const Text('0kay'),
//       ),
//     ],
//   );

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alertDialog;
//     },
//   );
// }


// CustomOptionDialog(BuildContext context,
//     {required title, required content, required Function onYes}) {
//   AlertDialog alertDialog = AlertDialog(
//     title: CustomFont(
//       text: title,
//       fontSize: 30.sp, color: Ec_DARK_PRIMARY,
//     ),
//     content: CustomFont(text: content, fontSize: 0, color: Colors.white,),
//     actions: <Widget>[
//       OutlinedButton(
//         onPressed: () {
//           Navigator.of(context).pop();
//           onYes();
//         },
//         child: CustomFont(text: 'No', fontSize: 0, color: Colors.white,),
//       ),
//       ElevatedButton(
//         child: CustomFont(
//           text: 'Yes',
//           color: Colors.white, 
//           fontSize: 0,
//         ),
//         style: ElevatedButton.styleFrom(
//             backgroundColor: Ec_DARK_PRIMARY, foregroundColor: Colors.white),
//         onPressed: () {
//           Navigator.of(context).pop();
//           onYes();
//         },
//       ),
//     ],
//   );

//   showDialog(
//     context: context, 
//     builder: (BuildContext context){
//       return alertDialog;
//     },
//   );
// }
