import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/job.dart';

class JobApplyScreen extends StatefulWidget {
  final String jobId;
  final String userEmail;

  const JobApplyScreen({
    super.key,
    required this.jobId,
    required this.userEmail,
  });

  @override
  _JobApplyScreenState createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends State<JobApplyScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _messageController = TextEditingController();
  File? _cvFile;
  PlatformFile? _platformFile;
  Uint8List? _fileBytes;
  final ApiService apiService = ApiService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _platformFile = result.files.first;
        if (kIsWeb) {
          _fileBytes = _platformFile!.bytes;
        } else {
          _cvFile = File(_platformFile!.path!);
        }
      });
    }
  }

  Future<void> _applyForJob() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final country = _countryController.text;
    final message = _messageController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        country.isEmpty ||
        message.isEmpty ||
        _platformFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload a CV')),
      );
      return;
    }

    try {
      final job = await apiService.fetchJobById(widget.jobId);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/applications'),
      );

      request.fields['jobId'] = widget.jobId;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['country'] = country;
      request.fields['message'] = message;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cv',
            _fileBytes!,
            filename: _platformFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('cv', _cvFile!.path),
        );
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        await apiService.createNotification(
          widget.userEmail,
          'Application Submitted',
          'You have successfully applied for ${job.title}',
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied for ${job.title} successfully')),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Apply for Job',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 24),
                  // First Name
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person, color: Color(0xFFF06292)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Last Name
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person, color: Color(0xFFF06292)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFFF06292)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Country
                  TextField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      prefixIcon: Icon(Icons.public, color: Color(0xFFF06292)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Message
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      prefixIcon: Icon(Icons.message, color: Color(0xFFF06292)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  // Upload CV Button
                  ElevatedButton(
                    onPressed: _pickFile,
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
                        Icon(Icons.upload_file),
                        SizedBox(width: 8),
                        Text(
                          'Upload CV (PDF)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_platformFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: Color(0xFFF06292)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected file: ${_platformFile!.name}',
                              style: TextStyle(color: Color(0xFFF06292)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 24),
                  // Apply Button
                  ElevatedButton(
                    onPressed: _applyForJob,
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
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text(
                          'Apply',
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
      ),
    );
  }
}
