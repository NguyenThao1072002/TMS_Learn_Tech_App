import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

class HomeDiscoverWidget extends StatelessWidget {
  const HomeDiscoverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.blockSpacing,
        horizontal: AppDimensions.screenPadding / 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Khám phá', style: AppStyles.sectionTitle),
          const SizedBox(height: AppDimensions.blockSpacing),
          SizedBox(
            height: AppDimensions.cardButtonHeight,
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    context,
                    icon: Icons.new_releases,
                    title: 'Khóa học mới',
                    startColor: const Color(0xFF6E8CF7),
                    endColor: const Color(0xFF4C6EF5),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppDimensions.formSpacing),
                Expanded(
                  child: _buildQuickAccessButton(
                    context,
                    icon: Icons.discount_outlined,
                    title: 'Giảm giá',
                    startColor: const Color(0xFFFF6B6B),
                    endColor: const Color(0xFFE03131),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.formSpacing),
          SizedBox(
            height: AppDimensions.cardButtonHeight,
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAccessButton(
                    context,
                    icon: Icons.star_outline_rounded,
                    title: 'Nổi bật',
                    startColor: const Color(0xFFC471ED),
                    endColor: const Color(0xFF9C46B0),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppDimensions.formSpacing),
                Expanded(
                  child: _buildQuickAccessButton(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Mới xem',
                    startColor: const Color(0xFF69DB7C),
                    endColor: const Color(0xFF2F9E44),
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

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.formSpacing * 1.3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusRounded),
          boxShadow: [
            BoxShadow(
              color: endColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.iconPadding),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: AppDimensions.iconSize,
              ),
            ),
            const Spacer(),
            Text(title, style: AppStyles.discoverTitle),
            const SizedBox(height: AppDimensions.smallSpacing),
            Row(
              children: [
                Text('Khám phá ngay', style: AppStyles.discoverSubtitle),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
