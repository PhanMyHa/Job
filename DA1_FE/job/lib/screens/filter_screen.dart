import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String category = 'UI/UX Design';
  String subcategory = '';
  String location = '';
  String salary = '';
  String jobType = '';

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
                  Text(
                    'Set Filters',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'UI/UX Design',
                      prefixIcon: Icon(
                        Icons.category,
                        color: Color(0xFFF06292),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => category = value,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Subcategory',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Graphics',
                      prefixIcon: Icon(
                        Icons.subdirectory_arrow_right,
                        color: Color(0xFFF06292),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => subcategory = value,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Canada',
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Color(0xFFF06292),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => location = value,
                  ),
                  SizedBox(height: 16),
                  // Salary
                  Text(
                    'Salary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '\$2K - \$5K',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: Color(0xFFF06292),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => salary = value,
                  ),
                  SizedBox(height: 16),
                  // Job Type
                  Text(
                    'Job Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF06292),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('FULL TIME'),
                        selected: jobType == 'FULL TIME',
                        selectedColor: Color(0xFFF8E1E9),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        checkmarkColor: Color(0xFFF06292),
                        labelStyle: TextStyle(
                          color:
                              jobType == 'FULL TIME'
                                  ? Color(0xFFF06292)
                                  : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            jobType = selected ? 'FULL TIME' : '';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text('PART TIME'),
                        selected: jobType == 'PART TIME',
                        selectedColor: Color(0xFFF8E1E9),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        checkmarkColor: Color(0xFFF06292),
                        labelStyle: TextStyle(
                          color:
                              jobType == 'PART TIME'
                                  ? Color(0xFFF06292)
                                  : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            jobType = selected ? 'PART TIME' : '';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text('FREELANCE'),
                        selected: jobType == 'FREELANCE',
                        selectedColor: Color(0xFFF8E1E9),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        checkmarkColor: Color(0xFFF06292),
                        labelStyle: TextStyle(
                          color:
                              jobType == 'FREELANCE'
                                  ? Color(0xFFF06292)
                                  : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            jobType = selected ? 'FREELANCE' : '';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text('REMOTE'),
                        selected: jobType == 'REMOTE',
                        selectedColor: Color(0xFFF8E1E9),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        checkmarkColor: Color(0xFFF06292),
                        labelStyle: TextStyle(
                          color:
                              jobType == 'REMOTE'
                                  ? Color(0xFFF06292)
                                  : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            jobType = selected ? 'REMOTE' : '';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Apply Filters Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'category': category,
                        'subcategory': subcategory,
                        'location': location,
                        'salary': salary,
                        'jobType': jobType,
                      });
                    },
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
                        Icon(Icons.filter_alt),
                        SizedBox(width: 8),
                        Text(
                          'Apply Filters',
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
