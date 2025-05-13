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

class _CourseScreenState extends State<CourseScreen> {
  late final CourseController _controller;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    final courseUseCase = GetIt.instance<CourseUseCase>();
    final categoryUseCase = GetIt.instance<CategoryUseCase>();
    _controller =
        CourseController(courseUseCase, categoryUseCase: categoryUseCase);
    _controller.loadCourses();
  }

  @override
  void dispose() {
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

  void _showDiscountFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<Map<String, bool>>(
        valueListenable: _controller.discountRanges,
        builder: (context, discountRanges, _) {
          return DiscountFilterDialog(
            discountRanges: discountRanges,
            onUpdateRange: _controller.updateDiscountRange,
            onResetRanges: _controller.resetDiscountRanges,
          );
        },
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.courseScreenBgColor,
      appBar: AppBar(
        title: const Text(
          "Danh sách khóa học",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppStyles.appBarColor,
        elevation: 0,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _handleRefresh,
                ),
          // Add search button
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
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
                  _buildFilterSection(),
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
                              CourseList(
                                courses: _controller.getCurrentPageCourses(),
                              ),
                            if (courses.isNotEmpty)
                              ValueListenableBuilder<int>(
                                valueListenable: _controller.currentPage,
                                builder: (context, currentPage, _) {
                                  return PaginationWidget(
                                    currentPage: currentPage,
                                    totalPages: _controller.getTotalPages(),
                                    onPageChanged: _controller.changePage,
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

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.standardPadding, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterButton("Danh mục", 'category',
              onTap: _showCategoryFilterDialog),
          _buildFilterButton("Giảm giá", 'discount'),
          _buildFilterButton("Combo khóa học", 'combo'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter,
      {VoidCallback? onTap}) {
    return ValueListenableBuilder<String>(
      valueListenable: _controller.selectedFilter,
      builder: (context, selectedFilter, _) {
        final isSelected = selectedFilter == filter;
        return ElevatedButton(
          onPressed: () {
            _controller.filterCourses(filter);
            if (onTap != null) {
              onTap();
            } else if (filter == 'discount') {
              _showDiscountFilterDialog();
            }
          },
          style: AppStyles.courseScreenFilterButtonStyle(isSelected),
          child: Text(
            label,
            style: const TextStyle(color: AppStyles.filterButtonTextColor),
          ),
        );
      },
    );
  }
}
