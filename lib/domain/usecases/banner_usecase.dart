import 'package:tms_app/data/models/banner_model.dart';
import 'package:tms_app/domain/repositories/banner_repository.dart';

class BannerUseCase {
  final BannerRepository bannerRepository;

  BannerUseCase(this.bannerRepository);

  Future<List<BannerModel>> getAllBanners() async {
    return await bannerRepository.getAllBanners();
  }

  Future<List<BannerModel>> getBannersByPosition(String position) async {
    return await bannerRepository.getBannersByPosition(position);
  }

  // Lọc banner theo vị trí và platform
  Future<List<BannerModel>> getBannersByPositionAndPlatform(
      String position, String platform) async {
    final banners = await getBannersByPosition(position);
    return banners
        .where((banner) =>
            banner.platform.toLowerCase() == platform.toLowerCase() ||
            banner.platform.toLowerCase() == 'all')
        .toList();
  }
}
