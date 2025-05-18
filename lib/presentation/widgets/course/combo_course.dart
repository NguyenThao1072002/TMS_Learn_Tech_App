import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';
import 'package:tms_app/data/models/course/combo_course/combo_course_detail_model.dart';
import 'package:tms_app/presentation/screens/course/course_detail.dart';
import 'package:tms_app/presentation/controller/course_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tms_app/presentation/widgets/course/course_card.dart';
import 'package:tms_app/presentation/controller/cart_controller.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/cart.dart';

class ComboCourseScreen extends StatefulWidget {
  final int? comboId;

  const ComboCourseScreen({this.comboId, Key? key}) : super(key: key);

  @override
  State<ComboCourseScreen> createState() => _ComboCourseScreenState();
}

class _ComboCourseScreenState extends State<ComboCourseScreen> {
  late final CourseController _controller;
  late final CartController _cartController;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  ComboCourseDetailModel? _combo;
  final _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _controller = GetIt.instance<CourseController>();
    _cartController = CartController(cartUseCase: GetIt.instance<CartUseCase>());
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _cartController.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.comboId != null) {
        // Nếu có comboId, lấy chi tiết combo đó
        _combo = await _controller.getComboDetail(widget.comboId!);
      } else {
        // Nếu không có comboId, lấy combo đầu tiên trong danh sách
        if (_controller.comboCourses.value.isEmpty) {
          await _controller.loadComboCourses();
        }

        if (_controller.comboCourses.value.isNotEmpty) {
          final firstCombo = _controller.comboCourses.value.first;
          _combo = await _controller.getComboDetail(firstCombo.id);
        }
      }
    } catch (e) {
      print('Lỗi khi tải combo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Thêm combo vào giỏ hàng
  Future<void> _addToCart() async {
    if (_isAddingToCart || _combo == null) return; // Tránh nhấn nhiều lần liên tiếp
    
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      final success = await _cartController.addToCart(
        itemId: _combo!.id,
        type: "COMBO",
        price: _combo!.price,
      );
      
      if (success) {
        _showAddToCartFeedback();
      } else {
        if (_cartController.errorMessage.value?.contains('đã có trong giỏ hàng') ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Combo đã có trong giỏ hàng'),
              backgroundColor: Colors.orange,
            )
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể thêm vào giỏ hàng. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    } catch (e) {
      print('Lỗi khi thêm combo vào giỏ hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        )
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  // Hiển thị thông báo đã thêm vào giỏ hàng
  void _showAddToCartFeedback() {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đã thêm combo vào giỏ hàng',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'XEM GIỎ',
        textColor: Colors.white,
        onPressed: _navigateToCart,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Chuyển đến màn hình giỏ hàng
  void _navigateToCart() {
    if (_combo == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          preSelectedItemId: _combo!.id.toString(),
          preSelectedItemType: "COMBO",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _combo?.name ?? 'Combo Khóa Học',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.lightBlue),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _combo == null
              ? const Center(
                  child: Text('Không tìm thấy thông tin combo khóa học!'),
                )
              : Column(
                  children: [
                    // Main content - scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Banner section
                              _buildPromoBanner(_combo!),
                              const SizedBox(height: 24),

                              // Combo details
                              Text(
                                _combo!.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildComboDescription(_combo!),
                              const SizedBox(height: 24),

                              // Course cards
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Khóa học trong combo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height:
                                    280, // Fixed height for horizontal scrolling list
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _combo!.courses.map((course) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: _buildCourseCard(
                                        course: course.toCardModel(),
                                        context: context,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Price summary
                              _buildPriceSummary(_combo!),
                              const SizedBox(
                                  height: 80), // Extra padding for button
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fixed buttons at bottom
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: _buildRegisterButton(_combo!),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPromoBanner(ComboCourseDetailModel combo) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Banner background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3498DB),
                    Color(0xFF2980B9),
                  ],
                ),
              ),
            ),

            // Banner content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIẾT KIỆM ${combo.discount}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Combo ${combo.courses.length} khóa học cao cấp với giá cực ưu đãi',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Ưu đãi có hạn!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${combo.discount}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComboDescription(ComboCourseDetailModel combo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Combo khóa học cao cấp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            combo.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureItem(
                  Icons.check_circle_outline, 'Truy cập trọn đời'),
              const SizedBox(width: 16),
              _buildFeatureItem(
                  Icons.ondemand_video, '${combo.courses.length}+ khóa học'),
              const SizedBox(width: 16),
              _buildFeatureItem(Icons.workspace_premium, 'Chứng chỉ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade700),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard({
    required CourseCardModel course,
    required BuildContext context,
  }) {
    return CourseCard(
      course: course,
      selectedIndex: null,
      onTap: (course) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
    );
  }

  Widget _buildPriceSummary(ComboCourseDetailModel combo) {
    // Tính tổng giá gốc
    double totalOriginalPrice =
        combo.courses.fold(0, (sum, course) => sum + course.cost);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng giá trị khóa học',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          // Hiển thị giá từng khóa
          ...combo.courses.map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPriceRow(
                  course.title, _currencyFormat.format(course.cost)),
            );
          }),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildPriceRow(
              'Tổng cộng', _currencyFormat.format(totalOriginalPrice),
              isBold: true),
          const SizedBox(height: 8),
          _buildPriceRow('Giảm giá',
              '-${_currencyFormat.format(totalOriginalPrice - combo.price)}',
              isDiscount: true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings, color: Colors.green, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá ưu đãi combo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _currencyFormat.format(combo.price),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Tiết kiệm ${combo.discount}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
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

  Widget _buildPriceRow(String label, String price,
      {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF333333),
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.red.shade700 : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(ComboCourseDetailModel combo) {
    return Row(
      children: [
        // Add to cart button
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFF3498DB), width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isAddingToCart ? null : _addToCart,
              borderRadius: BorderRadius.circular(28),
              child: Center(
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                        ),
                      )
                    : const Icon(
                        Icons.shopping_cart,
                        color: Color(0xFF3498DB),
                        size: 24,
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Register now button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3498DB),
                  Color(0xFF2980B9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _navigateToCart,
                borderRadius: BorderRadius.circular(28),
                child: const Center(
                  child: Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
