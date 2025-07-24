import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:EcBarko/constants.dart';
import 'dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';

Map<String, dynamic>? userData;

String getBaseUrl() {
  return 'https://ecbarko.onrender.com';
  // return 'http://localhost:3000';
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? userData;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final birthdateController = TextEditingController();

  String selectedCardType = 'Type 1';
  final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];

  String? profileImage;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      print("userId is $userId");
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);

          if (userData != null) {
            nameController.text = userData!['name'] ?? '';
            emailController.text = userData!['email'] ?? '';
            phoneController.text = userData!['phone'] ?? '';
            birthdateController.text = userData!['birthdate'] ?? '';
          }
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    }
  }

  Future<void> _updateProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final birthdate = birthdateController.text.trim();
    final password = passwordController.text.trim();

    // ✅ Local null/empty field validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all required fields (name, email, phone).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication failed. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('${getBaseUrl()}/api/edituser/$userId');
    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'birthdate': birthdate,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['message'] ?? 'Unknown error';
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // ✅ FIXED: Use pop instead of pushReplacement
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          profileImage = image.path; // ✅ Update local file path
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
          iconTheme: const IconThemeData(color: Colors.white),
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
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 58,
                                  backgroundImage: profileImage != null
                                      ? FileImage(File(
                                          profileImage!)) // ← Shows picked image
                                      : (userData?['profileImageUrl'] != null
                                              ? NetworkImage(userData![
                                                  'profileImageUrl']) // ← From DB
                                              : const AssetImage(
                                                  'images/default.png'))
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
                  const SizedBox(height: 40),

                  // ✅ NEW: Display Name Text Below Image
                  Text(
                    userData?['name'] ?? 'Loading...',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // const SizedBox(height: 10),
                  Chip(
                    backgroundColor: Ec_PRIMARY,
                    label: Text(
                      'User ID: #${userData?['id'] ?? '...'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Ec_DARK_PRIMARY),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _updateProfile(); // ✅ Call the backend update function
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
