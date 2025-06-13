import 'package:tms_app/data/models/my_test/my_test_list_model.dart';
import 'package:tms_app/data/models/my_test/test_result_model.dart';
import 'package:tms_app/data/models/my_test/test_result_detail_model.dart';
import 'package:tms_app/data/models/my_test/test_answer_model.dart';
import 'package:tms_app/data/services/my_test/my_test_list_service.dart';
import 'package:tms_app/domain/repositories/my_test/my_test_list_repository.dart';

/// Triển khai MyTestListRepository
class MyTestListRepositoryImpl implements MyTestListRepository {
  final MyTestListService _myTestListService;

  MyTestListRepositoryImpl(this._myTestListService);

  /// Lấy danh sách đề thi của tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy đề thi
  /// [page] là số trang (mặc định là 0)
  /// [size] là kích thước trang (mặc định là 20)
  /// [search] là từ khóa tìm kiếm (tùy chọn)
  @override
  Future<MyTestPaginatedData> getTestsByAccountExam(
    int accountId, {
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    try {
      final response = await _myTestListService.getTestsByAccountExam(
        accountId,
        page: page,
        size: size,
        search: search,
      );

      // Trả về dữ liệu từ response
      return response.data;
    } catch (e) {
      // Chuyển tiếp lỗi từ service
      throw e;
    }
  }

  /// Lấy danh sách kết quả đề thi của tài khoản
  /// 
  /// [accountId] là ID của tài khoản cần lấy kết quả đề thi
  /// [page] là số trang (mặc định là 0)
  /// [size] là kích thước trang (mặc định là 20)
  /// [search] là từ khóa tìm kiếm (tùy chọn)
  @override
  Future<TestResultPaginatedData> getTestResultsByAccountExam(
    int accountId, {
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    try {
      final response = await _myTestListService.getTestResultsByAccountExam(
        accountId,
        page: page,
        size: size,
        search: search,
      );

      // Trả về dữ liệu từ response
      return response.data;
    } catch (e) {
      // Chuyển tiếp lỗi từ service
      throw e;
    }
  }
  
  /// Lấy danh sách các kết quả làm bài của một bài kiểm tra cụ thể
  /// 
  /// [testId] là ID của bài kiểm tra cần lấy kết quả
  /// [accountId] là ID của tài khoản (nếu cần lọc theo tài khoản cụ thể)
  @override
  Future<TestResultDetailResponse> getTestResultsByTest(
    int testId, {
    int? accountId,
  }) async {
    try {
      final response = await _myTestListService.getTestResultsByTest(
        testId,
        accountId: accountId,
      );

      // Trả về dữ liệu từ response
      return response;
    } catch (e) {
      // Chuyển tiếp lỗi từ service
      throw e;
    }
  }
  
  /// Lấy chi tiết câu trả lời của một bài làm cụ thể
  /// 
  /// [accountId] là ID của tài khoản đã làm bài
  /// [testId] là ID của bài kiểm tra
  /// [testResultId] là ID của kết quả bài làm cần lấy chi tiết
  @override
  Future<TestAnswerResponse> getTestAnswers({
    required int accountId,
    required int testId,
    required int testResultId,
  }) async {
    try {
      final response = await _myTestListService.getTestAnswers(
        accountId: accountId,
        testId: testId,
        testResultId: testResultId,
      );

      // Trả về dữ liệu từ response
      return response;
    } catch (e) {
      // Chuyển tiếp lỗi từ service
      throw e;
    }
  }
}
