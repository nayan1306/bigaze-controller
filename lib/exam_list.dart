import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/schedule_exam_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  _ExamListPageState createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Calendar state variables
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final Stream<QuerySnapshot> _examStream;

  @override
  void initState() {
    super.initState();
    _examStream = fetchExamEntries();
  }

  // Helper: Normalize a date by removing the time component.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Fetch exam entries from Firestore, ordered by latest startAt.
  Stream<QuerySnapshot> fetchExamEntries() async* {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No user logged in!')));
      return;
    }
    // Get the teacher's document ID.
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();
    if (userDoc.docs.isNotEmpty) {
      final teacherDocId = userDoc.docs.first.id;
      yield* _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .orderBy('startAt', descending: true)
          .snapshots();
    }
  }

  // Update the isLive status for an exam.
  Future<void> updateIsLiveStatus(String examId, bool isLiveStatus) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No user logged in!')));
        return;
      }
      final userDoc = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        final teacherDocId = userDoc.docs.first.id;
        await _firestore
            .collection('teacher')
            .doc(teacherDocId)
            .collection('exams')
            .doc(examId)
            .update({'isLive': isLiveStatus});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam status updated!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating exam status: $e')));
    }
  }

  // Delete an exam.
  Future<void> deleteExam(String examId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No user logged in!')));
        return;
      }
      final userDoc = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();
      if (userDoc.docs.isNotEmpty) {
        final teacherDocId = userDoc.docs.first.id;
        await _firestore
            .collection('teacher')
            .doc(teacherDocId)
            .collection('exams')
            .doc(examId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam deleted!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting exam: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Calendar'),
      ),
      // Wrap the body in a GestureDetector to collapse the calendar when tapping outside.
      body: StreamBuilder<QuerySnapshot>(
        stream: _examStream,
        builder: (context, snapshot) {
          // Build the events map from exam data.
          Map<DateTime, List<dynamic>> events = {};
          if (snapshot.hasData) {
            for (var exam in snapshot.data!.docs) {
              DateTime examDate = _normalizeDate(exam['startAt'].toDate());
              events.putIfAbsent(examDate, () => []).add(exam);
            }
          }
          // Determine which exams to show based on the selected day.
          List<dynamic> examsToShow;
          if (_selectedDay != null) {
            DateTime normalizedSelected = _normalizeDate(_selectedDay!);
            examsToShow = snapshot.hasData
                ? snapshot.data!.docs.where((exam) {
                    DateTime examDate =
                        _normalizeDate(exam['startAt'].toDate());
                    return examDate == normalizedSelected;
                  }).toList()
                : [];
          } else {
            examsToShow = snapshot.hasData ? snapshot.data!.docs : [];
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Collapse the calendar (to week view) when tapped anywhere.
              if (_calendarFormat == CalendarFormat.month) {
                setState(() {
                  _calendarFormat = CalendarFormat.week;
                  _selectedDay = null;
                });
              }
            },
            child: Column(
              children: [
                // Calendar widget.
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  eventLoader: (day) {
                    DateTime normalizedDay = _normalizeDate(day);
                    return events[normalizedDay] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      if (_calendarFormat == CalendarFormat.week) {
                        _calendarFormat = CalendarFormat.month;
                      }
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  // Use calendarBuilders to display a custom image marker.
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child: Image.asset(
                            'assets/icon/exam-time.png',
                            width: 20,
                            height: 20,
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Expanded exam list with a PageStorageKey to preserve state.
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                          ? Center(child: Text('Error: ${snapshot.error}'))
                          : snapshot.hasData && examsToShow.isNotEmpty
                              ? ListView.builder(
                                  key: const PageStorageKey('examList'),
                                  itemCount: examsToShow.length,
                                  itemBuilder: (context, index) {
                                    var examData = examsToShow[index];
                                    String examId = examData.id;
                                    String examName =
                                        examData['examName'] ?? 'N/A';
                                    String examType =
                                        examData['examType'] ?? 'N/A';
                                    int duration = examData['duration'] ?? 0;
                                    String instructions =
                                        examData['instructions'] ?? 'N/A';
                                    String startAt = examData['startAt']
                                            ?.toDate()
                                            .toString() ??
                                        'N/A';
                                    bool isLive = examData['isLive'] ?? false;
                                    return Dismissible(
                                      key: Key(examId),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                      confirmDismiss: (direction) async {
                                        return await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Confirm Deletion"),
                                              content: const Text(
                                                  "Are you sure you want to delete this exam?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text("Delete",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onDismissed: (direction) {
                                        deleteExam(examId);
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          title: Text(examName),
                                          subtitle: Text(
                                              'Type: $examType\nDuration: $duration minutes\nStart At: $startAt\nInstructions: $instructions'),
                                          trailing: IconButton(
                                            icon: Icon(
                                              isLive
                                                  ? Icons.stop
                                                  : Icons.play_arrow,
                                              color: isLive
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                            onPressed: () {
                                              updateIsLiveStatus(
                                                  examId, !isLive);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 200,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor:
                                            Colors.white.withOpacity(0.5),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.white, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ScheduleExamPage(),
                                          ),
                                        );
                                      },
                                      child: const Text("Schedule Exam"),
                                    ),
                                  ),
                                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
