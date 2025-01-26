import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> fetchTeacherDocId() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }

    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      return userDoc.docs.first.id;
    }
    return null;
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchStudents() async {
    final studentsSnapshot = await _firestore
        .collection('students')
        .where('isActive', isEqualTo: true) // Fetch only active students
        .get();

    Map<String, List<Map<String, dynamic>>> groupedStudents = {};
    for (var doc in studentsSnapshot.docs) {
      final studentData = doc.data();
      final className = studentData['class'].toString();

      if (!groupedStudents.containsKey(className)) {
        groupedStudents[className] = [];
      }

      groupedStudents[className]!.add({
        'id': doc.id,
        'name': studentData['name'],
        'email': studentData['email'],
        'class': className,
      });
    }
    return groupedStudents;
  }

  Future<void> addStudents(
      String teacherDocId, List<Map<String, String>> studentsToAdd) async {
    final batch = _firestore.batch();
    final collectionRef = _firestore
        .collection('teacher')
        .doc(teacherDocId)
        .collection('students');

    for (var student in studentsToAdd) {
      final docRef = collectionRef.doc();
      batch.set(docRef, student);
    }

    await batch.commit();
  }
}
