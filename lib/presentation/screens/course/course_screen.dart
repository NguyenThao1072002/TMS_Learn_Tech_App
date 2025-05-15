import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:tms_app/presentation/widgets/component/pagination.dart';
import 'package:tms_app/presentation/widgets/course/filter_course/category_filter_dialog.dart';
import 'package:tms_app/presentation/widgets/course/filter_course/discount_filter_dialog.dart';
import 'course_list.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/widgets/component/search/unified_search_delegate.dart';

class CourseScreen extends StatefulWidget {
  final String? initialFilter;
  final String? category;

  const CourseScreen({
    super.key,
    this.initialFilter,
    this.category,
  });

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  late final CourseController _controller;
  bool _isRefreshing = false;

  // Danh sách giảng viên đã chọn
  List<String> _selectedTeachers = [];
  List<String> _teachers = [];

  // Danh sách danh mục đã chọn
  List<int> _selectedCategoryIds = [];

  // Danh sách thông tin mức giảm giá
  final List<Map<String, dynamic>> _discountOptions = [
    {'label': '0% - 10%', 'value': '0-10%'},
    {'label': '10% - 30%', 'value': '10-30%'},
    {'label': '30% - 50%', 'value': '30-50%'},
    {'label': '50% - 70%', 'value': '50-70%'},
    {'label': 'Trên 70%', 'value': '70%+'},
  ];

  // Danh sách mức giảm giá đã chọn
  List<String> _selectedDiscountValues = [];

  // Animation controller for expand/collapse icon
  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  bool _isTopSectionExpanded = true;

  @override
  void initState() {
    super.initState();
    final courseUseCase = GetIt.instance<CourseUseCase>();
    final categoryUseCase = GetIt.instance<CategoryUseCase>();
    _controller =
        CourseController(courseUseCase, categoryUseCase: categoryUseCase);
    _controller.loadCourses();

    // Set initial filter if specified
    if (widget.initialFilter != null) {
      _controller.filterCourses(widget.initialFilter!);
    }

    // Extract teachers
    Future.delayed(Duration.zero, () {
      _extractTeachers();
    });

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns =
        Tween<double>(begin: 0.0, end: 0.5).animate(_animationController);

    // Set initial state of animation
    if (_isTopSectionExpanded) {
      _animationController.value = 0.0;
    } else {
      _animationController.value = 1.0;
    }
  }

  void _extractTeachers() {
    final courses = _controller.allCourses.value;
    if (courses.isNotEmpty) {
      final Set<String> teachers = {};
      for (var course in courses) {
        if (course.author.isNotEmpty) {
          teachers.add(course.author);
        }
      }
      setState(() {
        _teachers = ['Tất cả', ...teachers.toList()];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Hàm refresh danh sách khóa học
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _controller.loadCourses();
      _extractTeachers();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder(
        valueListenable: _controller.categories,
        builder: (context, categories, _) {
          return ValueListenableBuilder(
            valueListenable: _controller.selectedCategoryIds,
            builder: (context, selectedCategoryIds, _) {
              return CategoryFilterDialog(
                categories: categories,
                selectedCategoryIds: selectedCategoryIds,
                onApplyFilter: (selectedIds) {
                  _controller.filterByCategories(selectedIds);
                },
              );
            },
          );
        },
      ),
    );
  }

  // void _showDiscountFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => ValueListenableBuilder<Map<String, bool>>(
  //       valueListenable: _controller.discountRanges,
  //       builder: (context, discountRanges, _) {
  //         return DiscountFilterDialog(
  //           discountRanges: discountRanges,
  //           onUpdateRange: _controller.updateDiscountRange,
  //           onResetRanges: _controller.resetDiscountRanges,
  //         );
  //       },
  //     ),
  //   );
  // }

  void _showSearchDialog() {
    // Get the search controller from provider
    final searchController =
        Provider.of<UnifiedSearchController>(context, listen: false);

    showSearch(
      context: context,
      delegate: UnifiedSearchDelegate(
        searchType: SearchType.course,
        onSearch: (query, type) {
          searchController.search(query, type);
        },
        itemBuilder: (context, item, type) {
          // Hiển thị kết quả tìm kiếm khóa học
          return ListTile(
            title: Text(item.title ?? ''),
            subtitle: Text(item.author ?? ''),
            leading: item.imageUrl != null && item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 50),
                  )
                : const Icon(Icons.book, size: 50),
            onTap: () {
              // Đóng màn hình tìm kiếm và chuyển hướng đến khóa học
              Navigator.pop(context);
              Navigator.pushNamed(context, '/course-detail',
                  arguments: item.id);
            },
          );
        },
        searchController: searchController,
      ),
    );
  }

  void _showComprehensiveFilterDialog() {
    int? tempCategoryId =
        _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds.first : null;
    String? tempTeacherFilter =
        _selectedTeachers.isNotEmpty ? _selectedTeachers.first : null;
    List<Map<String, dynamic>> tempDiscountRanges =
        _selectedDiscountValues.isNotEmpty
            ? _selectedDiscountValues
                .map((value) => _discountOptions
                    .firstWhere((option) => option['value'] == value))
                .toList()
            : [
                {'label': '0% - 10%', 'value': '0-10%'},
                {'label': '10% - 30%', 'value': '10-30%'},
                {'label': '30% - 50%', 'value': '30-50%'},
                {'label': '50% - 70%', 'value': '50-70%'},
                {'label': 'Trên 70%', 'value': '70%+'},
              ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lọc khóa học',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      // Filter by category
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danh mục',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                            valueListenable: _controller.categories,
                            builder: (context, categories, _) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilterChip(
                                    label: const Text('Tất cả'),
                                    selected: tempCategoryId == null,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setModalState(() {
                                          _selectedCategoryIds = [];
                                        });
                                      }
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    selectedColor: const Color(0xFF3498DB),
                                    labelStyle: TextStyle(
                                      color: tempCategoryId == null
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: tempCategoryId == null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  ...categories.map((category) {
                                    final isSelected = _selectedCategoryIds
                                        .contains(category.id);
                                    return FilterChip(
                                      label: Text(category.name),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            _selectedCategoryIds
                                                .add(category.id!);
                                          } else {
                                            _selectedCategoryIds
                                                .remove(category.id);
                                          }
                                        });
                                      },
                                      backgroundColor: Colors.grey.shade200,
                                      selectedColor: const Color(0xFF3498DB),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Filter by teacher
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giảng viên',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _teachers.isEmpty
                              ? const Text(
                                  'Không có giảng viên nào để hiển thị')
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _teachers.map((teacher) {
                                    final isSelected =
                                        _selectedTeachers.contains(teacher);

                                    return FilterChip(
                                      label: Text(teacher),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            _selectedTeachers.add(teacher);
                                          } else {
                                            _selectedTeachers.remove(teacher);
                                          }
                                        });
                                      },
                                      backgroundColor: Colors.grey.shade200,
                                      selectedColor: const Color(0xFF3498DB),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Filter by discount range
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mức giảm giá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...tempDiscountRanges.map((range) {
                                final label = range['label'];
                                final min = range['min'];
                                final max = range['max'];
                                final isSelected = _selectedDiscountValues
                                    .contains(range['value']);

                                return FilterChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        _selectedDiscountValues
                                            .add(range['value']);
                                      } else {
                                        _selectedDiscountValues
                                            .remove(range['value']);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  selectedColor: const Color(0xFF3498DB),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                      ),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryIds = _selectedCategoryIds.isNotEmpty
                              ? _selectedCategoryIds
                              : [];
                          _selectedTeachers = _selectedTeachers.isNotEmpty
                              ? _selectedTeachers
                              : [];
                          _selectedDiscountValues =
                              _selectedDiscountValues.isNotEmpty
                                  ? _selectedDiscountValues
                                  : [];
                        });
                        _applyComprehensiveFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyComprehensiveFilters() {
    // Reset to initial state
    _controller.filterCourses('all');
    _controller.resetDiscountRanges();

    // Track if we need to reload the base list
    bool needsBaseReload = true;

    // Apply discount range filter
    if (_selectedDiscountValues.isNotEmpty) {
      _controller.filterCourses('discount');
      needsBaseReload = false;

      // Apply discount range filter using the correct method signature
      for (var value in _selectedDiscountValues) {
        final range = _discountOptions.firstWhere(
          (option) => option['value'] == value,
        );
        final label = range['label'];
        final min = range['min'];
        final max = range['max'];
        if (label == 'Tất cả') {
          _controller.updateDiscountRange(label, true);
        } else {
          _controller.updateDiscountRange(label, true);
        }
      }
    }

    // Apply category filter if selected
    if (_selectedCategoryIds.isNotEmpty && _selectedCategoryIds.first != null) {
      _controller.filterByCategories(_selectedCategoryIds);
      needsBaseReload = false;
    }

    // Apply teacher filter if selected
    if (_selectedTeachers.isNotEmpty && _selectedTeachers.first != null) {
      List<CourseCardModel> courses;

      if (needsBaseReload) {
        // If no filter applied yet, use all courses
        courses = _controller.allCourses.value;
      } else {
        // Otherwise, filter the already filtered courses
        courses = _controller.filteredCourses.value;
      }

      final teacherFiltered = courses
          .where((course) => _selectedTeachers.contains(course.author))
          .toList();

      _controller.filteredCourses.value = teacherFiltered;
    }
  }

  void _resetComprehensiveFilters() {
    setState(() {
      _selectedCategoryIds = [];
      _selectedTeachers = [];
      _selectedDiscountValues = [];
    });

    // Reset all filters in the controller
    _controller.filterCourses('all');
    _controller.resetDiscountRanges();
    _controller.selectedCategoryIds.value = [];
  }

  bool get _hasActiveFilters =>
      _selectedCategoryIds.isNotEmpty ||
      _selectedTeachers.isNotEmpty ||
      _selectedDiscountValues.isNotEmpty;

  void _toggleTopSection() {
    setState(() {
      _isTopSectionExpanded = !_isTopSectionExpanded;
      if (_isTopSectionExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.courseScreenBgColor,
      appBar: AppBar(
        title: const Text(
          "Khóa học",
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.lightBlue),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        actions: [
          // Add refresh button
          _isRefreshing
              ? Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.lightBlue),
                  onPressed: _handleRefresh,
                ),
          // Add filter button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.lightBlue),
            onPressed: _showComprehensiveFilterDialog,
            tooltip: 'Lọc khóa học',
          ),
          // Add search button
          IconButton(
            icon: const Icon(Icons.search, color: Colors.lightBlue),
            onPressed: _showSearchDialog,
          ),
          // Add expand/collapse button
          IconButton(
            icon: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more, color: Colors.lightBlue),
            ),
            onPressed: _toggleTopSection,
            tooltip: 'Mở rộng/Thu gọn',
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ValueListenableBuilder<List<CourseCardModel>>(
            valueListenable: _controller.filteredCourses,
            builder: (context, courses, _) {
              return Column(
                children: [
                  // Collapsible top section with filter buttons and chips
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isTopSectionExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        // Premium Combo Courses Banner
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3498DB).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Combo Khóa Học',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tiết kiệm 30% khi đăng ký gói combo khóa học',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        _controller.filterCourses('combo');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF3498DB),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        'Xem ngay',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white30,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Show active filters as chips
                        if (_hasActiveFilters)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_selectedCategoryIds.isNotEmpty &&
                                    _selectedCategoryIds.first != null)
                                  Chip(
                                    label: Text(
                                        'Danh mục: ${_getCategoryName(_selectedCategoryIds.first!)}'),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedCategoryIds = [];
                                      });
                                      _applyComprehensiveFilters();
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    deleteIconColor: Colors.black54,
                                  ),
                                if (_selectedTeachers.isNotEmpty &&
                                    _selectedTeachers.first != null)
                                  Chip(
                                    label: Text(
                                        'Giảng viên: ${_selectedTeachers.first}'),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedTeachers = [];
                                      });
                                      _applyComprehensiveFilters();
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    deleteIconColor: Colors.black54,
                                  ),
                                if (_selectedDiscountValues.isNotEmpty)
                                  Chip(
                                    label: Text(_getDiscountRangeText()),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedDiscountValues = [];
                                      });
                                      _applyComprehensiveFilters();
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    deleteIconColor: Colors.black54,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                        child: Text(
                          'Bộ lọc khóa học',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            if (courses.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 50),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 80, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      "Không có khóa học nào",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: CourseList(
                                  courses: _controller.getCurrentPageCourses(),
                                ),
                              ),
                            if (courses.isNotEmpty)
                              ValueListenableBuilder<int>(
                                valueListenable: _controller.currentPage,
                                builder: (context, currentPage, _) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 16, top: 8),
                                    child: PaginationWidget(
                                      currentPage: currentPage,
                                      totalPages: _controller.getTotalPages(),
                                      onPageChanged: _controller.changePage,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _getCategoryName(int id) {
    final categories = _controller.categories.value;
    final category = categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => categories.first,
    );
    return category.name;
  }

  String _getDiscountRangeText() {
    if (_selectedDiscountValues.isEmpty) {
      return 'Tất cả mức giảm giá';
    } else {
      final ranges = _selectedDiscountValues.map((value) {
        final range = _discountOptions.firstWhere(
          (option) => option['value'] == value,
        );
        final label = range['label'];
        final min = range['min'];
        final max = range['max'];
        if (label == 'Tất cả') {
          return 'Tất cả mức giảm giá';
        } else if (min == null && max == null) {
          return label;
        } else if (min == null) {
          return 'Trên $max%';
        } else if (max == null) {
          return 'Từ $min%';
        } else {
          return 'Giảm giá: $min% - $max%';
        }
      }).join(', ');
      return ranges;
    }
  }
}
