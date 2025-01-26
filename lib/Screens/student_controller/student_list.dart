import 'package:flutter/material.dart';

class StudentList extends StatelessWidget {
  final List<Map<String, String>> students;
  final Function(Map<String, String>) onRemoveStudent;

  const StudentList({
    super.key,
    required this.students,
    required this.onRemoveStudent, // A callback function to remove the student
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(student['name'] ?? 'No Name'),
                    subtitle: Text(student['email'] ?? 'No Email'),
                    tileColor: const Color.fromARGB(255, 42, 42, 42),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Call the onRemoveStudent callback to remove the student
                        onRemoveStudent(student);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
