import 'package:tms_app/data/models/my_test/my_test_list_model.dart';
import 'package:tms_app/data/models/my_test/test_result_model.dart';
import 'package:tms_app/data/models/my_test/test_result_detail_model.dart';
import 'package:tms_app/data/models/my_test/test_answer_model.dart';
import 'package:tms_app/domain/repositories/my_test/my_test_list_repository.dart';

/// UseCase xử lý các tác vụ liên quan đến danh sách đề thi
class MyTestListUseCase {
  final MyTestListRepository _myTestListRepository;

  MyTestListUseCase(this._myTestListRepository);

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
  }) async {
    return await _myTestListRepository.getTestsByAccountExam(
      accountId,
      page: page,
      size: size,
      search: search,
    );
  }

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
  }) async {
    return await _myTestListRepository.getTestResultsByAccountExam(
      accountId,
      page: page,
      size: size,
      search: search,
    );
  }
  
  /// Lấy danh sách các kết quả làm bài của một bài kiểm tra cụ thể
  /// 
  /// [testId] là ID của bài kiểm tra cần lấy kết quả
  /// [accountId] là ID của tài khoản (nếu cần lọc theo tài khoản cụ thể)
  Future<TestResultDetailResponse> getTestResultsByTest(
    int testId, {
    int? accountId,
  }) async {
    return await _myTestListRepository.getTestResultsByTest(
      testId,
      accountId: accountId,
    );
  }

  /// Lấy chi tiết câu trả lời của một bài làm cụ thể
  /// 
  /// [accountId] là ID của tài khoản đã làm bài
  /// [testId] là ID của bài kiểm tra
  /// [testResultId] là ID của kết quả bài làm cần lấy chi tiết
  Future<TestAnswerResponse> getTestAnswers({
    required int accountId,
    required int testId,
    required int testResultId,
  }) async {
    return await _myTestListRepository.getTestAnswers(
      accountId: accountId,
      testId: testId,
      testResultId: testResultId,
    );
  }

  /// Lấy danh sách các đề thi gần đây nhất
  /// 
  /// [data] là dữ liệu phân trang các đề thi
  /// [count] là số lượng đề thi cần lấy (mặc định là 3)
  List<MyTestItem> getRecentTests(MyTestPaginatedData data, {int count = 3}) {
    final sortedTests = List<MyTestItem>.from(data.content);
    
    // Sắp xếp theo thời gian tạo mới nhất
    sortedTests.sort((a, b) => 
      b.testCreatedAt.compareTo(a.testCreatedAt));
    
    // Trả về [count] đề thi gần nhất
    return sortedTests.take(count).toList();
  }

  /// Tìm kiếm đề thi theo tiêu đề
  /// 
  /// [data] là dữ liệu phân trang các đề thi
  /// [query] là từ khóa tìm kiếm
  List<MyTestItem> searchTestsByTitle(MyTestPaginatedData data, String query) {
    if (query.isEmpty) return data.content;
    
    final lowercaseQuery = query.toLowerCase();
    
    return data.content.where((test) => 
      test.testTitle.toLowerCase().contains(lowercaseQuery)).toList();
  }
  
  /// Sắp xếp các kết quả đề thi theo phần trăm hoàn thành
  /// 
  /// [data] là dữ liệu phân trang các kết quả đề thi
  List<TestResultItem> sortTestResultsByCompletion(TestResultPaginatedData data) {
    final sortedTestResults = List<TestResultItem>.from(data.content);
    
    // Sắp xếp theo phần trăm hoàn thành cao nhất
    sortedTestResults.sort((a, b) => 
      b.completedPercentage.compareTo(a.completedPercentage));
    
    return sortedTestResults;
  }
  
  /// Tìm kiếm kết quả bài thi theo tiêu đề hoặc điểm số
  /// 
  /// [data] là danh sách kết quả làm bài
  /// [query] là từ khóa tìm kiếm
  List<TestResultDetail> searchTestResultDetails(List<TestResultDetail> data, String query) {
    if (query.isEmpty) return data;
    
    final lowercaseQuery = query.toLowerCase();
    
    return data.where((result) => 
      result.testTitle.toLowerCase().contains(lowercaseQuery) ||
      result.score.toString().contains(query)
    ).toList();
  }

  /// Đánh giá kết quả làm bài
  /// 
  /// [answers] là danh sách các câu trả lời
  Map<String, dynamic> evaluateTestAnswers(List<TestAnswer> answers) {
    int correctCount = 0;
    int incorrectCount = 0;
    
    for (final answer in answers) {
      if (answer.isCorrect) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    }
    
    final totalQuestions = answers.length;
    final completionRate = totalQuestions > 0 
        ? ((correctCount + incorrectCount) / totalQuestions) * 100 
        : 0.0;
    final correctRate = totalQuestions > 0 
        ? (correctCount / totalQuestions) * 100 
        : 0.0;
    
    return {
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'totalQuestions': totalQuestions,
      'completionRate': completionRate,
      'correctRate': correctRate,
    };
  }
}
