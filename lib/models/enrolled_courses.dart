class Enrolled_courses {
  final int? id;
  final DateTime? enrollment_date;
  final String? status;
  final int? account_id;
  final int? course_id;

  Enrolled_courses({
    this.id,
    this.enrollment_date,
    this.status,
    this.account_id,
    this.course_id,
  });

  factory Enrolled_courses.fromJson(Map<String, dynamic> json) {
    return Enrolled_courses(
      id: json['id'],
      enrollment_date: json['enrollment_date'],
      status: json['status'],
      account_id: json['account_id'],
      course_id: json['course_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollment_date': enrollment_date,
      'status': status,
      'account_id': account_id,
      'course_id': course_id,
    };
  }
}
