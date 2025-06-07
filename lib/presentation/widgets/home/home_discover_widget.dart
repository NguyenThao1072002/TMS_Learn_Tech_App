import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

class HomeDiscoverWidget extends StatelessWidget {
  const HomeDiscoverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem thiết bị đang sử dụng chế độ tối hay không
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.blockSpacing,
        horizontal: AppDimensions.screenPadding / 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Khám phá', style: AppStyles.sectionTitle.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87
              )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.blockSpacing),
          SizedBox(
            height:
                AppDimensions.cardButtonHeight + 10, // Slightly taller cards
            child: Row(
              children: [
                Expanded(
                  child: _buildFloatingParticleButton(
                    context,
                    icon: Icons.new_releases,
                    title: 'Khóa học mới',
                    startColor: const Color(0xFF6E8CF7),
                    endColor: const Color(0xFF4C6EF5),
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppDimensions.formSpacing),
                Expanded(
                  child: _buildFloatingParticleButton(
                    context,
                    icon: Icons.discount_outlined,
                    title: 'Giảm giá',
                    startColor: const Color(0xFFFF6B6B),
                    endColor: const Color(0xFFE03131),
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.formSpacing),
          SizedBox(
            height:
                AppDimensions.cardButtonHeight + 10, // Slightly taller cards
            child: Row(
              children: [
                Expanded(
                  child: _buildFloatingParticleButton(
                    context,
                    icon: Icons.star_outline_rounded,
                    title: 'Nổi bật',
                    startColor: const Color(0xFFC471ED),
                    endColor: const Color(0xFF9C46B0),
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppDimensions.formSpacing),
                Expanded(
                  child: _buildFloatingParticleButton(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Mới xem',
                    startColor: const Color(0xFF69DB7C),
                    endColor: const Color(0xFF2F9E44),
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color startColor,
    required Color endColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return _FloatingParticleButton(
      icon: icon,
      title: title,
      startColor: startColor,
      endColor: endColor,
      isDarkMode: isDarkMode,
      onTap: onTap,
    );
  }
}

class _FloatingParticleButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color startColor;
  final Color endColor;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _FloatingParticleButton({
    required this.icon,
    required this.title,
    required this.startColor,
    required this.endColor,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_FloatingParticleButton> createState() =>
      _FloatingParticleButtonState();
}

class _FloatingParticleButtonState extends State<_FloatingParticleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;
  final List<_Particle> _particles = [];
  final int _particleCount = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Initialize particles
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        _Particle(
          position: Offset(
            random.nextDouble() * 100,
            random.nextDouble() * 100,
          ),
          speed: 0.5 + random.nextDouble() * 1.5,
          size: 4 + random.nextDouble() * 4,
          angle: random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor =
        Color.lerp(widget.startColor, widget.endColor, 0.5)!;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Main card container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppDimensions.formSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDarkMode 
                      ? [
                          Color.lerp(Colors.grey[900], themeColor, 0.1)!,
                          Color.lerp(Colors.grey[800], themeColor, 0.2)!,
                        ]
                      : [
                          Colors.white,
                          Color.lerp(Colors.white, themeColor,
                              0.08 * (_isPressed ? 1.5 : 1))!,
                        ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDarkMode
                          ? themeColor.withOpacity(_isPressed ? 0.3 : 0.25)
                          : themeColor.withOpacity(_isPressed ? 0.25 : 0.18),
                      blurRadius: _isPressed ? 10 : 15,
                      spreadRadius: _isPressed ? 0 : 1,
                      offset: Offset(0, _isPressed ? 2 : 5),
                    ),
                    if (!widget.isDarkMode)
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 15,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                  ],
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.grey[700]!.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icon container with pulsing effect
                        _buildPulsingIconContainer(),

                        // Small decorative element
                        _buildFloatingDecoration(themeColor),
                      ],
                    ),
                    const Spacer(),
                    // Title with larger font
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: widget.isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.8),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Action text with arrow in a row
                    _buildActionButton(themeColor),
                  ],
                ),
              ),

              // Floating particles
              ..._buildParticles(themeColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPulsingIconContainer() {
    final pulseValue =
        0.5 + (math.sin(_controller.value * math.pi * 2) + 1) / 4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.startColor,
            widget.endColor,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(widget.startColor, widget.endColor, 0.5)!
                .withOpacity(0.3 + pulseValue * 0.2),
            blurRadius: 12 + pulseValue * 8,
            spreadRadius: pulseValue * 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildFloatingDecoration(Color themeColor) {
    final rotationValue = _controller.value * math.pi * 2;

    return Transform.rotate(
      angle: rotationValue,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          gradient: SweepGradient(
            colors: [
              themeColor.withOpacity(0.05),
              themeColor.withOpacity(0.2),
              themeColor.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: GradientRotation(rotationValue),
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.rotate(
            angle: -rotationValue * 2,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Color themeColor) {
    final pulseValue =
        0.5 + (math.sin(_controller.value * math.pi * 4) + 1) / 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(widget.isDarkMode
            ? (_isPressed ? 0.25 : 0.2)
            : (_isPressed ? 0.15 : 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Khám phá ngay',
            style: TextStyle(
              fontSize: 13,
              color: themeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          // Arrow in a circle with animation
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(widget.isDarkMode
                  ? (_isPressed ? 0.4 : 0.3)
                  : (_isPressed ? 0.3 : 0.2)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.2),
                  blurRadius: pulseValue * 8,
                  spreadRadius: pulseValue * 1,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: themeColor,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Color themeColor) {
    final List<Widget> particleWidgets = [];
    final containerWidth = 100.0; // Approximate container width
    final containerHeight = 100.0; // Approximate container height

    for (int i = 0; i < _particles.length; i++) {
      final particle = _particles[i];

      // Update particle position
      final progress = (_controller.value + i / _particleCount) % 1.0;
      final x = containerWidth / 2 +
          math.cos(particle.angle) * progress * containerWidth / 2;
      final y = containerHeight / 2 +
          math.sin(particle.angle) * progress * containerHeight / 2;

      // Opacity based on progress (fade in/out)
      final opacity = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

      particleWidgets.add(
        Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity * 0.7,
            child: Container(
              width: particle.size * (1 - progress),
              height: particle.size * (1 - progress),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return particleWidgets;
  }
}

class _Particle {
  Offset position;
  double speed;
  double size;
  double angle;

  _Particle({
    required this.position,
    required this.speed,
    required this.size,
    required this.angle,
  });
}
