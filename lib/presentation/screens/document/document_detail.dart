import 'package:flutter/material.dart';
import 'package:tms_app/data/models/document/document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package for launching URLs
import 'package:tms_app/presentation/controller/documnet_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/domain/usecases/documents_usecase.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory, getExternalStorageDirectory, getDownloadsDirectory;
import 'package:tms_app/presentation/widgets/document/header.dart'; // Import DocumentHeader

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;
  final DocumentController? controller;

  const DocumentDetailScreen({
    Key? key, 
    required this.document,
    this.controller,
  }) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  int _currentPage = 1;
  final PageController _pageController = PageController();
  bool _isLoggedIn = false; // Trạng thái đăng nhập

  // Các biến để xử lý tài liệu từ URL
  File? _localFile;
  bool _isLoading = true;
  String? _errorMessage;

  // Số trang xem trước tối đa
  final int _maxPreviewPages = 3;

  // Thêm biến để kiểm soát chế độ xem đầy đủ
  bool _isFullView = false;

  // Thêm biến để lưu tổng số trang thực tế của tài liệu
  int _totalPages = 3; // Mặc định là 3 nhưng sẽ được cập nhật khi tải tài liệu

  late DocumentController _documentController;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    // Tải và lưu tài liệu để xem trước
    _loadDocumentForPreview();
    
    // Khởi tạo controller hoặc sử dụng controller được truyền vào
    _documentController = widget.controller ?? DocumentController(GetIt.instance<DocumentUseCase>());
    
    // Nếu tài liệu có categoryId, tải tài liệu liên quan
    if (widget.document.categoryId != null) {
      _loadRelatedDocuments(widget.document.categoryId!);
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  // Hàm mới để tải tài liệu từ URL và lưu vào bộ nhớ tạm
  Future<void> _loadDocumentForPreview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy URL từ document model
      final url = widget.document.fileUrl;

      // Tạo tên file dựa trên ID và định dạng
      final fileName = '${widget.document.id}_preview.${_getFileExtension()}';

      // Lấy thư mục tạm để lưu file
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';

      // Kiểm tra xem file đã tồn tại chưa
      final file = File(filePath);
      if (await file.exists()) {
        setState(() {
          _localFile = file;
          _isLoading = false;
          // Giả định số trang thực tế là 10 (trong thực tế sẽ được đọc từ file)
          _totalPages = 10;
        });
        return;
      }

      // Nếu chưa tồn tại, tải file từ URL
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Lưu nội dung tải xuống vào file
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localFile = file;
          _isLoading = false;
          // Giả định số trang thực tế là 10 (trong thực tế sẽ được đọc từ file)
          _totalPages = 10;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể tải tài liệu: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải tài liệu: $e';
        _isLoading = false;
      });
    }
  }

  // Kiểm tra xem tài liệu có phải là docx hoặc pptx không
  bool _needsWebsiteView() {
    final format = widget.document.format.toLowerCase();
    return format == 'word' ||
        format == 'doc' ||
        format == 'docx' ||
        format == 'ppt' ||
        format == 'pptx' ||
        format == 'powerpoint';
  }

  // Mở trang web để xem tài liệu
  void _openWebsiteToView() async {
    // Thay URL này bằng URL thực của trang web xem tài liệu
    final websiteUrl =
        'http://tmslearntech.io.vn/documents/${widget.document.id}';

    if (await canLaunch(websiteUrl)) {
      await launch(websiteUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở trang web. Vui lòng thử lại sau.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Lấy phần mở rộng của file dựa trên định dạng trong model
  String _getFileExtension() {
    final format = widget.document.format.toLowerCase();
    switch (format) {
      case 'pdf':
        return 'pdf';
      case 'word':
      case 'doc':
        return 'docx';
      case 'ppt':
      case 'powerpoint':
        return 'pptx';
      default:
        return 'pdf'; // Mặc định là PDF
    }
  }

  // Xử lý sự kiện tải xuống
  void _handleDownload() async {
    // Luôn cho phép tải xuống, không quan tâm đến trạng thái đăng nhập
    _downloadDocument();
  }

  // Tải tài liệu
  void _downloadDocument() async {
    try {
      // Hiển thị thông báo đang tải xuống
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tải xuống tài liệu...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Lấy URL từ document model
      final url = widget.document.fileUrl;
      final fileName = '${widget.document.title}_${widget.document.id}.${_getFileExtension()}';

      // Lấy thư mục Downloads hoặc Documents để lưu file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        _showDownloadError('Không thể tìm thấy thư mục lưu trữ.');
        return;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Bắt đầu tải xuống
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Lưu nội dung tải xuống vào file
        await file.writeAsBytes(response.bodyBytes);
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải xuống thành công. Lưu tại: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Tăng số lượt tải (nếu có API để cập nhật)
        _documentController.incrementDownload(widget.document.id);
      } else {
        _showDownloadError('Lỗi khi tải xuống: ${response.statusCode}');
      }
    } catch (e) {
      _showDownloadError('Lỗi khi tải xuống: $e');
    }
  }
  
  void _showDownloadError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Lấy số lượng trang xem trước dựa vào chế độ xem
  int _getViewablePageCount() {
    if (_isFullView) {
      return _totalPages; // Trả về tổng số trang thực tế
    } else {
      return _maxPreviewPages; // Trả về số trang xem trước tối đa (3)
    }
  }

  // Xử lý nút Xem Thêm
  void _handleViewMore() {
    if (_needsWebsiteView()) {
      // Nếu là docx hoặc pptx, hiển thị thông báo và mở website
      _showWebsiteViewDialog();
    } else {
      // Nếu không, cho phép xem đầy đủ tài liệu
      setState(() {
        _isFullView = true;
      });
    }
  }

  // Hiển thị hộp thoại thông báo xem trên website
  void _showWebsiteViewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mở trang web để xem'),
        content: Text(
          'Tài liệu định dạng ${widget.document.format.toUpperCase()} cần được xem trên trang web. Bạn có muốn mở trang web để xem toàn bộ tài liệu không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openWebsiteToView();
            },
            child: const Text('Mở trang web'),
          ),
        ],
      ),
    );
  }

  // Hàm cập nhật để xem trước tài liệu từ URL
  Widget _buildDocumentPreviewPage(int pageNumber, bool isDarkMode) {
    // Nếu đang tải, hiển thị biểu tượng tải
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải tài liệu...'),
          ],
        ),
      );
    }

    // Nếu có lỗi, hiển thị thông báo lỗi
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // Hiển thị trang xem trước dựa vào định dạng tài liệu
    return Stack(
      children: [
        // Nội dung tài liệu (dùng cách hiển thị tạm thời)
        _buildDocumentViewerByType(pageNumber, isDarkMode),

        // Watermark - chỉ hiển thị khi không phải là xem đầy đủ
        if (!_isFullView)
          Center(
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(315 / 360),
              child: Text(
                'Trang xem trước\n${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.grey.withOpacity(0.1),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Page number
        Positioned(
          bottom: 16,
          right: 16,
          child: Text(
            '$pageNumber / ${_getViewablePageCount()}',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  // Hiển thị tài liệu dựa vào loại định dạng
  Widget _buildDocumentViewerByType(int pageNumber, bool isDarkMode) {
    // Đây là nơi bạn sẽ tích hợp với thư viện thực tế để hiển thị tài liệu
    // Hiện tại chúng ta sẽ sử dụng phương thức giả để mô phỏng
    final format = widget.document.format.toLowerCase();

    switch (format) {
      case 'pdf':
        // Dùng SyncfusionFlutterPdfViewer trong phiên bản thực tế
        // Trong ví dụ này, chúng ta sẽ hiển thị chế độ xem giả
        return _buildPdfPreview(pageNumber, isDarkMode);

      case 'word':
      case 'doc':
      case 'docx':
        // Nếu đã nhấn "Xem thêm", hiển thị thông báo xem trên website
        if (_isFullView) {
          return _buildWebsiteRedirectView(format, isDarkMode);
        }
        return _buildWordPreview(pageNumber, isDarkMode);

      case 'ppt':
      case 'pptx':
      case 'powerpoint':
        // Nếu đã nhấn "Xem thêm", hiển thị thông báo xem trên website
        if (_isFullView) {
          return _buildWebsiteRedirectView(format, isDarkMode);
        }
        return _buildPowerPointPreview(pageNumber, isDarkMode);

      default:
        return _buildFallbackPreviewPage(pageNumber, isDarkMode);
    }
  }

  // Widget hiển thị thông báo điều hướng đến website
  Widget _buildWebsiteRedirectView(String format, bool isDarkMode) {
    String formatName = format.toUpperCase();
    if (format.contains('word') || format.contains('doc')) {
      formatName = 'Word';
    } else if (format.contains('ppt') || format.contains('powerpoint')) {
      formatName = 'PowerPoint';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.open_in_browser,
            size: 80,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Xem tài liệu $formatName trên website',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tài liệu định dạng $formatName cần được xem trên trang web.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Mở trang web để xem'),
            onPressed: _openWebsiteToView,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị PDF
  Widget _buildPdfPreview(int pageNumber, bool isDarkMode) {
    if (_localFile == null) return _buildFallbackPreviewPage(pageNumber, isDarkMode);

    // Sử dụng flutter_pdfview thay vì SyncfusionFlutterPdfViewer
    return PDFView(
      filePath: _localFile!.path,
      defaultPage: pageNumber - 1,
      swipeHorizontal: true,
      pageSnap: true,
      pageFling: true,
      onPageChanged: (page, total) {
        // Trang được tính từ 0, nên cần +1
        setState(() {
          _currentPage = (page ?? 0) + 1;
          if (total != null && total > 0) {
            _totalPages = total;
          }
        });
      },
    );
  }

  // Hiển thị Word
  Widget _buildWordPreview(int pageNumber, bool isDarkMode) {
    if (_localFile == null) return _buildFallbackPreviewPage(pageNumber, isDarkMode);

    // Trong phiên bản thực tế, bạn cần tìm thư viện thích hợp để hiển thị Word
    // Hiển thị mẫu tạm thời
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article,
            size: 80,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Xem trước Word - Trang $pageNumber',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'File: ${_localFile!.path.split('/').last}',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (pageNumber == 1)
            Column(
              children: [
                Text(
                  widget.document.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.document.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          else if (pageNumber == 2)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHẦN I: ĐẶT VẤN ĐỀ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Hiện học đối với hành văn đề...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            )
          else
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHẦN II: NỘI DUNG',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Giới thiệu\n2. Phương pháp nghiên cứu\n3. Kết quả và thảo luận',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Hiển thị PowerPoint
  Widget _buildPowerPointPreview(int pageNumber, bool isDarkMode) {
    if (_localFile == null) return _buildFallbackPreviewPage(pageNumber, isDarkMode);

    // Trong phiên bản thực tế, bạn cần tìm thư viện thích hợp để hiển thị PowerPoint
    // Hiển thị mẫu tạm thời
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.slideshow,
            size: 80,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Xem trước PowerPoint - Slide $pageNumber',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'File: ${_localFile!.path.split('/').last}',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                'Slide $pageNumber',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Trang xem trước thay thế khi không thể hiển thị tài liệu
  Widget _buildFallbackPreviewPage(int pageNumber, bool isDarkMode) {
    // Mô phỏng nội dung trang
    String pageContent = 'Nội dung trang $pageNumber';
    if (pageNumber == 1) {
      pageContent = widget.document.title;
    } else if (pageNumber == 2) {
      pageContent = 'PHẦN I: ĐẶT VẤN ĐỀ\n\nHiện học đối với hành văn đề...';
    } else if (pageNumber == 3) {
      pageContent =
          'PHẦN II: NỘI DUNG\n\n1. Giới thiệu\n2. Phương pháp nghiên cứu\n3. Kết quả và thảo luận';
    } else {
      // Nếu trang > 3, tạo nội dung mẫu cho trang đó
      pageContent =
          'PHẦN ${pageNumber - 1}: NỘI DUNG MỞ RỘNG\n\nĐây là nội dung của trang $pageNumber trong chế độ xem đầy đủ.';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pageNumber == 1)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    _getDocumentIcon(),
                    size: 80,
                    color: _getDocumentIconColor(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.document.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Loại: ${widget.document.format.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dung lượng: ${widget.document.size}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  pageContent,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon() {
    String format = widget.document.format.toLowerCase();
    if (format == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (format == 'word' || format == 'doc' || format == 'docx') {
      return Icons.article;
    } else if (format == 'excel' || format == 'xls' || format == 'xlsx') {
      return Icons.table_chart;
    } else if (format == 'ppt' || format == 'pptx' || format == 'powerpoint') {
      return Icons.slideshow;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color _getDocumentIconColor() {
    String format = widget.document.format.toLowerCase();
    if (format == 'pdf') {
      return Colors.red.shade400;
    } else if (format == 'word' || format == 'doc' || format == 'docx') {
      return Colors.blue.shade400;
    } else if (format == 'excel' || format == 'xls' || format == 'xlsx') {
      return Colors.green.shade400;
    } else if (format == 'ppt' || format == 'pptx' || format == 'powerpoint') {
      return Colors.orange.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
      appBar: DocumentHeader(
        document: widget.document,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề tài liệu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.document.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 47, 78, 255)),
              ),
            ),

            // Thông tin cơ bản
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildInfoItem(Icons.description, '$_totalPages', isDarkMode),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                      Icons.remove_red_eye, '${widget.document.view}', isDarkMode),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                      Icons.download, '${widget.document.downloads}', isDarkMode),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Xem trước tài liệu
            Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Thanh công cụ xem trước
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                      border: Border(
                          bottom: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 18),
                              onPressed: _currentPage > 1
                                  ? () {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              color:
                                  _currentPage > 1 ? (isDarkMode ? Colors.white : Colors.black) : Colors.grey,
                            ),
                            Text(
                              '$_currentPage / ${_getViewablePageCount()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 18),
                              onPressed: _currentPage < _getViewablePageCount()
                                  ? () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              color: _currentPage < _getViewablePageCount()
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : Colors.grey,
                            ),
                          ],
                        ),
                        Text(
                          _isFullView
                              ? 'Xem đầy đủ'
                              : 'Xem trước ${_maxPreviewPages} trang',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nội dung xem trước
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _getViewablePageCount(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index + 1;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildDocumentPreviewPage(index + 1, isDarkMode);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Nút tải xuống và xem thêm
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildButton(
                    _isFullView ? 'THU GỌN' : 'XEM THÊM',
                    const Color.fromARGB(255, 0, 188, 169),
                    _isFullView
                        ? () {
                            setState(() {
                              _isFullView = false;
                              // Reset về trang đầu tiên khi thu gọn
                              _pageController.jumpToPage(0);
                              _currentPage = 1;
                            });
                          }
                        : _handleViewMore,
                  ),
                  const SizedBox(height: 12),
                  _buildButton(
                    'TẢI XUỐNG',
                    const Color.fromARGB(255, 255, 157, 10),
                    _handleDownload,
                  ),
                ],
              ),
            ),

            // Thông báo giới hạn
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _isFullView
                    ? 'Bạn đang xem đầy đủ tài liệu'
                    : 'Tài liệu hạn chế xem trước, để xem đầy đủ mời bạn chọn Xem Thêm hoặc Tải xuống',
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            // Thông báo redirect đối với docx/pptx
            if (_needsWebsiteView())
              Container(
                padding: const EdgeInsets.all(12),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tài liệu định dạng ${widget.document.format.toUpperCase()} cần được mở trên trang web để xem đầy đủ.',
                        style: TextStyle(color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Thông tin tài liệu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'THÔNG TIN TÀI LIỆU',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // Bảng thông tin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildInfoTable(isDarkMode),
            ),

            const SizedBox(height: 24),
            
            // Thêm phần tài liệu liên quan
            _buildRelatedDocumentsSection(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTable(bool isDarkMode) {
    return Table(
      border: TableBorder.all(
        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      children: [
        _buildTableRow('Định dạng', _buildFileTypeRow(isDarkMode), isDarkMode),
        _buildTableRow('Dung lượng', Text(
          _formatFileSize(widget.document.size),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ), isDarkMode),
      ],
    );
  }

  TableRow _buildTableRow(String label, Widget content, bool isDarkMode) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: content,
        ),
      ],
    );
  }

  // Hàm định dạng dung lượng từ chuỗi thành MB, KB
  String _formatFileSize(String sizeString) {
    // Trích xuất số từ chuỗi
    RegExp regExp = RegExp(r'[0-9.]+');
    final match = regExp.firstMatch(sizeString);
    if (match == null) return sizeString;
    
    String numberStr = match.group(0) ?? '';
    double size;
    try {
      size = double.parse(numberStr);
    } catch (e) {
      return sizeString;
    }
    
    // Xác định đơn vị
    if (sizeString.toLowerCase().contains('mb')) {
      return '${size.toStringAsFixed(2)} MB';
    } else if (sizeString.toLowerCase().contains('kb')) {
      return '${size.toStringAsFixed(2)} KB';
    } else if (size > 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (size > 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$size Bytes';
    }
  }

  Color _getColorForDocType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'word':
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'excel':
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
      case 'powerpoint':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFileTypeRow(bool isDarkMode) {
    String format = widget.document.format.toLowerCase();

    // Default colors (gray for inactive badges)
    Color wordColor = Colors.grey.shade400;
    Color pdfColor = Colors.grey.shade400;
    Color xlsColor = Colors.grey.shade400;
    Color pptxColor = Colors.grey.shade400; // Thêm màu cho PPTX

    // Determine which badge should be highlighted based on the document format
    if (format == 'word' || format == 'doc' || format == 'docx') {
      wordColor = Colors.blue;
    } else if (format == 'pdf') {
      pdfColor = Colors.red;
    } else if (format == 'excel' || format == 'xls' || format == 'xlsx') {
      xlsColor = Colors.green;
    } else if (format == 'ppt' || format == 'pptx' || format == 'powerpoint') {
      pptxColor = Colors.orange;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: wordColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'W',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: pdfColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'PDF',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: xlsColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'XLS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: pptxColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'PPTX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Tải tài liệu liên quan
  Future<void> _loadRelatedDocuments(int categoryId) async {
    await _documentController.loadRelatedDocuments(categoryId);
  }

  // Tạo section tài liệu liên quan
  Widget _buildRelatedDocumentsSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TÀI LIỆU LIÊN QUAN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<DocumentModel>>(
            valueListenable: _documentController.relatedDocuments,
            builder: (context, relatedDocs, child) {
              // Lọc bỏ tài liệu đang xem khỏi danh sách tài liệu liên quan
              final filteredDocs = relatedDocs
                  .where((doc) => doc.id != widget.document.id)
                  .toList();
                  
              if (filteredDocs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Không có tài liệu liên quan',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDocs.length > 5 ? 5 : filteredDocs.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                ),
                itemBuilder: (context, index) {
                  final document = filteredDocs[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentDetailScreen(
                            document: document,
                            controller: _documentController,
                          ),
                        ),
                      );
                    },
                    child: _buildRelatedDocument(
                      document.title,
                      document.format,
                      document.view,
                      document.downloads,
                      isDarkMode,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedDocument(
    String title,
    String type,
    int views,
    int downloads,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getColorForDocType(type),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoItem(Icons.remove_red_eye, '$views', isDarkMode),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.download, '$downloads', isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
