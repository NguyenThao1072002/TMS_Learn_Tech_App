import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/widgets/course/my_course.dart';

class MyCoursesTabbedScreen extends StatefulWidget {
  const MyCoursesTabbedScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesTabbedScreen> createState() => _MyCoursesTabbedScreenState();
}

class _MyCoursesTabbedScreenState extends State<MyCoursesTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CourseController _courseController;

  final CourseUseCase _courseUseCase = GetIt.instance<CourseUseCase>();
  List<CourseCardModel> _allCourses = [];
  List<CourseCardModel> _inProgressCourses = [];
  List<CourseCardModel> _completedCourses = [];

  // For search & filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  List<String> _categories = [
    'Tất cả',
    'Công nghệ',
    'Kinh doanh',
    'Thiết kế',
    'Marketing',
    'Khác',
  ];
  bool _isFilterVisible = false;

  bool _isLoading = true;
  int _currentPage = 1;
  final int _coursesPerPage = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _courseController = CourseController(_courseUseCase);
    _loadMyCourses();

    // Listen to tab changes
    _tabController.addListener(_handleTabSelection);

    // Listen to search queries
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _currentPage = 1; // Reset to first page when search changes
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentPage = 1; // Reset pagination when switching tabs
      });
    }
  }

  Future<void> _loadMyCourses() async {
    setState(() {
      _isLoading = true;
    });

    await _courseController.loadCourses();

    // For demo purposes, let's simulate different course statuses
    final allCourses = _courseController.filteredCourses.value;

    setState(() {
      _allCourses = allCourses;

      // Demo: Divide courses into in-progress and completed
      // In a real app, you would use actual course status data
      _inProgressCourses = allCourses.take(allCourses.length ~/ 2).toList();
      _completedCourses = allCourses.skip(allCourses.length ~/ 2).toList();

      _isLoading = false;
    });
  }

  List<CourseCardModel> _getCurrentTabCourses() {
    // First get the current tab's courses
    List<CourseCardModel> courses;
    switch (_tabController.index) {
      case 0:
        courses = _allCourses;
        break;
      case 1:
        courses = _inProgressCourses;
        break;
      case 2:
        courses = _completedCourses;
        break;
      default:
        courses = _allCourses;
    }

    // Then apply search filter if any
    if (_searchQuery.isNotEmpty) {
      courses = courses
          .where(
            (course) =>
                course.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                course.author.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    // Apply category filter if not 'All'
    if (_selectedCategory != 'Tất cả') {
      courses = courses
          .where((course) => course.categoryName == _selectedCategory)
          .toList();
    }

    return courses;
  }

  int get _totalPages {
    final courses = _getCurrentTabCourses();
    return (courses.length / _coursesPerPage).ceil();
  }

  List<CourseCardModel> get _paginatedCourses {
    final courses = _getCurrentTabCourses();
    final startIndex = (_currentPage - 1) * _coursesPerPage;

    if (startIndex >= courses.length) {
      return [];
    }

    final endIndex = (startIndex + _coursesPerPage < courses.length)
        ? startIndex + _coursesPerPage
        : courses.length;

    return courses.sublist(startIndex, endIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _searchController.removeListener(_onSearchChanged);
    _tabController.dispose();
    _courseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Khóa học của tôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFilterVisible ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.orange,
            ),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _loadMyCourses,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isFilterVisible ? 140 : 48),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.orange,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Đang học'),
                    Tab(text: 'Hoàn thành'),
                  ],
                ),
              ),
              if (_isFilterVisible) _buildFilterSection(),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCoursesTab(_allCourses),
                      _buildCoursesTab(_inProgressCourses),
                      _buildCoursesTab(_completedCourses),
                    ],
                  ),
                ),
                if (_totalPages > 1) _buildPagination(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          // Navigate to course catalog/store
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chuyển đến danh mục khóa học'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm khóa học...',
              prefixIcon: const Icon(Icons.search, color: Colors.orange),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 8),

          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _currentPage = 1; // Reset to first page
                      });
                    },
                    selectedColor: Colors.orange.withOpacity(0.2),
                    checkmarkColor: Colors.orange,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.orange : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab(List<CourseCardModel> courses) {
    final filteredCourses = _getCurrentTabCourses();

    if (filteredCourses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: Colors.orange,
      onRefresh: _loadMyCourses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paginatedCourses.length,
        itemBuilder: (context, index) {
          final course = _paginatedCourses[index];
          return _buildCourseCard(course, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có khóa học',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Khám phá danh mục khóa học ngay bây giờ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to course catalog
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm khóa học'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseCardModel course, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to course details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chọn: ${course.title}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course thumbnail with progress overlay
                Stack(
                  children: [
                    Image.network(
                      course.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        color: Colors.grey.withOpacity(0.3),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _tabController.index == 2
                              ? 1.0
                              : (index % 3 == 0
                                  ? 0.3
                                  : index % 3 == 1
                                      ? 0.6
                                      : 0.8), // Demo varying progress
                          child: Container(color: Colors.orange),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.duration} giờ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index % 4 == 0) // Demo some courses are new
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'MỚI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course title
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Instructor and category
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.author,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tabController.index == 2
                                ? 'Hoàn thành'
                                : 'Tiến độ: ${(index % 3 == 0 ? 30 : index % 3 == 1 ? 60 : 80)}%', // Demo varying progress
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _tabController.index == 2
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.averageRating}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/5',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            color: _currentPage > 1 ? Colors.orange : Colors.grey,
          ),
          Text(
            'Trang $_currentPage / $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            color: _currentPage < _totalPages ? Colors.orange : Colors.grey,
          ),
        ],
      ),
    );
  }
}
