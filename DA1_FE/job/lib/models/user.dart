class User {
  final String email;
  final String name;
  final String password;
  final bool receiveNotifications;
  final List<Education> education;
  final List<String> skills;
  final List<Experience> experience;
  final String? avatar;

  User({
    required this.email,
    required this.name,
    required this.password,
    this.receiveNotifications = true,
    this.education = const [],
    this.skills = const [],
    this.experience = const [],
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      receiveNotifications: json['receiveNotifications'] as bool? ?? true,
      education:
          (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      experience:
          (json['experience'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'receiveNotifications': receiveNotifications,
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'avatar': avatar,
    };
  }
}

class Education {
  final String degree;
  final String school;
  final int startYear;
  final int? endYear;

  Education({
    required this.degree,
    required this.school,
    required this.startYear,
    this.endYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'] as String,
      school: json['school'] as String,
      startYear: json['startYear'] as int,
      endYear: json['endYear'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'school': school,
      'startYear': startYear,
      'endYear': endYear,
    };
  }
}

class Experience {
  final String position;
  final String company;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  Experience({
    required this.position,
    required this.company,
    required this.startDate,
    this.endDate,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      position: json['position'] as String,
      company: json['company'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] != null
              ? DateTime.parse(json['endDate'] as String)
              : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'company': company,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
    };
  }
}
