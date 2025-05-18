class CourseBundle {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final dynamic cost;
  final List<BundledCourse> courses;
  final int? discount;

  CourseBundle({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.cost,
    required this.courses,
    this.discount,
  });

  factory CourseBundle.fromJson(Map<String, dynamic> json) {
    List<BundledCourse> courseList = [];
    if (json['courses'] != null) {
      courseList = (json['courses'] as List)
          .map((course) => BundledCourse.fromJson(course))
          .toList();
    }

    return CourseBundle(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      imageUrl: json['imageUrl'],
      cost: json['cost'],
      courses: courseList,
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'cost': cost,
      'courses': courses.map((course) => course.toJson()).toList(),
      'discount': discount,
    };
  }
}

class BundledCourse {
  final int id;
  final String title;
  final String? imageUrl;
  final double price;
  final String author;

  BundledCourse({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    required this.author,
  });

  factory BundledCourse.fromJson(Map<String, dynamic> json) {
    return BundledCourse(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'author': author,
    };
  }
} 