import 'package:flutter/material.dart';
import 'package:tms_app/data/models/document/document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentDetailScreen({Key? key, required this.document})
      : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  int _currentPage = 1;
  final PageController _pageController = PageController();
  bool _isLoggedIn = false; // Trạng thái đăng nhập
  int _downloadCount = 0; // Số lần đã tải
  final int _maxDownloads =
      3; // Số lần tải tối đa cho người dùng chưa đăng nhập

  @override
  void initState() {
    super.initState();
    _loadDownloadCount();
    // Trong ứng dụng thực tế, kiểm tra trạng thái đăng nhập từ hệ thống quản lý trạng thái
    _checkLoginStatus();
  }

  // Kiểm tra trạng thái đăng nhập
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  // Lấy số lần tải xuống từ local storage
  Future<void> _loadDownloadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadCount = prefs.getInt('downloadCount') ?? 0;
    });
  }

  // Lưu số lần tải xuống vào local storage
  Future<void> _saveDownloadCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('downloadCount', _downloadCount);
  }

  // Xử lý sự kiện tải xuống
  void _handleDownload() async {
    if (_isLoggedIn) {
      _downloadDocument();
    } else {
      if (_downloadCount < _maxDownloads) {
        setState(() {
          _downloadCount++;
        });
        await _saveDownloadCount();
        _downloadDocument();
      } else {
        _showLoginRequiredDialog();
      }
    }
  }

  // Tải tài liệu
  void _downloadDocument() {
    // Tăng biến đếm downloads trong model
    widget.document.downloads++;

    // TODO: Logic tải tài liệu thực tế
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tải xuống tài liệu...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Hiển thị hộp thoại yêu cầu đăng nhập
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text(
          'Bạn đã vượt quá giới hạn tải xuống cho người dùng chưa đăng nhập. Vui lòng đăng nhập để tiếp tục tải xuống.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  // Điều hướng đến trang đăng nhập
  void _navigateToLogin() {
    // TODO: Điều hướng đến trang đăng nhập
    // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
                  _buildInfoItem(
                      Icons.description, '${widget.document.pageCount}'),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                      Icons.remove_red_eye, '${widget.document.views}'),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                      Icons.download, '${widget.document.downloads}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Xem trước tài liệu - 3 trang đầu
            Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Thanh công cụ xem trước
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
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
                                  _currentPage > 1 ? Colors.black : Colors.grey,
                            ),
                            Text(
                              '$_currentPage / ${_getPreviewPageCount()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 18),
                              onPressed: _currentPage < _getPreviewPageCount()
                                  ? () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              color: _currentPage < _getPreviewPageCount()
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ],
                        ),
                        Text(
                          'Xem trước ${_getPreviewPageCount()} trang',
                          style: TextStyle(
                            color: Colors.grey[600],
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
                      itemCount: _getPreviewPageCount(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index + 1;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildDocumentPreviewPage(index + 1);
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
                    'XEM THÊM',
                    const Color.fromARGB(255, 0, 188, 169),
                    () {},
                  ),
                  const SizedBox(height: 12),
                  _buildButton(
                    'TẢI XUỐNG${!_isLoggedIn ? " (${_maxDownloads - _downloadCount}/${_maxDownloads} lần)" : ""}',
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
                'Tài liệu hạn chế xem trước, để xem đầy đủ mời bạn chọn Tải xuống',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            // Thông tin tài liệu
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'THÔNG TIN TÀI LIỆU',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Bảng thông tin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildInfoTable(),
            ),

            const SizedBox(height: 24),

            // Tài liệu cùng người dùng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TÀI LIỆU CÙNG NGƯỜI DÙNG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRelatedDocument(
                    'Nghiên cứu hiệu ứng phát hỏa ba bậc hai trên cấu trúc nano kim loại',
                    'pdf',
                    5,
                    517,
                    12,
                  ),
                  const Divider(),
                  _buildRelatedDocument(
                    'Nghiên cứu hiệu ứng từ nhiệt trên hệ hợp kim Fe73,5xMnx Cu1Nb3Si13.5B9 chế tạo bằng phương pháp quay nhanh',
                    'word',
                    57,
                    227,
                    0,
                  ),
                  const Divider(),
                  _buildRelatedDocument(
                    'QUẢN LÝ HOẠT ĐỘNG CUNG ỨNG CHẾ NGUYÊN LIỆU TẠI CÔNG TY CHẾ PHÚ BẾN TRE',
                    'word',
                    82,
                    483,
                    0,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  int _getPreviewPageCount() {
    // Giới hạn chỉ xem trước 3 trang hoặc ít hơn nếu tài liệu có ít hơn 3 trang
    return widget.document.pageCount > 3 ? 3 : widget.document.pageCount;
  }

  Widget _buildDocumentPreviewPage(int pageNumber) {
    // Simulating different content for different pages
    String pageContent = 'Nội dung trang $pageNumber';
    if (pageNumber == 1) {
      pageContent = widget.document.title;
    } else if (pageNumber == 2) {
      pageContent = 'PHẦN I: ĐẶT VẤN ĐỀ\n\nHiện học đối với hành văn đề...';
    } else if (pageNumber == 3) {
      pageContent =
          'PHẦN II: NỘI DUNG\n\n1. Giới thiệu\n2. Phương pháp nghiên cứu\n3. Kết quả và thảo luận';
    }

    String watermarkText = 'Trang xem trước\n${DateTime.now().year}';

    return Stack(
      children: [
        Container(
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
                        'Loại: ${widget.document.type.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Số trang: ${widget.document.pageCount}',
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
        ),
        // Watermark
        Center(
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation(315 / 360),
            child: Text(
              watermarkText,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.grey.withOpacity(0.1),
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
            '$pageNumber / ${widget.document.pageCount}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon() {
    String type = widget.document.type.toLowerCase();
    if (type == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (type == 'word' || type == 'doc' || type == 'docx') {
      return Icons.article;
    } else if (type == 'excel' || type == 'xls' || type == 'xlsx') {
      return Icons.table_chart;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color _getDocumentIconColor() {
    String type = widget.document.type.toLowerCase();
    if (type == 'pdf') {
      return Colors.red.shade400;
    } else if (type == 'word' || type == 'doc' || type == 'docx') {
      return Colors.blue.shade400;
    } else if (type == 'excel' || type == 'xls' || type == 'xlsx') {
      return Colors.green.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
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

  Widget _buildInfoTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      children: [
        _buildTableRow('Định dạng', _buildFileTypeRow()),
        _buildTableRow('Số trang', Text('${widget.document.pageCount}')),
        _buildTableRow('Dung lượng', const Text('28,96 MB')),
      ],
    );
  }

  TableRow _buildTableRow(String label, Widget content) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
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

  Widget _buildFileTypeRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
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
            color: Colors.red,
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
            color: Colors.green,
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
      ],
    );
  }

  Widget _buildRelatedDocument(
    String title,
    String type,
    int pages,
    int views,
    int downloads,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoItem(Icons.description, '$pages'),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.remove_red_eye, '$views'),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.download, '$downloads'),
                  ],
                ),
              ],
            ),
          ),
        ],
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
    } else {
      return Colors.grey;
    }
  }
}
