import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/data/models/banner_model.dart';
import 'package:get_it/get_it.dart';

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
        final Map<String, dynamic> responseData = response.data;

        if (responseData['data'] != null) {
          final List<dynamic> bannerData = responseData['data'];
          final banners =
              bannerData.map((json) => BannerModel.fromJson(json)).toList();

          return banners;
        } else {
          throw Exception('Failed to load banners: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  // Lọc banner theo vị trí (position)
  Future<List<BannerModel>> getBannersByPosition(String position) async {
    try {
      final allBanners = await getBanners();
      return allBanners
          .where((banner) =>
              banner.position.toLowerCase() == position.toLowerCase() &&
              banner.status)
          .toList()
        ..sort((a, b) =>
            a.priority.compareTo(b.priority)); // Sắp xếp theo priority
    } catch (e) {
      return [];
    }
  }

}
