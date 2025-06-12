import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/my_test/my_test_list_model.dart';
import 'package:tms_app/domain/usecases/my_test/my_test_list_usecase.dart';
import 'package:tms_app/domain/usecases/my_course/content_test_usecase.dart';
import 'package:tms_app/presentation/screens/my_account/my_course/take_test.dart';

class MyTestListScreen extends StatefulWidget {
  const MyTestListScreen({Key? key}) : super(key: key);

  @override
  State<MyTestListScreen> createState() => _MyTestListScreenState();
}

class _MyTestListScreenState extends State<MyTestListScreen> {
  final MyTestListUseCase _myTestListUseCase = GetIt.instance<MyTestListUseCase>();
  final ContentTestUseCase _contentTestUseCase = GetIt.instance<ContentTestUseCase>();
  
  bool _isLoading = true;
  String? _error;
  MyTestPaginatedData? _testData;
  
  // Biến tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Phân trang
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  
  // Biến để theo dõi trạng thái loading khi lấy nội dung bài kiểm tra
  bool _isLoadingTest = false;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTests();
    
    // Thêm scroll listener để phân trang
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  // Xử lý tải thêm dữ liệu khi cuộn đến cuối
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreTests();
    }
  }
  
  // Tải danh sách đề thi ban đầu
  Future<void> _loadTests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString(SharedPrefs.KEY_USER_ID) ?? '0') ?? 0;
      
      if (userId <= 0) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }
      
      final result = await _myTestListUseCase.getTestsByAccountExam(
        userId,
        page: 0,
        size: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      setState(() {
        _testData = result;
        _currentPage = 0;
        _hasMoreData = result.numberOfElements >= _pageSize;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Đã xảy ra lỗi: $e';
        _isLoading = false;
      });
    }
  }
  
  // Tải thêm dữ liệu khi cuộn đến cuối danh sách
  Future<void> _loadMoreTests() async {
    if (!_hasMoreData || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final nextPage = _currentPage + 1;
      
      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString(SharedPrefs.KEY_USER_ID) ?? '0') ?? 0;
      
      final result = await _myTestListUseCase.getTestsByAccountExam(
        userId,
        page: nextPage,
        size: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      if (result.content.isNotEmpty) {
        setState(() {
          // Cập nhật danh sách đề thi
          if (_testData != null) {
            final updatedContent = [..._testData!.content, ...result.content];
            _testData = MyTestPaginatedData(
              totalElements: result.totalElements,
              totalPages: result.totalPages,
              pageable: result.pageable,
              size: result.size,
              content: updatedContent,
              number: result.number,
              sorted: result.sorted,
              empty: result.empty,
              unsorted: result.unsorted,
              numberOfElements: updatedContent.length,
              first: _currentPage == 0,
              last: nextPage >= result.totalPages - 1,
            );
          } else {
            _testData = result;
          }
          
          _currentPage = nextPage;
          _hasMoreData = result.content.length >= _pageSize;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      // Chỉ hiển thị lỗi, không thay đổi dữ liệu hiện có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thêm dữ liệu: $e')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Tìm kiếm đề thi
  void _onSearch() {
    _searchQuery = _searchController.text.trim();
    _loadTests();
  }
  
  // Mở bài kiểm tra
  Future<void> _openTest(MyTestItem test) async {
    // Hiển thị hộp thoại xác nhận
    final bool startTest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          test.testTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn bắt đầu làm bài kiểm tra này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!startTest) return;
    
    // Bắt đầu lấy nội dung bài kiểm tra
    setState(() {
      _isLoadingTest = true;
    });
    
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );
    
    try {
      // Lấy nội dung bài kiểm tra từ API
      final contentTest = await _contentTestUseCase.getContentTest(test.testId);
      
      // Đóng dialog loading
      Navigator.pop(context);
      
      // Điều hướng đến màn hình làm bài kiểm tra
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakeTestScreen(
            contentTest: contentTest,
            contentTestUseCase: _contentTestUseCase,
            onTestCompleted: (score) {
              // Callback khi hoàn thành bài kiểm tra
              debugPrint('Điểm số: $score');
              // Tải lại danh sách đề thi nếu cần
              _loadTests();
            },
          ),
        ),
      );
    } catch (e) {
      // Đóng dialog loading
      Navigator.pop(context);
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải nội dung bài kiểm tra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingTest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Danh sách đề thi', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đề thi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _loadTests();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          
          // Danh sách đề thi
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!, style: TextStyle(color: textColor)))
                : _buildTestList(isDarkMode),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestList(bool isDarkMode) {
    if (_testData == null || _testData!.content.isEmpty) {
      return Center(
        child: Text(
          'Không có đề thi nào',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
            fontSize: 16,
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTests,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _testData!.content.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _testData!.content.length) {
            return _buildLoadingIndicator();
          }
          
          return _buildTestCard(_testData!.content[index], isDarkMode);
        },
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
  
  Widget _buildTestCard(MyTestItem test, bool isDarkMode) {
    // Format date
    final formattedDate = DateFormat('dd/MM/yyyy').format(test.testCreatedAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Xử lý khi nhấn vào đề thi
          _openTest(test);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh preview
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                test.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    width: double.infinity,
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            
            // Nội dung
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.testTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ngày tạo: $formattedDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoadingTest ? null : () => _openTest(test),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isLoadingTest
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Làm bài'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
