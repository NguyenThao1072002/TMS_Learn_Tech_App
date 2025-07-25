import 'package:flutter/material.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with SingleTickerProviderStateMixin {
  // Theme colors
  late Color _backgroundColor;
  late Color _cardColor;
  late Color _textColor;
  late Color _textSecondaryColor;
  late Color _borderColor;
  late Color _dividerColor;
  late Color _tableHeaderColor;
  late Color _shadowColor;
  
  void _initializeColors(bool isDarkMode) {
    if (isDarkMode) {
      _backgroundColor = const Color(0xFF121212);
      _cardColor = const Color(0xFF1E1E1E);
      _textColor = Colors.white;
      _textSecondaryColor = Colors.grey.shade300;
      _borderColor = Colors.grey.shade700;
      _dividerColor = Colors.grey.shade800;
      _tableHeaderColor = const Color(0xFF2A2D3E);
      _shadowColor = Colors.black.withOpacity(0.3);
    } else {
      _backgroundColor = Colors.white;
      _cardColor = Colors.white;
      _textColor = Colors.black87;
      _textSecondaryColor = Colors.grey.shade700;
      _borderColor = Colors.grey.shade200;
      _dividerColor = Colors.grey.shade200;
      _tableHeaderColor = Colors.grey.shade100;
      _shadowColor = Colors.black.withOpacity(0.1);
    }
  }

  // Loại gói thành viên được chọn
  String _selectedPlan = 'premium';
  String _selectedDuration = '6_month';

  // Controller cho animation
  late AnimationController _animationController;

  // Dữ liệu về các loại gói thành viên
  final List<MembershipPlan> _plans = [
    MembershipPlan(
      id: 'basic',
      name: 'Basic',
      monthlyPrice: 199000,
      annualPrice: 1990000,
      sixMonthPrice: 995000,
      mainColor: const Color(0xFF7A86CB),
      features: [
        'Truy cập 10 khóa học cơ bản',
        'Học không giới hạn 24/7',
        'Nhận chứng chỉ hoàn thành khóa học',
        'Chatbot hỗ trợ cơ bản',
        'Tham gia diễn đàn cộng đồng',
      ],
      popularFeatures: [
        'Tham gia diễn đàn cộng đồng',
      ],
    ),
    MembershipPlan(
      id: 'premium',
      name: 'Premium',
      monthlyPrice: 349000,
      annualPrice: 3490000,
      sixMonthPrice: 1745000,
      mainColor: const Color(0xFF5C6BC0),
      features: [
        'Truy cập toàn bộ khóa học',
        'Học không giới hạn 24/7',
        'Nhận chứng chỉ hoàn thành khóa học',
        'Chatbot hỗ trợ nâng cao và giải bài tập',
        'Tài liệu học tập độc quyền',
        'Thảo luận 1-1 với giảng viên',
        'Tham gia nhóm học tập chuyên sâu',
        'Bài kiểm tra đánh giá năng lực',
      ],
      popularFeatures: [
        'Chatbot hỗ trợ nâng cao và giải bài tập',
        'Tài liệu học tập độc quyền',
        'Bài kiểm tra đánh giá năng lực',
      ],
    ),
    MembershipPlan(
      id: 'business',
      name: 'Business',
      monthlyPrice: 699000,
      annualPrice: 6990000,
      sixMonthPrice: 3495000,
      mainColor: const Color(0xFF3F51B5),
      features: [
        'Truy cập toàn bộ khóa học',
        'Học không giới hạn 24/7',
        'Nhận chứng chỉ hoàn thành khóa học',
        'Chatbot AI cao cấp 24/7 với giải pháp chuyên sâu',
        'Tài liệu học tập độc quyền',
        'Thảo luận 1-1 với giảng viên cao cấp',
        'Khóa học riêng tư theo nhóm',
        'Quản lý tài khoản doanh nghiệp',
        'Báo cáo tiến độ học tập chi tiết',
        'Tư vấn phát triển kỹ năng chuyên môn',
        'Workshop trực tuyến hàng tháng',
        'Đào tạo theo yêu cầu doanh nghiệp',
      ],
      popularFeatures: [
        'Chatbot AI cao cấp 24/7 với giải pháp chuyên sâu',
        'Tư vấn phát triển kỹ năng chuyên môn',
        'Đào tạo theo yêu cầu doanh nghiệp',
        'Workshop trực tuyến hàng tháng',
      ],
    ),
  ];

  // Tính giá tiền theo gói và thời hạn
  int getPrice(String planId, String duration) {
    final plan = _plans.firstWhere((element) => element.id == planId);

    switch (duration) {
      case 'monthly':
        return plan.monthlyPrice;
      case '6_month':
        return plan.sixMonthPrice;
      case 'annual':
        return plan.annualPrice;
      default:
        return plan.monthlyPrice;
    }
  }

  // Format giá tiền
  String formatPrice(int price) {
    String priceString = price.toString();
    String formattedPrice = '';

    for (int i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        formattedPrice += '.';
      }
      formattedPrice += priceString[i];
    }

    return '$formattedPrice₫';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Khởi động animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _initializeColors(isDarkMode);
    
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text(
          'Gói thành viên',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner gói thành viên
              _buildMembershipBanner(),

              const SizedBox(height: 24),

              // Các tùy chọn kỳ hạn
              _buildDurationSelector(),

              const SizedBox(height: 32),

              // Các gói thành viên
              _buildMembershipCards(),

              const SizedBox(height: 32),

              // So sánh các tính năng
              _buildFeatureComparison(),

              const SizedBox(height: 30),

              // FAQ về gói thành viên
              _buildMembershipFAQ(),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị banner gói thành viên
  Widget _buildMembershipBanner() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [
                  const Color(0xFF303F9F),
                  const Color(0xFF3949AB),
                ]
              : [
                  const Color(0xFF3F51B5),
                  const Color(0xFF5C6BC0),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withOpacity(isDarkMode ? 0.5 : 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nâng cấp tài khoản ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mở khóa toàn bộ tính năng cao cấp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Lợi ích khi nâng cấp:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBenefitItem(Icons.video_library, 'Truy cập không giới hạn'),
              _buildBenefitItem(Icons.support_agent, 'Hỗ trợ ưu tiên'),
              _buildBenefitItem(Icons.download, 'Tải tài liệu'),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị mục lợi ích
  Widget _buildBenefitItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị bộ chọn thời hạn
  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn thời hạn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2A2D3E) 
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildDurationOption('monthly', 'Hàng tháng'),
              _buildDurationOption('6_month', '6 tháng', isPopular: true),
              _buildDurationOption('annual', 'Hàng năm', discount: 20),
            ],
          ),
        ),
      ],
    );
  }

  // Widget hiển thị tùy chọn thời hạn
  Widget _buildDurationOption(String id, String label,
      {bool isPopular = false, int? discount}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedDuration == id;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDuration = id;
          });
        },
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF3F51B5) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : _textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (discount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Tiết kiệm $discount%',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.green,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isPopular)
                Positioned(
                  top: -8,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Phổ biến',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị các thẻ gói thành viên
  Widget _buildMembershipCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn gói thành viên',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _plans.length,
          (index) => _buildPlanCard(_plans[index]),
        ),
      ],
    );
  }

  // Widget hiển thị thẻ gói thành viên
  Widget _buildPlanCard(MembershipPlan plan) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPlan == plan.id;
    final currentPrice = _selectedDuration == 'monthly'
        ? plan.monthlyPrice
        : _selectedDuration == '6_month'
            ? plan.sixMonthPrice
            : plan.annualPrice;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? plan.mainColor : _borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? plan.mainColor.withOpacity(isDarkMode ? 0.3 : 0.2)
                  : _shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? plan.mainColor 
                    : (isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey.shade50),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : _textColor,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatPrice(currentPrice),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : _textColor,
                        ),
                      ),
                      Text(
                        _selectedDuration == 'monthly'
                            ? '/tháng'
                            : _selectedDuration == '6_month'
                                ? '/6 tháng'
                                : '/năm',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected 
                              ? Colors.white70 
                              : (isDarkMode ? Colors.grey.shade400 : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Features
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...plan.features.map((feature) {
                    final isPopular = plan.popularFeatures.contains(feature);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: isPopular ? Colors.orange : plan.mainColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: isPopular
                                    ? _textColor
                                    : _textSecondaryColor,
                                fontWeight: isPopular
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Nổi bật',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPlan = plan.id;
                        });
                        // TODO: Implement subscription purchase
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? plan.mainColor : _cardColor,
                        foregroundColor:
                            isSelected ? Colors.white : plan.mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: plan.mainColor),
                        elevation: isSelected ? 2 : 0,
                      ),
                      child: Text(
                        isSelected ? 'Đăng ký ngay' : 'Chọn gói này',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị so sánh tính năng
  Widget _buildFeatureComparison() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'So sánh các gói thành viên',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(_tableHeaderColor),
            columnSpacing: 20,
            columns: [
              DataColumn(
                label: Text(
                  'Tính năng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Basic',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Business',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
            ],
            rows: [
              _buildFeatureRow('Truy cập khóa học', 'Giới hạn',
                  'Không giới hạn', 'Không giới hạn'),
              _buildFeatureRow('Tải tài liệu', 'Giới hạn', 'Không giới hạn',
                  'Không giới hạn'),
              _buildFeatureRow('Chứng chỉ', 'Có', 'Có', 'Có'),
              _buildFeatureRow('Chatbot', 'Cơ bản', 'Nâng cao với giải bài tập',
                  'AI cao cấp 24/7'),
              _buildFeatureRow('Thảo luận với giảng viên', 'Không', 'Có',
                  'Giảng viên cao cấp'),
              _buildFeatureRow('Học theo nhóm', 'Không', 'Có', 'Có'),
              _buildFeatureRow('Quản lý nhóm', 'Không', 'Không', 'Có'),
              _buildFeatureRow('Báo cáo tiến độ', 'Không', 'Có', 'Chi tiết'),
              _buildFeatureRow('Bài kiểm tra đánh giá', 'Không', 'Có', 'Có'),
              _buildFeatureRow(
                  'Workshop trực tuyến', 'Không', 'Không', 'Hàng tháng'),
              _buildFeatureRow('Đào tạo theo yêu cầu', 'Không', 'Không', 'Có'),
              _buildFeatureRow('Diễn đàn cộng đồng', 'Có', 'Có', 'Có'),
            ],
          ),
        ),
      ],
    );
  }

  // Widget hiển thị hàng trong bảng so sánh
  DataRow _buildFeatureRow(
      String feature, String basic, String premium, String business) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return DataRow(
      cells: [
        DataCell(Text(feature, style: TextStyle(color: _textColor))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              basic == 'Có' || basic.contains('Không giới hạn')
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 16)
                  : basic == 'Không'
                      ? const Icon(Icons.cancel, color: Colors.red, size: 16)
                      : const SizedBox.shrink(),
              const SizedBox(width: 4),
              Text(
                basic == 'Có' || basic == 'Không' ? '' : basic,
                style: TextStyle(
                  color: basic.contains('Giới hạn') 
                      ? Colors.orange 
                      : (isDarkMode ? Colors.grey.shade300 : Colors.black),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              premium == 'Có' || premium.contains('Không giới hạn')
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 16)
                  : premium == 'Không'
                      ? const Icon(Icons.cancel, color: Colors.red, size: 16)
                      : const SizedBox.shrink(),
              const SizedBox(width: 4),
              Text(
                premium == 'Có' || premium == 'Không' ? '' : premium,
                style: TextStyle(
                  color: premium.contains('Giới hạn') 
                      ? Colors.orange 
                      : (isDarkMode ? Colors.grey.shade300 : Colors.black),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              business == 'Có' || business.contains('Không giới hạn')
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 16)
                  : business == 'Không'
                      ? const Icon(Icons.cancel, color: Colors.red, size: 16)
                      : const SizedBox.shrink(),
              const SizedBox(width: 4),
              Text(
                business == 'Có' || business == 'Không' ? '' : business,
                style: TextStyle(
                  color: business.contains('Giới hạn') 
                      ? Colors.orange 
                      : (isDarkMode ? Colors.grey.shade300 : Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget hiển thị FAQ về gói thành viên
  Widget _buildMembershipFAQ() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu hỏi thường gặp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            children: [
              _buildFAQItem(
                'Tôi có thể đổi gói thành viên không?',
                'Bạn có thể nâng cấp gói thành viên bất kỳ lúc nào. Khi nâng cấp, chúng tôi sẽ tính phí chênh lệch tương ứng với thời gian còn lại của gói hiện tại.',
              ),
              _buildFAQItem(
                'Có tự động gia hạn không?',
                'Có, gói thành viên của bạn sẽ tự động gia hạn khi hết hạn. Bạn có thể hủy tự động gia hạn bất kỳ lúc nào trong phần Cài đặt tài khoản.',
              ),
              _buildFAQItem(
                'Tôi có thể hủy gói thành viên không?',
                'Bạn có thể hủy gói thành viên bất kỳ lúc nào. Khi hủy, bạn vẫn có thể sử dụng dịch vụ cho đến hết thời hạn đã thanh toán.',
              ),
              _buildFAQItem(
                'Chính sách bảo hành của TMS là gì?',
                'TMS cam kết mang đến trải nghiệm học tập tốt nhất cho người dùng. Nếu bạn gặp bất kỳ vấn đề nào về nội dung hoặc chất lượng khóa học, chúng tôi sẽ hỗ trợ khắc phục hoặc cung cấp quyền truy cập vào nội dung thay thế phù hợp. Chúng tôi không áp dụng hoàn tiền sau 24 giờ kể từ khi mua gói dịch vụ.',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget hiển thị mục FAQ
  Widget _buildFAQItem(String question, String answer, {bool isLast = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: _textColor,
            ),
          ),
          iconColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          collapsedIconColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          children: [
            Text(
              answer,
              style: TextStyle(
                color: _textSecondaryColor,
                height: 1.5,
              ),
            ),
          ],
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: _dividerColor,
          ),
      ],
    );
  }
}

// Model cho gói thành viên
class MembershipPlan {
  final String id;
  final String name;
  final int monthlyPrice;
  final int annualPrice;
  final int sixMonthPrice;
  final Color mainColor;
  final List<String> features;
  final List<String> popularFeatures;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.sixMonthPrice,
    required this.mainColor,
    required this.features,
    required this.popularFeatures,
  });
}
