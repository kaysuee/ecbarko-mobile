import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:EcBarko/constants.dart';
import 'dashboard_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController(text: 'Vicky Jang');
  final emailController = TextEditingController(text: 'VickyJang6@gmail.com');
  final phoneController = TextEditingController(text: '092272817629');
  final passwordController = TextEditingController();
  final birthdateController = TextEditingController();

  String selectedCardType = 'Type 1';
  final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];

  String profileImage = 'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg';

  bool _obscurePassword = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text("Take a photo"),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Choose from gallery"),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          profileImage = image.path;
        });
      }
    }
  }

  Future<void> _selectBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthdateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  bool _hasUnsavedChanges() {
    return passwordController.text.isNotEmpty;
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges()) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Unsaved Changes"),
          content: const Text("You have unsaved changes. Leave anyway?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Leave")),
          ],
        ),
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(
                    context); // ✅ FIXED: Use pop instead of pushReplacement
              }
            },
          ),
          title: const Text('Edit Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Ec_PRIMARY,
          elevation: 0,
        ),
        backgroundColor: Ec_BG_SKY_BLUE,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              width: double.infinity,
                              height: 200,
                              child: Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 68,
                                  backgroundImage: profileImage.contains('http')
                                      ? NetworkImage(profileImage)
                                      : FileImage(File(profileImage))
                                          as ImageProvider,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.camera_alt,
                                        size: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // ✅ NEW: Display Name Text Below Image
                  // Text(
                  //   nameController.text,
                  //   style: const TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // const SizedBox(height: 10),

                  const Text(
                    'Vicky Jang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    backgroundColor: Ec_PRIMARY,
                    label: Text(
                      'User ID: #${DateTime.now().millisecondsSinceEpoch % 1000000}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  _buildTextField('Name', Icons.person, nameController),
                  const SizedBox(height: 10),
                  _buildTextField('Email', Icons.email, emailController,
                      validator: (val) =>
                          val!.contains('@') ? null : 'Enter valid email'),
                  const SizedBox(height: 10),
                  _buildTextField('Phone Number', Icons.phone, phoneController,
                      validator: (val) => val!.length >= 10
                          ? null
                          : 'Enter valid phone number'),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Birthdate',
                    Icons.calendar_today,
                    birthdateController,
                    readOnly: true,
                    onTap: _selectBirthdate,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Select your birthdate'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Password',
                    Icons.lock,
                    passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Ec_DARK_PRIMARY,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Changes"),
                            content: const Text(
                                "Are you sure you want to save the changes?"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel")),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Ec_DARK_PRIMARY),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Profile updated successfully!')),
                                  );
                                },
                                child: const Text("Save",
                                    style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon ??
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => controller.clear(),
            ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      ValueChanged<String> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Ec_DARK_PRIMARY,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          iconSize: 0,
          dropdownColor: Ec_DARK_PRIMARY,
          style: const TextStyle(color: Colors.white),
          onChanged: (newValue) => onChanged(newValue!),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text("$label: $item",
                        style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:EcBarko/constants.dart';
// import 'dashboard_screen.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController(text: 'Vicky Jang');
//   final emailController = TextEditingController(text: 'VickyJang6@gmail.com');
//   final phoneController = TextEditingController(text: '092272817629');
//   final passwordController = TextEditingController();
//   final birthdateController = TextEditingController();

//   String selectedCardType = 'Type 1';
//   String selectedGender = 'Female';
//   final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];
//   final List<String> genders = ['Male', 'Female', 'Other'];

//   String profileImage = 'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg';

//   bool _obscurePassword = true;

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final source = await showModalBottomSheet<ImageSource?>(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.photo_camera),
//             title: const Text("Take a photo"),
//             onTap: () => Navigator.pop(context, ImageSource.camera),
//           ),
//           ListTile(
//             leading: const Icon(Icons.photo_library),
//             title: const Text("Choose from gallery"),
//             onTap: () => Navigator.pop(context, ImageSource.gallery),
//           ),
//         ],
//       ),
//     );

//     if (source != null) {
//       final image = await picker.pickImage(source: source);
//       if (image != null) {
//         setState(() {
//           profileImage = image.path;
//         });
//       }
//     }
//   }

//   Future<void> _selectBirthdate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       birthdateController.text =
//           "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//     }
//   }

//   bool _hasUnsavedChanges() {
//     return passwordController.text.isNotEmpty;
//   }

//   Future<bool> _onWillPop() async {
//     if (_hasUnsavedChanges()) {
//       final shouldLeave = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Unsaved Changes"),
//           content: const Text("You have unsaved changes. Leave anyway?"),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text("Cancel")),
//             ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text("Leave")),
//           ],
//         ),
//       );
//       return shouldLeave ?? false;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () async {
//               if (await _onWillPop()) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                 );
//               }
//             },
//           ),
//           title: const Text('Edit Profile',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontFamily: 'Arial',
//                   fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           backgroundColor: Ec_PRIMARY,
//           elevation: 0,
//         ),
//         backgroundColor: Ec_BG_SKY_BLUE,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         height: 200,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20)),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.network(
//                             'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: 200,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 Container(
//                               color: Colors.grey[300],
//                               width: double.infinity,
//                               height: 200,
//                               child: Icon(Icons.broken_image,
//                                   size: 50, color: Colors.grey[600]),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: -40,
//                         left: 0,
//                         right: 0,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 70,
//                                 backgroundColor: Colors.white,
//                                 child: CircleAvatar(
//                                   radius: 68,
//                                   backgroundImage: profileImage.contains('http')
//                                       ? NetworkImage(profileImage)
//                                       : FileImage(File(profileImage))
//                                           as ImageProvider,
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: _pickImage,
//                                   child: CircleAvatar(
//                                     radius: 15,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Icon(Icons.camera_alt,
//                                         size: 16, color: Colors.black),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 60),
//                   _buildDropdownField('Card Type', cardTypes, selectedCardType,
//                       (val) => setState(() => selectedCardType = val)),
//                   const SizedBox(height: 10),
//                   _buildDropdownField('Gender', genders, selectedGender,
//                       (val) => setState(() => selectedGender = val)),
//                   const SizedBox(height: 10),
//                   _buildTextField('Name', Icons.person, nameController),
//                   const SizedBox(height: 10),
//                   _buildTextField('Email', Icons.email, emailController,
//                       validator: (val) =>
//                           val!.contains('@') ? null : 'Enter valid email'),
//                   const SizedBox(height: 10),
//                   _buildTextField('Phone Number', Icons.phone, phoneController,
//                       validator: (val) => val!.length >= 10
//                           ? null
//                           : 'Enter valid phone number'),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                     'Birthdate',
//                     Icons.calendar_today,
//                     birthdateController,
//                     readOnly: true,
//                     onTap: _selectBirthdate,
//                     validator: (val) => val == null || val.isEmpty
//                         ? 'Select your birthdate'
//                         : null,
//                   ),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                     'Password',
//                     Icons.lock,
//                     passwordController,
//                     obscureText: _obscurePassword,
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Ec_DARK_PRIMARY,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25)),
//                     ),
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: const Text("Confirm Changes"),
//                             content: const Text(
//                                 "Are you sure you want to save the changes?"),
//                             actions: [
//                               TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text("Cancel")),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Ec_DARK_PRIMARY),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text(
//                                             'Profile updated successfully!')),
//                                   );
//                                 },
//                                 child: const Text("Save",
//                                     style: TextStyle(color: Colors.white)),
//                               )
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text('Save',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     String label,
//     IconData icon,
//     TextEditingController controller, {
//     bool obscureText = false,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     String? Function(String?)? validator,
//     Widget? suffixIcon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       readOnly: readOnly,
//       onTap: onTap,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         prefixIcon: Icon(icon),
//         suffixIcon: suffixIcon ??
//             IconButton(
//               icon: const Icon(Icons.clear),
//               onPressed: () => controller.clear(),
//             ),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget _buildDropdownField(String label, List<String> items, String value,
//       ValueChanged<String> onChanged) {
//     return Container(
//       height: 40,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Ec_DARK_PRIMARY,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           iconSize: 0,
//           dropdownColor: Ec_DARK_PRIMARY,
//           style: const TextStyle(color: Colors.white),
//           onChanged: (newValue) => onChanged(newValue!),
//           items: items
//               .map((item) => DropdownMenuItem<String>(
//                     value: item,
//                     child: Text("$label: $item",
//                         style: const TextStyle(color: Colors.white)),
//                   ))
//               .toList(),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:EcBarko/constants.dart';
// import 'dashboard_screen.dart'; // Make sure this import points to your actual dashboard screen path

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController(text: 'Vicky Jang');
//   final emailController = TextEditingController(text: 'VickyJang6@gmail.com');
//   final phoneController = TextEditingController(text: '092272817629');
//   final passwordController = TextEditingController();
//   final birthdateController = TextEditingController();

//   String selectedCardType = 'Type 1';
//   String selectedGender = 'Female';
//   final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];
//   final List<String> genders = ['Male', 'Female', 'Other'];

//   String profileImage =
//       'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg'; // Default image

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final source = await showModalBottomSheet<ImageSource?>(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.photo_camera),
//             title: const Text("Take a photo"),
//             onTap: () => Navigator.pop(context, ImageSource.camera),
//           ),
//           ListTile(
//             leading: const Icon(Icons.photo_library),
//             title: const Text("Choose from gallery"),
//             onTap: () => Navigator.pop(context, ImageSource.gallery),
//           ),
//         ],
//       ),
//     );

//     if (source != null) {
//       final image = await picker.pickImage(source: source);
//       if (image != null) {
//         setState(() {
//           profileImage = image.path;
//         });
//       }
//     }
//   }

//   Future<void> _selectBirthdate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       birthdateController.text =
//           "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
//     }
//   }

//   bool _hasUnsavedChanges() {
//     return passwordController.text.isNotEmpty;
//   }

//   Future<bool> _onWillPop() async {
//     if (_hasUnsavedChanges()) {
//       final shouldLeave = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Unsaved Changes"),
//           content: const Text("You have unsaved changes. Leave anyway?"),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text("Cancel")),
//             ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text("Leave")),
//           ],
//         ),
//       );
//       return shouldLeave ?? false;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () async {
//               if (await _onWillPop()) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                 );
//               }
//             },
//           ),
//           title: const Text('Edit Profile',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontFamily: 'Arial',
//                   fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           backgroundColor: Ec_PRIMARY,
//           elevation: 0,
//         ),
//         backgroundColor: Ec_BG_SKY_BLUE,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         height: 200,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20)),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.network(
//                             'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: 200,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 Container(
//                               color: Colors.grey[300],
//                               width: double.infinity,
//                               height: 200,
//                               child: Icon(Icons.broken_image,
//                                   size: 50, color: Colors.grey[600]),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: -40,
//                         left: 0,
//                         right: 0,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 70,
//                                 backgroundColor: Colors.white,
//                                 child: CircleAvatar(
//                                   radius: 68,
//                                   backgroundImage: profileImage.contains('http')
//                                       ? NetworkImage(profileImage)
//                                       : FileImage(File(profileImage))
//                                           as ImageProvider,
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: _pickImage,
//                                   child: CircleAvatar(
//                                     radius: 15,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Icon(Icons.camera_alt,
//                                         size: 16, color: Colors.black),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 60),
//                   _buildDropdownField('Card Type', cardTypes, selectedCardType,
//                       (val) => setState(() => selectedCardType = val)),
//                   const SizedBox(height: 10),
//                   _buildDropdownField('Gender', genders, selectedGender,
//                       (val) => setState(() => selectedGender = val)),
//                   const SizedBox(height: 10),
//                   _buildTextField('Name', Icons.person, nameController),
//                   const SizedBox(height: 10),
//                   _buildTextField('Email', Icons.email, emailController,
//                       validator: (val) =>
//                           val!.contains('@') ? null : 'Enter valid email'),
//                   const SizedBox(height: 10),
//                   _buildTextField('Phone Number', Icons.phone, phoneController,
//                       validator: (val) => val!.length >= 10
//                           ? null
//                           : 'Enter valid phone number'),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                       'Birthdate', Icons.calendar_today, birthdateController,
//                       readOnly: true, onTap: _selectBirthdate),
//                   const SizedBox(height: 10),
//                   _buildTextField('Password', Icons.lock, passwordController,
//                       obscureText: true),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Ec_DARK_PRIMARY,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25)),
//                     ),
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: const Text("Confirm Changes"),
//                             content: const Text(
//                                 "Are you sure you want to save the changes?"),
//                             actions: [
//                               TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text("Cancel")),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Ec_DARK_PRIMARY),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text(
//                                             'Profile updated successfully!')),
//                                   );
//                                 },
//                                 child: const Text("Save",
//                                     style: TextStyle(color: Colors.white)),
//                               )
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text('Save',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     String label,
//     IconData icon,
//     TextEditingController controller, {
//     bool obscureText = false,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       readOnly: readOnly,
//       onTap: onTap,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () => controller.clear(),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget _buildDropdownField(String label, List<String> items, String value,
//       ValueChanged<String> onChanged) {
//     return Container(
//       height: 40,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Ec_DARK_PRIMARY,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           iconSize: 0,
//           dropdownColor: Ec_DARK_PRIMARY,
//           style: const TextStyle(color: Colors.white),
//           onChanged: (newValue) => onChanged(newValue!),
//           items: items
//               .map((item) => DropdownMenuItem<String>(
//                     value: item,
//                     child: Text("\$label: \$item",
//                         style: const TextStyle(color: Colors.white)),
//                   ))
//               .toList(),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';

// import 'package:EcBarko/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // For image upload (simulated)

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController nameController =
//       TextEditingController(text: 'Vicky Jang');
//   final TextEditingController emailController =
//       TextEditingController(text: 'VickyJang6@gmail.com');
//   final TextEditingController phoneController =
//       TextEditingController(text: '092272817629');
//   final TextEditingController passwordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();

//   String selectedCardType = 'Type 1';
//   final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];

//   String profileImage =
//       'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg'; // Default image

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         profileImage = image.path; // For now, assume local path (simulation)
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Edit Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontFamily: 'Arial',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Ec_PRIMARY,
//         elevation: 0,
//       ),
//       backgroundColor: Ec_BG_SKY_BLUE,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         height: 200,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image.network(
//                             'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: 200,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 color: Colors.grey[300],
//                                 width: double.infinity,
//                                 height: 200,
//                                 child: Icon(Icons.broken_image,
//                                     size: 50, color: Colors.grey[600]),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: -40,
//                         left: 0,
//                         right: 0,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 70,
//                                 backgroundColor: Colors.white,
//                                 child: CircleAvatar(
//                                   radius: 68,
//                                   backgroundImage: profileImage.contains('http')
//                                       ? NetworkImage(profileImage)
//                                           as ImageProvider
//                                       : FileImage(
//                                           File(profileImage),
//                                         ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: _pickImage,
//                                   child: CircleAvatar(
//                                     radius: 15,
//                                     backgroundColor: Colors.grey[300],
//                                     child: const Icon(
//                                       Icons.camera_alt,
//                                       size: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 60),

//                   /// Card Type Dropdown
//                   DropdownButtonHideUnderline(
//                     child: Container(
//                       height: 40,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Ec_DARK_PRIMARY,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: DropdownButton<String>(
//                         value: selectedCardType,
//                         iconSize: 0,
//                         dropdownColor: Ec_DARK_PRIMARY,
//                         style: const TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.w500),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedCardType = newValue!;
//                           });
//                         },
//                         items: cardTypes.map((String type) {
//                           return DropdownMenuItem<String>(
//                             value: type,
//                             child: Text("Card Type: $type",
//                                 style: const TextStyle(color: Colors.white)),
//                           );
//                         }).toList(),
//                         selectedItemBuilder: (context) {
//                           return cardTypes.map((type) {
//                             return Align(
//                               alignment: Alignment.center,
//                               child: Text("Card Type: $type",
//                                   style: const TextStyle(color: Colors.white)),
//                             );
//                           }).toList();
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   /// Profile Info Card
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           buildInputField(
//                               hint: 'Name',
//                               icon: Icons.person,
//                               controller: nameController),
//                           const SizedBox(height: 12),
//                           buildInputField(
//                               hint: 'Email',
//                               icon: Icons.email,
//                               controller: emailController,
//                               validator: (value) {
//                                 if (value == null ||
//                                     !value.contains('@') ||
//                                     !value.contains('.')) {
//                                   return 'Enter a valid email';
//                                 }
//                                 return null;
//                               }),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   /// Account Info Card
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           buildInputField(
//                               hint: 'Phone Number',
//                               icon: Icons.phone,
//                               controller: phoneController,
//                               validator: (value) {
//                                 if (value == null || value.length < 10) {
//                                   return 'Enter a valid phone number';
//                                 }
//                                 return null;
//                               }),
//                           const SizedBox(height: 12),
//                           buildInputField(
//                               hint: 'Password',
//                               icon: Icons.lock,
//                               controller: passwordController,
//                               obscureText: true),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Ec_DARK_PRIMARY,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25)),
//                     ),
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: const Text("Confirm Changes"),
//                             content: const Text(
//                                 "Are you sure you want to save the changes?"),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: const Text("Cancel"),
//                               ),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Ec_DARK_PRIMARY),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   // Implement actual save logic here
//                                   print(
//                                       "Saved profile with card type: $selectedCardType");
//                                 },
//                                 child: const Text("Save",
//                                     style: TextStyle(color: Colors.white)),
//                               )
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text('Save',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildInputField({
//     required String hint,
//     required IconData icon,
//     required TextEditingController controller,
//     bool obscureText = false,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: hint,
//         prefixIcon: Icon(icon),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.grey)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.grey)),
//       ),
//     );
//   }
// }

// import 'package:EcBarko/constants.dart';
// import 'package:flutter/material.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController nameController =
//       TextEditingController(text: 'Vicky Jang');
//   final TextEditingController emailController =
//       TextEditingController(text: 'VickyJang6@gmail.com');
//   final TextEditingController phoneController =
//       TextEditingController(text: '092272817629');
//   final TextEditingController passwordController = TextEditingController();

//   String selectedCardType = 'Type 1';
//   final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Edit Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontFamily: 'Arial',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Ec_PRIMARY,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       backgroundColor: Ec_BG_SKY_BLUE,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.network(
//                           'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg?quality=75&strip=all',
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: 200,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey[300],
//                               width: double.infinity,
//                               height: 200,
//                               child: Icon(Icons.broken_image,
//                                   size: 50, color: Colors.grey[600]),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: -40,
//                       left: 0,
//                       right: 0,
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             const CircleAvatar(
//                               radius: 70, // Outer circle radius
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius:
//                                     68, // Inner circle radius (slightly smaller for border effect)
//                                 backgroundImage: NetworkImage(
//                                   'https://pbs.twimg.com/media/Fl8z7wlakAEFsET.jpg',
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: CircleAvatar(
//                                 radius: 15,
//                                 backgroundColor: Colors.grey[300],
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   size: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//                 const Text(
//                   'Vicky Jang',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 DropdownButtonHideUnderline(
//                   child: Container(
//                     height: 36,
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Ec_DARK_PRIMARY,
//                       borderRadius: BorderRadius.circular(
//                           10), // Rounded but less pill-like
//                     ),
//                     child: DropdownButton<String>(
//                       value: selectedCardType,
//                       iconSize: 0,
//                       dropdownColor: Ec_DARK_PRIMARY,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       isExpanded: false,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedCardType = newValue!;
//                         });
//                       },
//                       items: cardTypes.map((String type) {
//                         return DropdownMenuItem<String>(
//                           value: type,
//                           child: Text("Card Type: $type",
//                               style: const TextStyle(color: Colors.white)),
//                         );
//                       }).toList(),
//                       selectedItemBuilder: (BuildContext context) {
//                         return cardTypes.map((String type) {
//                           return Align(
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Card Type: $type",
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text('Edit Profile:',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(height: 6),
//                 buildTextField('Name:', nameController),
//                 const SizedBox(height: 6),
//                 buildTextField('Email:', emailController),
//                 const SizedBox(height: 6),
//                 buildTextField('Phone Number:', phoneController),
//                 const SizedBox(height: 6),
//                 buildTextField('Password:', passwordController,
//                     obscureText: true),
//                 const SizedBox(height: 15),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Ec_DARK_PRIMARY,
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25)),
//                   ),
//                   onPressed: () {
//                     // Save logic
//                     print('Saved profile with card type: $selectedCardType');
//                   },
//                   child:
//                       const Text('Save', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String label, TextEditingController controller,
//       {bool obscureText = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//         const SizedBox(height: 5),
//         TextField(
//           controller: controller,
//           obscureText: obscureText,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//           ),
//         ),
//       ],
//     );
//   }
// }
