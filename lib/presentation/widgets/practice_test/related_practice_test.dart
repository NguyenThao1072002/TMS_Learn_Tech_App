import 'package:flutter/material.dart';
import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_detail.dart';
import 'package:tms_app/presentation/widgets/practice_test/practice_test_card.dart';

class RelatedPracticeTest extends StatefulWidget {
  final PracticeTestUseCase practiceTestUseCase;
  final int currentTestId;
  final int courseId;
  final int size;

  const RelatedPracticeTest({
    Key? key,
    required this.practiceTestUseCase,
    required this.currentTestId,
    required this.courseId,
    this.size = 5,
  }) : super(key: key);

  @override
  State<RelatedPracticeTest> createState() => _RelatedPracticeTestState();
}

class _RelatedPracticeTestState extends State<RelatedPracticeTest> {
  late Future<List<PracticeTestCardModel>> _relatedTestsFuture;

  @override
  void initState() {
    super.initState();
    _relatedTestsFuture = _loadRelatedTests();
  }

  Future<List<PracticeTestCardModel>> _loadRelatedTests() async {
    try {
      print('Đang tải đề thi liên quan cho courseId: ${widget.courseId}');
      // Sử dụng API tests/exam/public với tham số lọc courseId
      final tests = await widget.practiceTestUseCase.getPracticeTests(
        courseId: widget.courseId,
        page: 0,
        size: widget.size +
            5, // Lấy thêm nhiều đề thi để đảm bảo có đủ sau khi lọc
      );

      print(
          'Đã tải ${tests.length} đề thi, lọc bỏ đề hiện tại: ${widget.currentTestId}');

      // Lọc bỏ đề thi hiện tại
      final filteredTests = tests
          .where((test) => test.testId != widget.currentTestId)
          .take(widget.size)
          .toList();

      print('Số đề thi liên quan sau khi lọc: ${filteredTests.length}');

      return filteredTests;
    } catch (e) {
      print('Lỗi khi tải đề thi liên quan: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đề thi liên quan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<PracticeTestCardModel>>(
          future: _relatedTestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              print('Lỗi khi hiển thị đề thi liên quan: ${snapshot.error}');
              return Center(
                child: Text(
                  'Không thể tải đề thi liên quan',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            final filteredTests = snapshot.data ?? [];

            if (filteredTests.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Không có đề thi liên quan',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 390, // Chiều cao phù hợp với kích thước thẻ
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredTests.length,
                itemBuilder: (context, index) {
                  final test = filteredTests[index];
                  // Sử dụng chiều rộng nhỏ hơn cho cuộn ngang
                  return SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: PracticeTestCard(
                        test: test,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PracticeTestDetailScreen(
                                testId: test.testId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
