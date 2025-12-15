class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String time;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      time: DateTime.parse(
        json['createdAt'] as String,
      ).toString().substring(11, 16),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
