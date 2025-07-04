import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/widgets/course/combo_course.dart';
import 'package:tms_app/presentation/widgets/navbar/bottom_navbar_widget.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';

class ComboCourseListScreen extends StatefulWidget {
  final CourseController? controller;

  const ComboCourseListScreen({this.controller, Key? key}) : super(key: key);

  @override
  State<ComboCourseListScreen> createState() => _ComboCourseListScreenState();
}

class _ComboCourseListScreenState extends State<ComboCourseListScreen> {
  late final CourseController _controller;
  final _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  bool _isLoading = true;
  List<CourseCardModel> _comboCourses = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? _getControllerInstance();
    _loadComboCourses();
  }

  CourseController _getControllerInstance() {
    try {
      return GetIt.instance<CourseController>();
    } catch (e) {
      print('Không thể lấy CourseController từ GetIt: $e');

      // Fallback: tạo một instance mới với dependencies
      try {
        final courseUseCase = GetIt.instance<CourseUseCase>();
        CategoryUseCase? categoryUseCase;
        try {
          categoryUseCase = GetIt.instance<CategoryUseCase>();
        } catch (e) {
          print('Không thể lấy CategoryUseCase: $e');
        }

        final controller =
            CourseController(courseUseCase, categoryUseCase: categoryUseCase);

        // Thử đăng ký controller vào GetIt
        try {
          if (!GetIt.instance.isRegistered<CourseController>()) {
            GetIt.instance.registerSingleton<CourseController>(controller);
            print('Đã đăng ký CourseController vào GetIt');
          }
        } catch (e) {
          print('Không thể đăng ký CourseController: $e');
        }

        return controller;
      } catch (e) {
        print('Lỗi khi tạo CourseController: $e');
        throw Exception('Không thể tạo CourseController');
      }
    }
  }

  Future<void> _loadComboCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the controller to load combo courses
      await _controller.loadComboCourses();

      // Get the data directly from controller
      final courses = _controller.comboCourses.value;
      print('Controller comboCourses: ${courses.length}');

      for (int i = 0; i < courses.length && i < 2; i++) {
        print(
            'Combo $i: ${courses[i].title}, id=${courses[i].id}, price=${courses[i].price}, cost=${courses[i].cost}');
      }

      // Tạo bản sao mới để đảm bảo cập nhật giao diện
      _comboCourses = List<CourseCardModel>.from(courses);

      // Debug
      print('Combo trên màn hình: ${_comboCourses.length}');

      if (_comboCourses.isNotEmpty) {
        print(
            'Combo đầu tiên: ${_comboCourses[0].title}, price: ${_comboCourses[0].price}, cost: ${_comboCourses[0].cost}');
      }

      // Force UI refresh
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Lỗi khi tải danh sách combo khóa học: $e');
      _comboCourses = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Manual mapping của combo course JSON trả về từ API sang CourseCardModel
  List<CourseCardModel> _mapComboCourses(List<dynamic> comboJson) {
    try {
      return comboJson.map((combo) {
        // Lấy dữ liệu cơ bản
        double price = combo['price'] != null
            ? double.parse(combo['price'].toString())
            : 0.0;
        double cost = combo['cost'] != null
            ? double.parse(combo['cost'].toString())
            : price;
        int discount = combo['discount'] ?? 0;

        return CourseCardModel(
          id: combo['id'] ?? 0,
          title: combo['name'] ?? '',
          description: combo['description'] ?? '',
          imageUrl: combo['imageUrl'] ?? '',
          price: price,
          cost: cost,
          discountPercent: discount,
          author: '',
          courseOutput: combo['description'] ?? '',
          duration: 0,
          language: 'Vietnamese',
          status: true,
          type: 'COMBO',
          categoryName: '',
        );
      }).toList();
    } catch (e) {
      print('Lỗi khi chuyển đổi dữ liệu combo: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    print(
        'Build ComboCourseListScreen - isLoading: $_isLoading, Courses: ${_comboCourses.length}');

    // Print the first course data if available
    if (_comboCourses.isNotEmpty) {
      print(
          'First course: ${_comboCourses.first.title} - ${_comboCourses.first.price}');
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Combo Khóa Học',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.lightBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadComboCourses,
              child: _comboCourses.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : _buildComboCourseList(_comboCourses, isDarkMode),
            ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Combo Khóa Học',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Flexible(
                  child: Text(
                    'Tiết kiệm chi phí và học nhiều hơn với các combo khóa học từ TMS Learn Tech',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        color: Colors.amber.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tiết kiệm đến 30%',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboCard(BuildContext context,
      {required CourseCardModel course, required bool isDarkMode}) {
    // Tính toán phần trăm giảm giá thực tế
    int discountPercent = course.discountPercent;
    if (course.cost > course.price && discountPercent == 0) {
      discountPercent =
          ((course.cost - course.price) / course.cost * 100).round();
    }

    // Debug - hiển thị thông tin giá
    print(
        'Card ${course.title}: price=${course.price}, cost=${course.cost}, discount=${discountPercent}%');

    return GestureDetector(
      onTap: () {
        // Navigate to combo course detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComboCourseScreen(comboId: course.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2A2D3E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Course image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    course.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: isDarkMode ? Colors.grey[600] : Colors.grey),
                      ),
                    ),
                  ),
                  if (discountPercent > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Giảm ${discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Course details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Giá đã giảm
                            Text(
                              _currencyFormat.format(course.price),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Giá gốc
                            if (course.cost > course.price)
                              Text(
                                _currencyFormat.format(course.cost),
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.lineThrough,
                                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to combo course detail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ComboCourseScreen(comboId: course.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Tìm kiếm combo khóa học',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Nhập tên combo khóa học...',
            hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchComboCourses(value);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy', style: TextStyle(color: Colors.lightBlue)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _searchComboCourses(controller.text);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }

  // Local search implementation
  void _searchComboCourses(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use controller to search or do local filtering
      await _controller.searchComboCourses(query);

      // Update local list
      setState(() {
        _comboCourses = List.from(_controller.comboCourses.value);
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tìm kiếm combo khóa học: $e');

      // Do local search as fallback
      if (_controller.comboCourses.value.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        _comboCourses = _controller.comboCourses.value.where((course) {
          return course.title.toLowerCase().contains(lowerQuery) ||
              course.description.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Text(
        'Không có combo khóa học nào!',
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildComboCourseList(List<CourseCardModel> courses, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: false,
      children: [
        _buildBanner(),
        const SizedBox(height: 20),

        // Title section
        Text(
          'Combo khóa học nổi bật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),

        // Combo courses list
        ...courses
            .map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildComboCard(
                    context,
                    course: course,
                    isDarkMode: isDarkMode,
                  ),
                ))
            .toList(),
      ],
    );
  }
}
