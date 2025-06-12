import 'package:tms_app/data/models/my_test/my_test_list_model.dart';
import 'package:tms_app/data/models/my_test/test_result_model.dart';
import 'package:tms_app/data/models/my_test/test_result_detail_model.dart';
import 'package:tms_app/data/models/my_test/test_answer_model.dart';

/// Interface định nghĩa các phương thức làm việc với danh sách đề thi
abstract class MyTestListRepository {
  /// Lấy danh sách đề thi của tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy đề thi
  /// [page] là số trang (mặc định là 0)
  /// [size] là kích thước trang (mặc định là 20)
  /// [search] là từ khóa tìm kiếm (tùy chọn)
  Future<MyTestPaginatedData> getTestsByAccountExam(
    int accountId, {
    int page = 0,
    int size = 20,
    String? search,
  });

  /// Lấy danh sách kết quả đề thi của tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy kết quả đề thi
  /// [page] là số trang (mặc định là 0)
  /// [size] là kích thước trang (mặc định là 20)
  /// [search] là từ khóa tìm kiếm (tùy chọn)
  Future<TestResultPaginatedData> getTestResultsByAccountExam(
    int accountId, {
    int page = 0,
    int size = 20,
    String? search,
  });
  
  /// Lấy danh sách các kết quả làm bài của một bài kiểm tra cụ thể
  /// 
  /// [testId] là ID của bài kiểm tra cần lấy kết quả
  /// [accountId] là ID của tài khoản (nếu cần lọc theo tài khoản cụ thể)
  Future<TestResultDetailResponse> getTestResultsByTest(
    int testId, {
    int? accountId,
  });
  
  /// Lấy chi tiết câu trả lời của một bài làm cụ thể
  /// 
  /// [accountId] là ID của tài khoản đã làm bài
  /// [testId] là ID của bài kiểm tra
  /// [testResultId] là ID của kết quả bài làm cần lấy chi tiết
  Future<TestAnswerResponse> getTestAnswers({
    required int accountId,
    required int testId,
    required int testResultId,
  });
}
