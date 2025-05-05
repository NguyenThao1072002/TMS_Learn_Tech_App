
import '../../domain/repositories/banner_repository.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerService bannerService;

  BannerRepositoryImpl({required this.bannerService});

  @override
  Future<List<BannerModel>> getAllBanners() async {
    return await bannerService.getBanners();
  }

  @override
  Future<List<BannerModel>> getBannersByPosition(String position) async {
    return await bannerService.getBannersByPosition(position);
  }
}
