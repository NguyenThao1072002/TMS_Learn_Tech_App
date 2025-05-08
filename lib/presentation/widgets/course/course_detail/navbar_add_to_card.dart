import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';

class NavbarAddToCard extends StatelessWidget {
  final CourseCardModel course;
  final bool isPurchased;
  final VoidCallback onAddToCart;
  final VoidCallback onPurchase;
  final VoidCallback onContinueLearning;

  const NavbarAddToCard({
    Key? key,
    required this.course,
    required this.isPurchased,
    required this.onAddToCart,
    required this.onPurchase,
    required this.onContinueLearning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.standardPadding, 
        vertical: 12
      ),
      decoration: AppStyles.navbarBoxDecoration,
      child: isPurchased ? _buildAlreadyPurchasedBar() : _buildPurchaseBar(),
    );
  }

  Widget _buildAlreadyPurchasedBar() {
    // Hiển thị cho người dùng đã mua khóa học
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppDimensions.standardButtonHeight,
            decoration: AppStyles.continueStudyButtonDecoration,
            child: ElevatedButton.icon(
              onPressed: onContinueLearning,
              icon: Icon(Icons.play_arrow),
              label: Text("Tiếp tục học"),
              style: AppStyles.continueStudyButtonStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseBar() {
    return Row(
      children: [
        // Phần giá
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị giá với ellipsis để tránh tràn
              Text(
                "${course.price} đ",
                style: AppStyles.priceTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
              if (course.cost > 0)
                Text(
                  "${course.cost} đ",
                  style: AppStyles.oldPriceTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Khoảng cách
        SizedBox(width: 8),

        // Nút thêm vào giỏ hàng
        Container(
          height: AppDimensions.standardButtonHeight,
          width: AppDimensions.standardButtonHeight,
          decoration: AppStyles.addToCartButtonDecoration,
          child: IconButton(
            onPressed: onAddToCart,
            icon: Icon(
              Icons.shopping_cart_outlined, 
              color: AppStyles.addToCartIconColor
            ),
            tooltip: 'Thêm vào giỏ hàng',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),

        // Khoảng cách
        SizedBox(width: 8),

        // Nút đăng ký học
        Expanded(
          flex: 2,
          child: SizedBox(
            height: AppDimensions.standardButtonHeight,
            child: ElevatedButton(
              onPressed: onPurchase,
              style: AppStyles.registerButtonStyle,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Đăng ký",
                  style: AppStyles.registerButtonTextStyle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
