import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedAudience = "All Participants";
  String? _deviceToken;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _getDeviceToken();
    _listenForNotifications();
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show a local notification
  Future<void> _showLocalNotification(String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  // Get the device token
  Future<void> _getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        setState(() {
          _deviceToken = token;
        });
        debugPrint("FCM Token: $token");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FCM Token fetched successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Error fetching FCM Token: $e");
    }
  }

  // Listen for foreground notifications
  void _listenForNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show a local notification in the system tray
        _showLocalNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No message',
        );
      }
    });
  }

  // Send notification (simulate)
  void _sendNotification() {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;
      String message = _messageController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification Sent Successfully!\n\n'
              'Title: $title\n'
              'Message: $message\n'
              'Audience: $_selectedAudience\n'
              'Token: $_deviceToken'),
        ),
      );

      // Clear the form
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedAudience = "All Participants";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter notification title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notification Message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Enter notification message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a message.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Audience',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedAudience,
                  items: const [
                    DropdownMenuItem(
                      value: 'All Participants',
                      child: Text('All Participants'),
                    ),
                    DropdownMenuItem(
                      value: 'Invigilators',
                      child: Text('Invigilators'),
                    ),
                    DropdownMenuItem(
                      value: 'Specific Groups',
                      child: Text('Specific Groups'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAudience = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _sendNotification,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text(
                      'Send Notification',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
