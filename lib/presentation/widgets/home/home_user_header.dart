import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

class HomeUserHeader extends StatelessWidget {
  const HomeUserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppDimensions.screenPadding / 1.5,
        right: AppDimensions.screenPadding / 1.5,
        top: AppDimensions.formSpacing,
        bottom: AppDimensions.headingSpacing,
      ),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusRounded),
          bottomRight: Radius.circular(AppDimensions.radiusRounded),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXZhdGFyfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60',
            ),
          ),
          const SizedBox(width: AppDimensions.formSpacing),
          const Expanded(
            child: Text(
              'Xin chào, Nguyen Van A!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
