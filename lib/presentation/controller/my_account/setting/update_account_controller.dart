import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/user_update_model.dart';
import 'package:tms_app/domain/usecases/update_account_usecase.dart';

class UpdateAccountController extends GetxController {
  final UpdateAccountUseCase _updateAccountUseCase;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;

  // Thêm biến để lưu thông tin user profile
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);

  UpdateAccountController({required UpdateAccountUseCase updateAccountUseCase})
      : _updateAccountUseCase = updateAccountUseCase;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  // Phương thức lấy thông tin profile user
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Lấy userId từ SharedPreferences
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        errorMessage.value = 'Không tìm thấy ID người dùng';
        return;
      }

      // Lấy thông tin chi tiết user
      final profile = await _updateAccountUseCase.getUserById(userId);
      userProfile.value = profile;
    } catch (e) {
      errorMessage.value =
          'Không thể tải thông tin người dùng: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Cập nhật thông tin tài khoản
  Future<bool> updateAccount(Map<String, dynamic> accountData) async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Xóa thông báo lỗi trước đó
      isSuccess.value = false;

      // Tạo một Map mới để xử lý dữ liệu trước khi gửi
      final Map<String, dynamic> processedData = {...accountData};

      // Xử lý riêng cho trường hợp image là File
      if (accountData['image'] != null && accountData['image'] is File) {
        // Lấy File ra từ accountData để xử lý riêng
        File imageFile = accountData['image'] as File;

        // Cập nhật processedData với đường dẫn file thay vì đối tượng File
        // Điều này phụ thuộc vào cách _updateAccountUseCase xử lý
        processedData['image'] = imageFile.path;

        // Thêm flag để usecase biết đây là file cần xử lý đặc biệt
        processedData['isImageFile'] = true;
      }

      // Gọi usecase để cập nhật thông tin
      final result = await _updateAccountUseCase(accountData);

      if (!result) {
        errorMessage.value = 'Cập nhật thông tin thất bại. Vui lòng thử lại.';
        return false;
      }

      // Cập nhật thành công, lấy lại thông tin profile
      await fetchUserProfile();

      isSuccess.value = true;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy userId từ SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
