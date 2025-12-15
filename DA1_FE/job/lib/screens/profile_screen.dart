import 'package:flutter/material.dart';
import 'package:job/screens/login_screen.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'applications_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({super.key, required this.userEmail});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();
  late Future<User> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = apiService.fetchUser(widget.userEmail);
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
          child: FutureBuilder<User>(
            future: userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFFF06292)),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text(
                    'No user data',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                );
              }
              final user = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFF8E1E9),
                            backgroundImage:
                                user.avatar != null && user.avatar!.isNotEmpty
                                    ? NetworkImage(
                                      'http://localhost:3000${user.avatar}',
                                    )
                                    : null,
                            child:
                                user.avatar == null || user.avatar!.isEmpty
                                    ? Text(
                                      user.name.isNotEmpty ? user.name[0] : '',
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Color(0xFFF06292),
                                      ),
                                    )
                                    : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF06292),
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      // Education
                      Row(
                        children: [
                          Icon(Icons.school, color: Color(0xFFF06292)),
                          SizedBox(width: 8),
                          Text(
                            'Education',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF06292),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (user.education.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Text(
                            'No education added.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      else
                        ...user.education.map(
                          (edu) => Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${edu.degree} at ${edu.school}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${edu.startYear} - ${edu.endYear ?? "Present"}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      // Skills
                      Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFF06292)),
                          SizedBox(width: 8),
                          Text(
                            'Skills',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF06292),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (user.skills.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Text(
                            'No skills added.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children:
                              user.skills
                                  .map(
                                    (skill) => Chip(
                                      label: Text(
                                        skill,
                                        style: TextStyle(
                                          color: Color(0xFFF06292),
                                        ),
                                      ),
                                      backgroundColor: Color(0xFFF8E1E9),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      SizedBox(height: 24),
                      // Experience
                      Row(
                        children: [
                          Icon(Icons.work, color: Color(0xFFF06292)),
                          SizedBox(width: 8),
                          Text(
                            'Experience',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF06292),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (user.experience.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Text(
                            'No experience added.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      else
                        ...user.experience.map(
                          (exp) => Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${exp.position} at ${exp.company}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${exp.startDate.year} - ${exp.endDate?.year ?? "Present"}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  if (exp.description != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        exp.description!,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      // Navigation Options
                      Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF06292),
                        ),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFFF06292)),
                        title: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: Color(0xFFF8E1E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () async {
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditProfileScreen(user: user),
                            ),
                          );
                          if (updatedUser != null) {
                            setState(() {
                              userFuture = apiService.fetchUser(
                                widget.userEmail,
                              );
                            });
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.work, color: Color(0xFFF06292)),
                        title: Text(
                          'Applications',
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: Color(0xFFF8E1E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ApplicationsScreen(
                                    email: widget.userEmail,
                                  ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: Color(0xFFF06292),
                        ),
                        title: Text(
                          'Notifications',
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: Color(0xFFF8E1E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NotificationsScreen(
                                    email: widget.userEmail,
                                  ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.settings, color: Color(0xFFF06292)),
                        title: Text(
                          'Settings',
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: Color(0xFFF8E1E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(user: user),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.share, color: Color(0xFFF06292)),
                        title: Text(
                          'Share App',
                          style: TextStyle(color: Colors.black),
                        ),
                        tileColor: Color(0xFFF8E1E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {},
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        tileColor: Color(0xFFF8E1E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
