import 'package:flutter/material.dart';
import 'package:tms_app/data/datasources/document_data.dart';
import 'package:tms_app/data/repositories/document_repository_impl.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:tms_app/presentation/screens/document/document_detail.dart';
import 'package:tms_app/presentation/widgets/document/document_item.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tms_app/presentation/widgets/navbar/bottom_navbar_widget.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen>
    with SingleTickerProviderStateMixin {
  late final FetchDocumentsUseCase useCase;
  late final IncrementDocumentViewsUseCase incrementViewsUseCase;
  late Future<List> documentsFuture;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFormat = 'Tất cả';
  String _selectedCategory = 'Tất cả';

  // Banner ad items
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
  final List<String> _formatOptions = ['Tất cả', 'PDF', 'Word', 'Excel', 'PPT'];

  // Document category options
  final List<String> _categoryOptions = [
    'Tất cả',
    'Giáo dục',
    'Công nghệ',
    'Kinh tế',
    'Y tế',
    'Kỹ thuật',
    'Khoa học',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final datasource = DocumentRemoteDatasource();
    final repository = DocumentRepositoryImpl(datasource);
    useCase = FetchDocumentsUseCase(repository);
    incrementViewsUseCase = IncrementDocumentViewsUseCase(repository);
    documentsFuture = useCase.call();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Function to navigate to detail page and increment views
  void _navigateToDetailAndIncrementViews(context, document) {
    // Increment view count
    incrementViewsUseCase.call(document);

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

  // Function to filter documents
  List filterDocuments(List documents) {
    return documents.where((doc) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          doc.title.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by format
      final matchesFormat = _selectedFormat == 'Tất cả' ||
          doc.type.toLowerCase() == _selectedFormat.toLowerCase();

      // Filter by category (assuming document has a category property)
      final matchesCategory = _selectedCategory == 'Tất cả' ||
          (doc.category != null && doc.category == _selectedCategory);

      return matchesSearch && matchesFormat && matchesCategory;
    }).toList();
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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
    return ListView(
      children: [
        // Banner ad carousel
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 150,
              aspectRatio: 16 / 9,
              viewportFraction: 0.9,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
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
                        colors: [item['color'], item['color'].withOpacity(0.8)],
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
                                'https://via.placeholder.com/600x300',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    borderRadius: BorderRadius.circular(20),
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
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tài liệu...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
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
                          child: DropdownButton<String>(
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
                            },
                            items: _formatOptions
                                .map<DropdownMenuItem<String>>((String value) {
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
                                            color: _getColorForDocType(value),
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
                          ),
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
                            },
                            items: _categoryOptions
                                .map<DropdownMenuItem<String>>((String value) {
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
                  _searchQuery.isNotEmpty)
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
                          _searchQuery = '';
                        });
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
    );
  }

  Widget _buildDocumentListContent() {
    return FutureBuilder<List>(
      future: documentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        documentsFuture = useCase.call();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có tài liệu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        } else {
          final documents = snapshot.data!;
          // Filter documents
          final filteredDocuments = filterDocuments(documents);

          if (filteredDocuments.isEmpty) {
            return SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy kết quả cho "$_searchQuery"',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _navigateToDetailAndIncrementViews(
                    context,
                    filteredDocuments[index],
                  );
                },
                child: DocumentItem(document: filteredDocuments[index]),
              );
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
    switch (category.toLowerCase()) {
      case 'giáo dục':
        return Colors.blue;
      case 'công nghệ':
        return Colors.purple;
      case 'kinh tế':
        return Colors.green;
      case 'y tế':
        return Colors.red;
      case 'kỹ thuật':
        return Colors.amber;
      case 'khoa học':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
