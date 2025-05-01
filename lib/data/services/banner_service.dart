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

        // Log dữ liệu phản hồi từ API
        print('Banner API Raw Response: ${response.data}');

        // Log dữ liệu thô
        print('Banner API Status Code: ${response.statusCode}');
        print('Banner API Headers: ${response.headers}');

        if (responseData['data'] != null) {
          final List<dynamic> bannerData = responseData['data'];

          // Log dữ liệu chi tiết
          print('Banner data length: ${bannerData.length}');

          // Log JSON thô của item đầu tiên
          if (bannerData.isNotEmpty) {
            print('First banner raw: ${bannerData[0]}');
            print('First banner imageUrl: ${bannerData[0]['imageUrl']}');
            print('First banner title: ${bannerData[0]['title']}');
          }

          final banners =
              bannerData.map((json) => BannerModel.fromJson(json)).toList();

          // Log mô hình chuyển đổi
          if (banners.isNotEmpty) {
            print(
                'First banner after conversion - imageUrl: ${banners[0].imageUrl}');
            print('First banner after conversion - title: ${banners[0].title}');
          }

          return banners;
        } else {
          // Log khi không có dữ liệu
          print('No banner data found in response: ${responseData['message']}');
          throw Exception('Failed to load banners: ${responseData['message']}');
        }
      } else {
        // Log lỗi HTTP
        print('HTTP Error: ${response.statusCode} - ${response.statusMessage}');
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      // Log lỗi tổng quát
      print('Error loading banners: $e');
      // Fallback to sample data in case of error
      return _getSampleBanners();
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
      print('Error filtering banners by position: $e');
      return [];
    }
  }

  // Fallback sample data in case API fails
  List<BannerModel> _getSampleBanners() {
    return [
      BannerModel(
        id: 1,
        title: 'Khóa học Frontend',
        imageUrl:
            'https://img.freepik.com/free-vector/gradient-ui-ux-background_23-2149052117.jpg',
        link: '/courses/frontend',
        position: 'course',
        platform: 'ALL',
        type: 'VOUCHER',
        startDate: '2025-04-20T17:00:00',
        endDate: '2025-04-24T20:00:00',
        status: true,
        priority: 1,
        description: 'Giảm 25% tất cả khóa học Frontend',
        createdAt: '2025-04-22T04:13:23.211189',
        updatedAt: '2025-04-22T05:44:40.134829',
        accountId: 2,
      ),
      BannerModel(
        id: 2,
        title: 'Khóa học AI',
        imageUrl:
            'https://img.freepik.com/free-vector/artificial-intelligence-concept-landing-page_23-2148259341.jpg',
        link: '/courses/ai',
        position: 'course',
        platform: 'ALL',
        type: 'REGULAR',
        startDate: '2025-04-21T17:00:00',
        endDate: '2025-04-21T17:00:00',
        status: true,
        priority: 2,
        description: 'Khóa học AI mới nhất',
        createdAt: '2025-04-22T05:45:09.448821',
        updatedAt: '2025-04-22T05:45:09.448821',
        accountId: 2,
      ),
      BannerModel(
        id: 3,
        title: 'Khóa học Mobile',
        imageUrl:
            'https://img.freepik.com/free-vector/gradient-technology-background_23-2149122887.jpg',
        link: '/courses/mobile',
        position: 'course',
        platform: 'ALL',
        type: 'REGULAR',
        startDate: '2025-04-21T17:00:00',
        endDate: '2025-04-21T17:00:00',
        status: true,
        priority: 3,
        description: 'Học Flutter và React Native',
        createdAt: '2025-04-22T05:45:34.486609',
        updatedAt: '2025-04-22T05:45:34.486609',
        accountId: 2,
      ),
    ];
  }
}
