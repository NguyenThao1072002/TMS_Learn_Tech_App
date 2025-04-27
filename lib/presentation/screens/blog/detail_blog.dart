import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tms_app/domain/entities/blog.dart';

class DetailBlogScreen extends StatefulWidget {
  final Blog blog;

  const DetailBlogScreen({Key? key, required this.blog}) : super(key: key);

  @override
  State<DetailBlogScreen> createState() => _DetailBlogScreenState();
}

class _DetailBlogScreenState extends State<DetailBlogScreen> {
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Đã lưu bài viết' : 'Đã bỏ lưu bài viết'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareArticle() {
    Share.share(
      '${widget.blog.title} - Đọc thêm tại TMS: https://tms.edu.vn/blog/${widget.blog.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _showAppBarTitle
            ? Text(
                widget.blog.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: _shareArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                widget.blog.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade400,
                      size: 40,
                    ),
                  );
                },
              ),
            ),

            // Article content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.blog.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.blog.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metadata
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.blog.authorAvatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.blog.author,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeago.format(widget.blog.publishDate,
                                locale: 'vi'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.remove_red_eye_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        widget.blog.views.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.blog.readTime} phút',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.blog.summary,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  _buildContent(),

                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.blog.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Related articles section
                  const Text(
                    'Bài viết liên quan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mock related articles
                  _buildRelatedArticles(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_upward),
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    // Đang sử dụng nội dung mẫu cho bài viết
    String htmlContent = '''
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi. Sed euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl. Nulla facilisi. Sed euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl.</p>
    
    <h2>Heading 1</h2>
    <p>Suspendisse potenti. Nam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl.</p>
    
    <p>Suspendisse potenti. Nam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl.</p>
    
    <blockquote>Suspendisse potenti. Nam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl.</blockquote>
    
    <h2>Heading 2</h2>
    <p>Suspendisse potenti. Nam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl.</p>
    
    <ul>
      <li>Item 1</li>
      <li>Item 2</li>
      <li>Item 3</li>
    </ul>
    
    <p>Suspendisse potenti. Nam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl.</p>
    ''';

    // Sử dụng flutter_html để hiển thị nội dung HTML
    return Html(
      data: htmlContent,
      style: {
        'p': Style(
          fontSize: FontSize(16),
          lineHeight: LineHeight(1.7),
          margin: Margins.only(bottom: 16),
        ),
        'h2': Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 24, bottom: 16),
        ),
        'blockquote': Style(
          backgroundColor: Colors.grey.shade50,
          padding: HtmlPaddings.all(16),
          margin: Margins.symmetric(vertical: 16),
          border: Border(left: BorderSide(color: Colors.blue, width: 4)),
        ),
        'ul': Style(
          margin: Margins.only(bottom: 16),
        ),
        'li': Style(
          margin: Margins.only(bottom: 8),
        ),
      },
    );
  }

  Widget _buildRelatedArticles() {
    // Mock related articles data
    final relatedArticles = [
      {
        'title': 'Top 10 ngôn ngữ lập trình được yêu thích nhất 2023',
        'imageUrl':
            'https://miro.medium.com/max/1200/1*eqa5gLZAOXZM2C5QmldAuw.jpeg',
      },
      {
        'title': 'Cách AI đang thay đổi quá trình phát triển phần mềm',
        'imageUrl':
            'https://www.freecodecamp.org/news/content/images/2023/05/ai-as-dev.png',
      },
      {
        'title': 'Những xu hướng công nghệ sẽ bùng nổ trong năm tới',
        'imageUrl':
            'https://thumbor.forbes.com/thumbor/fit-in/900x510/https://www.forbes.com/advisor/wp-content/uploads/2022/09/Image_-_Computer_Science.jpeg.jpg',
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatedArticles.length,
        itemBuilder: (context, index) {
          final article = relatedArticles[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(
                right: index != relatedArticles.length - 1 ? 16 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 120,
                  child: Image.network(
                    article['imageUrl']!,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          article['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đọc tiếp >>',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
