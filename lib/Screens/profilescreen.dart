import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Text controllers for fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController profilePictureController =
      TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  bool subscriptionStatus = false;
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Options for multi-select dropdowns
  final List<String> _roleOptions = ['Teacher', 'Admin', 'Coordinator'];
  final List<String> _subjectOptions = [
    'Math',
    'Physics',
    'Chemistry',
    'English',
    'Computers'
  ];
  final List<int> _classOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  // Selected values for multi-select dropdowns
  List<String> selectedRoles = [];
  List<String> selectedSubjects = [];
  List<int> selectedClasses = [];

  @override
  void initState() {
    super.initState();
    _fetchExistingProfile();
  }

  // Fetch existing profile and populate fields
  Future<void> _fetchExistingProfile() async {
    setState(() => isLoading = true);

    try {
      // Replace with the current user's email to fetch their profile
      const String email = 'sample@gmail.com'; // Replace with dynamic email
      final querySnapshot = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        profilePictureController.text = data['profilePicture'] ??
            'https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/teacher.webp';
        organizationController.text = data['organizationId'] ?? '';
        subscriptionStatus = data['subscriptionStatus'] ?? false;
        selectedRoles = List<String>.from(data['role'] ?? []);
        selectedSubjects = List<String>.from(data['subjects'] ?? []);
        selectedClasses = List<int>.from(data['class'] ?? []);
      }
    } catch (e) {
      _showSnackbar('Error fetching profile: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Function to handle form submission
  Future<void> handleSubmit() async {
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Email is required to identify the profile.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final querySnapshot = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      final data = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'profilePicture': profilePictureController.text.trim(),
        'organizationId': organizationController.text.trim(),
        'role': selectedRoles,
        'subjects': selectedSubjects,
        'class': selectedClasses,
        'subscriptionStatus': subscriptionStatus,
        'updatedAt': DateTime.now(),
      };

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing profile
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update(data);
        _showSnackbar('Profile updated successfully!');
      } else {
        // Create new profile
        await _firestore.collection('teacher').add({
          ...data,
          'createdAt': DateTime.now(),
        });
        _showSnackbar('Profile created successfully!');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Snackbar for user feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // UI for a multi-select dropdown
  Widget _buildMultiSelectField(
    String title,
    List items,
    List selectedItems,
    Function(List) onConfirm,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: MultiSelectDialogField(
        items: items.map((e) => MultiSelectItem(e, e.toString())).toList(),
        title: Text('Select $title'),
        selectedColor: const Color.fromRGBO(141, 208, 255, 1),
        itemsTextStyle:
            const TextStyle(color: Color.fromARGB(221, 167, 167, 167)),
        selectedItemsTextStyle: const TextStyle(color: Colors.blueAccent),
        backgroundColor: const Color.fromARGB(188, 0, 0, 0),
        dialogHeight: 200,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        buttonIcon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.blue,
        ),
        buttonText: Text(
          selectedItems.isNotEmpty
              ? '$title: ${selectedItems.join(", ")}'
              : 'Select $title',
          style: const TextStyle(
            color: Color.fromARGB(255, 186, 186, 186),
            fontSize: 16,
          ),
        ),
        initialValue: selectedItems,
        onConfirm: (results) => setState(() => onConfirm(results)),
      ),
    );
  }

  // UI for the entire screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField('Name', nameController),
                  _buildTextField('Email (required)', emailController),
                  _buildTextField('Phone', phoneController),
                  _buildTextField(
                      'Profile Picture URL', profilePictureController),
                  _buildTextField('Organization ID', organizationController),
                  _buildMultiSelectField('Roles', _roleOptions, selectedRoles,
                      (results) => selectedRoles = results.cast<String>()),
                  _buildMultiSelectField(
                      'Subjects',
                      _subjectOptions,
                      selectedSubjects,
                      (results) => selectedSubjects = results.cast<String>()),
                  _buildMultiSelectField(
                      'Classes',
                      _classOptions,
                      selectedClasses,
                      (results) => selectedClasses = results.cast<int>()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subscription Status:'),
                      Switch(
                        value: subscriptionStatus,
                        onChanged: (value) {
                          setState(() => subscriptionStatus = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: handleSubmit,
                    child: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isMultiline = false,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: isMultiline ? null : 1,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
