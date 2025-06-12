import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/banner_model.dart';
import 'package:tms_app/data/models/document/document_model.dart';
import 'package:tms_app/domain/usecases/banner_usecase.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:tms_app/presentation/controller/documnet_controller.dart';
import 'package:tms_app/presentation/screens/document/document_detail.dart';
import 'package:tms_app/presentation/widgets/document/document_item.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tms_app/presentation/widgets/component/pagination.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/presentation/controller/unified_search_controller.dart';
import 'package:tms_app/presentation/widgets/component/search/unified_search_delegate.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen>
    with TickerProviderStateMixin {
  late final DocumentController _documentController;
  late TabController _tabController;
  late List<String> _categoryOptions = ['Tất cả'];
  final TextEditingController _searchController = TextEditingController();
  final bannerUseCase = GetIt.instance<BannerUseCase>();
  late Future<List<BannerModel>> bannersFuture;
  String _selectedFormat = 'Tất cả';
  bool _isRefreshing = false;
  String _selectedCategory = 'Tất cả';

  // Animation controller for expand/collapse icon
  late AnimationController _animationController;
  late Animation<double> _iconTurns;
  bool _isTopSectionExpanded = true;

  final List<Map<String, dynamic>> _bannerItems = [
    {
      'title': 'Khám phá kho tài liệu mới',
      'image': 'assets/images/banner1.jpg',
      'color': const Color(0xFF5E35B1),
    },
    {
      'title': 'Tài liệu độc quyền',
      'image': 'assets/images/banner2.jpg',
      'color': const Color(0xFF1976D2),
    },
    {
      'title': 'Giảm 50% cho thành viên mới',
      'image': 'assets/images/banner3.jpg',
      'color': const Color(0xFFD81B60),
    },
  ];

  // Document format options
  final List<String> _formatOptions = ['Tất cả', 'PDF', 'DOCX', 'PPTX'];

  void _loadCategoriesAndListenForChanges() async {
    // Tải danh mục
    await _documentController.loadCategories();

    // Lắng nghe sự thay đổi của danh sách danh mục
    _documentController.categories.addListener(_updateCategoryOptions);

    // Cập nhật danh sách hiển thị ban đầu
    _updateCategoryOptions();
  }

  // Cập nhật danh sách hiển thị
  void _updateCategoryOptions() {
    setState(() {
      _categoryOptions = _documentController.getCategoryNames();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Khởi tạo DocumentController thông qua Dependency Injection
    _documentController = DocumentController(
      GetIt.instance<DocumentUseCase>(),
      categoryUseCase: GetIt.instance<CategoryUseCase>(),
    );

    _loadCategoriesAndListenForChanges();
    // Mặc định tải tài liệu phổ biến khi màn hình được tạo
    _documentController.loadPopularDocuments();
    bannersFuture =
        bannerUseCase.getBannersByPositionAndPlatform('document', 'mobile');

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
    _searchController.dispose();
    _tabController.dispose();
    _documentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Hàm refresh dữ liệu
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Tải lại banner
      bannersFuture =
          bannerUseCase.getBannersByPositionAndPlatform('document', 'mobile');

      // Tải lại danh mục
      await _documentController.loadCategories();

      // Tải lại dữ liệu tài liệu theo tab hiện tại
      _reloadCurrentTabData();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }

    return;
  }

  // Function to navigate to detail page and increment views
  void _navigateToDetailAndIncrementViews(
      BuildContext context, DocumentModel document) {
    // Increment view count
    _documentController.incrementView(document.id);

    // Navigate to detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailScreen(
          document: document,
        ),
      ),
    ).then((_) {
      // Refresh UI when returning from detail page
      setState(() {});
    });
  }

  // Function to filter documents by format
  void _filterDocumentsByFormat(String format) {
    _selectedFormat = format;
    if (format == 'Tất cả') {
      // Reset filter, reload documents based on current tab
      _reloadCurrentTabData();
    } else {
      _documentController.filterDocumentsByFormat(format);
    }
  }

  // Function to reload data based on current tab
  void _reloadCurrentTabData() {
    if (_tabController.index == 0) {
      _documentController.loadPopularDocuments();
    } else if (_tabController.index == 1) {
      _documentController.loadNewDocuments();
    } else {
      // Tab 2 - For now, we'll just load popular documents
      _documentController.loadPopularDocuments();
    }
  }

  void _showSearchDialog() {
    // Get the search controller from provider
    final searchController =
        Provider.of<UnifiedSearchController>(context, listen: false);

    showSearch(
      context: context,
      delegate: UnifiedSearchDelegate(
        searchType: SearchType.document,
        onSearch: (query, type) {
          // Tìm kiếm theo tiêu đề tài liệu
          print('Tìm kiếm tài liệu với từ khóa: "$query", trường: "title"');
          searchController.searchByField(query, type, field: 'title');
        },
        itemBuilder: (context, item, type) {
          // Hiển thị kết quả tìm kiếm tài liệu
          if (item is DocumentModel) {
            final document = item;
            return ListTile(
              title: Text(
                document.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${document.format.toUpperCase()} • ${document.view} lượt xem • ${document.categoryName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorForDocType(document.format),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getDocumentIconData(document.format),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              onTap: () {
                // Đóng màn hình tìm kiếm và chuyển hướng đến chi tiết tài liệu
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentDetailScreen(document: document),
                  ),
                );
              },
            );
          }
          return const ListTile(
            title: Text('Kết quả không hợp lệ'),
          );
        },
        searchController: searchController,
      ),
    );
  }

  // Hàm trả về IconData dựa trên loại tài liệu
  IconData _getDocumentIconData(String type) {
    type = type.toLowerCase();
    if (type == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (type == 'excel' || type == 'xls' || type == 'xlsx') {
      return Icons.table_chart;
    } else if (type == 'word' || type == 'doc' || type == 'docx') {
      return Icons.article;
    } else if (type == 'ppt' || type == 'pptx') {
      return Icons.slideshow;
    } else {
      return Icons.article;
    }
  }

  void _showComprehensiveFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String tempFormat = _selectedFormat;
    String tempCategory = _selectedCategory;

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
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lọc tài liệu',
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
                      // Filter by format
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Định dạng',
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
                            children: _formatOptions.map((format) {
                              final isSelected = tempFormat == format;
                              return FilterChip(
                                label: Text(format),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    tempFormat = selected ? format : 'Tất cả';
                                  });
                                },
                                backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey[200],
                                selectedColor: Colors.lightBlue,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
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
                            children: _categoryOptions.map((category) {
                              final isSelected = tempCategory == category;
                              return FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    tempCategory =
                                        selected ? category : 'Tất cả';
                                  });
                                },
                                backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey[200],
                                selectedColor: Colors.lightBlue,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
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
                        foregroundColor: Colors.lightBlue,
                      ),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFormat = tempFormat;
                          _selectedCategory = tempCategory;
                        });

                        // Get category ID if a category is selected
                        int? categoryId;
                        if (_selectedCategory != 'Tất cả') {
                          categoryId = _documentController
                              .getCategoryIdByName(_selectedCategory);
                        }

                        // Apply combined filters
                        if (_selectedFormat == 'Tất cả' &&
                            _selectedCategory == 'Tất cả') {
                          // No filters applied, reload based on current tab
                          _reloadCurrentTabData();
                        } else {
                          // Use the new combined filtering method
                          _documentController
                              .filterDocumentsByFormatAndCategory(
                                  _selectedFormat, categoryId);
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
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

  bool get _hasActiveFilters =>
      _selectedFormat != 'Tất cả' || _selectedCategory != 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        title: const Text(
          'Tài liệu',
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
          // Add filter button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.lightBlue),
            onPressed: _showComprehensiveFilterDialog,
            tooltip: 'Lọc tài liệu',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.lightBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.lightBlue,
          onTap: (index) {
            if (index == 0) {
              _documentController.loadPopularDocuments();
            } else if (index == 1) {
              _documentController.loadNewDocuments();
            } else {
              // Tab 2 - Suggested documents, for now we'll load popular documents
              _documentController.loadPopularDocuments();
            }
            // Reset về trang 1 khi chuyển tab
            _documentController.changePage(1);
          },
          tabs: const [
            Tab(text: 'Phổ biến'),
            Tab(text: 'Mới nhất'),
            Tab(text: 'Đề xuất'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Popular tab
          _buildTabContent(isDarkMode),

          // New tab
          _buildTabContent(isDarkMode),

          // Recommended tab
          _buildTabContent(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Collapsible top section with banner and filter chips
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isTopSectionExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  // Banner slider từ dữ liệu API
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: FutureBuilder<List<BannerModel>>(
                      future: bannersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return SizedBox(
                            height: 150,
                            child: Center(
                              child:
                                  Text('Lỗi khi tải banner: ${snapshot.error}'),
                            ),
                          );
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          final banners = snapshot.data!;
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: 180,
                              aspectRatio: 16 / 9,
                              viewportFraction: 1.0,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                            ),
                            items: banners.map((banner) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF5E35B1)
                                              .withOpacity(0.6),
                                          const Color(0xFF5E35B1)
                                              .withOpacity(0.4)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Opacity(
                                              opacity: 0.8,
                                              child: Image.network(
                                                banner.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 50),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(20.0),
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.center,
                                        //     children: [
                                        //       Text(
                                        //         banner.title,
                                        //         style: const TextStyle(
                                        //           fontSize: 20,
                                        //           fontWeight: FontWeight.bold,
                                        //           color: Colors.white,
                                        //         ),
                                        //       ),
                                        //       const SizedBox(height: 8),
                                        //       ElevatedButton(
                                        //         onPressed: () {
                                        //           // Xử lý hành động khi click vào banner
                                        //           if (banner.link != null &&
                                        //               banner.link!.isNotEmpty) {
                                        //             // Mở link hoặc xử lý hành động tương ứng
                                        //           }
                                        //         },
                                        //         style: ElevatedButton.styleFrom(
                                        //           backgroundColor: Colors.white,
                                        //           foregroundColor:
                                        //               const Color(0xFF5E35B1),
                                        //           shape: RoundedRectangleBorder(
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     20),
                                        //           ),
                                        //         ),
                                        //         child: const Text('Xem ngay'),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        } else {
                          // Fallback khi không có banner từ API
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: 180,
                              aspectRatio: 16 / 9,
                              viewportFraction: 1.0,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                            ),
                            items: _bannerItems.map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          item['color'].withOpacity(0.6),
                                          item['color'].withOpacity(0.4)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Opacity(
                                              opacity: 0.8,
                                              child: Image.network(
                                                'https://via.placeholder.com/600x300',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item['title'],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      item['color'],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                                child: const Text('Xem ngay'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
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
                          if (_selectedFormat != 'Tất cả')
                            Chip(
                              label: Text(
                                'Định dạng: $_selectedFormat',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              onDeleted: () {
                                setState(() {
                                  _selectedFormat = 'Tất cả';
                                });
                                // Áp dụng lại bộ lọc với chỉ category
                                if (_selectedCategory != 'Tất cả') {
                                  final categoryId = _documentController
                                      .getCategoryIdByName(_selectedCategory);
                                  if (categoryId != null) {
                                    _documentController
                                        .filterDocumentsByFormatAndCategory(
                                            'Tất cả', categoryId);
                                  }
                                } else {
                                  _reloadCurrentTabData();
                                }
                              },
                              backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey[200],
                              deleteIconColor: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          if (_selectedCategory != 'Tất cả')
                            Chip(
                              label: Text(
                                'Danh mục: $_selectedCategory',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategory = 'Tất cả';
                                });
                                // Áp dụng lại bộ lọc với chỉ format
                                if (_selectedFormat != 'Tất cả') {
                                  _documentController
                                      .filterDocumentsByFormatAndCategory(
                                          _selectedFormat, null);
                                } else {
                                  _reloadCurrentTabData();
                                }
                              },
                              backgroundColor: isDarkMode ? Color(0xFF2A2D3E) : Colors.grey[200],
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
                    'Bộ lọc tài liệu',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Document list
            ValueListenableBuilder<bool>(
              valueListenable: _documentController.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return ValueListenableBuilder<List<DocumentModel>>(
                  valueListenable: _documentController.filteredDocuments,
                  builder: (context, documents, _) {
                    if (documents.isEmpty) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchController.text.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.book,
                                size: 80,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'Không tìm thấy kết quả cho "${_searchController.text}"'
                                    : 'Không có tài liệu',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Main content with pagination
                    final currentPageDocuments =
                        _documentController.getCurrentPageDocuments();

                    return Column(
                      children: [
                        // Documents grid
                        GridView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: currentPageDocuments.length,
                          itemBuilder: (context, index) {
                            final document = currentPageDocuments[index];
                            return GestureDetector(
                              onTap: () {
                                _navigateToDetailAndIncrementViews(
                                    context, document);
                              },
                              child: DocumentItem(document: document),
                            );
                          },
                        ),

                        // Pagination - simplified structure like in CourseScreen
                        if (_documentController.getTotalPages() > 1)
                          ValueListenableBuilder<int>(
                            valueListenable: _documentController.currentPage,
                            builder: (context, currentPage, _) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: PaginationWidget(
                                  currentPage: currentPage,
                                  totalPages:
                                      _documentController.getTotalPages(),
                                  onPageChanged: _documentController.changePage,
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForDocType(String type) {
    type = type.toLowerCase();
    if (type == 'pdf') {
      return Colors.red;
    } else if (type == 'word' || type == 'doc' || type == 'docx') {
      return Colors.blue;
    } else if (type == 'excel' || type == 'xls' || type == 'xlsx') {
      return Colors.green;
    } else if (type == 'ppt' || type == 'pptx') {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    if (category == 'Tất cả') {
      return Colors.grey;
    }

    // Tạo màu ngẫu nhiên nhưng ổn định cho mỗi category
    // Sử dụng hash code của tên category để tạo màu ổn định (cùng tên sẽ cho cùng màu)
    final int hash = category.hashCode;

    // Sử dụng hashCode để tạo màu, đảm bảo màu không quá tối hoặc quá sáng
    return Color.fromARGB(
      255,
      100 + (hash & 0xFF) % 155, // Red component (100-255)
      100 + ((hash >> 8) & 0xFF) % 155, // Green component (100-255)
      100 + ((hash >> 16) & 0xFF) % 155, // Blue component (100-255)
    );
  }
}
