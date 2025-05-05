import 'package:flutter/material.dart';
import 'package:tms_app/data/models/course/course_card_model.dart';

class CoursePreviewScreen extends StatefulWidget {
  final CourseCardModel course;
  final int progress;
  final bool isCompleted;

  const CoursePreviewScreen({
    Key? key,
    required this.course,
    required this.progress,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<CoursePreviewScreen> createState() => _CoursePreviewScreenState();
}

class _CoursePreviewScreenState extends State<CoursePreviewScreen> {
  bool _isExpanded = false;
  final List<String> _sampleLessons = [
    'Bài 1: Giới thiệu tổng quan',
    'Bài 2: Kiến thức cơ bản',
    'Bài 3: Kỹ thuật nâng cao',
    'Bài 4: Ứng dụng thực tế',
    'Bài 5: Bài tập thực hành',
    'Bài 6: Đánh giá và cải thiện',
    'Bài 7: Dự án thực tế',
    'Bài 8: Tổng kết khóa học',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with course image background
          SliverAppBar(
            expandedHeight: 240.0,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Course image
                  Image.network(
                    widget.course.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Course title and details
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.course.author,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.course.duration} giờ',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm vào danh sách yêu thích'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã chia sẻ khóa học'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          // Course content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  _buildProgressSection(),
                  const SizedBox(height: 24),

                  // About course
                  const Text(
                    'Giới thiệu về khóa học',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isExpanded
                        ? 'Khóa học "${widget.course.title}" cung cấp kiến thức toàn diện về chủ đề này. Bạn sẽ được học từ căn bản đến nâng cao, với nhiều ví dụ thực tế và bài tập thực hành. Khóa học được thiết kế bởi ${widget.course.author}, một chuyên gia trong lĩnh vực này với nhiều năm kinh nghiệm. \n\nKhóa học này phù hợp cho cả người mới bắt đầu và những người đã có kiến thức cơ bản muốn nâng cao kỹ năng. Bạn sẽ nhận được chứng chỉ sau khi hoàn thành tất cả các bài học và bài tập.'
                        : 'Khóa học "${widget.course.title}" cung cấp kiến thức toàn diện về chủ đề này. Bạn sẽ được học từ căn bản đến nâng cao, với nhiều ví dụ thực tế và bài tập thực hành...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Thu gọn' : 'Xem thêm',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course features
                  _buildFeatureSection(),
                  const SizedBox(height: 24),

                  // Course lessons
                  const Text(
                    'Nội dung khóa học',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLessonsList(),
                  const SizedBox(height: 24),

                  // Reviews section
                  _buildReviewsSection(),
                  const SizedBox(height: 32),

                  // CTA Button
                  _buildCallToActionButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isCompleted
                  ? 'Đã hoàn thành'
                  : 'Tiến độ: ${widget.progress}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              widget.isCompleted
                  ? 'Hoàn thành vào 15/05/2023'
                  : 'Cập nhật gần đây: 22/06/2023',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRounded(
          child: LinearProgressIndicator(
            value: widget.progress / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isCompleted ? Colors.green : Colors.orange,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureSection() {
    final features = [
      {'icon': Icons.assignment, 'text': '8 bài học'},
      {'icon': Icons.quiz, 'text': '4 bài kiểm tra'},
      {'icon': Icons.category, 'text': widget.course.categoryName},
      {'icon': Icons.star, 'text': '${widget.course.averageRating}/5 điểm'},
      {
        'icon': Icons.people,
        'text': '${widget.course.numberOfStudents} học viên'
      },
      {'icon': Icons.verified, 'text': 'Chứng chỉ'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin khóa học',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    features[index]['icon'] as IconData,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      features[index]['text'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLessonsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sampleLessons.length,
      itemBuilder: (context, index) {
        final bool isCompleted = widget.isCompleted ||
            widget.progress > (index * 100 / _sampleLessons.length);
        final bool isCurrent = !widget.isCompleted &&
            widget.progress < ((index + 1) * 100 / _sampleLessons.length) &&
            widget.progress >= (index * 100 / _sampleLessons.length);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isCurrent
                ? const BorderSide(color: Colors.orange, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : isCurrent
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              child: Icon(
                isCompleted
                    ? Icons.check_circle
                    : isCurrent
                        ? Icons.play_circle_filled
                        : Icons.lock,
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? Colors.orange
                        : Colors.grey,
              ),
            ),
            title: Text(
              _sampleLessons[index],
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              isCompleted
                  ? 'Hoàn thành'
                  : isCurrent
                      ? 'Đang học'
                      : 'Chưa bắt đầu',
              style: TextStyle(
                fontSize: 12,
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? Colors.orange
                        : Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                isCompleted || isCurrent ? Icons.arrow_forward : Icons.lock,
                color: isCompleted || isCurrent ? Colors.blue : Colors.grey,
              ),
              onPressed: isCompleted || isCurrent
                  ? () {
                      // Navigate to lesson content
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đang mở ${_sampleLessons[index]}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    // Sample reviews
    final reviews = [
      {
        'name': 'Nguyễn Văn A',
        'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
        'rating': 5,
        'date': '10/05/2023',
        'text':
            'Khóa học rất hay và bổ ích. Giảng viên giảng dạy rõ ràng, dễ hiểu.',
      },
      {
        'name': 'Trần Thị B',
        'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
        'rating': 4,
        'date': '22/04/2023',
        'text': 'Tốt, nhưng có thể cải thiện phần bài tập thực hành.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá từ học viên',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // View all reviews
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Rating overview
        Row(
          children: [
            Text(
              '${widget.course.averageRating}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < widget.course.averageRating.floor()
                          ? Icons.star
                          : index + 0.5 == widget.course.averageRating
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                ),
                Text(
                  '${widget.course.numberOfStudents} đánh giá',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Reviews
        ...reviews.map((review) => _buildReviewItem(review)).toList(),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              review['avatar'] as String,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < (review['rating'] as int)
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review['text'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToActionButton() {
    return widget.isCompleted
        ? ElevatedButton.icon(
            onPressed: () {
              // Download certificate
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang tải chứng chỉ...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.download),
            label: const Text(
              'Tải chứng chỉ khóa học',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ElevatedButton.icon(
            onPressed: () {
              // Continue learning
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tiếp tục học...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Tiếp tục học',
              style: TextStyle(fontSize: 16),
            ),
          );
  }
}

class ClipRounded extends StatelessWidget {
  final Widget child;
  final double radius;

  const ClipRounded({
    Key? key,
    required this.child,
    this.radius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }
}
