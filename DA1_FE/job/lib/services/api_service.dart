import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:file_picker/file_picker.dart';
import '../models/job.dart';
import '../models/application.dart';
import '../models/user.dart';
import '../models/notification.dart';
import '../models/message.dart';
import '../models/admin_notification.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  final String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';
  final String geminiApiKey = 'AIzaSyC64CAjssUSiW-EmdVp7DNqN3K4qDar7-g';
  late Function(dynamic) socketListener;
  static IO.Socket? _socket;
  static bool _isConnected = false;

  void connectToSocket(
    String userEmail,
    void Function(dynamic) onMessageReceived,
  ) {
    if (_socket != null && _isConnected) return;

    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      _socket!.emit('join', userEmail);
      print('Socket connected');
    });

    _socket!.on('receive_message', onMessageReceived);
    _socket!.on('receive_notification', onMessageReceived);

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('Socket disconnected');
    });
  }

  void broadcastMessage(String sender, String content) {
    if (_socket != null && _isConnected) {
      _socket!.emit('broadcast_message', {
        'sender': sender,
        'content': content,
        'time': DateTime.now().toIso8601String(),
      });
    } else {
      print('Socket chưa kết nối');
    }
  }

  void removeSocketListener(void Function(dynamic) onMessageReceived) {
    if (_socket != null) {
      _socket!.off('receive_message', onMessageReceived);
      _socket!.off('receive_notification', onMessageReceived);
      print('Socket listener đã được gỡ');
    }
  }

  void disconnectSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.destroy();
      _socket = null;
      _isConnected = false;
      print('Socket ngắt kết nối');
    }
  }

  Future<String> analyzeCVAndSuggestLearningPath({
    File? file,
    List<int>? fileData,
    required String fileName,
    required String desiredJobTitle,
    required bool isWeb,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/jobs/upload-cv'),
      );

      if (isWeb) {
        if (fileData == null) {
          throw Exception('Dữ liệu file trên web là null');
        }
        request.files.add(
          http.MultipartFile.fromBytes('cv', fileData, filename: fileName),
        );
      } else {
        if (file == null) {
          throw Exception('File trên mobile là null');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'cv',
            file.path,
            filename: fileName,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to upload CV: ${response.statusCode} - ${response.body}',
        );
      }

      String cvText = jsonDecode(response.body)['text'] as String;

      cvText =
          cvText
              .replaceAll(RegExp(r'\s+'), ' ')
              .replaceAll(RegExp(r'[^\w\s@.-]'), '')
              .trim();

      final prompt = '''
Dưới đây là nội dung CV được trích xuất từ ảnh bằng OCR, có thể không hoàn hảo (có lỗi định dạng hoặc ký tự sai). Hãy phân tích CV và đề xuất lộ trình học tập để đạt được công việc mong muốn:

**Nội dung CV:**
$cvText

**Công việc mong muốn:** $desiredJobTitle

Hãy đưa ra:
1. Phân tích điểm mạnh và điểm yếu từ CV so với yêu cầu của công việc.
2. Lộ trình học tập cụ thể (kỹ năng cần học, khóa học đề xuất, thời gian dự kiến) để đạt được công việc mong muốn.

Nếu văn bản CV không rõ ràng, hãy cố gắng suy luận hợp lý từ thông tin có sẵn.
''';

      final geminiResponse = await http.post(
        Uri.parse('$geminiApiUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 1000, 'temperature': 0.7},
        }),
      );

      if (geminiResponse.statusCode == 200) {
        final data = jsonDecode(geminiResponse.body);
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          return 'Không nhận được phản hồi từ Gemini';
        }
        final parts = candidates[0]['content']['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          return 'Không nhận được nội dung từ Gemini';
        }
        final content = parts
            .map((part) => (part['text'] ?? '').toString())
            .join(' ');
        return content.isNotEmpty
            ? content
            : 'Không nhận được phản hồi từ Gemini';
      } else {
        throw Exception(
          'Lỗi khi gọi Gemini API: ${geminiResponse.statusCode} - ${geminiResponse.body}',
        );
      }
    } catch (e) {
      throw Exception('Lỗi khi phân tích CV: $e');
    }
  }

  Future<String> callGeminiApi(String message) async {
    final jobRelatedKeywords = [
      'job',
      'career',
      'cv',
      'resume',
      'hiring',
      'recruitment',
      'skill',
      'learning path',
      'job application',
      'interview',
      'employment',
      'việc làm',
      'nghề nghiệp',
      'kỹ năng',
      'lộ trình học',
      'ứng tuyển',
      'phỏng vấn',
    ];

    bool isJobRelated = jobRelatedKeywords.any(
      (keyword) => message.toLowerCase().contains(keyword),
    );

    if (!isJobRelated) {
      return 'Xin lỗi, hệ thống chỉ hỗ trợ các câu hỏi liên quan đến tìm việc, CV, hoặc lộ trình học tập. Vui lòng đặt câu hỏi phù hợp!';
    }

    try {
      final response = await http.post(
        Uri.parse('$geminiApiUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 500, 'temperature': 0.7},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          return 'Không nhận được phản hồi từ Gemini';
        }
        final parts = candidates[0]['content']['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          return 'Không nhận được nội dung từ Gemini';
        }

        final content = parts
            .map((part) => (part['text'] ?? '').toString())
            .join(' ');
        return content.isNotEmpty
            ? content
            : 'Không nhận được phản hồi từ Gemini';
      } else {
        print('Lỗi Gemini API: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Lỗi khi gọi Gemini API: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Ngoại lệ: $e');
      return 'Lỗi: $e';
    }
  }

  Future<Map<String, dynamic>> adminLogin(
    String adminId,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'adminId': adminId, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> adminRegister(
    String adminId,
    String name,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'adminId': adminId,
        'name': name,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<List<Job>> fetchJobSuggestions(String userEmail) async {
    final uri = Uri.parse('$baseUrl/jobs/suggestions/$userEmail');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load job suggestions: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Job>> fetchJobs({Map<String, dynamic>? filters}) async {
    final uri = Uri.parse('$baseUrl/jobs').replace(
      queryParameters: filters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  Future<Job> fetchJobById(String jobId) async {
    final response = await http.get(Uri.parse('$baseUrl/jobs/$jobId'));

    if (response.statusCode == 200) {
      return Job.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load job details');
    }
  }

  Future<void> createNotification(
    String userEmail,
    String title,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userEmail': userEmail,
        'title': title,
        'message': message,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create notification');
    }
  }

  Future<void> applyForJob(
    Application application,
    PlatformFile? cvFile,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/applications'),
    );

    request.fields.addAll({
      'jobId': application.jobId,
      'firstName': application.firstName,
      'lastName': application.lastName,
      'email': application.email,
      'country': application.country,
      'message': application.message,
      'status': application.status,
    });

    if (cvFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cv',
            cvFile.bytes!,
            filename: cvFile.name,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'cv',
            cvFile.path!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to apply for job');
    }
  }

  Future<User> fetchUser(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$email'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> updateUser(String email, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<List<Application>> fetchApplications(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/applications/$email'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Application.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  Future<List<Notification>> fetchNotifications(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/$email'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<AdminNotification>> fetchAdminNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/admin-notifications'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AdminNotification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load admin notifications');
    }
  }

  Future<List<Message>> fetchMessages(String userEmail) async {
    final response = await http.get(Uri.parse('$baseUrl/messages/$userEmail'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  Future<String> uploadAvatar(String email, PlatformFile avatarFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/$email/avatar'),
    );

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          avatarFile.bytes!,
          filename: avatarFile.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path!),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody.body);
      return data['avatar'];
    } else {
      throw Exception('Failed to upload avatar');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String name,
    String password,
    bool receiveNotifications,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'password': password,
        'receiveNotifications': receiveNotifications,
      }),
    );

    return jsonDecode(response.body);
  }
}
