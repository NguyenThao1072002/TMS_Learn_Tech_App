import 'package:tms_app/data/models/banner_model.dart';
import 'package:tms_app/data/services/banner_service.dart';
import 'package:tms_app/domain/repositories/banner_repository.dart';

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
