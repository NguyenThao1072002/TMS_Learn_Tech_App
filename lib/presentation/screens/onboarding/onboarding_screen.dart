import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/presentation/screens/homePage/home.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  // Animation controllers
  late final AnimationController _backgroundAnimController;
  late final AnimationController _imageAnimController;
  late final AnimationController _textAnimController;

  // Animations
  late final Animation<double> _imageScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _backgroundParticleAngle;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Chào mừng đến với TMS Learn Tech',
      description:
          'Nền tảng học tập công nghệ hàng đầu với nhiều tài liệu, khóa học và bài kiểm tra thực hành',
      image: 'assets/images/onboarding/welcome.png',
      color: const Color(0xFF3498DB),
      gradientColors: const [Color(0xFF3498DB), Color(0xFF2980B9)],
      icon: Icons.school,
    ),
    OnboardingItem(
      title: 'Khóa học đa dạng',
      description:
          'Truy cập hàng trăm khóa học chất lượng cao từ các chuyên gia công nghệ hàng đầu',
      image: 'assets/images/onboarding/courses.png',
      color: const Color(0xFF2ECC71),
      gradientColors: const [Color(0xFF2ECC71), Color(0xFF27AE60)],
      icon: Icons.video_library,
    ),
    OnboardingItem(
      title: 'Bài kiểm tra thực hành',
      description:
          'Nâng cao kỹ năng với các bài kiểm tra thực tế, từ cơ bản đến nâng cao',
      image: 'assets/images/onboarding/practice.png',
      color: const Color(0xFFE74C3C),
      gradientColors: const [Color(0xFFE74C3C), Color(0xFFC0392B)],
      icon: Icons.assignment,
    ),
    OnboardingItem(
      title: 'Tài liệu công nghệ',
      description:
          'Thư viện tài liệu đa dạng, cập nhật liên tục từ cộng đồng công nghệ',
      image: 'assets/images/onboarding/documents.png',
      color: const Color(0xFF9B59B6),
      gradientColors: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      icon: Icons.article,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Setup animation controllers
    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Setup animations
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageAnimController,
        curve: Curves.easeOutBack,
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimController,
        curve: Curves.easeOut,
      ),
    );

    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _backgroundParticleAngle =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _backgroundAnimController,
        curve: Curves.linear,
      ),
    );

    // Start animations for first page
    _playPageAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundAnimController.dispose();
    _imageAnimController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  void _playPageAnimation() {
    _imageAnimController.reset();
    _textAnimController.reset();
    _imageAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _textAnimController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundAnimController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _pages[_currentPage].gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background particles
                    ...List.generate(30, (index) {
                      final random = math.Random(index);
                      final size = random.nextDouble() * 15 + 2;
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;
                      final xPos = random.nextDouble() * screenWidth;
                      final yPos = random.nextDouble() * screenHeight;
                      final opacity = random.nextDouble() * 0.2 + 0.1;
                      final angle = _backgroundParticleAngle.value + index;

                      return Positioned(
                        left:
                            xPos + 20 * math.cos(angle * (index % 5 + 1) / 10),
                        top: yPos + 20 * math.sin(angle * (index % 3 + 1) / 10),
                        child: Transform.rotate(
                          angle: random.nextDouble() * math.pi,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(size / 2),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top design element
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TMS Learn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'Tech',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _playPageAnimation();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _numPages,
                          (index) => _buildDotIndicator(index == _currentPage),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bottom buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Skip button
                          _currentPage < _numPages - 1
                              ? TextButton(
                                  onPressed: () => _completeOnboarding(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                  ),
                                  child: const Text(
                                    'Bỏ qua',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : const SizedBox(width: 80),

                          // Next button
                          _currentPage < _numPages - 1
                              ? ElevatedButton(
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _pages[_currentPage].color,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.black26,
                                  ),
                                  child: const Text(
                                    'Tiếp theo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () => _completeOnboarding(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _pages[_currentPage].color,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.black26,
                                  ),
                                  child: const Text(
                                    'Bắt đầu ngay',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image with animation
          Expanded(
            flex: 5,
            child: ScaleTransition(
              scale: _imageScale,
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Hero(
                  tag: 'onboarding_image_${item.title}',
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          item.icon,
                          size: 120,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Text with animation
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    }
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.gradientColors,
    required this.icon,
  });
}
