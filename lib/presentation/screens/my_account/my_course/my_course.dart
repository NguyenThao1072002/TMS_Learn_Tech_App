import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({Key? key}) : super(key: key);

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  int _totalPages = 5;
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = [
    'Tất cả',
    'Mới nhất',
    'Phổ biến',
    'Đánh giá cao'
  ];

  // Sample course data
  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Lập trình C',
      'image': 'assets/images/c_programming.jpg',
      'progress': 0.0,
      'timeLeft': '6 giờ còn lại',
      'lastViewed': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'title': 'Lập trình Python',
      'image': 'assets/images/python_programming.jpg',
      'progress': 0.3,
      'timeLeft': '4 giờ còn lại',
      'lastViewed': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'title': 'Lập trình Java',
      'image': 'assets/images/java_programming.jpg',
      'progress': 0.7,
      'timeLeft': '2 giờ còn lại',
      'lastViewed': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'title': 'Flutter Development',
      'image': 'assets/images/flutter_dev.jpg',
      'progress': 0.5,
      'timeLeft': '5 giờ còn lại',
      'lastViewed': DateTime.now().subtract(const Duration(hours: 5)),
    },
  ];

  // Filtered courses based on search and filters
  List<Map<String, dynamic>> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch = course['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  // Recent courses (last viewed)
  List<Map<String, dynamic>> get _recentCourses {
    final sortedCourses = List<Map<String, dynamic>>.from(_courses);
    sortedCourses.sort((a, b) =>
        (a['lastViewed'] as DateTime).compareTo(b['lastViewed'] as DateTime));
    return sortedCourses.reversed.take(2).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentPage = 1; // Reset page when changing tabs
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Khóa học của tôi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: const [
              Tab(
                icon: Icon(Icons.library_books),
                text: 'Đã đăng ký',
              ),
              Tab(
                icon: Icon(Icons.play_circle_outline),
                text: 'Đang học',
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline),
                text: 'Hoàn thành',
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm khóa học...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Filter dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      icon: const Icon(Icons.filter_list),
                      items: _filters.map((String filter) {
                        return DropdownMenuItem<String>(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(_filteredCourses),
                _buildCoursesTab(_filteredCourses
                    .where((course) =>
                        course['progress'] > 0 && course['progress'] < 1.0)
                    .toList()),
                _buildCoursesTab(_filteredCourses
                    .where((course) => course['progress'] == 1.0)
                    .toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show recommendations or featured courses
          _showRecommendedCourses();
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.lightbulb_outline),
      ),
    );
  }

  Widget _buildCoursesTab(List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có khóa học nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Kiểm tra nếu đang ở tab đầu tiên (Đã đăng ký) để hiển thị phần đã xem gần đây
    if (_tabController.index == 0 && _recentCourses.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần đã xem gần đây
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đã xem gần đây',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Xử lý khi nhấn xem tất cả
                  },
                  icon:
                      const Icon(Icons.history, size: 16, color: Colors.orange),
                  label: const Text(
                    'Xem tất cả',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          // Danh sách khóa học đã xem gần đây
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recentCourses.length,
              itemBuilder: (context, index) {
                final course = _recentCourses[index];
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _navigateToCourseDetail(course),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hình ảnh khóa học
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.asset(
                            course['image'],
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 80,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text(
                                    course['title'][0],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Thông tin khóa học
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: course['progress'],
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(),
          ),
          // Tất cả khóa học
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tất cả khóa học',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          // Danh sách tất cả khóa học
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _buildCourseListItem(course);
              },
            ),
          ),
        ],
      );
    }

    // Các tab khác chỉ hiển thị danh sách khóa học
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseListItem(course);
      },
    );
  }

  // Widget hiển thị một khóa học trong danh sách
  Widget _buildCourseListItem(Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _navigateToCourseDetail(course);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Course image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  course['image'],
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 80,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          course['title'][0],
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course['timeLeft'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 20.0,
                          lineWidth: 4.0,
                          percent: course['progress'],
                          center: Text(
                            '${(course['progress'] * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progressColor: Colors.orange,
                          backgroundColor: Colors.grey[300]!,
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

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      // Here you would typically load new data based on the page
    });
  }

  void _navigateToCourseDetail(Map<String, dynamic> course) {
    // Navigate to course detail
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                course['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  course['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          course['title'][0],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: course['progress'],
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ: ${(course['progress'] * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    course['timeLeft'],
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Continue learning
                  _showContinueLearningOptions(course);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Vào học',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Thông tin khóa học',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Khóa học này sẽ giúp bạn nắm vững các kiến thức cơ bản và nâng cao về lập trình, thực hành với nhiều bài tập thực tế và dự án nhỏ để áp dụng kiến thức đã học.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContinueLearningOptions(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiếp tục học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.play_circle_filled, color: Colors.orange),
              title: const Text('Bài học tiếp theo'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to next lesson
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Tài liệu học tập'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to course materials
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.green),
              title: const Text('Bài tập thực hành'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to practice exercises
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showRecommendedCourses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Khóa học được đề xuất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecommendCourseCard(
                    'Lập trình Web',
                    'Học HTML, CSS, JavaScript và các framework hiện đại',
                    Colors.blue,
                  ),
                  _buildRecommendCourseCard(
                    'Machine Learning cơ bản',
                    'Giới thiệu về học máy và trí tuệ nhân tạo',
                    Colors.green,
                  ),
                  _buildRecommendCourseCard(
                    'Khoa học dữ liệu',
                    'Phân tích và trực quan hóa dữ liệu với Python',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendCourseCard(
      String title, String description, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Show course details or enrollment options
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Xem chi tiết'),
            ),
          ),
        ],
      ),
    );
  }
}
