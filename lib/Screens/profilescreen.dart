import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/authgate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? currentUser;

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
    currentUser = _firebaseAuth.currentUser;
    _fetchExistingProfile();
  }

  // Fetch existing profile and populate fields
  Future<void> _fetchExistingProfile() async {
    setState(() => isLoading = true);

    try {
      final User? currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        _showSnackbar('No user logged in!');
        return;
      }

      // Populate fields with default values from the logged-in user
      emailController.text = currentUser.email ?? '';
      nameController.text = currentUser.displayName ?? '';
      profilePictureController.text = currentUser.photoURL ??
          'https://raw.githubusercontent.com/nayan1306/assets/refs/heads/main/teacher.webp';

      // Fetch additional profile data from Firestore
      final querySnapshot = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        phoneController.text = data['phone'] ?? '';
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
          border: Border.all(
              color: const Color.fromARGB(255, 181, 181, 181), width: 1),
        ),
        buttonIcon: const Icon(
          Icons.arrow_drop_down,
          color: Color.fromARGB(255, 180, 180, 180),
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
        backgroundColor: Colors.black26,
        surfaceTintColor: const Color.fromARGB(255, 48, 48, 48),
        leading: const Text(" "),
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: '👋 Welcome, ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(210, 255, 204, 20),
                ),
              ),
              TextSpan(
                text:
                    '${currentUser?.displayName?.split(' ').first ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseAuth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                      height: 90,
                      width: 90,
                      child: Image.network(currentUser!.photoURL.toString())),
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
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(184, 145, 255, 156)),
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _firebaseAuth.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(185, 255, 82, 82))),
                    child: const Text(
                      "SIGN OUT",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  )
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
