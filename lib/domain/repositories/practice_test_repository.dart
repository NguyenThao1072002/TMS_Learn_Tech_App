import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';

abstract class PracticeTestRepository {
  Future<List<PracticeTestCardModel>> getPracticeTests({
    String? search,
    int? courseId,
    int? accountId,
    int page,
    int size,
  });

  Future<PracticeTestDetailModel?> getPracticeTestDetail(
    int testId, {
    int? accountId,
  });

  Future<List<PracticeTestReviewModel>> getPracticeTestReviews(
    int testId, {
    int page,
    int size,
  });

  Future<bool> submitPracticeTestReview(
    int testId,
    int accountId,
    int rating, {
    String? review,
  });

  Future<List<Map<String, dynamic>>> getPracticeTestCategories();
}
