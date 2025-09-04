import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:EcBarko/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
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

  String? profileImage;
  bool isEditMode = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userID');

      if (token != null && userId != null) {
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
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to load user data: ${response.statusCode}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final birthdate = birthdateController.text.trim();

    // Check if at least one field has changed
    bool hasChanges = false;
    Map<String, dynamic> updateData = {};

    if (name != userData?['name']) {
      updateData['name'] = name;
      hasChanges = true;
    }
    if (email != userData?['email']) {
      updateData['email'] = email;
      hasChanges = true;
    }
    if (phone != userData?['phone']) {
      updateData['phone'] = phone;
      hasChanges = true;
    }
    if (birthdate != userData?['birthdate']) {
      updateData['birthdate'] = birthdate;
      hasChanges = true;
    }

    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected.'),
          backgroundColor: Colors.orange,
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
    final body = jsonEncode(updateData);

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Create a message showing what was updated
        List<String> updatedFields = [];
        if (updateData.containsKey('name')) updatedFields.add('Name');
        if (updateData.containsKey('email')) updatedFields.add('Email');
        if (updateData.containsKey('phone')) updatedFields.add('Phone');
        if (updateData.containsKey('birthdate')) updatedFields.add('Birthdate');

        String message = 'Updated: ${updatedFields.join(', ')}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';
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
    try {
      final picker = ImagePicker();

      // Show source selection
      final source = await showModalBottomSheet<ImageSource?>(
        context: context,
        builder: (_) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Ec_PRIMARY),
                title: const Text("Take a photo"),
                subtitle: const Text("Use camera to take a new photo"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Ec_PRIMARY),
                title: const Text("Choose from gallery"),
                subtitle: const Text("Select from your photo library"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
            ),
          ),
        );

        try {
          final image = await picker.pickImage(
            source: source,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 85,
          );

          // Hide loading indicator
          Navigator.pop(context);

          if (image != null) {
            setState(() {
              profileImage = image.path;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image selected successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Hide loading indicator
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error accessing ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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
        backgroundColor: Ec_BG_SKY_BLUE,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Ec_PRIMARY,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(
                isEditMode ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                if (isEditMode) {
                  // Cancel editing - reset form fields to original values
                  setState(() {
                    isEditMode = false;
                    if (userData != null) {
                      nameController.text = userData!['name'] ?? '';
                      emailController.text = userData!['email'] ?? '';
                      phoneController.text = userData!['phone'] ?? '';
                      birthdateController.text = userData!['birthdate'] ?? '';
                    }
                  });
                } else {
                  // Start editing
                  setState(() {
                    isEditMode = true;
                  });
                }
              },
              tooltip: isEditMode ? 'Cancel Edit' : 'Edit Profile',
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadUserData,
                child: _buildBody(),
              ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildFormSection(),
          if (isEditMode) ...[
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cover + Avatar stacked
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Cover Photo
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: Image.network(
                  userData?['coverImageUrl'] ??
                      'https://grist.org/wp-content/uploads/2013/10/shutterstock_118021813.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.landscape,
                          size: 64, color: Colors.grey[600]),
                    );
                  },
                ),
              ),

              // Profile Picture (overlapping bottom)
              Positioned(
                bottom: -60,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profileImage != null
                            ? FileImage(File(profileImage!))
                            : (userData?['profileImageUrl'] != null
                                    ? NetworkImage(userData!['profileImageUrl'])
                                    : const AssetImage(
                                        'assets/images/default.png'))
                                as ImageProvider,
                      ),
                      // Camera icon overlay for editing
                      if (isEditMode)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Ec_PRIMARY,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
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

          const SizedBox(height: 70),

          // User Info
          Column(
            children: [
              Text(
                userData?['name'] ?? 'User Name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'User ID: #${userData?['id'] ?? '000000'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (userData?['email'] != null) ...[
                const SizedBox(height: 2),
                Text(
                  userData?['email'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit_note : Icons.person,
                    color: Ec_PRIMARY,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode
                        ? 'Edit Personal Information'
                        : 'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Ec_PRIMARY,
                    ),
                  ),
                  if (isEditMode) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EDITING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Name Field
              _buildTextField(
                'Name',
                Icons.person,
                nameController,
                readOnly: !isEditMode,
                validator: isEditMode
                    ? (val) => val!.isEmpty ? 'Name is required' : null
                    : null,
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildTextField(
                'Email',
                Icons.email,
                emailController,
                readOnly: !isEditMode,
                keyboardType: TextInputType.emailAddress,
                validator: isEditMode
                    ? (val) => val!.contains('@') ? null : 'Enter valid email'
                    : null,
              ),
              const SizedBox(height: 16),

              // Phone Field
              _buildTextField(
                'Phone Number',
                Icons.phone,
                phoneController,
                readOnly: !isEditMode,
                keyboardType: TextInputType.phone,
                validator: isEditMode
                    ? (val) =>
                        val!.length >= 10 ? null : 'Enter valid phone number'
                    : null,
              ),
              const SizedBox(height: 16),

              // Birthdate Field
              _buildTextField(
                'Birthdate',
                Icons.calendar_today,
                birthdateController,
                readOnly: true,
                onTap: isEditMode ? _selectBirthdate : null,
                validator: isEditMode
                    ? (val) => val == null || val.isEmpty
                        ? 'Select your birthdate'
                        : null
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
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
          color: readOnly ? Colors.grey[500] : Ec_PRIMARY,
          size: 22,
        ),
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
            color: Ec_PRIMARY,
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

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Ec_PRIMARY.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Ec_PRIMARY,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Confirm Changes"),
                content:
                    const Text("Are you sure you want to save the changes?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Ec_PRIMARY,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _updateProfile();
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
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
    );
  }
}
