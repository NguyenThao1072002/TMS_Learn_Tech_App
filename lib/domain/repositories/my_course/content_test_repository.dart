import 'package:tms_app/data/models/my_course/test/content_test_model.dart';

/// Interface định nghĩa các phương thức làm việc với nội dung bài kiểm tra
abstract class ContentTestRepository {
  /// Lấy nội dung bài kiểm tra theo testId
  ///
  /// [testId] là ID của bài kiểm tra cần lấy
  Future<ContentTestModel> getContentTest(int testId);
}
