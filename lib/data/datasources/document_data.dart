import '../models/document_model.dart';

class DocumentRemoteDatasource {
  Future<List<DocumentModel>> getDocuments() async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data response
    return [
      DocumentModel(
        id: '1',
        title:
            'Nghiên cứu ứng dụng trí tuệ nhân tạo trong phân tích dữ liệu Y tế',
        type: 'pdf',
        pageCount: 15,
        views: 324,
        downloads: 120,
        category: 'Y tế',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '2',
        title: 'Thuật toán và cấu trúc dữ liệu cơ bản',
        type: 'word',
        pageCount: 78,
        views: 456,
        downloads: 67,
        category: 'Công nghệ',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '3',
        title: 'Phân tích dữ liệu kinh tế vĩ mô Việt Nam 2023',
        type: 'excel',
        pageCount: 42,
        views: 189,
        downloads: 53,
        category: 'Kinh tế',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '4',
        title: 'Đề xuất giải pháp nâng cao hiệu quả quản lý doanh nghiệp',
        type: 'ppt',
        pageCount: 32,
        views: 275,
        downloads: 98,
        category: 'Kinh tế',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '5',
        title: 'Giáo trình Vật lý Đại cương phần Cơ học',
        type: 'pdf',
        pageCount: 120,
        views: 1257,
        downloads: 482,
        category: 'Giáo dục',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '6',
        title: 'Cơ sở dữ liệu phân tán và ứng dụng',
        type: 'word',
        pageCount: 67,
        views: 320,
        downloads: 112,
        category: 'Công nghệ',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '7',
        title: 'Nguyên lý và ứng dụng IoT trong nông nghiệp',
        type: 'pdf',
        pageCount: 54,
        views: 427,
        downloads: 230,
        category: 'Kỹ thuật',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
      DocumentModel(
        id: '8',
        title: 'Phân tích cấu trúc thị trường tài chính Việt Nam',
        type: 'excel',
        pageCount: 28,
        views: 312,
        downloads: 85,
        category: 'Kinh tế',
        thumbnailUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }

  // Increment document views count
  Future<void> incrementViews(DocumentModel document) async {
    // In real implementation, this would make an API call
    document.increaseViews();
  }
}
