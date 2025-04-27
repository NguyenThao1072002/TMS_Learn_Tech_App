import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_list.dart';

class PracticeTestDetailScreen extends StatefulWidget {
  final PracticeTest test;

  const PracticeTestDetailScreen({Key? key, required this.test})
      : super(key: key);

  @override
  State<PracticeTestDetailScreen> createState() =>
      _PracticeTestDetailScreenState();
}

class _PracticeTestDetailScreenState extends State<PracticeTestDetailScreen> {
  bool _showPaymentOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
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
                    widget.test.imageUrl,
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
                          widget.test.title,
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
                                widget.test.category,
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
                              '${widget.test.rating}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.test.ratingCount} đánh giá)',
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
                        title: '${widget.test.questionCount} câu hỏi',
                        subtitle: 'Đa dạng độ khó',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: '${widget.test.questionCount ~/ 2} phút',
                        subtitle: 'Thời gian làm bài',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        icon: Icons.bar_chart,
                        title: 'Trung bình',
                        subtitle: 'Độ khó',
                        iconColor: Colors.orange,
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
                    widget.test.description,
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
                  _buildBulletPoint(
                      'Kiến thức core và chuyên sâu về ${widget.test.category}'),
                  _buildBulletPoint('Kỹ năng xử lý vấn đề và debug code'),
                  _buildBulletPoint(
                      'Hiểu biết về các best practices và design patterns'),
                  _buildBulletPoint('Khả năng tối ưu hiệu suất ứng dụng'),

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
                  _buildBulletPoint(
                      'Kiến thức cơ bản về lập trình ${widget.test.category}'),
                  _buildBulletPoint(
                      'Đã từng phát triển ít nhất 1 ứng dụng di động'),
                  _buildBulletPoint(
                      'Hiểu biết về UI/UX và component-based architecture'),

                  const SizedBox(height: 32),

                  // Reviews section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đánh giá từ học viên',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sample reviews
                  _buildReviewCard(
                    name: 'Nguyễn Văn A',
                    avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
                    rating: 5,
                    comment:
                        'Đề thi rất hay và sát với thực tế, giúp tôi nắm vững kiến thức và ôn tập hiệu quả.',
                    date: '12/05/2023',
                  ),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                    name: 'Trần Thị B',
                    avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
                    rating: 4,
                    comment:
                        'Bộ đề khá toàn diện, có một số câu hỏi khó nhưng rất bổ ích. Đáng để mua và thử sức.',
                    date: '28/04/2023',
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _showPaymentOptions
            ? _buildPaymentOptions()
            : _buildPurchaseButton(),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
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
                color: Colors.grey.shade600,
                fontSize: 12,
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
          Icon(
            Icons.check_circle,
            color: const Color(0xFF3498DB),
            size: 18,
          ),
          const SizedBox(width: 8),
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

  Widget _buildReviewCard({
    required String name,
    required String avatar,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatar),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey.shade500,
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
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    if (widget.test.isPurchased) {
      return ElevatedButton(
        onPressed: () {
          // Navigate to test
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow),
            SizedBox(width: 8),
            Text(
              'Bắt đầu làm bài',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(widget.test.price / 1000).toStringAsFixed(0)}K VND',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                'Truy cập trọn đời',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showPaymentOptions = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mua ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPaymentOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showPaymentOptions = false;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment methods
        _buildPaymentMethod(
          icon: Icons.credit_card,
          title: 'Thẻ tín dụng / Ghi nợ',
          isSelected: true,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethod(
          icon: Icons.account_balance_wallet,
          title: 'Ví điện tử MoMo',
          iconColor: Colors.pink,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethod(
          icon: Icons.account_balance,
          title: 'Chuyển khoản ngân hàng',
          iconColor: Colors.green,
        ),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Process payment
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Thanh toán thành công'),
                content: const Text('Bạn đã mua thành công bộ đề thi này!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _showPaymentOptions = false;
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.test.price / 1000).toStringAsFixed(0)}K VND',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Color iconColor = const Color(0xFF3498DB),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE1F5FE) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF3498DB) : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF3498DB),
            ),
        ],
      ),
    );
  }
}
