import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/data/models/teaching_staff/teaching_staff_model.dart';
import 'package:tms_app/data/models/teaching_staff/course_of_teaching_staff_model.dart';
import 'package:tms_app/presentation/controller/teaching_staff_controller.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/domain/usecases/teaching_staff/teaching_staff_usecase.dart';
import 'package:tms_app/presentation/widgets/course/course_card.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';

class TeachingStaffScreen extends StatefulWidget {
  final int? staffIdToShow;

  const TeachingStaffScreen({
    Key? key,
    this.staffIdToShow,
  }) : super(key: key);

  @override
  State<TeachingStaffScreen> createState() => _TeachingStaffScreenState();
}

class _TeachingStaffScreenState extends State<TeachingStaffScreen> {
  late TeachingStaffController _controller;
  final TextEditingController _searchController = TextEditingController();

  // Danh sách các danh mục
  List<Map<String, dynamic>> _categories = [
    {'id': null, 'name': 'Tất cả'},
  ];
  dynamic _selectedCategoryId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy controller từ Provider
    _controller = Provider.of<TeachingStaffController>(context);

    // Đảm bảo chỉ gọi loadData một lần sau khi widget đã hoàn toàn khởi tạo
    if (!_initialized) {
      _loadData();
      _initialized = true;
      
      // If a specific staff ID was provided, show their details after loading
      if (widget.staffIdToShow != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSpecificStaffDetails(widget.staffIdToShow!);
        });
      }
    }
  }

  void _loadData() async {
    try {
      // Lấy danh sách giảng viên
      await _controller.getTeachingStaffs(refresh: true);

      // Cập nhật UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Lỗi đã được xử lý trong controller
      print('Lỗi khi tải dữ liệu giảng viên: $e');
    }
  }

  void _onSearchChanged() {
    _controller.setSearchKeyword(_searchController.text);
  }

  void _selectCategory(dynamic categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _controller.filterByCategory(categoryId);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem thiết bị đang sử dụng chế độ tối hay không
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Đội ngũ giảng viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              // Show information about instructors
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Image
          Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                // Banner Image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3498DB),
                        const Color(0xFF3498DB).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Image.network(
                    'https://ik.imagekit.io/kbxte3uo1/teaching_staff_banner.jpg?updatedAt=1746243177185',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups,
                              size: 48,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Overlay with text
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Text content
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Đội ngũ chuyên gia hàng đầu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Giảng dạy bởi những người giỏi nhất trong lĩnh vực',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giảng viên...',
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final bool isSelected = category['id'] == _selectedCategoryId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      category['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : isDarkMode ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3498DB),
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                    onSelected: (_) => _selectCategory(category['id']),
                  ),
                );
              },
            ),
          ),

          // Instructors Grid - với trạng thái loading và error handling
          Expanded(
            child: _buildTeachingStaffGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Find instructor functionality
          _showSuggestInstructorDialog();
        },
        backgroundColor: const Color(0xFF3498DB),
        child: const Icon(Icons.lightbulb_outline),
        tooltip: 'Gợi ý giảng viên',
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildTeachingStaffGrid() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_controller.isLoading && _controller.teachingStaffs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null && _controller.teachingStaffs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Không thể tải dữ liệu: ${_controller.error}',
              style: AppStyles.errorText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_controller.teachingStaffs.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy giảng viên phù hợp',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _controller.getTeachingStaffs(refresh: true);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !_controller.isLoading &&
              _controller.hasMoreData) {
            _controller.getTeachingStaffs();
            return true;
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _controller.teachingStaffs.length +
              (_controller.hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _controller.teachingStaffs.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final staff = _controller.teachingStaffs[index];
            return _buildInstructorCard(staff);
          },
        ),
      ),
    );
  }

  Widget _buildInstructorCard(TeachingStaff staff) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => _showInstructorDetails(staff),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2A2D3E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: isDarkMode ? 2 : 1,
              blurRadius: isDarkMode ? 8 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructor image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.2),
                      const Color(0xFF3498DB).withOpacity(0.05),
                    ],
                  ),
                ),
                child: Image.network(
                  staff.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Instructor info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      staff.fullname,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      staff.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              staff.averageRating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.library_books_outlined,
                              color: Color(0xFF3498DB),
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${staff.courseCount} khóa',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructorDetails(TeachingStaff staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInstructorDetailsSheet(staff),
    );
  }

  Widget _buildInstructorDetailsSheet(TeachingStaff staff) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Header with instructor image & name
              Stack(
                children: [
                  // Background gradient
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3498DB),
                          const Color(0xFF3498DB).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),

                  // Profile content
                  Column(
                    children: [
                      // Handle bar for dragging
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            staff.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Instructor name & role
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              staff.fullname,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              staff.categoryName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.library_books_outlined,
                      label: 'Khóa học',
                      value: staff.courseCount.toString(),
                    ),
                    _buildStatItem(
                      icon: Icons.people_outline,
                      label: 'Học viên',
                      value: staff.totalStudents.toString(),
                    ),
                    _buildStatItem(
                      icon: Icons.star_outline,
                      label: 'Đánh giá',
                      value: staff.averageRating.toString(),
                    ),
                  ],
                ),
              ),

              Divider(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              ),

              // Bio/Instruction
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      staff.instruction,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Expertise
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chuyên môn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      staff.expert,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // View courses button
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {
                    // Hiển thị khóa học của giảng viên
                    _showTeachingStaffCourses(staff);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3498DB)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Xem khóa học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // Hiển thị danh sách khóa học của giảng viên
  void _showTeachingStaffCourses(TeachingStaff staff) {
    Navigator.pop(context); // Đóng bottom sheet chi tiết giảng viên

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTeachingStaffCoursesSheet(staff),
    );
  }

  Widget _buildTeachingStaffCoursesSheet(TeachingStaff staff) {
    // Lấy accountId từ đối tượng staff
    final int accountId = staff.accountId;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF3498DB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar for dragging
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(staff.avatarUrl),
                          onBackgroundImageError: (exception, stackTrace) =>
                              const Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khóa học của ${staff.fullname}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                staff.categoryName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Courses list
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future:
                      GetIt.I<TeachingStaffUseCase>().getCoursesOfTeachingStaff(
                    accountId: accountId, // Sử dụng accountId thay vì id
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không thể tải dữ liệu: ${snapshot.error}',
                              style: AppStyles.errorText,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showInstructorDetails(staff);
                              },
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    final List<CourseOfTeachingStaffModel> courses =
                        data['courses'];

                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Giảng viên chưa có khóa học nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        // Chuyển đổi CourseOfTeachingStaffModel sang CourseCardModel
                        final courseCardModel = CourseCardModel(
                          id: course.id,
                          title: course.title,
                          imageUrl: course.imageUrl,
                          categoryName: course.categoryName,
                          totalLessons: course.lessonCount,
                          numberOfStudents: course.studentCount,
                          averageRating: course.rating,
                          cost: course.cost,
                          price: course.price,
                          discountPercent: course.percentDiscount,
                          author: course.author,
                          language: course.language,
                          description: course.courseOutput,
                          duration: course.duration,
                          courseOutput: course.courseOutput,
                          status: course.status,
                          type: course.type,
                        );

                        return CourseCard(
                          course: courseCardModel,
                          selectedIndex: null,
                          onTap: (course) {
                            // Xử lý khi bấm vào khóa học
                            Navigator.pop(context);
                            // TODO: Điều hướng đến trang chi tiết khóa học
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Đã chọn khóa học: ${course.title}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF3498DB),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Về đội ngũ giảng viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3498DB),
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đội ngũ giảng viên của TMS Learn Tech',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đội ngũ giảng viên của chúng tôi bao gồm các chuyên gia hàng đầu trong nhiều lĩnh vực công nghệ khác nhau. Tất cả giảng viên đều có kinh nghiệm thực tế phong phú và kỹ năng giảng dạy xuất sắc.',
                style: TextStyle(
                  height: 1.5,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Các giảng viên được tuyển chọn kỹ lưỡng và đào tạo bài bản để đảm bảo chất lượng giảng dạy tốt nhất cho học viên. Họ không chỉ là những người hướng dẫn mà còn là người cố vấn, sẵn sàng hỗ trợ học viên trong suốt quá trình học tập.',
                style: TextStyle(
                  height: 1.5,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(
                color: Color(0xFF3498DB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuggestInstructorDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Gợi ý giảng viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3498DB),
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chúng tôi có thể giúp bạn tìm giảng viên phù hợp với nhu cầu học tập của bạn.',
              style: TextStyle(
                height: 1.5,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập chủ đề bạn muốn học...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi yêu cầu tìm giảng viên'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
            ),
            child: const Text('Tìm giảng viên'),
          ),
        ],
      ),
    );
  }

  // Method to show details of a specific staff member
  void _showSpecificStaffDetails(int staffId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final staffDetail = await _controller.getTeachingStaffDetailById(staffId);
      
      // Dismiss loading indicator
      Navigator.pop(context);
      
      if (staffDetail != null && mounted) {
        // Find the staff in the loaded list or directly use staffDetail
        TeachingStaff? staffToShow;
        
        // Try to find in the list first
        final staffIndex = _controller.teachingStaffs.indexWhere((s) => s.id == staffId);
        if (staffIndex >= 0) {
          staffToShow = _controller.teachingStaffs[staffIndex];
        } else {
          // If not found in list, create TeachingStaff from detail
          staffToShow = TeachingStaff(
            id: staffDetail.id,
            accountId: staffDetail.accountId,
            fullname: staffDetail.fullname,
            avatarUrl: staffDetail.avatarUrl,
            courseCount: staffDetail.courseCount,
            averageRating: staffDetail.averageRating,
            instruction: staffDetail.instruction,
            expert: staffDetail.expert,
            totalStudents: staffDetail.totalStudents,
            categoryId: staffDetail.categoryId,
            categoryName: staffDetail.categoryName,
          );
        }
        
        // Show instructor details directly
        if (staffToShow != null) {
          _showInstructorDetails(staffToShow);
        }
      }
    } catch (e) {
      // Dismiss loading indicator if it's showing
      Navigator.of(context, rootNavigator: true).pop();
      print('Error loading staff details: $e');
    }
  }
}
