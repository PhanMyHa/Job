import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _educationDegreeController =
      TextEditingController();
  final TextEditingController _educationSchoolController =
      TextEditingController();
  final TextEditingController _educationStartYearController =
      TextEditingController();
  final TextEditingController _educationEndYearController =
      TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _experiencePositionController =
      TextEditingController();
  final TextEditingController _experienceCompanyController =
      TextEditingController();
  final TextEditingController _experienceStartDateController =
      TextEditingController();
  final TextEditingController _experienceEndDateController =
      TextEditingController();
  final TextEditingController _experienceDescriptionController =
      TextEditingController();

  late List<Education> educationList;
  late List<String> skillsList;
  late List<Experience> experienceList;
  String? avatarUrl;
  PlatformFile? _avatarFile;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    educationList = widget.user.education;
    skillsList = widget.user.skills;
    experienceList = widget.user.experience;
    avatarUrl = widget.user.avatar;
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _avatarFile = result.files.first;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      if (_avatarFile != null) {
        avatarUrl = await apiService.uploadAvatar(
          widget.user.email,
          _avatarFile!,
        );
      }

      final updatedUser = User(
        email: widget.user.email,
        name: _nameController.text,
        password: widget.user.password,
        receiveNotifications: widget.user.receiveNotifications,
        education: educationList,
        skills: skillsList,
        experience: experienceList,
        avatar: avatarUrl,
      );

      await apiService.updateUser(widget.user.email, updatedUser);
      Navigator.pop(context, updatedUser);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _addEducation() {
    if (_educationDegreeController.text.isNotEmpty &&
        _educationSchoolController.text.isNotEmpty &&
        _educationStartYearController.text.isNotEmpty) {
      setState(() {
        educationList.add(
          Education(
            degree: _educationDegreeController.text,
            school: _educationSchoolController.text,
            startYear: int.parse(_educationStartYearController.text),
            endYear:
                _educationEndYearController.text.isNotEmpty
                    ? int.parse(_educationEndYearController.text)
                    : null,
          ),
        );
        _educationDegreeController.clear();
        _educationSchoolController.clear();
        _educationStartYearController.clear();
        _educationEndYearController.clear();
      });
    }
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        skillsList.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  void _addExperience() {
    if (_experiencePositionController.text.isNotEmpty &&
        _experienceCompanyController.text.isNotEmpty &&
        _experienceStartDateController.text.isNotEmpty) {
      setState(() {
        experienceList.add(
          Experience(
            position: _experiencePositionController.text,
            company: _experienceCompanyController.text,
            startDate: DateTime.parse(_experienceStartDateController.text),
            endDate:
                _experienceEndDateController.text.isNotEmpty
                    ? DateTime.parse(_experienceEndDateController.text)
                    : null,
            description:
                _experienceDescriptionController.text.isNotEmpty
                    ? _experienceDescriptionController.text
                    : null,
          ),
        );
        _experiencePositionController.clear();
        _experienceCompanyController.clear();
        _experienceStartDateController.clear();
        _experienceEndDateController.clear();
        _experienceDescriptionController.clear();
      });
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF06292),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.save, color: Color(0xFFF06292)),
                      onPressed: _saveProfile,
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xFFF8E1E9),
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFF8E1E9),
                        backgroundImage:
                            _avatarFile != null
                                ? (kIsWeb
                                    ? MemoryImage(_avatarFile!.bytes!)
                                        as ImageProvider
                                    : FileImage(File(_avatarFile!.path!))
                                        as ImageProvider)
                                : (avatarUrl != null && avatarUrl!.isNotEmpty
                                    ? NetworkImage(
                                      'http://localhost:3000$avatarUrl',
                                    )
                                    : null),
                        child:
                            (_avatarFile == null &&
                                    (avatarUrl == null || avatarUrl!.isEmpty))
                                ? Text(
                                  widget.user.name.isNotEmpty
                                      ? widget.user.name[0]
                                      : '',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xFFF06292),
                                  ),
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Color(0xFFF06292),
                          ),
                          onPressed: _pickAvatar,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            padding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Name
                Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFF06292),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person, color: Color(0xFFF06292)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Education
                Text(
                  'Education',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF06292),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _educationDegreeController,
                  decoration: InputDecoration(
                    labelText: 'Degree',
                    prefixIcon: Icon(Icons.school, color: Color(0xFFF06292)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _educationSchoolController,
                  decoration: InputDecoration(
                    labelText: 'School',
                    prefixIcon: Icon(
                      Icons.account_balance,
                      color: Color(0xFFF06292),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _educationStartYearController,
                  decoration: InputDecoration(
                    labelText: 'Start Year',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF06292),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _educationEndYearController,
                  decoration: InputDecoration(
                    labelText: 'End Year (optional)',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF06292),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addEducation,
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
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text(
                        'Add Education',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                ...educationList.map(
                  (edu) => Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.school, color: Color(0xFFF06292)),
                      title: Text(
                        '${edu.degree} at ${edu.school}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${edu.startYear} - ${edu.endYear ?? "Present"}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Color(0xFFF06292)),
                        onPressed: () {
                          setState(() {
                            educationList.remove(edu);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Skills
                Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF06292),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _skillController,
                  decoration: InputDecoration(
                    labelText: 'Skill',
                    prefixIcon: Icon(Icons.star, color: Color(0xFFF06292)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addSkill,
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
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text(
                        'Add Skill',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      skillsList
                          .map(
                            (skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Color(0xFFF8E1E9),
                              labelStyle: TextStyle(color: Color(0xFFF06292)),
                              deleteIcon: Icon(
                                Icons.close,
                                color: Color(0xFFF06292),
                              ),
                              onDeleted: () {
                                setState(() {
                                  skillsList.remove(skill);
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
                SizedBox(height: 24),
                // Experience
                Text(
                  'Experience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF06292),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _experiencePositionController,
                  decoration: InputDecoration(
                    labelText: 'Position',
                    prefixIcon: Icon(Icons.work, color: Color(0xFFF06292)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _experienceCompanyController,
                  decoration: InputDecoration(
                    labelText: 'Company',
                    prefixIcon: Icon(Icons.business, color: Color(0xFFF06292)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _experienceStartDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF06292),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _experienceEndDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date (optional, YYYY-MM-DD)',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFF06292),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _experienceDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(
                      Icons.description,
                      color: Color(0xFFF06292),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addExperience,
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
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text(
                        'Add Experience',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                ...experienceList.map(
                  (exp) => Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.work, color: Color(0xFFF06292)),
                      title: Text(
                        '${exp.position} at ${exp.company}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${exp.startDate.year} - ${exp.endDate?.year ?? "Present"}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Color(0xFFF06292)),
                        onPressed: () {
                          setState(() {
                            experienceList.remove(exp);
                          });
                        },
                      ),
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
