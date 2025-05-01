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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXZhdGFyfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60',
                ),
              ),
              const SizedBox(width: AppDimensions.formSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xin chào, Nguyen Van A!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadius),
                              color: Colors.grey.shade300,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.borderRadius),
                                    color: AppStyles.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.formSpacing / 2),
                        Text(
                          '60%',
                          style: AppStyles.subText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hoàn thành Flutter - cơ bản đến nâng cao',
                      style: AppStyles.subText.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.formSpacing * 1.3),

          // Thanh tìm kiếm
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusRounded - 5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khóa học, tài liệu...',
                hintStyle: AppStyles.subText.copyWith(fontSize: 15),
                prefixIcon:
                    const Icon(Icons.search, color: AppStyles.primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.formSpacing),
              ),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
        ],
      ),
    );
  }
}
