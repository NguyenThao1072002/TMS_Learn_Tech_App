import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
      subtitle: 'tms.huit@gmail.com',
      color: Colors.orange,
      onTap: () {
        // Mở ứng dụng email
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: 'tms.huit@gmail.com',
        );
        launchUrl(emailUri, mode: LaunchMode.externalApplication);
      },
    ),
    ContactMethod(
      icon: Icons.phone,
      title: 'Hotline',
      subtitle: '0348 740 942',
      color: Colors.green,
      onTap: () {
        // Mở ứng dụng gọi điện
        final Uri callUri = Uri(
          scheme: 'tel',
          path: '0348740942',
        );
        launchUrl(callUri, mode: LaunchMode.externalApplication);
      },
    ),
    // ContactMethod(
    //   icon: Icons.chat,
    //   title: 'Live Chat',
    //   subtitle: 'Trò chuyện trực tiếp',
    //   color: Colors.blue,
    //   onTap: () {},
    // ),
    // ContactMethod(
    //   icon: Icons.groups,
    //   title: 'Cộng đồng',
    //   subtitle: 'Diễn đàn hỗ trợ',
    //   color: Colors.purple,
    //   onTap: () {},
    // ),
  ];

  // Danh sách nội dung hướng dẫn
  final List<GuideCategory> _guideCategories = [
    GuideCategory(
      title: 'Hướng dẫn bắt đầu',
      guides: [
        GuideItem(
          title: 'Cách đăng ký tài khoản mới',
          content: """
# Đăng ký tài khoản mới

Để tạo tài khoản mới trên nền tảng TMS Learn Tech, vui lòng làm theo các bước sau:

## Bước 1: Truy cập màn hình đăng ký
- Mở ứng dụng TMS Learn Tech
- Nhấn vào nút "Đăng ký" trên màn hình đăng nhập

## Bước 2: Điền thông tin cá nhân
- Nhập họ tên đầy đủ
- Nhập email hợp lệ (sẽ được dùng để xác minh tài khoản)
- Tạo mật khẩu mạnh (ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt)
- Xác nhận lại mật khẩu

## Bước 3: Xác minh tài khoản
- Kiểm tra email để nhận mã xác minh
- Nhập mã xác minh vào ứng dụng

## Bước 4: Hoàn tất đăng ký
- Sau khi xác minh thành công, tài khoản của bạn đã sẵn sàng sử dụng
- Đăng nhập và bắt đầu khám phá các khóa học!

Nếu bạn gặp vấn đề khi đăng ký, vui lòng liên hệ đội ngũ hỗ trợ của chúng tôi qua email hoặc hotline.
          """,
        ),
        GuideItem(
          title: 'Tùy chỉnh hồ sơ cá nhân',
          content: """
# Tùy chỉnh hồ sơ cá nhân

Cập nhật thông tin cá nhân giúp cá nhân hóa trải nghiệm của bạn và nhận được các đề xuất phù hợp hơn.

## Truy cập hồ sơ cá nhân
- Mở ứng dụng và đăng nhập vào tài khoản
- Nhấn vào biểu tượng tài khoản ở góc phải phía dưới
- Chọn "Tài khoản của tôi"

## Chỉnh sửa thông tin cá nhân
- Nhấn vào nút "Chỉnh sửa" gần phần thông tin cá nhân
- Bạn có thể cập nhật các thông tin sau:
  + Ảnh đại diện
  + Họ tên
  + Số điện thoại
  + Địa chỉ
  + Thông tin giới thiệu

## Thay đổi mật khẩu
- Trong phần Cài đặt tài khoản, chọn "Đổi mật khẩu"
- Nhập mật khẩu hiện tại
- Tạo mật khẩu mới và xác nhận

## Cài đặt bảo mật và quyền riêng tư
- Tùy chỉnh các thông báo bạn muốn nhận
- Quản lý cài đặt riêng tư của tài khoản

Lưu ý: Đảm bảo lưu các thay đổi sau khi cập nhật thông tin để áp dụng cập nhật.
          """,
        ),
        GuideItem(
          title: 'Tìm kiếm khóa học phù hợp',
          content: """
# Tìm kiếm khóa học phù hợp

Khám phá và tìm kiếm các khóa học phù hợp với nhu cầu học tập của bạn.

## Sử dụng thanh tìm kiếm
- Nhấn vào biểu tượng tìm kiếm ở góc trên của ứng dụng
- Nhập từ khóa liên quan đến chủ đề bạn quan tâm
- Xem kết quả tìm kiếm và lọc theo nhu cầu

## Lọc khóa học
- Từ màn hình khóa học, sử dụng các bộ lọc để thu hẹp kết quả:
  + Danh mục (lập trình, thiết kế, marketing,...)
  + Cấp độ (cơ bản, trung cấp, nâng cao)
  + Đánh giá (4 sao trở lên, 5 sao)
  + Thời lượng (ngắn, trung bình, dài)

## Khám phá danh mục
- Truy cập tab "Khóa học" từ màn hình chính
- Duyệt qua các danh mục khác nhau
- Xem các khóa học phổ biến hoặc mới nhất

## Xem chi tiết khóa học
- Nhấn vào khóa học để xem thông tin chi tiết
- Kiểm tra nội dung chương trình học
- Đọc đánh giá từ học viên trước
- Xem thông tin về giảng viên

## Lưu và so sánh
- Lưu các khóa học bạn quan tâm vào danh sách yêu thích
- So sánh các khóa học để chọn ra khóa phù hợp nhất

Mẹo: Đăng ký nhận thông báo về các khóa học mới trong lĩnh vực bạn quan tâm để không bỏ lỡ cơ hội học tập.
          """,
        ),
      ],
    ),
    GuideCategory(
      title: 'Khóa học & Học tập',
      guides: [
        GuideItem(
          title: 'Cách tham gia khóa học',
          content: """
# Cách tham gia khóa học

TMS Learn Tech cung cấp nhiều loại khóa học khác nhau, từ miễn phí đến có phí, để phù hợp với nhu cầu học tập của bạn.

## Đăng ký khóa học

### Khóa học miễn phí:
- Tìm khóa học bạn quan tâm
- Nhấn vào nút "Đăng ký học"
- Khóa học sẽ được thêm vào danh sách "Khóa học của tôi" và bạn có thể bắt đầu học ngay lập tức

### Khóa học có phí:
- Chọn khóa học bạn muốn tham gia
- Nhấn vào nút "Đăng ký học"
- Thực hiện thanh toán theo hướng dẫn
- Sau khi thanh toán thành công, khóa học sẽ được thêm vào danh sách "Khóa học của tôi"

## Học viên HUIT

Nếu bạn là sinh viên HUIT, bạn có thể kích hoạt khóa học bằng mã đặc biệt:

1. Vào phần "Kích hoạt khóa học" từ menu chính
2. Nhập mã kích hoạt được cung cấp bởi giảng viên
3. Sau khi kích hoạt thành công, bạn có thể truy cập tất cả nội dung khóa học ngay lập tức
4. Kết quả bài kiểm tra sẽ được sử dụng làm điểm BTVN và phân tích khả năng học tập

### Thời hạn mã kích hoạt HUIT:
- Mã kích hoạt chỉ có hiệu lực trong khoảng thời gian học tập tại trường
- Mỗi mã được giảng viên thiết lập thời gian hiệu lực cụ thể
- Sau khi hết thời hạn hiệu lực, bạn sẽ không thể sử dụng mã để kích hoạt
- Thời gian truy cập khóa học sau khi kích hoạt sẽ tương ứng với thời gian học kỳ
- Nếu bạn chưa kích hoạt trước thời hạn, hãy liên hệ trực tiếp với giảng viên

## Cấu trúc khóa học

Mỗi khóa học bao gồm:
- Nhiều chương học
- Mỗi chương có nhiều bài học
- Mỗi bài học bao gồm video bài giảng và bài kiểm tra
- Mỗi chương kết thúc bằng một bài kiểm tra chương

**Lưu ý về quy định hoàn thành bài học:**
- Học viên đăng ký tự do: Phải hoàn thành bài kiểm tra với điểm đạt yêu cầu mới được tiếp tục bài học tiếp theo
- Học viên HUIT: Có thể tự do truy cập tất cả nội dung, không bắt buộc hoàn thành bài kiểm tra để tiếp tục
          """,
        ),
        GuideItem(
          title: 'Theo dõi tiến độ học tập',
          content: """
# Theo dõi tiến độ học tập

TMS Learn Tech cung cấp nhiều công cụ để theo dõi và quản lý tiến độ học tập của bạn.

## Bảng điều khiển học tập

Bảng điều khiển học tập cá nhân hiển thị:
- Day streak (số ngày học liên tiếp)
- Xếp hạng của bạn trong cộng đồng học viên
- Khóa học đang học và tiến độ hoàn thành
- Đề xuất bài học tiếp theo
- Thành tích và điểm thưởng

## Lộ trình học tập cá nhân hóa

Dựa trên kết quả học tập và mục tiêu của bạn, hệ thống sẽ đề xuất:
- Lộ trình học tập phù hợp
- Thời gian học đề xuất
- Bài học cần ưu tiên

## Thống kê và phân tích

Truy cập phần "Thống kê học tập" để xem:
- Biểu đồ tiến bộ theo thời gian
- Điểm mạnh và điểm yếu
- Tỷ lệ hoàn thành bài học
- Thời gian học trung bình

## Dành riêng cho sinh viên HUIT

Các tính năng đặc biệt:
- Dự đoán khả năng không đạt môn dựa trên kết quả bài kiểm tra
- Đề xuất bài học cần ôn tập
- Tích hợp điểm BTVN với hệ thống đánh giá của trường

## Day Streak và Phần thưởng

Duy trì day streak để nhận:
- Huy hiệu đặc biệt
- Voucher giảm giá khóa học
- Mở khóa tính năng đặc biệt
- Tăng thứ hạng trong bảng xếp hạng
          """,
        ),
        GuideItem(
          title: 'Tải tài liệu học tập',
          content: """
# Tải tài liệu học tập

TMS Learn Tech cung cấp nhiều loại tài liệu học tập để hỗ trợ quá trình học của bạn.

## Phân loại tài liệu

Nền tảng của chúng tôi cung cấp hai loại tài liệu chính:

### Tài liệu công khai:
- Có thể truy cập miễn phí bởi tất cả người dùng đã đăng ký
- Bao gồm tài liệu giới thiệu, sách trắng, và hướng dẫn cơ bản
- Không yêu cầu mua khóa học để truy cập

### Tài liệu khóa học:
- Chỉ dành riêng cho học viên đã đăng ký và thanh toán khóa học
- Bao gồm tài liệu chuyên sâu, bài tập thực hành, mã nguồn và dự án mẫu
- Cần đăng nhập và xác thực quyền truy cập để xem và tải xuống
- Được bảo vệ bản quyền và không được phép chia sẻ với người khác

## Loại tài liệu có sẵn

Trong mỗi khóa học, bạn có thể truy cập:
- Slide bài giảng (PDF)
- Tài liệu tham khảo
- Mã nguồn và ví dụ thực hành
- Bài tập thực hành
- Tài liệu bổ sung

## Cách tải tài liệu

1. Vào khóa học bạn đã đăng ký
2. Chọn bài học có tài liệu bạn muốn tải
3. Tìm phần "Tài liệu" trong trang bài học
4. Nhấn vào biểu tượng tải xuống bên cạnh tài liệu
5. Tài liệu sẽ được lưu vào thiết bị của bạn

## Quản lý tài liệu đã tải

- Tất cả tài liệu đã tải có thể được truy cập trong phần "Tài liệu của tôi"
- Bạn có thể tổ chức tài liệu theo khóa học hoặc theo chủ đề
- Chức năng tìm kiếm giúp bạn nhanh chóng tìm tài liệu cần thiết

## Chính sách bảo mật tài liệu

- **Không chia sẻ tài liệu khóa học**: Tài liệu khóa học không được phép chia sẻ cho người khác
- Mọi hành vi chia sẻ trái phép tài liệu khóa học đều vi phạm điều khoản sử dụng
- Hệ thống có các biện pháp bảo vệ và theo dõi việc sử dụng tài liệu
- Tài liệu có thể chứa thông tin định danh người dùng để ngăn chặn chia sẻ trái phép
- Vi phạm chính sách có thể dẫn đến việc khóa tài khoản và mất quyền truy cập

## Tài liệu ngoại tuyến

- Tài liệu đã tải có thể được truy cập ngay cả khi không có kết nối internet
- Đánh dấu tài liệu để dễ dàng truy cập sau này
- Một số tài liệu có thời hạn truy cập offline giới hạn vì lý do bảo mật
          """,
        ),
        GuideItem(
          title: 'Tham gia thảo luận',
          content: """
# Tham gia thảo luận

Cộng đồng học tập là một phần quan trọng của trải nghiệm TMS Learn Tech. Tham gia thảo luận để học hỏi và chia sẻ kiến thức.

## Diễn đàn khóa học

Mỗi khóa học có diễn đàn riêng:
- Đặt câu hỏi về nội dung bài học
- Chia sẻ giải pháp bài tập
- Nhận hỗ trợ từ giảng viên và học viên khác
- Thảo luận về các chủ đề liên quan

## Tạo bài đăng mới

1. Vào phần "Thảo luận" trong khóa học
2. Nhấn nút "Tạo bài đăng mới"
3. Nhập tiêu đề và nội dung câu hỏi/thảo luận
4. Thêm mã code, hình ảnh hoặc tệp đính kèm nếu cần
5. Chọn thẻ phù hợp để phân loại bài đăng
6. Đăng bài

## Trả lời và tương tác

- Nhấn "Trả lời" để phản hồi bài đăng
- Sử dụng nút "Hữu ích" để đánh dấu câu trả lời có giá trị
- Đánh dấu bài đăng để nhận thông báo khi có phản hồi mới

## Nhóm học tập

- Tạo hoặc tham gia nhóm học tập với học viên khác
- Chia sẻ tài nguyên và học tập cùng nhau
- Tổ chức buổi thảo luận trực tuyến

## Quy tắc cộng đồng

Khi tham gia thảo luận, vui lòng tuân thủ:
- Tôn trọng học viên khác
- Không chia sẻ nội dung không phù hợp
- Tập trung vào chủ đề học tập
- Không sao chép hoặc đạo văn
          """,
        ),
      ],
    ),
    GuideCategory(
      title: 'Thanh toán & Đăng ký',
      guides: [
        GuideItem(
          title: 'Các phương thức thanh toán',
          content: """
# Các phương thức thanh toán

TMS Learn Tech hỗ trợ nhiều phương thức thanh toán để bạn có thể dễ dàng đăng ký khóa học.

## Phương thức thanh toán được hỗ trợ

### Thanh toán trực tuyến:
- Thẻ tín dụng/ghi nợ quốc tế (Visa, Mastercard, JCB)
- Thẻ ATM nội địa (có đăng ký Internet Banking)
- Ví điện tử (MoMo, ZaloPay, VNPay)
- Quét mã QR

### Thanh toán khác:
- Chuyển khoản ngân hàng
- Thanh toán tại văn phòng TMS
- Thanh toán qua đại lý ủy quyền

## Quy trình thanh toán

1. Chọn khóa học bạn muốn đăng ký
2. Nhấn nút "Đăng ký học"
3. Kiểm tra thông tin đơn hàng
4. Chọn phương thức thanh toán phù hợp
5. Làm theo hướng dẫn để hoàn tất thanh toán
6. Sau khi thanh toán thành công, bạn sẽ nhận được email xác nhận

## Combo khóa học

Đăng ký combo khóa học để tiết kiệm:
- Tiết kiệm hơn so với mua riêng lẻ
- Nhiều combo được thiết kế theo lộ trình phát triển kỹ năng
- Thanh toán một lần và truy cập toàn bộ khóa học trong combo

## Mã khuyến mãi và ưu đãi

- Nhập mã khuyến mãi tại trang thanh toán
- Mã giảm giá có thể được cấp từ chương trình day streak
- Một số ưu đãi đặc biệt cho sinh viên và học viên cũ

          """,
        ),
        GuideItem(
          title: 'Truy cập khóa học đã mua',
          content: """
# Truy cập khóa học đã mua

Sau khi đăng ký thành công, bạn có thể dễ dàng truy cập và quản lý khóa học của mình.

## Truy cập khóa học

### Từ trang chủ:
1. Đăng nhập vào tài khoản của bạn
2. Nhấn vào mục "Khóa học của tôi" trên menu chính
3. Danh sách khóa học đã đăng ký sẽ hiển thị
4. Chọn khóa học bạn muốn học

### Từ ứng dụng di động:
- Mở ứng dụng TMS Learn Tech
- Chuyển đến tab "Khóa học của tôi"
- Nhấn vào khóa học để bắt đầu học

## Quản lý khóa học

- Sắp xếp khóa học theo thứ tự ưu tiên
- Đánh dấu khóa học yêu thích
- Theo dõi tiến độ hoàn thành
- Đặt lịch học và nhận thông báo nhắc nhở

## Thời hạn truy cập

- Hầu hết các khóa học cung cấp quyền truy cập vĩnh viễn sau khi mua
- Một số khóa học đặc biệt có thời hạn truy cập giới hạn
- Kiểm tra thông tin khóa học để biết thêm chi tiết

## Học trên nhiều thiết bị

- Truy cập khóa học từ máy tính, điện thoại, hoặc máy tính bảng
- Tiến độ học tập được đồng bộ giữa các thiết bị
- Tải ứng dụng di động để học offline khi không có kết nối internet

## Khắc phục sự cố truy cập

Nếu bạn không thể truy cập khóa học:
- Kiểm tra kết nối internet
- Đăng xuất và đăng nhập lại
- Xóa cache trình duyệt hoặc ứng dụng
- Liên hệ hỗ trợ nếu vấn đề vẫn tiếp diễn
          """,
        ),
        GuideItem(
          title: 'Yêu cầu hoàn tiền',
          content: """
# Chính sách không hoàn tiền

TMS Learn Tech áp dụng chính sách không hoàn tiền cho tất cả các khóa học và gói thành viên đã thanh toán.

## Chính sách thanh toán

- Tất cả các giao dịch thanh toán đều là cuối cùng và không được hoàn tiền
- Vui lòng xem xét kỹ thông tin khóa học và gói thành viên trước khi quyết định mua
- Bạn có thể trải nghiệm nội dung miễn phí hoặc bài học demo trước khi thanh toán
- Chúng tôi cam kết cung cấp thông tin chính xác về nội dung khóa học

## Quản lý gói thành viên

### Đổi gói thành viên
- Có thể nâng cấp gói thành viên bất kỳ lúc nào
- Khi nâng cấp, hệ thống sẽ tính phí chênh lệch tương ứng với thời gian còn lại của gói hiện tại
- Việc nâng cấp có hiệu lực ngay lập tức
- Các quyền lợi của gói mới sẽ được áp dụng ngay sau khi thanh toán thành công

### Tự động gia hạn
- Gói thành viên sẽ tự động gia hạn khi hết hạn
- Thông báo gia hạn sẽ được gửi qua email trước ngày gia hạn 7 ngày
- Có thể hủy tự động gia hạn bất kỳ lúc nào trong phần Cài đặt tài khoản
- Nếu có thay đổi về giá, bạn sẽ được thông báo trước khi gia hạn

### Hủy gói thành viên
- Có thể hủy gói thành viên bất kỳ lúc nào
- Khi hủy, bạn vẫn có thể sử dụng dịch vụ cho đến hết thời hạn đã thanh toán
- Sau khi hết hạn, quyền truy cập vào nội dung độc quyền sẽ bị hạn chế
- Hủy gói không đồng nghĩa với việc xóa tài khoản

## Trường hợp đặc biệt

Trong một số trường hợp đặc biệt như gián đoạn dịch vụ kéo dài hoặc sự cố kỹ thuật nghiêm trọng từ phía chúng tôi, vui lòng liên hệ đội ngũ hỗ trợ để được giải quyết thỏa đáng. Mỗi trường hợp sẽ được xem xét riêng.

## Liên hệ hỗ trợ

Nếu bạn có bất kỳ câu hỏi nào về chính sách thanh toán hoặc cần hỗ trợ về gói thành viên:
- Email: tms.huit@gmail.com
- Hotline: 0348 740 942
- Chat trực tuyến: Có sẵn 24/7 trong ứng dụng
          """,
        ),
        GuideItem(
          title: 'Mã khuyến mãi và ưu đãi',
          content: """
# Mã khuyến mãi và ưu đãi

Tận dụng các mã khuyến mãi và ưu đãi để tiết kiệm khi đăng ký khóa học trên TMS Learn Tech.

## Loại mã khuyến mãi

### Mã giảm giá cố định:
- Giảm một số tiền cố định từ giá khóa học
- Ví dụ: Giảm 200.000 VNĐ cho khóa học bất kỳ

### Mã giảm giá theo phần trăm:
- Giảm theo tỷ lệ phần trăm từ giá gốc
- Ví dụ: Giảm 20% giá khóa học

### Mã combo:
- Áp dụng khi đăng ký nhiều khóa học cùng lúc
- Tiết kiệm từ 10% đến 50% tổng giá trị

## Cách nhận mã khuyến mãi

- Đạt thành tích trong day streak
- Hoàn thành khóa học và nhận mã giảm giá cho khóa tiếp theo
- Tham gia sự kiện và cuộc thi
- Đăng ký nhận bản tin để cập nhật khuyến mãi mới nhất
- Giới thiệu bạn bè tham gia

## Sử dụng mã khuyến mãi

1. Chọn khóa học bạn muốn đăng ký
2. Tiến hành thanh toán
3. Tại trang thanh toán, nhập mã khuyến mãi vào ô "Mã giảm giá"
4. Nhấn "Áp dụng" để kiểm tra tính hợp lệ
5. Giá khóa học sẽ được cập nhật nếu mã hợp lệ

## Khuyến mãi từ quản trị viên

- Quản trị viên thường xuyên cập nhật và công bố các chương trình khuyến mãi đặc biệt
- Các khuyến mãi có thể thay đổi theo mùa, sự kiện hoặc chiến dịch marketing
- Theo dõi thông báo trong ứng dụng và email để không bỏ lỡ các ưu đãi mới nhất
- Các khuyến mãi đặc biệt có thể bao gồm:
  + Flash sale trong thời gian giới hạn
  + Khuyến mãi theo mùa (Tết, hè, năm học mới)
  + Ưu đãi nhân dịp kỷ niệm của nền tảng
  + Chương trình giới thiệu với phần thưởng tăng gấp đôi

## Lưu ý quan trọng

- Mỗi mã khuyến mãi có thời hạn sử dụng giới hạn
- Một số mã chỉ áp dụng cho khóa học cụ thể
- Không thể kết hợp nhiều mã khuyến mãi cho một lần thanh toán
- Kiểm tra điều kiện áp dụng trước khi sử dụng mã

## Ưu đãi đặc biệt

- Ưu đãi cho sinh viên: Giảm 15% với email trường học hợp lệ
- Ưu đãi nhóm: Đăng ký từ 5 người trở lên được giảm thêm 10%
- Chương trình học viên thân thiết: Tích điểm và đổi ưu đãi
          """,
        ),
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
                      guide.title,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      _showGuideDetailDialog(guide);
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

  // Hiển thị dialog hướng dẫn chi tiết
  void _showGuideDetailDialog(GuideItem guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Thanh kéo
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book,
                            color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          guide.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: _buildMarkdownContent(guide.content),
                  ),
                ),

                // Bottom padding để tránh các nút điều hướng
                Container(
                  height: MediaQuery.of(context).padding.bottom,
                  color: Colors.white,
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget để hiển thị nội dung markdown đơn giản
  Widget _buildMarkdownContent(String content) {
    final lines = content.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      if (line.startsWith('# ')) {
        // Heading 1
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            line.substring(2),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        // Heading 2
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            line.substring(3),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        // Bullet points
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ));
      } else if (line.startsWith('  + ')) {
        // Nested bullet points
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('◦ ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  line.substring(4),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ));
      } else if (line.isEmpty) {
        // Empty line for spacing
        widgets.add(const SizedBox(height: 8));
      } else {
        // Regular paragraph
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: const TextStyle(fontSize: 14),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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
              _sendFeedbackEmail();
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

  // Phương thức để mở email feedback
  void _sendFeedbackEmail() async {
    final String email = 'tms.huit@gmail.com';
    final String subject = 'Phản hồi từ ứng dụng TMS Learn Tech';
    final String body = '''
Kính gửi Đội ngũ Hỗ trợ TMS Learn Tech,

Tôi muốn gửi phản hồi sau về ứng dụng:

Loại phản hồi: [Báo cáo lỗi / Góp ý cải thiện / Câu hỏi / Khác]

Chi tiết: 
[Vui lòng mô tả chi tiết phản hồi của bạn ở đây]

Thông tin thiết bị:
- Mẫu thiết bị: 
- Phiên bản hệ điều hành: 
- Phiên bản ứng dụng: 

Xin cảm ơn!
    ''';

    // Tạo mailto URL trực tiếp với encoding đúng
    final String encodedSubject = Uri.encodeComponent(subject);
    final String encodedBody = Uri.encodeComponent(body);
    final String mailtoUrl =
        'mailto:$email?subject=$encodedSubject&body=$encodedBody';

    try {
      // Sử dụng cách parse URI từ string để đảm bảo encoding chính xác
      final Uri mailtoUri = Uri.parse(mailtoUrl);
      final bool launched = await launchUrl(
        mailtoUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Nếu không thể mở ứng dụng email, hiển thị hộp thoại lỗi
        _showEmailErrorDialog();
      }
    } catch (e) {
      print('Error launching email: $e');
      _showEmailErrorDialog();
    }
  }

  // Hiển thị thông báo lỗi khi không thể mở ứng dụng email
  void _showEmailErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không thể mở ứng dụng email'),
        content: const Text(
            'Không thể mở ứng dụng email trên thiết bị của bạn. Vui lòng gửi email trực tiếp đến địa chỉ tms.huit@gmail.com'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(
                  const ClipboardData(text: 'tms.huit@gmail.com'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép địa chỉ email')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Sao chép địa chỉ email'),
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
  final List<GuideItem> guides;

  GuideCategory({required this.title, required List<GuideItem> guides})
      : guides = guides;
}

// Model cho mục hướng dẫn
class GuideItem {
  final String title;
  final String content;

  GuideItem({required this.title, required this.content});
}
