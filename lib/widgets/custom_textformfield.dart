import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class CustomTextformfield extends StatefulWidget {
  const CustomTextformfield({
    super.key,
    required this.validator,
    required this.onSaved,
    required this.controller,
    this.isObscure = false,
    required this.fontSize,
    required this.fontColor,
    this.hintTextSize = 12,
    this.hintText = '',
    this.fillColor = Colors.black12,
    required this.height,
    required this.width,
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.focusNode,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  final String? Function(String?) validator;
  final void Function(String?) onSaved;
  final TextEditingController controller;
  final bool isObscure;
  final double fontSize;
  final Color fontColor;
  final double height, width;
  final double hintTextSize;
  final String hintText;
  final Color fillColor;
  final TextInputType keyboardType;
  final int maxLength;

  // ✅ New optional fields
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;

  @override
  _CustomTextformfieldState createState() => _CustomTextformfieldState();
}

class _CustomTextformfieldState extends State<CustomTextformfield> {
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      onSaved: widget.onSaved,
      controller: widget.controller,
      obscureText: widget.isObscure ? _isObscure : false,
      keyboardType: widget.keyboardType,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      style: TextStyle(
        fontSize: widget.fontSize,
        color: widget.fontColor,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(
            widget.width * 3, widget.height, widget.width, widget.height),
        focusColor: Colors.black12,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFE9E8E8),
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        errorStyle: const TextStyle(fontFamily: 'Frutiger'),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Ec_DARK_PRIMARY,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: Colors.black12,
          fontSize: widget.hintTextSize,
          fontFamily: 'Frutiger',
        ),
        hintText: widget.hintText,
        fillColor: widget.fillColor,

        // ✅ Use provided suffixIcon if available, otherwise show password toggle if obscured
        suffixIcon: widget.suffixIcon ??
            (widget.isObscure
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  )
                : null),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../constants.dart';

// class CustomTextformfield extends StatefulWidget {
//   const CustomTextformfield({
//     super.key,
//     required this.validator,
//     required this.onSaved,
//     required this.controller,
//     this.isObscure = false,
//     required this.fontSize,
//     required this.fontColor,
//     this.hintTextSize = 12,
//     this.hintText = '',
//     this.fillColor = Colors.black12,
//     required this.height,
//     required this.width,
//     this.keyboardType = TextInputType.text,
//     this.maxLength = 200,
//   });

//   final String? Function(String?) validator;
//   final void Function(String?) onSaved;
//   final TextEditingController controller;
//   final bool isObscure;
//   final double fontSize;
//   final Color fontColor;
//   final double height, width;
//   final double hintTextSize;
//   final String hintText;
//   final Color fillColor;
//   final TextInputType keyboardType;
//   final int maxLength;

//   @override
//   _CustomTextformfieldState createState() => _CustomTextformfieldState();
// }

// class _CustomTextformfieldState extends State<CustomTextformfield> {
//   bool _isObscure = true;

//   @override
//   void initState() {
//     super.initState();
//     _isObscure = widget.isObscure;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       validator: widget.validator,
//       onSaved: widget.onSaved,
//       controller: widget.controller,
//       obscureText: widget.isObscure ? _isObscure : false,
//       keyboardType: widget.keyboardType,
//       inputFormatters: [
//         LengthLimitingTextInputFormatter(widget.maxLength),
//       ],
//       style: TextStyle(
//         fontSize: widget.fontSize,
//         color: widget.fontColor,
//       ),
//       decoration: InputDecoration(
//         contentPadding: EdgeInsets.fromLTRB(
//             widget.width * 3, widget.height, widget.width, widget.height),
//         focusColor: Colors.black12,
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Color(0xFFE9E8E8),
//             width: 2,
//           ),
//           borderRadius: BorderRadius.all(Radius.circular(30.0)),
//         ),
//         errorBorder: const OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Colors.red,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.all(Radius.circular(30.0)),
//         ),
//         errorStyle: const TextStyle(fontFamily: 'Frutiger'),
//         focusedErrorBorder: const OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Colors.red,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.all(Radius.circular(30.0)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Ec_DARK_PRIMARY,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.all(Radius.circular(30.0)),
//         ),
//         filled: true,
//         hintStyle: TextStyle(
//           color: Colors.black12,
//           fontSize: widget.hintTextSize,
//           fontFamily: 'Frutiger',
//         ),
//         hintText: widget.hintText,
//         fillColor: widget.fillColor,
//         suffixIcon: widget.isObscure
//             ? Padding(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 8.0), // Adjust padding as needed
//                 child: IconButton(
//                   icon: Icon(
//                     _isObscure ? Icons.visibility_off : Icons.visibility,
//                     color: Colors.grey,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _isObscure = !_isObscure;
//                     });
//                   },
//                 ),
//               )
//             : null,
//       ),
//     );
//   }
// }
