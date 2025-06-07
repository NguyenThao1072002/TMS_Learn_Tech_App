import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';

class NavbarAddToCard extends StatelessWidget {
  final CourseCardModel course;
  final bool isPurchased;
  final VoidCallback onAddToCart;
  final VoidCallback onPurchase;
  final VoidCallback onContinueLearning;
  final bool isDarkMode;

  const NavbarAddToCard({
    Key? key,
    required this.course,
    required this.isPurchased,
    required this.onAddToCart,
    required this.onPurchase,
    required this.onContinueLearning,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode || Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: isPurchased ? _buildAlreadyPurchasedBar() : _buildPurchaseBar(),
    );
  }

  Widget _buildAlreadyPurchasedBar() {
    // Hiển thị cho người dùng đã mua khóa học
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onContinueLearning,
              icon: Icon(Icons.play_arrow),
              label: Text("Tiếp tục học"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (course.cost > 0)
                Text(
                  "${course.cost} đ",
                  style: TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Khoảng cách
        SizedBox(width: 8),

        // Nút thêm vào giỏ hàng
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade300),
          ),
          child: IconButton(
            onPressed: onAddToCart,
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.blue),
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
            height: 45,
            child: ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Đăng ký",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
