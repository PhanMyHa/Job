import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../models/application.dart';
import '../models/notification.dart' as JobNotification;
import '../models/admin_notification.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService apiService = ApiService();
  late Future<List<Job>> jobsFuture;
  late Future<List<User>> usersFuture;
  late Future<List<AdminNotification>> adminNotificationsFuture;
  late Future<List<Application>> applicationsFuture;
  bool showForm = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController jobTypeController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController qualificationsController =
      TextEditingController();
  late IO.Socket socket;
  int _selectedIndex = 0; // Thêm chỉ số tab

  @override
  void initState() {
    super.initState();
    jobsFuture = _fetchJobs(); // Sử dụng hàm riêng để sắp xếp
    usersFuture = _fetchUsers(); // Sử dụng hàm riêng để sắp xếp
    adminNotificationsFuture =
        _fetchAdminNotifications(); // Sử dụng hàm riêng để sắp xếp
    applicationsFuture = _fetchApplications();
    _setupSocket();
  }

  // Hàm lấy jobs và sắp xếp theo createdAt
  Future<List<Job>> _fetchJobs() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/jobs'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Job.fromJson(json)).toList()..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        ); // Sắp xếp từ mới đến cũ
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Hàm lấy users và sắp xếp theo createdAt
  Future<List<User>> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/users'));
      if (response.statusCode == 200) {
        List<dynamic> userData = jsonDecode(response.body);
        return userData.map((json) => User.fromJson(json)).toList(); // Bỏ sort
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Hàm lấy admin notifications và sắp xếp theo createdAt
  Future<List<AdminNotification>> _fetchAdminNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin-notifications'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => AdminNotification.fromJson(json))
            .toList(); // Không sắp xếp nữa
      } else {
        throw Exception('Failed to load admin notifications');
      }
    } catch (e) {
      throw Exception('Error fetching admin notifications: $e');
    }
  }

  Future<List<Application>> _fetchApplications() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/applications'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Application.fromJson(json)).toList()..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        ); // Sắp xếp từ mới đến cũ
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      throw Exception('Error fetching applications: $e');
    }
  }

  void _setupSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('join', 'admin_room');
      print('Socket connected to admin_room');
    });

    socket.on('receive_admin_notification', (data) {
      final notification = AdminNotification.fromJson(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notification.title}: ${notification.message}'),
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() {
        adminNotificationsFuture = _fetchAdminNotifications();
        applicationsFuture = _fetchApplications();
      });
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    locationController.dispose();
    jobTypeController.dispose();
    salaryController.dispose();
    skillsController.dispose();
    qualificationsController.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      showForm = !showForm;
      if (!showForm) {
        titleController.clear();
        companyController.clear();
        locationController.clear();
        jobTypeController.clear();
        salaryController.clear();
        skillsController.clear();
        qualificationsController.clear();
      }
    });
  }

  void _postJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${ApiService.baseUrl}/jobs'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': titleController.text,
            'company': companyController.text,
            'location': locationController.text,
            'jobType': jobTypeController.text,
            'salary': salaryController.text,
            'requiredSkills':
                skillsController.text.split(',').map((s) => s.trim()).toList(),
            'qualifications':
                qualificationsController.text
                    .split(',')
                    .map((q) => q.trim())
                    .toList(),
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            jobsFuture = _fetchJobs(); // Cập nhật lại danh sách jobs
            _toggleForm();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job posted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post job: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _approveApplication(
    String applicationId,
    String userEmail,
    String jobId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/applications/$applicationId/approve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'Approved'}),
      );
      if (response.statusCode == 200) {
        setState(() {
          applicationsFuture = _fetchApplications();
          adminNotificationsFuture = _fetchAdminNotifications();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application approved and notification sent'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _rejectApplication(
    String applicationId,
    String userEmail,
    String jobId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/applications/$applicationId/reject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'Rejected'}),
      );
      if (response.statusCode == 200) {
        setState(() {
          applicationsFuture = _fetchApplications();
          adminNotificationsFuture = _fetchAdminNotifications();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application rejected and notification sent'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF06292),
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Tab Jobs
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _toggleForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF06292),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      showForm ? 'Cancel' : 'Post New Job',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (showForm) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'Job Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: companyController,
                                decoration: InputDecoration(
                                  labelText: 'Company',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: locationController,
                                decoration: InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: jobTypeController,
                                decoration: InputDecoration(
                                  labelText: 'Job Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: salaryController,
                                decoration: InputDecoration(
                                  labelText: 'Salary',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: skillsController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Required Skills (comma-separated)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: qualificationsController,
                                decoration: InputDecoration(
                                  labelText: 'Qualifications (comma-separated)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _postJob,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Submit Job',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Jobs',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Job>>(
                    future: jobsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF06292),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'No jobs available',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      final jobs = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Company: ${job.company}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Location: ${job.location}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Job Type: ${job.jobType}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Salary: ${job.salary}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Skills:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        job.requiredSkills
                                            .map(
                                              (skill) => Chip(
                                                label: Text(
                                                  skill,
                                                  style: const TextStyle(
                                                    color: Color(0xFFF06292),
                                                  ),
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFF8E1E9,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Qualifications:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        job.qualifications
                                            .map(
                                              (qual) => Chip(
                                                label: Text(
                                                  qual,
                                                  style: const TextStyle(
                                                    color: Color(0xFFF06292),
                                                  ),
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFF8E1E9,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Tab Users
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Users',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<User>>(
                    future: usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF06292),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'No users available',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      final users = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Email: ${user.email}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Skills: ${user.skills.isNotEmpty ? user.skills.join(', ') : 'None'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Education: ${user.education.isNotEmpty ? user.education.map((edu) => '${edu.degree} from ${edu.school}').join(', ') : 'None'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Experience: ${user.experience.isNotEmpty ? user.experience.map((exp) => '${exp.position} at ${exp.company}').join(', ') : 'None'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Tab Notifications
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Notifications',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<AdminNotification>>(
                    future: adminNotificationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF06292),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'No admin notifications available',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      final notifications = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.message,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Time: ${notification.time}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Applications',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Application>>(
                    future: applicationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF06292),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'No applications available',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      final applications = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Applicant: ${app.firstName} ${app.lastName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Email: ${app.email}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Job ID: ${app.jobId}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Job Title: ${app.jobTitle}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Salary: ${app.salary}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Status: ${app.status}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Country: ${app.country}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Message: ${app.message}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  if (app.status == 'Delivered') ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed:
                                              () => _approveApplication(
                                                app.id,
                                                app.email,
                                                app.jobId,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Approve'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed:
                                              () => _rejectApplication(
                                                app.id,
                                                app.email,
                                                app.jobId,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFF06292),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}
