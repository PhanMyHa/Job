import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/message.dart';
import '../services/api_service.dart';

class MessageScreen extends StatefulWidget {
  final String userEmail;

  const MessageScreen({super.key, required this.userEmail});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<List<Message>> messagesFuture;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController botMessageController = TextEditingController();
  List<Message> userMessages = [];
  List<Message> botMessages = [];
  // String receiverEmail = 'anaya.sanji@example.com';
  late void Function(dynamic) _socketListener;
  late TabController _tabController;
  String? desiredJobTitle;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    messagesFuture = apiService.fetchMessages(widget.userEmail);
    messagesFuture.then((initialMessages) {
      if (!mounted) return;
      setState(() {
        userMessages = initialMessages;
      });
    });

    _socketListener = (data) {
      final message = Message.fromJson(data);
      if (!mounted) return;
      setState(() {
        userMessages.add(message);
      });
    };

    apiService.connectToSocket(widget.userEmail, _socketListener);

    botMessages.add(
      Message(
        sender: 'Gemini AI',
        content:
            'Xin chào! Tôi là Gemini, sẵn sàng giúp bạn. Bạn muốn trò chuyện về gì? Nếu muốn phân tích CV và nhận lộ trình học tập, hãy upload CV và cho tôi biết công việc mong muốn của bạn!',
        time: DateTime.now().toString(),
      ),
    );
  }

  @override
  void dispose() {
    apiService.removeSocketListener(_socketListener);
    messageController.dispose();
    botMessageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _sendUserMessage() {
    if (messageController.text.isNotEmpty) {
      apiService.broadcastMessage(widget.userEmail, messageController.text);
      messageController.clear();
    }
  }

  void _sendBotMessage() async {
    if (botMessageController.text.isNotEmpty) {
      final userMessage = Message(
        sender: widget.userEmail,
        content: botMessageController.text,
        time: DateTime.now().toString(),
      );

      setState(() {
        botMessages.add(userMessage);
        desiredJobTitle = botMessageController.text;
      });

      final response = await apiService.callGeminiApi(
        botMessageController.text,
      );
      final botResponse = Message(
        sender: 'Gemini AI',
        content: response,
        time: DateTime.now().toString(),
      );

      if (!mounted) return;
      setState(() {
        botMessages.add(botResponse);
      });

      botMessageController.clear();
    }
  }

  void _uploadCVAndAnalyze() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final fileName = result.files.single.name;
        final userMessage = Message(
          sender: widget.userEmail,
          content: 'Đã upload CV: $fileName',
          time: DateTime.now().toString(),
        );

        setState(() {
          botMessages.add(userMessage);
        });

        String analysisResult;
        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes == null) {
            throw Exception('Không thể đọc dữ liệu file trên web');
          }
          analysisResult = await apiService.analyzeCVAndSuggestLearningPath(
            fileData: bytes,
            fileName: fileName,
            desiredJobTitle: desiredJobTitle ?? 'Software Engineer',
            isWeb: true,
          );
        } else {
          final path = result.files.single.path;
          if (path == null) {
            throw Exception('Không thể đọc đường dẫn file trên mobile');
          }
          final cvFile = File(path);
          analysisResult = await apiService.analyzeCVAndSuggestLearningPath(
            file: cvFile,
            fileName: fileName,
            desiredJobTitle: desiredJobTitle ?? 'Software Engineer',
            isWeb: false,
          );
        }

        if (analysisResult.contains('Không nhận được nội dung từ Gemini') ||
            analysisResult.trim().isEmpty) {
          throw Exception(
            'Không thể trích xuất văn bản từ CV. Vui lòng thử upload một ảnh CV rõ ràng hơn.',
          );
        }

        final botResponse = Message(
          sender: 'Gemini AI',
          content: analysisResult,
          time: DateTime.now().toString(),
        );

        if (!mounted) return;
        setState(() {
          botMessages.add(botResponse);
        });
      } else {
        final botResponse = Message(
          sender: 'Gemini AI',
          content: 'Không thể upload CV. Vui lòng thử lại.',
          time: DateTime.now().toString(),
        );

        setState(() {
          botMessages.add(botResponse);
        });
      }
    } catch (e) {
      final botResponse = Message(
        sender: 'Gemini AI',
        content: 'Lỗi khi upload CV: $e',
        time: DateTime.now().toString(),
      );

      setState(() {
        botMessages.add(botResponse);
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
          child: Column(
            children: [
              // Custom Header
              Container(
                color: Color(0xFFF8E1E9),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF06292),
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: Color(0xFFF06292),
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Color(0xFFF06292),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [Tab(text: 'Người dùng'), Tab(text: 'Gemini AI')],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // User Messages Tab
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: userMessages.length,
                            itemBuilder: (context, index) {
                              final message = userMessages[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xFFF8E1E9),
                                    foregroundColor: Color(0xFFF06292),
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(
                                    message.sender,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF06292),
                                    ),
                                  ),
                                  subtitle: Text(
                                    message.content,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  trailing: Text(
                                    message.time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFF06292),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Input Field
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tin nhắn...',
                                    prefixIcon: Icon(
                                      Icons.message,
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
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Color(0xFFF06292),
                                ),
                                onPressed: _sendUserMessage,
                                style: IconButton.styleFrom(
                                  backgroundColor: Color(0xFFF8E1E9),
                                  padding: EdgeInsets.all(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Gemini AI Tab
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: botMessages.length,
                            itemBuilder: (context, index) {
                              final message = botMessages[index];
                              final isUserMessage =
                                  message.sender == widget.userEmail;
                              return Align(
                                alignment:
                                    isUserMessage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                        0.75,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isUserMessage
                                            ? Color(0xFFF8E1E9)
                                            : Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        isUserMessage
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!isUserMessage)
                                            Icon(
                                              Icons.smart_toy,
                                              color: Color(0xFFF06292),
                                              size: 16,
                                            ),
                                          if (isUserMessage)
                                            Icon(
                                              Icons.person,
                                              color: Color(0xFFF06292),
                                              size: 16,
                                            ),
                                          SizedBox(width: 4),
                                          Text(
                                            message.sender,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF06292),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        message.content,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: null,
                                        overflow: TextOverflow.visible,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        message.time,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Input and Upload
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: botMessageController,
                                      decoration: InputDecoration(
                                        hintText: 'Nhập công việc mong muốn...',
                                        prefixIcon: Icon(
                                          Icons.work,
                                          color: Color(0xFFF06292),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: Color(0xFFF06292),
                                    ),
                                    onPressed: _sendBotMessage,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Color(0xFFF8E1E9),
                                      padding: EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _uploadCVAndAnalyze,
                                icon: Icon(
                                  Icons.upload_file,
                                  color: Color(0xFFF06292),
                                ),
                                label: Text(
                                  'Upload CV để phân tích',
                                  style: TextStyle(
                                    color: Color(0xFFF06292),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF8E1E9),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
