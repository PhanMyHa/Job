class Message {
  final String sender;
  final String content;
  final String time;

  Message({required this.sender, required this.content, required this.time});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      content: json['content'],
      time: DateTime.parse(json['timestamp']).toString().substring(11, 16),
    );
  }
}
