import 'package:tms_app/data/models/banner_model.dart';

abstract class BannerRepository {
  Future<List<BannerModel>> getAllBanners();
  Future<List<BannerModel>> getBannersByPosition(String position);
}
