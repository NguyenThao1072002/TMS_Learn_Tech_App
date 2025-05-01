import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/banner_model.dart';
import 'package:tms_app/domain/usecases/banner_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerSlider extends StatefulWidget {
  final String position;
  final String platform;
  final bool showText; // Thêm tùy chọn để ẩn/hiện text

  const BannerSlider({
    Key? key,
    this.position = 'course', // Mặc định hiển thị banner ở vị trí "course"
    this.platform = 'ALL', // Mặc định hiển thị banner cho tất cả nền tảng
    this.showText = false, // Mặc định không hiển thị text
  }) : super(key: key);

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  Timer? _timer;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bannerUseCase = GetIt.instance<BannerUseCase>();

      // Sử dụng usecase để lấy banner theo position và platform
      final banners = await bannerUseCase.getBannersByPositionAndPlatform(
          widget.position, widget.platform);

      print('Loaded ${banners.length} banners for position ${widget.position}');
      if (banners.isNotEmpty) {
        print('First banner URL: ${banners[0].imageUrl}');
      }

      setState(() {
        _banners = banners;
        _isLoading = false;

        if (_banners.isNotEmpty) {
          _startAutoSlide();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải banner: $e';
        print(_errorMessage);
      });
    }
  }

  // Hàm bắt đầu tự động chuyển banner
  void _startAutoSlide() {
    _timer?.cancel(); // Hủy timer cũ trước khi bắt đầu lại
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients && _banners.length > 1) {
        int nextIndex = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(nextIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        setState(() {
          _currentIndex = nextIndex;
        });
      }
    });
  }

  // Mở link banner khi người dùng nhấn vào
  Future<void> _openBannerLink(String url) async {
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Hủy timer khi dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('Không có banner nào'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Khi người dùng đổi trang, hủy và bắt đầu lại timer
              _startAutoSlide();
            },
            itemBuilder: (context, index) {
              return _buildBanner(_banners[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicator(), // Thanh indicator hiển thị trang
      ],
    );
  }

  // Widget hiển thị banner
  Widget _buildBanner(BannerModel banner) {
    print('Building banner: ${banner.title} - ${banner.imageUrl}');

    // Kiểm tra URL hợp lệ
    bool isValidUrl = Uri.tryParse(banner.imageUrl)?.hasAbsolutePath ?? false;
    if (!isValidUrl) {
      print('Invalid URL detected: ${banner.imageUrl}');
    }

    return GestureDetector(
      onTap: () => _openBannerLink(banner.link),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Banner image
              isValidUrl
                  ? Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Image.asset(
                          'assets/images/banners/bannerMain.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/banners/bannerMain.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),

              // Gradient overlay và text chỉ hiển thị khi showText = true
              if (widget.showText)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        if (banner.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            banner.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget indicator dưới banner
  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _banners.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 12 : 8,
          height: _currentIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
