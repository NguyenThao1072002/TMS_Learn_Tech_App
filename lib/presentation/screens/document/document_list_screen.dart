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

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen>
    with SingleTickerProviderStateMixin {
  late final DocumentController _documentController;
  late TabController _tabController;
  late List<String> _categoryOptions = ['Tất cả'];
  final TextEditingController _searchController = TextEditingController();
  final bannerUseCase = GetIt.instance<BannerUseCase>();
  late Future<List<BannerModel>> bannersFuture;
  String _selectedFormat = 'Tất cả';
  bool _isRefreshing = false;

  String _selectedCategory = 'Tất cả';
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _documentController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 42, 136, 50),
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tài liệu TMS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _handleRefresh,
                ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (index) {
            if (index == 0) {
              _documentController.loadPopularDocuments();
            } else if (index == 1) {
              _documentController.loadNewDocuments();
            } else {
              // Tab 2 - Suggested documents, for now we'll load popular documents
              _documentController.loadPopularDocuments();
            }
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
          _buildTabContent(),

          // New tab
          _buildTabContent(),

          // Recommended tab
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        children: [
          // Banner ad carousel
// Banner slider từ dữ liệu API
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: FutureBuilder<List<BannerModel>>(
              future: bannersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 150,
                    child: Center(
                      child: Text('Lỗi khi tải banner: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final banners = snapshot.data!;
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 150,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.9,
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
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF5E35B1),
                                  const Color(0xFF5E35B1).withOpacity(0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: Image.network(
                                        banner.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade300,
                                            child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 50),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Xử lý hành động khi click vào banner
                                          if (banner.link != null &&
                                              banner.link!.isNotEmpty) {
                                            // Mở link hoặc xử lý hành động tương ứng
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFF5E35B1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                } else {
                  // Fallback khi không có banner từ API
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 150,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.9,
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
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  item['color'],
                                  item['color'].withOpacity(0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Giữ nguyên phần này
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Opacity(
                                      opacity: 0.3,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          foregroundColor: item['color'],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
          // Search and filter section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _documentController.searchDocuments(value);
                      } else {
                        _reloadCurrentTabData();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tài liệu...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _reloadCurrentTabData();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter options
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Format filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
                            child: Text(
                              'Định dạng:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ValueListenableBuilder<String>(
                                valueListenable:
                                    _documentController.selectedFilter,
                                builder: (context, selectedFilter, _) {
                                  return DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedFormat,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 15),
                                    underline: Container(height: 0),
                                    alignment: AlignmentDirectional.centerStart,
                                    isDense: false,
                                    itemHeight: 50,
                                    borderRadius: BorderRadius.circular(12),
                                    menuMaxHeight: 300,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedFormat = newValue!;
                                      });
                                      _filterDocumentsByFormat(newValue!);
                                    },
                                    items: _formatOptions
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (value != 'Tất cả')
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  decoration: BoxDecoration(
                                                    color: _getColorForDocType(
                                                        value),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  width: 8,
                                                  height: 8,
                                                ),
                                              Text(value),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    hint: const Text("Định dạng"),
                                    dropdownColor: Colors.white,
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Category filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
                            child: Text(
                              'Danh mục:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 15),
                              underline: Container(height: 0),
                              alignment: AlignmentDirectional.centerStart,
                              isDense: false,
                              itemHeight: 50,
                              borderRadius: BorderRadius.circular(12),
                              menuMaxHeight: 300,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });

                                if (newValue == 'Tất cả') {
                                  _reloadCurrentTabData();
                                } else {
                                  // Lấy categoryId từ controller
                                  final categoryId = _documentController
                                      .getCategoryIdByName(newValue);

                                  if (categoryId != null) {
                                    // Sử dụng trực tiếp hàm loadDocumentsByCategory
                                    _documentController
                                        .loadDocumentsByCategory(categoryId);
                                  } else {
                                    print(
                                        'Không tìm thấy ID cho danh mục: $newValue');
                                    _reloadCurrentTabData();
                                  }
                                }
                              },
                              items: _categoryOptions
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (value != 'Tất cả')
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(value),
                                              shape: BoxShape.circle,
                                            ),
                                            width: 8,
                                            height: 8,
                                          ),
                                        Text(value),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              hint: const Text("Danh mục"),
                              dropdownColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Reset filters button
                if (_selectedFormat != 'Tất cả' ||
                    _selectedCategory != 'Tất cả' ||
                    _searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFormat = 'Tất cả';
                            _selectedCategory = 'Tất cả';
                            _searchController.clear();
                          });

                          // Reload data
                          _reloadCurrentTabData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.refresh, size: 16),
                              SizedBox(width: 4),
                              Text('Đặt lại'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // Main content - Document list
          _buildDocumentListContent(),
        ],
      ),
    );
  }

  Widget _buildDocumentListContent() {
    return ValueListenableBuilder<bool>(
      valueListenable: _documentController.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
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
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Không tìm thấy kết quả cho "${_searchController.text}"'
                              : 'Không có tài liệu',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ValueListenableBuilder<int>(
                  valueListenable: _documentController.currentPage,
                  builder: (context, currentPage, _) {
                    final currentPageDocuments =
                        _documentController.getCurrentPageDocuments();

                    return Column(
                      children: [
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
                                  context,
                                  document,
                                );
                              },
                              child: DocumentItem(document: document),
                            );
                          },
                        ),

                        // Pagination
                        if (_documentController.getTotalPages() > 1)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios),
                                  onPressed: currentPage <= 1
                                      ? null
                                      : () => _documentController
                                          .changePage(currentPage - 1),
                                  color: currentPage <= 1
                                      ? Colors.grey.shade400
                                      : Colors.green,
                                ),
                                Text(
                                  'Trang $currentPage/${_documentController.getTotalPages()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  onPressed: currentPage >=
                                          _documentController.getTotalPages()
                                      ? null
                                      : () => _documentController
                                          .changePage(currentPage + 1),
                                  color: currentPage >=
                                          _documentController.getTotalPages()
                                      ? Colors.grey.shade400
                                      : Colors.green,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  });
            },
          );
        }
      },
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
