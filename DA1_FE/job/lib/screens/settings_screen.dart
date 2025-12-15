import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  SettingsScreen({required this.user});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService apiService = ApiService();
  bool receiveNotifications = true;

  @override
  void initState() {
    super.initState();
    receiveNotifications = widget.user.receiveNotifications;
  }

  void _saveSettings() async {
    try {
      final updatedUser = User(
        email: widget.user.email,
        name: widget.user.name,
        password: widget.user.password,
        receiveNotifications: receiveNotifications,
      );
      await apiService.updateUser(widget.user.email, updatedUser);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Settings updated!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF06292),
                  ),
                ),
                SizedBox(height: 24),
                // Notifications
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFF06292),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'Receive Notifications',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: receiveNotifications,
                  onChanged: (value) {
                    setState(() {
                      receiveNotifications = value;
                    });
                  },
                  activeColor: Color(0xFFF06292),
                  activeTrackColor: Color(0xFFF8E1E9),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
                Spacer(),
                // Save Settings Button
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF8E1E9),
                    foregroundColor: Color(0xFFF06292),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
