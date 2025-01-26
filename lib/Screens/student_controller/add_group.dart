import 'package:examiner_bigaze/firebase/firebase_service.dart';
import 'package:flutter/material.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddMailState();
}

class _AddMailState extends State<AddGroup> {
  final FirebaseService _firebaseService = FirebaseService();
  final List<Map<String, String>> _studentsToAdd = [];
  Map<String, List<Map<String, dynamic>>> _studentsByClass = {};
  String? teacherDocId;

  @override
  void initState() {
    super.initState();
    _fetchTeacherDocId();
    _fetchStudents();
  }

  Future<void> _fetchTeacherDocId() async {
    final docId = await _firebaseService.fetchTeacherDocId();
    if (docId != null) {
      setState(() {
        teacherDocId = docId;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
    }
  }

  Future<void> _fetchStudents() async {
    final groupedStudents = await _firebaseService.fetchStudents();
    setState(() {
      _studentsByClass = groupedStudents;
    });
  }

  Future<void> _addStudents() async {
    if (_studentsToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students selected!')),
      );
      return;
    }

    if (teacherDocId != null) {
      try {
        await _firebaseService.addStudents(teacherDocId!, _studentsToAdd);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Students added successfully!')),
        );
        setState(() {
          _studentsToAdd.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding students: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Select Your Scholars',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _studentsByClass.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _studentsByClass.keys.length,
                    itemBuilder: (context, index) {
                      final className = _studentsByClass.keys.elementAt(index);
                      final studentsInClass = _studentsByClass[className]!;

                      return ExpansionTile(
                        backgroundColor: Colors.blueGrey.shade700,
                        title: Text(
                          'Cohort: $className',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        children: studentsInClass.map((student) {
                          return ListTile(
                            tileColor: Colors.blueGrey.shade800,
                            title: Text(student['name'] ?? 'No Name',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(student['email'] ?? 'No Email',
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Checkbox(
                              value: _studentsToAdd
                                  .any((s) => s['id'] == student['id']),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    _studentsToAdd.add({
                                      'id': student['id'],
                                      'name': student['name'],
                                      'email': student['email'],
                                      'class': student['class'],
                                    });
                                  } else {
                                    _studentsToAdd.removeWhere(
                                        (s) => s['id'] == student['id']);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 232, 255, 225),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Add Selected Students',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
