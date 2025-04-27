import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  // Dữ liệu cho FAQs
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Làm thế nào để đặt lại mật khẩu?',
      answer:
          'Để đặt lại mật khẩu, bạn có thể nhấn vào tùy chọn "Quên mật khẩu" trên màn hình đăng nhập. Sau đó, làm theo hướng dẫn để đặt lại mật khẩu thông qua email đã đăng ký.',
    ),
    FAQItem(
      question: 'Làm cách nào để liên hệ với đội ngũ hỗ trợ?',
      answer:
          'Bạn có thể liên hệ với đội ngũ hỗ trợ của chúng tôi qua email tms.huit@gmail.com hoặc gọi số hotline 0348 740 942. Chúng tôi sẽ phản hồi trong vòng 24 giờ làm việc.',
    ),
    FAQItem(
      question: 'Tôi không thể truy cập vào khóa học đã mua, phải làm sao?',
      answer:
          'Nếu bạn không thể truy cập vào khóa học đã mua, hãy thử đăng xuất và đăng nhập lại. Nếu vấn đề vẫn tiếp diễn, kiểm tra kết nối internet của bạn hoặc liên hệ với bộ phận hỗ trợ kỹ thuật để được giúp đỡ.',
    ),
    FAQItem(
      question: 'Chứng chỉ khóa học có giá trị pháp lý không?',
      answer:
          'Chứng chỉ hoàn thành khóa học của chúng tôi được công nhận bởi nhiều đối tác doanh nghiệp và tổ chức giáo dục. Tuy nhiên, tùy thuộc vào từng ngành nghề, giá trị pháp lý có thể khác nhau. Vui lòng kiểm tra thông tin chi tiết của từng khóa học.',
    ),
    FAQItem(
      question: 'Tôi có thể học trên thiết bị nào?',
      answer:
          'Bạn có thể học trên mọi thiết bị bao gồm máy tính, điện thoại, máy tính bảng thông qua ứng dụng hoặc website. Chúng tôi hỗ trợ đồng bộ tiến độ học tập giữa các thiết bị để bạn có thể học mọi lúc, mọi nơi.',
    ),
    FAQItem(
      question: 'Có thể thanh toán bằng những phương thức nào?',
      answer:
          'Chúng tôi hỗ trợ nhiều phương thức thanh toán như thẻ tín dụng/ghi nợ, chuyển khoản ngân hàng, ví điện tử (Momo, VNPay), và thanh toán qua các đại lý được ủy quyền.',
    ),
  ];

  // Contact methods
  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      icon: Icons.email,
      title: 'Email',
      subtitle: 'support@tms.edu.vn',
      color: Colors.orange,
      onTap: () {
        // Không sử dụng url_launcher
      },
    ),
    ContactMethod(
      icon: Icons.phone,
      title: 'Hotline',
      subtitle: '1900 1234',
      color: Colors.green,
      onTap: () {
        // Không sử dụng url_launcher
      },
    ),
    ContactMethod(
      icon: Icons.chat,
      title: 'Live Chat',
      subtitle: 'Trò chuyện trực tiếp',
      color: Colors.blue,
      onTap: () {},
    ),
    ContactMethod(
      icon: Icons.groups,
      title: 'Cộng đồng',
      subtitle: 'Diễn đàn hỗ trợ',
      color: Colors.purple,
      onTap: () {},
    ),
  ];

  // Danh sách nội dung hướng dẫn
  final List<GuideCategory> _guideCategories = [
    GuideCategory(
      title: 'Hướng dẫn bắt đầu',
      guides: [
        'Cách đăng ký tài khoản mới',
        'Tùy chỉnh hồ sơ cá nhân',
        'Tìm kiếm khóa học phù hợp',
      ],
    ),
    GuideCategory(
      title: 'Khóa học & Học tập',
      guides: [
        'Cách tham gia khóa học',
        'Theo dõi tiến độ học tập',
        'Tải tài liệu học tập',
        'Tham gia thảo luận',
      ],
    ),
    GuideCategory(
      title: 'Thanh toán & Đăng ký',
      guides: [
        'Các phương thức thanh toán',
        'Truy cập khóa học đã mua',
        'Yêu cầu hoàn tiền',
        'Mã khuyến mãi và ưu đãi',
      ],
    ),
  ];

  // Trạng thái mở rộng của các FAQ items
  final List<bool> _expandedFlags = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trung tâm trợ giúp',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner hỗ trợ
            _buildSupportBanner(),

            // Phần tìm kiếm
            _buildSearchBox(),

            // Phương thức liên hệ
            _buildSectionTitle('Liên hệ hỗ trợ'),
            _buildContactMethods(),

            // Câu hỏi thường gặp
            _buildSectionTitle('Câu hỏi thường gặp'),
            _buildFAQList(),

            // Hướng dẫn sử dụng
            _buildSectionTitle('Hướng dẫn sử dụng'),
            _buildGuidesList(),

            const SizedBox(height: 30),

            // Mục phản hồi
            _buildFeedbackSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị banner hỗ trợ
  Widget _buildSupportBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chúng tôi luôn sẵn sàng giúp đỡ bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đội ngũ hỗ trợ sẵn sàng giải đáp mọi thắc mắc',
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Không sử dụng url_launcher
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Gọi ngay'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị hộp tìm kiếm
  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm câu hỏi, hướng dẫn...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  // Widget hiển thị tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12, right: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget hiển thị các phương thức liên hệ
  Widget _buildContactMethods() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _contactMethods.length,
        itemBuilder: (context, index) {
          final method = _contactMethods[index];
          return GestureDetector(
            onTap: method.onTap,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(method.icon, color: method.color, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    method.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị danh sách FAQ
  Widget _buildFAQList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _faqItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          return ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              _faqItems[index].question,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    _expandedFlags[index] ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            trailing: Icon(
              _expandedFlags[index]
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedFlags[index] = expanded;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  _faqItems[index].answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget hiển thị danh sách hướng dẫn
  Widget _buildGuidesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _guideCategories.map((category) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ...category.guides.map((guide) {
                  return ListTile(
                    title: Text(
                      guide,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // TODO: Navigate to guide detail
                    },
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget hiển thị phần phản hồi
  Widget _buildFeedbackSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'Gửi phản hồi của bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Phản hồi của bạn giúp chúng tôi cải thiện dịch vụ hỗ trợ tốt hơn. Hãy chia sẻ ý kiến hoặc báo cáo vấn đề bạn gặp phải.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement feedback form
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Center(
              child: Text(
                'Gửi phản hồi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model cho FAQ item
class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

// Model cho phương thức liên hệ
class ContactMethod {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  ContactMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

// Model cho danh mục hướng dẫn
class GuideCategory {
  final String title;
  final List<String> guides;

  GuideCategory({required this.title, required this.guides});
}
