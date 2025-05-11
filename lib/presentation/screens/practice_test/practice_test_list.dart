import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_detail.dart';
import 'package:tms_app/presentation/widgets/practice_test/practice_test_card.dart';

class PracticeTestListScreen extends StatefulWidget {
  const PracticeTestListScreen({Key? key}) : super(key: key);

  @override
  State<PracticeTestListScreen> createState() => _PracticeTestListScreenState();
}

class _PracticeTestListScreenState extends State<PracticeTestListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Tất cả';
  List<Map<String, dynamic>> _categories = [];
  final List<String> _levelOptions = ['Tất cả', 'EASY', 'MEDIUM', 'HARD'];
  final List<String> _authorOptions = [];
  bool _isTopSectionExpanded = true; // Track if top section is expanded
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  // Use the PracticeTestUseCase from GetIt
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();

  // State variables
  late Future<List<PracticeTestCardModel>> _practiceTestsFuture;
  bool _isLoading = false;
  String? _searchQuery;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  final List<PracticeTestCardModel> _tests = [];

  // Filtering variables
  String? _levelFilter;
  String? _examTypeFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;
  int? _minDiscountFilter;
  int? _maxDiscountFilter;
  int? _courseIdFilter;
  int? _categoryIdFilter;
  String? _authorFilter;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTests();

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  Future<void> _loadCategories() async {
    try {
      final categories = await _practiceTestUseCase.getPracticeTestCategories();
      print('Loaded categories: ${categories.length}');

      if (categories.isNotEmpty) {
        print('First category: ${categories[0]}');
      }

      setState(() {
        _categories = categories;
      });

      // Extract unique authors from tests for author filter
      _extractAuthors();
    } catch (e, stackTrace) {
      print('Error loading categories: $e');
      print('StackTrace: $stackTrace');

      // Set an empty list rather than leaving it null/uninitialized
      setState(() {
        _categories = [];
      });
    }
  }

  void _extractAuthors() {
    final authorSet = <String>{};

    // Add default "All" option
    authorSet.add('Tất cả');

    // Extract unique authors from tests
    for (var test in _tests) {
      if (test.author.isNotEmpty) {
        authorSet.add(test.author);
      }
    }

    setState(() {
      _authorOptions.clear();
      _authorOptions.addAll(authorSet.toList()..sort());
    });
  }

  Future<void> _loadTests({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _tests.clear();
        _hasMore = true;
      }
    });

    try {
      final tests = await _practiceTestUseCase.getFilteredPracticeTests(
        title: _searchQuery,
        courseId: _courseIdFilter,
        categoryId: _categoryIdFilter,
        level: _levelFilter,
        examType: _examTypeFilter,
        minPrice: _minPriceFilter,
        maxPrice: _maxPriceFilter,
        minDiscount: _minDiscountFilter,
        maxDiscount: _maxDiscountFilter,
        author: _authorFilter,
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        if (tests.isEmpty) {
          _hasMore = false;
        } else {
          _tests.addAll(tests);
          _currentPage++;

          // Update author list when new tests are loaded
          _extractAuthors();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải đề thi: ${e.toString()}')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 0;
      _tests.clear();
      _hasMore = true;
    });

    _loadTests();
  }

  void _showFilterDialog() {
    String? tempLevelFilter = _levelFilter;
    String? tempAuthorFilter = _authorFilter;
    double? tempMinPrice = _minPriceFilter;
    double? tempMaxPrice = _maxPriceFilter;
    int? tempCategoryId = _categoryIdFilter;

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
                  'Lọc đề thi',
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
                              ..._categories.map((category) {
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
                      const SizedBox(height: 20),

                      // Filter by level
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Độ khó',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _levelOptions.map((level) {
                              final isSelected = tempLevelFilter == level ||
                                  (level == 'Tất cả' &&
                                      tempLevelFilter == null);

                              return FilterChip(
                                label: Text(level == 'Tất cả'
                                    ? level
                                    : _translateLevel(level)),
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
                                backgroundColor: Colors.grey.shade200,
                                selectedColor: const Color(0xFF3498DB),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
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
                          const Text(
                            'Tác giả',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _authorOptions.isEmpty
                              ? const Text('Không có tác giả nào để hiển thị')
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _authorOptions.map((author) {
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

                      // Price range
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Khoảng giá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Giá tối thiểu',
                                    border: OutlineInputBorder(),
                                    prefix: Text('₫'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setModalState(() {
                                        tempMinPrice = double.tryParse(value);
                                      });
                                    } else {
                                      setModalState(() {
                                        tempMinPrice = null;
                                      });
                                    }
                                  },
                                  controller: TextEditingController(
                                    text: tempMinPrice?.toString() ?? '',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Giá tối đa',
                                    border: OutlineInputBorder(),
                                    prefix: Text('₫'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setModalState(() {
                                        tempMaxPrice = double.tryParse(value);
                                      });
                                    } else {
                                      setModalState(() {
                                        tempMaxPrice = null;
                                      });
                                    }
                                  },
                                  controller: TextEditingController(
                                    text: tempMaxPrice?.toString() ?? '',
                                  ),
                                ),
                              ),
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
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _levelFilter = tempLevelFilter;
                          _authorFilter = tempAuthorFilter;
                          _minPriceFilter = tempMinPrice;
                          _maxPriceFilter = tempMaxPrice;
                          _categoryIdFilter = tempCategoryId;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
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

  String _translateLevel(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return level;
    }
  }

  String _getCategoryName(int categoryId) {
    try {
      final category = _categories.firstWhere(
        (category) => category['id'] == categoryId,
        orElse: () => {'name': 'Unknown'},
      );

      final name = category['name'];
      if (name == null) {
        print('Warning: Category $categoryId has null name: $category');
        return 'Unknown';
      }

      return name.toString();
    } catch (e) {
      print('Error getting category name for ID $categoryId: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Bộ đề thi',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF333333)),
            onPressed: () {
              // Implement search functionality
              showSearch(
                context: context,
                delegate: PracticeTestSearchDelegate(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                      _currentPage = 0;
                      _tests.clear();
                      _hasMore = true;
                    });
                    _loadTests();
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF333333)),
            onPressed: _showFilterDialog,
          ),
          // Add expand/collapse button in the app bar
          IconButton(
            icon: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more, color: Color(0xFF333333)),
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
            crossFadeState: _isTopSectionExpanded
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
                              'Premium Tests',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Mở khóa tất cả các đề thi để nâng cao kỹ năng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF3498DB),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Đăng ký ngay',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                      const Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category filter
                SizedBox(
                  height: 50,
                  child: _categories.isEmpty
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
                                backgroundColor: Colors.grey.shade200,
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
                          itemCount:
                              _categories.length + 1, // +1 for "All" option
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: const Text('Tất cả'),
                                  selected: _selectedCategory == 'Tất cả',
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = 'Tất cả';
                                        _categoryIdFilter = null;
                                        _currentPage = 0;
                                        _tests.clear();
                                        _hasMore = true;
                                      });
                                      _loadTests();
                                    }
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  selectedColor: const Color(0xFF3498DB),
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == 'Tất cả'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: _selectedCategory == 'Tất cả'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }

                            final category = _categories[index - 1];
                            final categoryName =
                                category['name'] as String? ?? 'Unknown';
                            final categoryId = category['id'] as int? ?? -1;
                            final isSelected =
                                categoryName == _selectedCategory;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(categoryName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCategory = categoryName;
                                      _categoryIdFilter = categoryId;
                                      _currentPage = 0;
                                      _tests.clear();
                                      _hasMore = true;
                                    });
                                    _loadTests();
                                  }
                                },
                                backgroundColor: Colors.grey.shade200,
                                selectedColor: const Color(0xFF3498DB),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
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
                if (_levelFilter != null ||
                    _authorFilter != null ||
                    _categoryIdFilter != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_categoryIdFilter != null)
                          Chip(
                            label: Text(
                                'Danh mục: ${_getCategoryName(_categoryIdFilter!)}'),
                            onDeleted: () {
                              setState(() {
                                _categoryIdFilter = null;
                              });
                              _applyFilters();
                            },
                            backgroundColor: Colors.grey.shade200,
                            deleteIconColor: Colors.black54,
                          ),
                        if (_levelFilter != null)
                          Chip(
                            label: Text(
                                'Độ khó: ${_translateLevel(_levelFilter!)}'),
                            onDeleted: () {
                              setState(() {
                                _levelFilter = null;
                              });
                              _applyFilters();
                            },
                            backgroundColor: Colors.grey.shade200,
                            deleteIconColor: Colors.black54,
                          ),
                        if (_authorFilter != null)
                          Chip(
                            label: Text('Tác giả: $_authorFilter'),
                            onDeleted: () {
                              setState(() {
                                _authorFilter = null;
                              });
                              _applyFilters();
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
                  'Đề thi và bộ lọc',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Test list
          Expanded(
            child: _isLoading && _tests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _tests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy đề thi',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _loadTests(refresh: true),
                              child: const Text('Tải lại'),
                            ),
                          ],
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              !_isLoading &&
                              _hasMore) {
                            _loadTests();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tests.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _tests.length) {
                              return _isLoading
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox();
                            }

                            final test = _tests[index];
                            return PracticeTestCard(
                              test: test,
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class PracticeTestSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  PracticeTestSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
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

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container(); // Results will be shown in the main screen
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Gợi ý tìm kiếm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Flutter'),
          onTap: () {
            query = 'Flutter';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('React Native'),
          onTap: () {
            query = 'React Native';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Frontend'),
          onTap: () {
            query = 'Frontend';
            showResults(context);
          },
        ),
      ],
    );
  }
}
