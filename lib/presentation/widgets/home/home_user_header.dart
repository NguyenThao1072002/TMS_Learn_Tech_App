import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/di/service_locator.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';
import 'package:tms_app/data/models/account/user_update_model.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

class HomeUserHeader extends StatefulWidget {
  const HomeUserHeader({super.key});

  @override
  State<HomeUserHeader> createState() => _HomeUserHeaderState();
}

class _HomeUserHeaderState extends State<HomeUserHeader> {
  String? userName = 'Người dùng';
  String? userImage;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);

      if (userId == null || userId.isEmpty) {
        setState(() {
          errorMessage = "Không tìm thấy thông tin người dùng";
          isLoading = false;
        });
        return;
      }

      // Lấy thông tin người dùng từ repository
      final accountRepository = sl<AccountRepository>();
      final userProfile = await accountRepository.getUserById(userId);

      // Cập nhật thông tin người dùng
      setState(() {
        userName = userProfile.fullname ?? 'Người dùng';
        userImage = userProfile.image;
        isLoading = false;
      });

      // In thông tin ra console để debug
      debugPrint('Đã tải thông tin người dùng: $userName, Avatar: $userImage');
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi khi tải thông tin người dùng: $e";
        isLoading = false;
      });
      debugPrint('Lỗi khi tải thông tin người dùng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppDimensions.screenPadding / 1.5,
        right: AppDimensions.screenPadding / 1.5,
        top: AppDimensions.formSpacing,
        bottom: AppDimensions.headingSpacing,
      ),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusRounded),
          bottomRight: Radius.circular(AppDimensions.radiusRounded),
        ),
      ),
      child: Row(
        children: [
          // Avatar của người dùng
          isLoading
              ? const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  backgroundImage: userImage != null && userImage!.isNotEmpty
                      ? NetworkImage(userImage!)
                      : null,
                  child: userImage == null || userImage!.isEmpty
                      ? Text(
                          userName?.isNotEmpty == true
                              ? userName![0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primaryColor,
                          ),
                        )
                      : null,
                ),
          const SizedBox(width: AppDimensions.formSpacing),
          Expanded(
            child: isLoading
                ? const Text(
                    'Đang tải...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  )
                : errorMessage != null
                    ? Text(
                        'Xin chào!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      )
                    : Text(
                        'Xin chào, $userName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
          ),
        ],
      ),
    );
  }
}
