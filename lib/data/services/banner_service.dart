import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/banner_model.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';

class BannerService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  BannerService([Dio? dioInstance])
      : dio = dioInstance ?? GetIt.instance<Dio>();

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/banner-voucher/list',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Sử dụng ApiResponseHelper để xử lý phản hồi
        return ApiResponseHelper.processList(
            response.data, BannerModel.fromJson);
      } else {
        print('Lỗi khi lấy banner: ${response.statusCode}');
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách banner: $e');
      return [];
    }
  }

  // Lọc banner theo vị trí (position)
  Future<List<BannerModel>> getBannersByPosition(String position) async {
    try {
      final allBanners = await getBanners();
      final filteredBanners = allBanners
          .where((banner) =>
              banner.position.toLowerCase() == position.toLowerCase() &&
              banner.status)
          .toList()
        ..sort((a, b) =>
            a.priority.compareTo(b.priority)); // priority : ưu tiên hiển thị

      print('Tìm thấy ${filteredBanners.length} banner cho vị trí: $position');
      return filteredBanners;
    } catch (e) {
      print('Lỗi khi lọc banner theo vị trí: $e');
      return [];
    }
  }

  // Lọc banner theo vị trí và platform
  Future<List<BannerModel>> getBannersByPositionAndPlatform(
      String position, String platform) async {
    try {
      final positionBanners = await getBannersByPosition(position);
      final filteredBanners = positionBanners
          .where((banner) =>
              banner.platform.toLowerCase() == platform.toLowerCase() ||
              banner.platform.toLowerCase() == 'all')
          .toList();

      print(
          'Tìm thấy ${filteredBanners.length} banner cho vị trí: $position, platform: $platform');
      return filteredBanners;
    } catch (e) {
      print('Lỗi khi lọc banner theo vị trí và platform: $e');
      return [];
    }
  }
}
