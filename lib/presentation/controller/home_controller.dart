import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course_card_model.dart';
import 'package:tms_app/domain/usecases/course_usecase.dart';
import 'package:tms_app/presentation/screens/course/course_screen.dart';
import 'package:tms_app/presentation/screens/notification/notification_view.dart';
import 'package:tms_app/presentation/screens/my_account/overview_my_account.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../screens/Login/login.dart';

class HomeController {
  final ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final CourseUseCase courseUseCase;

  // Constructor của HomeController
  HomeController(this.courseUseCase);

  // Phương thức tính toán discountPercent và sắp xếp theo số lượng học viên
  List<CourseCardModel> _calculateDiscountPercentAndSortByPopularity(
      List<CourseCardModel> courses) {
    // Tính toán phần trăm giảm giá chỉ cho các khóa học chưa có discountPercent từ API
    for (var course in courses) {
      // Nếu API đã trả về discountPercent (>0), sử dụng giá trị từ API
      if (course.discountPercent > 0) continue;

      // Nếu không, tính toán dựa trên oldPrice và price
      if (course.oldPriceAsDouble != null &&
          course.oldPriceAsDouble! > course.price) {
        course.discountPercent = ((course.oldPriceAsDouble! - course.price) /
                course.oldPriceAsDouble! *
                100)
            .toInt();
      } else {
        course.discountPercent = 0; // Không có giảm giá
      }
    }

    // Sắp xếp khóa học theo số lượng học viên giảm dần
    courses.sort((a, b) => b.numberOfStudents.compareTo(a.numberOfStudents));

    return courses;
  }

  // Phương thức để lấy tất cả các khóa học
  Future<List<CourseCardModel>> getAllCourses() async {
    List<CourseCardModel> courses = await courseUseCase.getAllCourses();
    return _calculateDiscountPercentAndSortByPopularity(courses);
  }

  // Phương thức để lấy khóa học giảm giá (discount)
  Future<List<CourseCardModel>> getDiscountCourses() async {
    // Lấy danh sách khóa học giảm giá từ CourseUseCase
    List<CourseCardModel> courses = await courseUseCase.getDiscountCourses();

    // Tính toán discountPercent và sắp xếp theo số lượng học viên
    List<CourseCardModel> discountCourses =
        _calculateDiscountPercentAndSortByPopularity(courses);

    // Lọc ra chỉ các khóa học có discountPercent > 0 (khóa học có giảm giá)
    return discountCourses
        .where((course) => course.discountPercent > 0)
        .toList();
  }

  // Phương thức để lấy khóa học phổ biến (có nhiều học viên nhất)
  Future<List<CourseCardModel>> getPopularCourses() async {
    // Lấy danh sách khóa học phổ biến từ CourseUseCase
    List<CourseCardModel> courses = await courseUseCase.getPopularCourses();

    // Tính toán discountPercent và sắp xếp theo số lượng học viên
    List<CourseCardModel> popularCourses =
        _calculateDiscountPercentAndSortByPopularity(courses);

    // Lấy top 5 khóa học phổ biến nhất (theo số lượng học viên)
    return popularCourses.take(5).toList();
  }

  List<Widget> getScreens(
    Widget homePage,
    Widget documentPage,
  ) {
    return [
      homePage, // Index 0: Home
      WillPopScope(
        onWillPop: () async {
          // Chuyển về màn hình Home khi nhấn nút Back trong Document
          selectedIndex.value = 0;
          return false; // Không thực hiện hành động "pop" mặc định
        },
        child: documentPage, // Index 1: Document
      ),
      WillPopScope(
        onWillPop: () async {
          // Chuyển về màn hình Home khi nhấn nút Back trong Course
          selectedIndex.value = 0;
          return false;
        },
        child: const CourseScreen(), // Index 2: Course
      ),
      WillPopScope(
        onWillPop: () async {
          // Chuyển về màn hình Home khi nhấn nút Back trong Practice Tests
          selectedIndex.value = 0;
          return false;
        },
        child: const PracticeTestListScreen(), // Index 3: Practice Tests
      ),
      WillPopScope(
        onWillPop: () async {
          // Chuyển về màn hình Home khi nhấn nút Back trong Account
          selectedIndex.value = 0;
          return false;
        },
        child: const AccountOverviewScreen(), // Index 4: Account
      ),
    ];
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  void dispose() {
    selectedIndex.dispose();
  }
}
