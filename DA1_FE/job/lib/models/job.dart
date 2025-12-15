class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String jobType;
  final String salary;
  final DateTime createdAt;
  final List<String> requiredSkills;
  final List<String> qualifications;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.createdAt,
    this.requiredSkills = const [],
    this.qualifications = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      jobType: json['jobType'],
      salary: json['salary'],
      createdAt: DateTime.parse(json['createdAt']),
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)?.cast<String>() ?? [],
      qualifications: (json['qualifications'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}