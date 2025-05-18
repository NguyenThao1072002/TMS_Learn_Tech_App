import 'package:flutter/material.dart';

// Import the MaterialType enum and MaterialItem class from enroll_course.dart using alias
import 'package:tms_app/presentation/screens/my_account/my_course/enroll_course.dart'
    as course_data;

class LessonMaterialsWidget extends StatelessWidget {
  final List<course_data.MaterialItem> materials;
  final String lessonTitle;

  const LessonMaterialsWidget({
    super.key,
    required this.materials,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Material Categories with modern card design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Danh mục tài liệu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Material Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildMaterialCategoryCard(
                    context,
                    icon: Icons.menu_book,
                    title: "Tài liệu bài học",
                    subtitle: "${materials.length} tài liệu",
                    color: Colors.blue,
                  ),
                  _buildMaterialCategoryCard(
                    context,
                    icon: Icons.assignment,
                    title: "Bài tập thực hành",
                    subtitle: "3 bài tập",
                    color: Colors.purple,
                  ),
                  _buildMaterialCategoryCard(
                    context,
                    icon: Icons.public,
                    title: "Tài nguyên web",
                    subtitle: "5 liên kết",
                    color: Colors.teal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Community section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cộng đồng khóa học',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '324 thành viên tích cực',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tham gia trao đổi, học hỏi và chia sẻ kinh nghiệm cùng các học viên khác trong cộng đồng khóa học',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCommunityButton(
                          context,
                          icon: Icons.forum_outlined,
                          label: 'Diễn đàn thảo luận',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mở diễn đàn thảo luận'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCommunityButton(
                          context,
                          icon: Icons.question_answer_outlined,
                          label: 'Hỏi đáp với giảng viên',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mở hỏi đáp với giảng viên'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Supplementary resources
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tài nguyên bổ sung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSupplementaryResource(
                    context,
                    icon: Icons.book,
                    title: 'Sách tham khảo',
                    description:
                        'Danh sách sách liên quan đến nội dung bài học',
                  ),
                  _buildSupplementaryResource(
                    context,
                    icon: Icons.video_library,
                    title: 'Video bổ sung',
                    description: 'Các video hướng dẫn chuyên sâu',
                  ),
                  _buildSupplementaryResource(
                    context,
                    icon: Icons.article,
                    title: 'Bài viết liên quan',
                    description: 'Các bài viết chuyên môn từ chuyên gia',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // List of Materials
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tài liệu của bài học này',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Materials list
            if (materials.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có tài liệu nào cho bài học này',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return _buildMaterialItem(context, material);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for material category cards
  Widget _buildMaterialCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mở danh mục: $title'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for material cards (replaced with _buildMaterialItem)
  Widget _buildMaterialItem(
      BuildContext context, course_data.MaterialItem material) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloading: ${material.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Material icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getMaterialColor(material.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getMaterialIcon(material.type),
                    size: 28,
                    color: _getMaterialColor(material.type),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Material details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      material.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Action buttons
                    Row(
                      children: [
                        Builder(
                          builder: (context) => _buildMaterialActionButton(
                            context,
                            icon: Icons.visibility,
                            label: 'Xem',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) => _buildMaterialActionButton(
                            context,
                            icon: Icons.download,
                            label: 'Tải về',
                            color: Colors.green,
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
    );
  }

  // Helper widget for material action buttons
  Widget _buildMaterialActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label tài liệu'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for community buttons
  Widget _buildCommunityButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for supplementary resources
  Widget _buildSupplementaryResource(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mở $title'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Determine color for material type
  Color _getMaterialColor(course_data.MaterialType type) {
    switch (type) {
      case course_data.MaterialType.pdf:
        return Colors.red;
      case course_data.MaterialType.document:
        return Colors.blue;
      case course_data.MaterialType.presentation:
        return Colors.orange;
      case course_data.MaterialType.spreadsheet:
        return Colors.green;
      case course_data.MaterialType.image:
        return Colors.purple;
      case course_data.MaterialType.code:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Determine icon for material type
  IconData _getMaterialIcon(course_data.MaterialType type) {
    switch (type) {
      case course_data.MaterialType.pdf:
        return Icons.picture_as_pdf;
      case course_data.MaterialType.document:
        return Icons.description;
      case course_data.MaterialType.presentation:
        return Icons.slideshow;
      case course_data.MaterialType.spreadsheet:
        return Icons.table_chart;
      case course_data.MaterialType.image:
        return Icons.image;
      case course_data.MaterialType.code:
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }
}
