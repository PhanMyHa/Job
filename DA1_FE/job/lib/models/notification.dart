class Notification {
  final String title;
  final String message;
  final String time;

  Notification({
    required this.title,
    required this.message,
    required this.time,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      title: json['title'],
      message: json['message'],
      time: DateTime.parse(json['createdAt']).toString().substring(11, 16),
    );
  }
}
