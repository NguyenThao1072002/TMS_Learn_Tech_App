// import 'package:flutter/material.dart';
// import 'package:tms_app/presentation/screens/my_account/my_course/take_test.dart';
// import 'package:tms_app/presentation/screens/my_account/my_course/lesson_content_screen.dart'
//     as lesson_content;

// /// A helper class to manage creating and launching tests after lessons
// class CourseTestHelper {
//   /// Generate a sample test for a lesson
//   static List<TestQuestion> generateSampleTest(String lessonTitle) {
//     return [
//       TestQuestion(
//         questionText: 'Đâu là đặc điểm chính của Flutter Framework?',
//         type: QuestionType.multipleChoice,
//         options: [
//           'Chỉ phát triển ứng dụng Android',
//           'Sử dụng JavaScript để lập trình',
//           'Tạo ứng dụng native cho nhiều nền tảng từ một codebase',
//           'Yêu cầu nhiều ngôn ngữ lập trình khác nhau',
//         ],
//         correctAnswer: 2, // index of correct option
//         points: 10,
//       ),
//       TestQuestion(
//         questionText: 'Đánh dấu tất cả các widget cơ bản trong Flutter:',
//         type: QuestionType.checkboxes,
//         options: [
//           'StatelessWidget',
//           'ViewGroup',
//           'StatefulWidget',
//           'Activity',
//           'Container',
//           'Fragment',
//         ],
//         correctAnswer: [0, 2, 4], // indices of correct options
//         points: 10,
//       ),
//       TestQuestion(
//         questionText: 'Flutter sử dụng ngôn ngữ lập trình nào?',
//         type: QuestionType.fillInBlank,
//         options: [],
//         correctAnswer: 'Dart',
//         points: 10,
//       ),
//       TestQuestion(
//         questionText:
//             'Giải thích cách quản lý trạng thái (state management) trong Flutter và tại sao nó quan trọng trong việc phát triển ứng dụng.',
//         type: QuestionType.essay,
//         options: [],
//         correctAnswer: '', // essay will be marked manually
//         points: 10,
//       ),
//       TestQuestion(
//         questionText: 'Đâu là lợi ích chính của Flutter Hot Reload?',
//         type: QuestionType.multipleChoice,
//         options: [
//           'Tăng kích thước ứng dụng',
//           'Xem thay đổi ngay lập tức mà không mất trạng thái',
//           'Tự động sửa lỗi trong code',
//           'Tối ưu hóa hiệu suất ứng dụng',
//         ],
//         correctAnswer: 1,
//         points: 10,
//       ),
//     ];
//   }

//   /// Generate sample materials for a lesson
//   static List<lesson_content.MaterialItem> generateSampleMaterials() {
//     return [
//       lesson_content.MaterialItem(
//         title: 'Hướng dẫn Flutter cơ bản',
//         description: 'Tài liệu PDF về các khái niệm cơ bản của Flutter',
//         type: lesson_content.MaterialType.pdf,
//         url: 'https://example.com/flutter_basics.pdf',
//       ),
//       lesson_content.MaterialItem(
//         title: 'Mã nguồn ví dụ',
//         description: 'Mã nguồn của ứng dụng mẫu được đề cập trong bài học',
//         type: lesson_content.MaterialType.code,
//         url: 'https://github.com/example/flutter_sample',
//       ),
//       lesson_content.MaterialItem(
//         title: 'Slide bài giảng',
//         description: 'Slide trình bày các khái niệm chính trong bài học',
//         type: lesson_content.MaterialType.presentation,
//         url: 'https://example.com/flutter_slides.pptx',
//       ),
//     ];
//   }

//   /// Launch a test for a specific lesson
//   static void launchLessonTest(BuildContext context, String lessonTitle) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => TakeTestScreen(
//           testTitle: 'Kiểm tra: $lessonTitle',
//           questionCount: generateSampleTest(lessonTitle).length,
//           timeInMinutes: 15,
//           questions: generateSampleTest(lessonTitle),
//         ),
//       ),
//     );
//   }

//   /// Launch the lesson content screen
//   static void launchLessonContent(
//     BuildContext context,
//     String lessonTitle,
//     String courseTitle,
//   ) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => lesson_content.LessonContentScreen(
//           lessonTitle: lessonTitle,
//           courseTitle: courseTitle,
//           videoUrl: 'dDn9uw7N9Xg', // Sample YouTube video ID
//           materials: generateSampleMaterials(),
//           summary: '''
// Flutter là một framework UI mã nguồn mở được tạo bởi Google để xây dựng ứng dụng đa nền tảng với một codebase duy nhất. 

// Trong bài học này, chúng ta đã tìm hiểu về cách Flutter sử dụng Dart làm ngôn ngữ lập trình và cách nó hoạt động thông qua hệ thống widget. Flutter sử dụng một cách tiếp cận "mọi thứ đều là widget" để xây dựng giao diện người dùng, từ các thành phần cơ bản như text và button đến các layout phức tạp.

// Chúng ta cũng đã tìm hiểu về hai loại widget cơ bản: StatelessWidget và StatefulWidget, và khi nào nên sử dụng mỗi loại. Ngoài ra, chúng ta đã khám phá các widget layout phổ biến như Container, Row, Column và cách kết hợp chúng để tạo giao diện người dùng phức tạp.

// Một trong những điểm mạnh của Flutter là khả năng Hot Reload, cho phép chúng ta thấy kết quả thay đổi ngay lập tức mà không làm mất trạng thái ứng dụng hiện tại, giúp tăng tốc quá trình phát triển.
//           ''',
//           hasTest: true,
//         ),
//       ),
//     );
//   }
// }
