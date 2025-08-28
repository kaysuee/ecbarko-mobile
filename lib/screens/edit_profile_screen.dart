import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:EcBarko/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../services/notification_service.dart';

Map<String, dynamic>? userData;

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
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
  final birthdateController = TextEditingController();

  String selectedCardType = 'Type 1';
  final List<String> cardTypes = ['Type 1', 'Type 2', 'Type 3', 'Type 4'];

  String? profileImage;
  bool isEditMode = false; // New: Track edit mode

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
        // Send notifications for each updated field
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userID');

        if (userId != null) {
          // Check which fields were updated and send notifications
          if (userData != null) {
            if (name != userData!['name']) {
              await NotificationService.notifyProfileUpdate(
                userId: userId,
                updatedField: 'name',
                oldValue: userData!['name'],
                newValue: name,
              );
            }

            if (email != userData!['email']) {
              await NotificationService.notifyProfileUpdate(
                userId: userId,
                updatedField: 'email',
                oldValue: userData!['email'],
                newValue: email,
              );
            }

            if (phone != userData!['phone']) {
              await NotificationService.notifyProfileUpdate(
                userId: userId,
                updatedField: 'phone number',
                oldValue: userData!['phone'],
                newValue: phone,
              );
            }

            if (birthdate != userData!['birthdate']) {
              await NotificationService.notifyProfileUpdate(
                userId: userId,
                updatedField: 'birthdate',
                oldValue: userData!['birthdate'],
                newValue: birthdate,
              );
            }
          }
        }

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
    print("Image picker tapped!"); // Debug print
    try {
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
        print("Source selected: $source"); // Debug print
        final image = await picker.pickImage(source: source);
        if (image != null) {
          print("Image selected: ${image.path}"); // Debug print
          setState(() {
            profileImage = image.path; // ✅ Update local file path
          });
        } else {
          print("No image selected"); // Debug print
        }
      } else {
        print("No source selected"); // Debug print
      }
    } catch (e) {
      print("Error picking image: $e"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    if (userData == null) return false;

    return nameController.text != userData!['name'] ||
        emailController.text != userData!['email'] ||
        phoneController.text != userData!['phone'] ||
        birthdateController.text != userData!['birthdate'];
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (await _onWillPop()) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
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
          title: const Text('Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Ec_DARK_PRIMARY,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isEditMode ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode;
                  if (!isEditMode) {
                    // Reset to original values when exiting edit mode
                    _loadUserData();
                  }
                });
              },
            ),
          ],
        ),
        backgroundColor: Ec_BG_SKY_BLUE,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Header Section
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isEditMode ? _pickImage : null,
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isEditMode
                                            ? Colors.grey[300]
                                            : Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: isEditMode
                                            ? Colors.black
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // NAME

                  // User Info Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          userData?['name'] ?? 'Loading...',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Chip(
                          backgroundColor: Ec_PRIMARY,
                          label: Text(
                            'User ID: #${userData?['id'] ?? '...'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Form Fields Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: Ec_DARK_PRIMARY,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Ec_DARK_PRIMARY,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Name Field
                        _buildTextField('Name', Icons.person, nameController,
                            readOnly: !isEditMode),
                        const SizedBox(height: 20),

                        // Email Field
                        _buildTextField('Email', Icons.email, emailController,
                            readOnly: !isEditMode,
                            validator: (val) => val!.contains('@')
                                ? null
                                : 'Enter valid email'),
                        const SizedBox(height: 20),

                        // Phone Field
                        _buildTextField(
                            'Phone Number', Icons.phone, phoneController,
                            readOnly: !isEditMode,
                            validator: (val) => val!.length >= 10
                                ? null
                                : 'Enter valid phone number'),
                        const SizedBox(height: 20),

                        // Birthdate Field
                        _buildTextField(
                          'Birthdate',
                          Icons.calendar_today,
                          birthdateController,
                          readOnly: true,
                          onTap: isEditMode ? _selectBirthdate : null,
                          validator: (val) => val == null || val.isEmpty
                              ? 'Select your birthdate'
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Save Button
                  if (isEditMode)
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Ec_DARK_PRIMARY.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_DARK_PRIMARY,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
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
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Bottom padding to ensure content doesn't get cut off
                  // const SizedBox(height: 5), //BOTTOM PADDING
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
      style: TextStyle(
        fontSize: 16,
        color: readOnly ? Colors.grey[600] : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(
          icon,
          color: readOnly ? Colors.grey[500] : Ec_DARK_PRIMARY,
          size: 22,
        ),
        suffixIcon: suffixIcon ??
            (isEditMode
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    onPressed: () => controller.clear(),
                  )
                : null),
        filled: true,
        fillColor: readOnly ? Colors.grey[50] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Ec_DARK_PRIMARY,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        isDense: false,
      ),
    );
  }
}
