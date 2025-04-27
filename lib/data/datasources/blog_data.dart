import 'package:tms_app/domain/entities/blog.dart';

class BlogDataSource {
  // Singleton pattern
  static final BlogDataSource _instance = BlogDataSource._internal();

  factory BlogDataSource() {
    return _instance;
  }

  BlogDataSource._internal();

  // Mock data cho blog
  final List<Blog> blogs = [
    Blog(
      id: 1,
      title: 'Flutter 3.10: Những tính năng mới đáng chú ý',
      summary:
          'Khám phá những tính năng mới và cải tiến trong Flutter 3.10 giúp tăng hiệu suất phát triển ứng dụng.',
      content: 'Nội dung chi tiết về Flutter 3.10...',
      imageUrl: 'https://miro.medium.com/max/1200/1*7lHaqe7CaS3RuduK9Nm4Ew.png',
      author: 'Nguyễn Văn A',
      authorAvatar: 'https://i.pravatar.cc/150?img=1',
      category: 'Lập trình',
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      readTime: 5,
      views: 1240,
      tags: ['Flutter', 'Mobile', 'Development'],
    ),
    Blog(
      id: 2,
      title: 'ChatGPT và tương lai của trí tuệ nhân tạo',
      summary:
          'Phân tích về tác động của ChatGPT và các mô hình ngôn ngữ lớn đến tương lai của AI và xã hội.',
      content: 'Nội dung chi tiết về ChatGPT...',
      imageUrl:
          'https://www.zdnet.com/a/img/resize/ba1914db6f0ea283c7b2c2f3a899b09c31bfe70f/2023/03/15/e0434656-6d6e-474e-b522-94eff131dbae/chatgpt.jpg?auto=webp&fit=crop&height=900&width=1200',
      author: 'Trần Thị B',
      authorAvatar: 'https://i.pravatar.cc/150?img=2',
      category: 'Trí tuệ nhân tạo',
      publishDate: DateTime.now().subtract(const Duration(days: 4)),
      readTime: 8,
      views: 2150,
      tags: ['AI', 'ChatGPT', 'Machine Learning'],
    ),
    Blog(
      id: 3,
      title: 'Blockchain và ứng dụng trong giáo dục',
      summary:
          'Tìm hiểu cách công nghệ blockchain có thể cách mạng hóa ngành giáo dục thông qua xác minh bằng cấp và học liệu.',
      content: 'Nội dung chi tiết về Blockchain trong giáo dục...',
      imageUrl:
          'https://blog.iprocessum.com/wp-content/uploads/2020/04/image5.jpg',
      author: 'Lê Văn C',
      authorAvatar: 'https://i.pravatar.cc/150?img=3',
      category: 'Blockchain',
      publishDate: DateTime.now().subtract(const Duration(days: 7)),
      readTime: 6,
      views: 980,
      tags: ['Blockchain', 'Education', 'Technology'],
    ),
    Blog(
      id: 4,
      title: 'Xu hướng phát triển IoT năm 2023',
      summary:
          'Phân tích các xu hướng nổi bật trong lĩnh vực Internet of Things (IoT) trong năm 2023.',
      content: 'Nội dung chi tiết về xu hướng IoT...',
      imageUrl:
          'https://www.simplilearn.com/ice9/free_resources_article_thumb/iot-explained-what-it-is-how-it-works-and-its-applications-banner.jpg',
      author: 'Phạm Thị D',
      authorAvatar: 'https://i.pravatar.cc/150?img=4',
      category: 'IoT',
      publishDate: DateTime.now().subtract(const Duration(days: 10)),
      readTime: 7,
      views: 1560,
      tags: ['IoT', 'Smart Devices', 'Technology'],
    ),
    Blog(
      id: 5,
      title: '5 ngôn ngữ lập trình đáng học năm 2023',
      summary:
          'Tổng hợp 5 ngôn ngữ lập trình được nhiều nhà tuyển dụng tìm kiếm nhất trong năm 2023.',
      content: 'Nội dung chi tiết về ngôn ngữ lập trình...',
      imageUrl:
          'https://www.freecodecamp.org/news/content/images/2022/12/main-image.png',
      author: 'Hoàng Văn E',
      authorAvatar: 'https://i.pravatar.cc/150?img=5',
      category: 'Lập trình',
      publishDate: DateTime.now().subtract(const Duration(days: 12)),
      readTime: 9,
      views: 3200,
      tags: ['Programming', 'Career', 'Development'],
    ),
    Blog(
      id: 6,
      title: 'Ứng dụng AI trong chăm sóc sức khỏe',
      summary:
          'Khám phá cách trí tuệ nhân tạo đang thay đổi ngành y tế và chăm sóc sức khỏe.',
      content: 'Nội dung chi tiết về AI trong y tế...',
      imageUrl:
          'https://images.healthshots.com/healthshots/en/uploads/2023/01/05125025/AI-healthcare.jpg',
      author: 'Nguyễn Thị F',
      authorAvatar: 'https://i.pravatar.cc/150?img=6',
      category: 'Trí tuệ nhân tạo',
      publishDate: DateTime.now().subtract(const Duration(days: 15)),
      readTime: 10,
      views: 1890,
      tags: ['AI', 'Healthcare', 'Medical'],
    ),
  ];

  // Lấy danh sách tất cả blog
  List<Blog> getAllBlogs() {
    return blogs;
  }

  // Lấy blog theo category
  List<Blog> getBlogsByCategory(String category) {
    if (category == 'Tất cả') {
      return blogs;
    }
    return blogs.where((blog) => blog.category == category).toList();
  }

  // Lấy blog theo id
  Blog? getBlogById(int id) {
    try {
      return blogs.firstWhere((blog) => blog.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy blog mới nhất (featured)
  Blog getFeaturedBlog() {
    // Sắp xếp theo ngày xuất bản và lấy blog mới nhất
    final sortedBlogs = List<Blog>.from(blogs)
      ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return sortedBlogs.first;
  }

  // Lấy các blog phổ biến nhất (theo lượt xem)
  List<Blog> getPopularBlogs({int limit = 5}) {
    final sortedBlogs = List<Blog>.from(blogs)
      ..sort((a, b) => b.views.compareTo(a.views));
    return sortedBlogs.take(limit).toList();
  }

  // Lấy các danh mục blog
  List<String> getCategories() {
    final categories = blogs.map((blog) => blog.category).toSet().toList();
    return ['Tất cả', ...categories];
  }
}
