class Application {
  final String id;
  final String jobId;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String message;
  final String? cvPath;
  final String status;
  final DateTime createdAt;
  final String jobTitle;
  final String salary;

  Application({
    required this.id,
    required this.jobId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.message,
    this.cvPath,
    required this.status,
    required this.createdAt,
    this.jobTitle = '',
    this.salary = '',
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['_id'] as String,
      jobId: json['jobId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      message: json['message'] as String,
      cvPath: json['cvPath'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      jobTitle: json['jobTitle'] as String? ?? '',
      salary: json['salary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'jobId': jobId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'country': country,
      'message': message,
      'cvPath': cvPath,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'jobTitle': jobTitle,
      'salary': salary,
    };
  }
}
