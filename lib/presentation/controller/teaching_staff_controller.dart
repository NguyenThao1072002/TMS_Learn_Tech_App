import 'package:flutter/material.dart';
import 'package:tms_app/data/models/teaching_staff/teaching_staff_model.dart';
import 'package:tms_app/data/models/teaching_staff/teaching_staff_detail_model.dart';
import 'package:tms_app/domain/usecases/teaching_staff/teaching_staff_usecase.dart';
import 'package:get_it/get_it.dart';

class TeachingStaffController with ChangeNotifier {
  final TeachingStaffUseCase _teachingStaffUseCase;

  // Trạng thái dữ liệu
  bool isLoading = false;
  String? error;
  List<TeachingStaff> teachingStaffs = [];
  List<TeachingStaff> featuredTeachingStaffs = [];
  TeachingStaffDetail? selectedTeachingStaffDetail;

  // Bộ lọc
  String searchKeyword = '';
  int? selectedCategoryId;

  // Phân trang
  int currentPage = 0;
  int pageSize = 10;
  int totalPages = 0;
  bool hasMoreData = true;

  // Singleton instance
  static final TeachingStaffController _instance =
      TeachingStaffController._internal();

  // Factory constructor
  factory TeachingStaffController() => _instance;

  // Private constructor
  TeachingStaffController._internal()
      : _teachingStaffUseCase = GetIt.instance<TeachingStaffUseCase>();

  // Safe notify listeners implementation
  @override
  void notifyListeners() {
    try {
      super.notifyListeners();
    } catch (e) {
      // Ignore NoSuchMethodError or other errors caused by listeners
      print("Error during notification: $e");
    }
  }

  /// Lấy danh sách giảng viên
  Future<void> getTeachingStaffs({
    bool refresh = false,
    String? search,
    int? categoryId,
  }) async {
    try {
      if (refresh) {
        isLoading = true;
        currentPage = 0;
        hasMoreData = true;
        error = null;
        teachingStaffs.clear();
        notifyListeners();
      } else if (isLoading || !hasMoreData) {
        return;
      } else {
        isLoading = true;
        notifyListeners();
      }

      final response = await _teachingStaffUseCase.getTeachingStaffs(
        page: currentPage,
        size: pageSize,
        search: search ?? searchKeyword,
        categoryId: categoryId ?? selectedCategoryId,
      );

      // Cập nhật thông tin phân trang
      totalPages = response.data.totalPages;
      hasMoreData = currentPage < totalPages - 1;

      // Thêm dữ liệu mới vào danh sách
      if (refresh) {
        teachingStaffs = response.data.content;
      } else {
        teachingStaffs.addAll(response.data.content);
      }

      // Tăng trang hiện tại nếu còn dữ liệu
      if (hasMoreData) {
        currentPage++;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  /// Lấy chi tiết giảng viên theo ID
  Future<TeachingStaffDetail?> getTeachingStaffDetailById(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      final response =
          await _teachingStaffUseCase.getTeachingStaffDetailById(id);
      selectedTeachingStaffDetail = response.data;

      isLoading = false;
      notifyListeners();
      return selectedTeachingStaffDetail;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Lấy danh sách giảng viên nổi bật
  Future<void> getFeaturedTeachingStaffs({int limit = 5}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      featuredTeachingStaffs =
          await _teachingStaffUseCase.getFeaturedTeachingStaffs(limit: limit);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  /// Tìm kiếm giảng viên
  void setSearchKeyword(String keyword) {
    searchKeyword = keyword;
    getTeachingStaffs(refresh: true);
  }

  /// Lọc theo danh mục
  void filterByCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    getTeachingStaffs(refresh: true);
  }

  /// Reset bộ lọc
  void resetFilters() {
    searchKeyword = '';
    selectedCategoryId = null;
    getTeachingStaffs(refresh: true);
  }
}
