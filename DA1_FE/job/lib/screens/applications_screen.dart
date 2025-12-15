import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/api_service.dart';

class ApplicationsScreen extends StatefulWidget {
  final String email;

  const ApplicationsScreen({super.key, required this.email});

  @override
  _ApplicationsScreenState createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> applicationsWithJobTitlesFuture;

  @override
  void initState() {
    super.initState();
    applicationsWithJobTitlesFuture = _fetchApplicationsWithJobTitles();
  }

  Future<List<Map<String, dynamic>>> _fetchApplicationsWithJobTitles() async {
    final applications = await apiService.fetchApplications(widget.email);

    final List<Map<String, dynamic>> applicationsWithTitles = [];
    for (var application in applications) {
      try {
        final job = await apiService.fetchJobById(application.jobId);
        applicationsWithTitles.add({
          'application': application,
          'jobTitle': job.title,
        });
      } catch (e) {
        applicationsWithTitles.add({
          'application': application,
          'jobTitle': 'Unknown Job',
        });
      }
    }

    return applicationsWithTitles;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Text(
                  'Applications',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF06292),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: applicationsWithJobTitlesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF06292),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No applications found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    final applicationsWithTitles = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: applicationsWithTitles.length,
                      itemBuilder: (context, index) {
                        final application =
                            applicationsWithTitles[index]['application']
                                as Application;
                        final jobTitle =
                            applicationsWithTitles[index]['jobTitle'] as String;
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFFF8E1E9),
                              foregroundColor: Color(0xFFF06292),
                              child: Icon(Icons.work),
                            ),
                            title: Text(
                              jobTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Status: ${application.status}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
