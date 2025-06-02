import 'package:tms_app/data/models/my_course/test/content_test_model.dart';
import 'package:tms_app/data/services/my_course/content_test_service.dart';
import 'package:tms_app/domain/repositories/my_course/content_test_repository.dart';

/// Triển khai ContentTestRepository
class ContentTestRepositoryImpl implements ContentTestRepository {
  final ContentTestService _contentTestService;

  ContentTestRepositoryImpl({required ContentTestService contentTestService})
      : _contentTestService = contentTestService;

  /// Lấy nội dung bài kiểm tra theo testId
  ///
  /// [testId] là ID của bài kiểm tra cần lấy
  @override
  Future<ContentTestModel> getContentTest(int testId) async {
    try {
      final response = await _contentTestService.getContentTest(testId);

      // Trả về dữ liệu từ response
      return response.data;
    } catch (e) {
      // Chuyển tiếp lỗi từ service
      throw e;
    }
  }
}
