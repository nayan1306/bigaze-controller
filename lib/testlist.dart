import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({super.key});

  @override
  _TestListPageState createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch test entries from Firestore
  Stream<QuerySnapshot> fetchTestEntries() {
    return _firestore.collection('examiner').snapshots();
  }

  // Function to update test start status in Firestore
  Future<void> updateTestStart(String testId, bool startStatus) async {
    try {
      await _firestore.collection('examiner').doc(testId).update({
        'teststart': startStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test status updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating test status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Entries'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchTestEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No test entries found.'));
          }

          // Data from Firestore
          var testEntries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: testEntries.length,
            itemBuilder: (context, index) {
              var testData = testEntries[index];
              bool testStart = testData['teststart'] ?? false;
              String testId = testData.id;
              String testName = testData['testname'] ?? 'N/A';
              String testDescription = testData['testdescription'] ?? 'N/A';
              String testSchedule =
                  testData['testschedule']?.toDate().toString() ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(testName),
                  subtitle: Text(
                      'Scheduled: $testSchedule\nDescription: $testDescription'),
                  trailing: IconButton(
                    icon: Icon(
                      testStart ? Icons.stop : Icons.play_arrow,
                      color: testStart ? Colors.red : Colors.green,
                    ),
                    onPressed: () {
                      // Toggle test start status
                      updateTestStart(testId, !testStart);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
