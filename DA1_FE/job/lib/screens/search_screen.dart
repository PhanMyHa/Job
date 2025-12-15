import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import 'filter_screen.dart';
import 'job_apply_screen.dart';

class SearchScreen extends StatefulWidget {
  final String userEmail;

  const SearchScreen({super.key, required this.userEmail});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Job>> jobsFuture;
  Map<String, dynamic>? filters;
  bool isShowingSuggestions = false;
  final TextEditingController _searchController =
      TextEditingController(); // Thêm controller cho TextField

  @override
  void initState() {
    super.initState();
    jobsFuture = apiService.fetchJobs();
  }

  void _applyFilters(Map<String, dynamic> newFilters) {
    setState(() {
      filters = newFilters;
      jobsFuture = apiService.fetchJobs(filters: filters);
      isShowingSuggestions = false;
      _searchController.clear(); // Xóa từ khóa tìm kiếm khi áp dụng bộ lọc
    });
  }

  void _showSuggestions() {
    setState(() {
      jobsFuture = apiService.fetchJobSuggestions(widget.userEmail);
      isShowingSuggestions = true;
      filters = null; // Xóa bộ lọc khi hiển thị gợi ý
      _searchController.clear(); // Xóa từ khóa tìm kiếm khi hiển thị gợi ý
    });
  }

  void _searchJobs(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        // Nếu từ khóa rỗng, hiển thị toàn bộ công việc
        filters = null;
        jobsFuture = apiService.fetchJobs();
        isShowingSuggestions = false;
      } else {
        // Tìm kiếm công việc theo từ khóa
        filters = {...?filters, 'title': keyword};
        jobsFuture = apiService.fetchJobs(filters: filters);
        isShowingSuggestions = false;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng controller
    super.dispose();
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
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller:
                              _searchController, // Gắn controller vào TextField
                          decoration: InputDecoration(
                            hintText: 'Search for jobs...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFFF06292),
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Color(0xFFF06292),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchJobs(''); // Reset tìm kiếm
                                        });
                                      },
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: (value) {
                            _searchJobs(value); // Tìm kiếm theo thời gian thực
                          },
                          onSubmitted: (value) {
                            _searchJobs(value); // Tìm kiếm khi nhấn Enter
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.filter_list, color: Color(0xFFF06292)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilterScreen(),
                          ),
                        );
                        if (result != null) {
                          _applyFilters(result);
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xFFF8E1E9),
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              // Filter Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showSuggestions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8E1E9),
                          foregroundColor: Color(0xFFF06292),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Most Relevant',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filters = {...?filters, 'sort': 'recent'};
                            jobsFuture = apiService.fetchJobs(filters: filters);
                            isShowingSuggestions = false;
                            _searchController.clear(); // Xóa từ khóa tìm kiếm
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8E1E9),
                          foregroundColor: Color(0xFFF06292),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Most Recent',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Job List
              Expanded(
                child: FutureBuilder<List<Job>>(
                  future: jobsFuture,
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
                          _searchController.text.isNotEmpty
                              ? 'No jobs found for "${_searchController.text}"'
                              : isShowingSuggestions
                              ? 'No suggested jobs available'
                              : 'No jobs available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    final jobs = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tiêu đề và công ty
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            job.company,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: Color(0xFFF06292),
                                      ),
                                      onPressed: () {
                                        // Logic lưu công việc yêu thích
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Thông tin cơ bản
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Color(0xFFF06292),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      job.location,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.work_outline,
                                      size: 18,
                                      color: Color(0xFFF06292),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      job.jobType,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      size: 18,
                                      color: Color(0xFFF06292),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      job.salary,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Kỹ năng yêu cầu
                                Text(
                                  'Kỹ năng yêu cầu:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      job.requiredSkills.map((skill) {
                                        return Chip(
                                          label: Text(
                                            skill,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFF06292),
                                            ),
                                          ),
                                          backgroundColor: Color(0xFFF8E1E9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        );
                                      }).toList(),
                                ),
                                SizedBox(height: 12),
                                // Trình độ yêu cầu
                                Text(
                                  'Trình độ yêu cầu:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      job.qualifications.map((qualification) {
                                        return Chip(
                                          label: Text(
                                            qualification,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFF06292),
                                            ),
                                          ),
                                          backgroundColor: Color(0xFFF8E1E9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        );
                                      }).toList(),
                                ),
                                if (isShowingSuggestions) ...[
                                  SizedBox(height: 12),
                                  Text(
                                    'Matched: ${job.requiredSkills.join(", ")}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFF06292),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12),
                                // Nút ứng tuyển
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => JobApplyScreen(
                                                jobId: job.id,
                                                userEmail: widget.userEmail,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFF06292),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      'Ứng tuyển ngay',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
