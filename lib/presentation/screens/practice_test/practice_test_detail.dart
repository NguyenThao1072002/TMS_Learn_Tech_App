import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/domain/usecases/cart_usecase.dart';
import 'package:tms_app/presentation/controller/cart_controller.dart';
import 'package:tms_app/presentation/controller/practice_test_controller.dart';
import 'package:tms_app/presentation/widgets/practice_test/related_practice_test.dart';
import 'package:tms_app/presentation/widgets/practice_test/test_review_section.dart';
import 'package:tms_app/presentation/screens/my_account/checkout/cart.dart';

class PracticeTestDetailScreen extends StatefulWidget {
  final int testId;

  const PracticeTestDetailScreen({Key? key, required this.testId})
      : super(key: key);

  @override
  State<PracticeTestDetailScreen> createState() =>
      _PracticeTestDetailScreenState();
}

class _PracticeTestDetailScreenState extends State<PracticeTestDetailScreen> {
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();
  final CartUseCase _cartUseCase = GetIt.instance<CartUseCase>();
  late PracticeTestDetailController _controller;
  late CartController _cartController;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _controller = PracticeTestDetailController(widget.testId);
    _cartController = CartController(cartUseCase: _cartUseCase);
  }

  @override
  void dispose() {
    _cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin đề thi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lỗi: ${_controller.errorMessage}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _controller.loadTestDetail(widget.testId);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (_controller.testDetail == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy đề thi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã đề thi: ${widget.testId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          final test = _controller.testDetail!;

          return CustomScrollView(
            slivers: [
              // App Bar with test image as background
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF3498DB),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        test.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF3498DB),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    test.courseTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${test.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${test.itemCountReview} đánh giá)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
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
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Test info cards
                      Row(
                        children: [
                          _buildInfoCard(
                            icon: Icons.help_outline,
                            title: '${test.totalQuestion} câu hỏi',
                            subtitle: 'Đa dạng độ khó',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.access_time,
                            title: '${test.totalQuestion ~/ 2} phút',
                            subtitle: 'Thời gian làm bài',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.bar_chart,
                            title: _controller.getVietnameseLevel(test.level),
                            subtitle: 'Độ khó',
                            iconColor: _controller.getLevelColor(test.level),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // About this test
                      const Text(
                        'Giới thiệu đề thi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        test.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // What you'll learn
                      const Text(
                        'Bạn sẽ được kiểm tra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...test.testContents
                          .map((item) => _buildBulletPoint(item)),

                      const SizedBox(height: 24),

                      // Requirements
                      const Text(
                        'Yêu cầu kiến thức',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...test.knowledgeRequirements
                          .map((item) => _buildBulletPoint(item)),

                      const SizedBox(height: 32),

                      // Price and purchase section
                      _buildPriceSection(test),

                      const SizedBox(height: 32),

                      // Reviews section using the widget
                      TestReviewSection(
                        testId: test.testId,
                        testTitle: test.title,
                        canReview: test.purchased,
                        practiceTestUseCase: _practiceTestUseCase,
                      ),

                      const SizedBox(height: 32),

                      // Related tests section
                      RelatedPracticeTest(
                        practiceTestUseCase: _practiceTestUseCase,
                        currentTestId: test.testId,
                        courseId: test.courseId,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.testDetail == null) {
            return const SizedBox.shrink();
          }

          final test = _controller.testDetail!;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (test.percentDiscount > 0)
                        Text(
                          '${_controller.formatPrice(test.cost)}đ',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      Text(
                        test.purchased
                            ? 'Đã mua'
                            : test.price > 0
                                ? '${_controller.formatPrice(test.price)}đ'
                                : 'Miễn phí',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: test.purchased
                              ? Colors.green
                              : const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                if (test.price > 0 && !test.purchased) ...[
                  OutlinedButton(
                    onPressed: () => _addToCart(test),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3498DB)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Thêm vào giỏ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton(
                  onPressed: () {
                    // Start the test or purchase flow
                    if (test.purchased) {
                      // Navigate to test taking screen
                      _controller.startTest();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bắt đầu làm bài thi...'),
                        ),
                      );
                    } else if (test.price > 0) {
                      // Show payment options or add to cart
                      _addToCart(test);
                      // Sau khi thêm vào giỏ, điều hướng đến giỏ hàng
                      _navigateToCart();
                    } else {
                      // Free test - navigate to test taking screen
                      _controller.startTest();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bắt đầu làm bài thi miễn phí...'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        test.purchased ? Colors.green : const Color(0xFF3498DB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    test.purchased
                        ? 'Làm bài ngay'
                        : test.price > 0
                            ? 'Mua ngay'
                            : 'Làm bài miễn phí',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceSection(PracticeTestDetailModel test) {
    if (test.purchased) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn đã mua đề thi này',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn có thể làm bài thi ngay bây giờ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giá',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                if (test.percentDiscount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Giảm ${test.percentDiscount}%',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  test.price > 0
                      ? '${_controller.formatPrice(test.price)}đ'
                      : 'Miễn phí',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: test.price > 0 ? Colors.black : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                if (test.percentDiscount > 0)
                  Text(
                    '${_controller.formatPrice(test.cost)}đ',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              test.price > 0
                  ? 'Truy cập vĩnh viễn sau khi mua'
                  : 'Bài thi miễn phí - có thể truy cập ngay',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            
            // Thêm nút Thêm vào giỏ hàng cho đề thi có phí
            if (test.price > 0) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addToCart(test),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Thêm vào giỏ hàng'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF3498DB),
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3498DB),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Phương thức thêm đề thi vào giỏ hàng
  Future<void> _addToCart(PracticeTestDetailModel test) async {
    if (_isAddingToCart) return; // Tránh nhấn nhiều lần liên tiếp
    if (test.purchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã mua đề thi này rồi'))
      );
      return;
    }
    
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      final success = await _cartController.addToCart(
        itemId: test.testId,
        type: "EXAM", // Loại sản phẩm là đề thi
        price: test.price,
      );
      
      if (success) {
        _showAddToCartFeedback();
      } else {
        if (_cartController.errorMessage.value?.contains('đã có trong giỏ hàng') ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đề thi đã có trong giỏ hàng'),
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
      print('Lỗi khi thêm đề thi vào giỏ hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        )
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  // Hiển thị thông báo đã thêm vào giỏ hàng
  void _showAddToCartFeedback() {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: const Text(
              'Đã thêm đề thi vào giỏ hàng',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          preSelectedItemId: _controller.testDetail?.testId.toString(),
          preSelectedItemType: 'EXAM',
        ),
      ),
    );
  }
}
