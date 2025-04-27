import 'dart:async';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  Timer? _timer;
  final List<String> _bannerImages = [
    'assets/images/banners/bannerMain.jpg',
    'assets/images/banners/bannerMemberVIP.jpg',
    'assets/images/banners/bannerDiscount.jpg',
    'assets/images/banners/bannerComboCourse.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  // Hàm bắt đầu tự động chuyển banner
  void _startAutoSlide() {
    _timer?.cancel(); // Hủy timer cũ trước khi bắt đầu lại
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentIndex + 1) % _bannerImages.length;
        _pageController.animateToPage(nextIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
        setState(() {
          _currentIndex = nextIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Hủy timer khi dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Khi người dùng đổi trang, hủy và bắt đầu lại timer
              _startAutoSlide();
            },
            itemBuilder: (context, index) {
              return _buildBanner(_bannerImages[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicator(), // Thanh indicator hiển thị trang
      ],
    );
  }

  // Widget hiển thị banner
  Widget _buildBanner(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  // Widget indicator dưới banner
  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _bannerImages.length,
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
