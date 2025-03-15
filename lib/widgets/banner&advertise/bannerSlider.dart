import 'dart:async';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  Timer? _timer; // Lưu trữ timer để huỷ khi dispose
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

  void _startAutoSlide() {
    _timer?.cancel();
    Timer.periodic(Duration(seconds: 15), (Timer timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentIndex + 1) % _bannerImages.length;
        _pageController.animateToPage(nextIndex,
            duration: Duration(milliseconds: 700), curve: Curves.easeInOut);
        setState(() {
          _currentIndex = nextIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBanner(_bannerImages[index]); // Hiển thị banner
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicator(), // Thanh indicator hiển thị trang
      ],
    );
  }

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
