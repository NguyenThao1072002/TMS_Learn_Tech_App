import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/controller/practice_test_controller.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_detail.dart';
import 'package:tms_app/presentation/widgets/practice_test/practice_test_card.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/widgets/component/search/search_button.dart';
import 'package:tms_app/presentation/widgets/component/search/unified_search_delegate.dart';
import 'package:tms_app/presentation/widgets/component/pagination.dart';

class PracticeTestListScreen extends StatefulWidget {
  const PracticeTestListScreen({Key? key}) : super(key: key);

  @override
  State<PracticeTestListScreen> createState() => _PracticeTestListScreenState();
}

class _PracticeTestListScreenState extends State<PracticeTestListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  late PracticeTestController _controller;
  late UnifiedSearchController _searchController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = PracticeTestController();
    _searchController =
        Provider.of<UnifiedSearchController>(context, listen: false);

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns =
        Tween<double>(begin: 0.0, end: 0.5).animate(_animationController);

    // Set initial state of animation
    if (_controller.isTopSectionExpanded) {
      _animationController.value = 0.0;
    } else {
      _animationController.value = 1.0;
    }

    // Listen to changes in expanded state
    _controller.addListener(_handleControllerChanges);
  }

  void _handleControllerChanges() {
    if (_controller.isTopSectionExpanded !=
        (_animationController.value == 0.0)) {
      if (_controller.isTopSectionExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
    setState(() {});
  }

  // Hàm refresh danh sách đề thi
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _controller.refresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.removeListener(_handleControllerChanges);
    super.dispose();
  }

  void _toggleTopSection() {
    _controller.toggleTopSection();
  }

  void _showFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String? tempLevelFilter = _controller.levelFilter;
    String? tempAuthorFilter = _controller.authorFilter;
    double? tempMinPrice = _controller.minPriceFilter;
    double? tempMaxPrice = _controller.maxPriceFilter;
    int? tempCategoryId = _controller.categoryIdFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
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
                Text(
                  'Lọc đề thi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
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
                          Text(
                            'Danh mục',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: tempCategoryId == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    setModalState(() {
                                      tempCategoryId = null;
                                    });
                                  }
                                },
                                backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                selectedColor: const Color(0xFF3498DB),
                                labelStyle: TextStyle(
                                  color: tempCategoryId == null
                                      ? Colors.white
                                      : (isDarkMode ? Colors.white70 : Colors.black),
                                  fontWeight: tempCategoryId == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              ..._controller.categories.map((category) {
                                String categoryName = 'Unknown';
                                int categoryId = -1;

                                try {
                                  categoryName =
                                      category['name'] as String? ?? 'Unknown';
                                  categoryId = category['id'] as int? ?? -1;

                                  if (categoryName == 'Unknown') {
                                    print(
                                        'Warning: Category has no name: $category');
                                  }

                                  if (categoryId == -1) {
                                    print(
                                        'Warning: Category has invalid ID: $category');
                                  }
                                } catch (e) {
                                  print(
                                      'Error parsing category: $e, category data: $category');
                                }

                                final isSelected = tempCategoryId == categoryId;

                                return FilterChip(
                                  label: Text(categoryName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempCategoryId =
                                          selected ? categoryId : null;
                                    });
                                  },
                                  backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                  selectedColor: const Color(0xFF3498DB),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode ? Colors.white70 : Colors.black),
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
                      const SizedBox(height: 20),

                      // Filter by level
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Độ khó',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _controller.levelOptions.map((level) {
                              final isSelected = tempLevelFilter == level ||
                                  (level == 'Tất cả' &&
                                      tempLevelFilter == null);

                              return FilterChip(
                                label: Text(level == 'Tất cả'
                                    ? level
                                    : _controller.translateLevel(level)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (level == 'Tất cả') {
                                      tempLevelFilter = null;
                                    } else {
                                      tempLevelFilter = selected ? level : null;
                                    }
                                  });
                                },
                                backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                selectedColor: const Color(0xFF3498DB),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black),
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

                      // Filter by author
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tác giả',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _controller.authorOptions.isEmpty
                              ? Text(
                                  'Không có tác giả nào để hiển thị',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _controller.authorOptions.map((author) {
                                    final isSelected =
                                        tempAuthorFilter == author ||
                                            (author == 'Tất cả' &&
                                                tempAuthorFilter == null);

                                    return FilterChip(
                                      label: Text(author),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (author == 'Tất cả') {
                                            tempAuthorFilter = null;
                                          } else {
                                            tempAuthorFilter =
                                                selected ? author : null;
                                          }
                                        });
                                      },
                                      backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                      selectedColor: const Color(0xFF3498DB),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDarkMode ? Colors.white70 : Colors.black),
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

                      // Price range
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       'Khoảng giá',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.bold,
                      //         color: isDarkMode ? Colors.white : Colors.black87,
                      //       ),
                      //     ),
                      //     const SizedBox(height: 10),
                      //     Row(
                      //       children: [
                      //         Expanded(
                      //           child: TextField(
                      //             decoration: InputDecoration(
                      //               labelText: 'Giá tối thiểu',
                      //               labelStyle: TextStyle(
                      //                 color: isDarkMode ? Colors.grey[400] : null,
                      //               ),
                      //               border: OutlineInputBorder(),
                      //               prefix: Text('₫', style: TextStyle(color: isDarkMode ? Colors.white : null)),
                      //               enabledBorder: OutlineInputBorder(
                      //                 borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                      //               ),
                      //             ),
                      //             style: TextStyle(color: isDarkMode ? Colors.white : null),
                      //             keyboardType: TextInputType.number,
                      //             onChanged: (value) {
                      //               if (value.isNotEmpty) {
                      //                 setModalState(() {
                      //                   tempMinPrice = double.tryParse(value);
                      //                 });
                      //               } else {
                      //                 setModalState(() {
                      //                   tempMinPrice = null;
                      //                 });
                      //               }
                      //             },
                      //             controller: TextEditingController(
                      //               text: tempMinPrice?.toString() ?? '',
                      //             ),
                      //           ),
                      //         ),
                      //         const SizedBox(width: 16),
                      //         Expanded(
                      //           child: TextField(
                      //             decoration: InputDecoration(
                      //               labelText: 'Giá tối đa',
                      //               labelStyle: TextStyle(
                      //                 color: isDarkMode ? Colors.grey[400] : null,
                      //               ),
                      //               border: OutlineInputBorder(),
                      //               prefix: Text('₫', style: TextStyle(color: isDarkMode ? Colors.white : null)),
                      //               enabledBorder: OutlineInputBorder(
                      //                 borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                      //               ),
                      //             ),
                      //             style: TextStyle(color: isDarkMode ? Colors.white : null),
                      //             keyboardType: TextInputType.number,
                      //             onChanged: (value) {
                      //               if (value.isNotEmpty) {
                      //                 setModalState(() {
                      //                   tempMaxPrice = double.tryParse(value);
                      //                 });
                      //               } else {
                      //                 setModalState(() {
                      //                   tempMaxPrice = null;
                      //                 });
                      //               }
                      //             },
                      //             controller: TextEditingController(
                      //               text: tempMaxPrice?.toString() ?? '',
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
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
                        _controller.updateFilters(
                          levelFilter: tempLevelFilter,
                          authorFilter: tempAuthorFilter,
                          minPriceFilter: tempMinPrice,
                          maxPriceFilter: tempMaxPrice,
                          categoryIdFilter: tempCategoryId,
                        );
                        _controller.applyFilters();
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        title: const Text(
          'Đề thi',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          IconButton(
            icon: const Icon(Icons.search, color: Colors.lightBlue),
            onPressed: () {
              // Implement search functionality
              showSearch(
                context: context,
                delegate: PracticeTestSearchDelegate(
                  onSearch: (query) {
                    _controller.search(query);
                  },
                  controller: _controller,
                  isDarkMode: isDarkMode,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.lightBlue),
            onPressed: _showFilterDialog,
          ),
          // Add expand/collapse button in the app bar
          IconButton(
            icon: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more, color: Colors.lightBlue),
            ),
            onPressed: _toggleTopSection,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsible top section
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _controller.isTopSectionExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium banner
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              'Bài thi thử chất lượng',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Luyện tập trước các bài thi thử để tự tin hơn trước khi thi thực tế',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            // const SizedBox(height: 12),
                            // ElevatedButton(
                            //   onPressed: () {},
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.white,
                            //     foregroundColor: const Color(0xFF3498DB),
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: 16, vertical: 10),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(30),
                            //     ),
                            //   ),
                            //   child: const Text(
                            //     'Đăng ký ngay',
                            //     style: TextStyle(fontWeight: FontWeight.bold),
                            //   ),
                            // ),
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
                          Icons.star,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category section header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category filter
                SizedBox(
                  height: 50,
                  child: _controller.categories.isEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: const Text('Tất cả'),
                                selected: true,
                                onSelected: (selected) {},
                                backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                selectedColor: const Color(0xFF3498DB),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _controller.categories.length +
                              1, // +1 for "All" option
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: const Text('Tất cả'),
                                  selected:
                                      _controller.selectedCategory == 'Tất cả',
                                  onSelected: (selected) {
                                    if (selected) {
                                      _controller.selectCategory(
                                          'Tất cả', null);
                                    }
                                  },
                                  backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                  selectedColor: const Color(0xFF3498DB),
                                  labelStyle: TextStyle(
                                    color:
                                        _controller.selectedCategory == 'Tất cả'
                                            ? Colors.white
                                            : (isDarkMode ? Colors.white70 : Colors.black),
                                    fontWeight:
                                        _controller.selectedCategory == 'Tất cả'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              );
                            }

                            final category = _controller.categories[index - 1];
                            final categoryName =
                                category['name'] as String? ?? 'Unknown';
                            final categoryId = category['id'] as int? ?? -1;
                            final isSelected =
                                categoryName == _controller.selectedCategory;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(categoryName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _controller.selectCategory(
                                        categoryName, categoryId);
                                  }
                                },
                                backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                                selectedColor: const Color(0xFF3498DB),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Applied filters chips
                if (_controller.levelFilter != null ||
                    _controller.authorFilter != null ||
                    _controller.categoryIdFilter != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_controller.categoryIdFilter != null)
                          Chip(
                            label: Text(
                              'Danh mục: ${_controller.getCategoryName(_controller.categoryIdFilter!)}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            onDeleted: () {
                              _controller.clearFilter(FilterType.CATEGORY);
                            },
                            backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                            deleteIconColor: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        if (_controller.levelFilter != null)
                          Chip(
                            label: Text(
                              'Độ khó: ${_controller.translateLevel(_controller.levelFilter!)}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            onDeleted: () {
                              _controller.clearFilter(FilterType.LEVEL);
                            },
                            backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                            deleteIconColor: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        if (_controller.authorFilter != null)
                          Chip(
                            label: Text(
                              'Tác giả: ${_controller.authorFilter}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            onDeleted: () {
                              _controller.clearFilter(FilterType.AUTHOR);
                            },
                            backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey.shade200,
                            deleteIconColor: isDarkMode ? Colors.white70 : Colors.black54,
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
                  'Đề thi và bộ lọc',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Test list
          Expanded(
            child: _controller.isLoading && _controller.tests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _controller.tests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: isDarkMode ? Colors.grey[600] : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy đề thi',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _handleRefresh,
                              child: const Text('Tải lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              _controller.tests.length + 1, // +1 cho phân trang
                          itemBuilder: (context, index) {
                            // Hiển thị phân trang ở cuối danh sách
                            if (index == _controller.tests.length) {
                              return ValueListenableBuilder<int>(
                                valueListenable:
                                    _controller.currentPageNotifier,
                                builder: (context, currentPage, _) {
                                  return ValueListenableBuilder<int>(
                                    valueListenable:
                                        _controller.totalPagesNotifier,
                                    builder: (context, totalPages, _) {
                                      return ValueListenableBuilder<int>(
                                        valueListenable:
                                            _controller.totalElementsNotifier,
                                        builder: (context, totalElements, _) {
                                          if (totalPages <= 1) {
                                            return const SizedBox.shrink();
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16, top: 8),
                                            child: PaginationWidget(
                                              currentPage: currentPage,
                                              totalPages: totalPages,
                                              onPageChanged:
                                                  _controller.changePage,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            }

                            // Hiển thị đề thi
                            final test = _controller.tests[index];
                            return PracticeTestCard(
                              test: test,
                              isDarkMode: isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PracticeTestDetailScreen(
                                            testId: test.testId),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class PracticeTestSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  // Sử dụng controller được truyền từ bên ngoài thay vì tạo mới
  final PracticeTestController _controller;
  // Đánh dấu trạng thái tìm kiếm
  bool _isSearching = false;
  // Biến đếm thời gian cho debounce tìm kiếm
  DateTime? _lastSearchTime;
  final bool isDarkMode;

  PracticeTestSearchDelegate({
    required this.onSearch,
    required PracticeTestController controller,
    required this.isDarkMode,
  }) : _controller = controller;

  @override
  String get searchFieldLabel => 'Tìm kiếm đề thi...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 16,
        color: Color(0xFF333333),
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF3498DB)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _performSearch();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  // Debounce tìm kiếm - chỉ tìm sau một khoảng thời gian không gõ
  void _performSearch() {
    final now = DateTime.now();
    _lastSearchTime = now;

    // Đánh dấu đang tìm kiếm
    _isSearching = true;

    // Thực hiện tìm kiếm sau 300ms nếu không có thêm ký tự nào được gõ
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_lastSearchTime == now) {
        // Thay đổi để sử dụng search thay vì searchByTitleAndAuthor
        _controller.search(query);

        _isSearching = false;
      }
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      _performSearch();
    }
    // Hiển thị kết quả tìm kiếm trực tiếp trên màn hình tìm kiếm
    return _buildSearchResultsWidget();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Nếu đang nhập và chưa bắt đầu tìm kiếm, hiển thị gợi ý
    // Nếu đã tìm kiếm, hiển thị kết quả
    if (query.isEmpty) {
      return _buildSuggestionsWidget();
    } else {
      // Thực hiện tìm kiếm thời gian thực khi người dùng gõ
      _performSearch();
      return _buildSearchResultsWidget();
    }
  }

  Widget _buildSuggestionsWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gợi ý tìm kiếm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tìm kiếm theo tên đề thi hoặc tác giả',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final suggestions = [
                    'Flutter',
                    'React Native',
                    'Android Development',
                    'iOS Development 2',
                    'Web Development',
                  ];

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.search,
                        color: Color(0xFF3498DB),
                      ),
                      title: Text(
                        suggestions[index],
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        query = suggestions[index];
                        _performSearch();
                        showResults(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_isSearching || _controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            );
          }

          if (_controller.tests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy đề thi phù hợp',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hệ thống tìm kiếm theo tên đề thi và tác giả',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.tests.length,
            itemBuilder: (context, index) {
              final test = _controller.tests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _controller.translateLevel(test.level),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            test.author,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      test.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  trailing: test.price > 0
                      ? Text(
                          '${_controller.formatPrice(test.price)}đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3498DB),
                          ),
                        )
                      : const Text(
                          'Miễn phí',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                  onTap: () {
                    // Đóng màn hình tìm kiếm và chuyển hướng đến chi tiết đề thi
                    close(context, test.testId.toString());

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PracticeTestDetailScreen(testId: test.testId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
