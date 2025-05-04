import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tms_app/data/models/blog_card_model.dart';

class DetailBlogScreen extends StatefulWidget {
  final BlogCardModel blog;

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
                widget.blog.image,
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
                      widget.blog.catergoryName,
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
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          widget.blog.authorName.isNotEmpty
                              ? widget.blog.authorName[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.blog.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeago.format(widget.blog.createdAt, locale: 'vi'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.remove_red_eye_outlined,
                                size: 14, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.blog.views}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Html(
                    data: widget.blog.content,
                    style: {
                      'body': Style(
                        fontSize: FontSize(16.0),
                        lineHeight: LineHeight(1.8),
                        textAlign: TextAlign.justify,
                      ),
                      'h1': Style(
                        fontSize: FontSize(22.0),
                        fontWeight: FontWeight.bold,
                        margin: Margins(
                            left: Margin(16.0),
                            right: Margin(16.0),
                            top: Margin(24.0),
                            bottom: Margin(16.0)),
                      ),
                      'h2': Style(
                        fontSize: FontSize(20.0),
                        fontWeight: FontWeight.bold,
                        margin: Margins(
                            left: Margin(16.0),
                            right: Margin(16.0),
                            top: Margin(20.0),
                            bottom: Margin(12.0)),
                      ),
                      'h3': Style(
                        fontSize: FontSize(18.0),
                        fontWeight: FontWeight.bold,
                        margin: Margins(
                            left: Margin(16.0),
                            right: Margin(16.0),
                            top: Margin(16.0),
                            bottom: Margin(10.0)),
                      ),
                      'p': Style(
                        margin: Margins(bottom: Margin(16.0)),
                      ),
                      'img': Style(
                        margin:
                            Margins(top: Margin(16.0), bottom: Margin(16.0)),
                      ),
                      'a': Style(
                        color: Colors.blue,
                        textDecoration: TextDecoration.none,
                      ),
                      'ul': Style(
                        margin: Margins(bottom: Margin(16.0)),
                      ),
                      'ol': Style(
                        margin: Margins(bottom: Margin(16.0)),
                      ),
                      'li': Style(
                        margin: Margins(bottom: Margin(8.0)),
                      ),
                      'blockquote': Style(
                        backgroundColor: Colors.grey.shade100,
                        padding: HtmlPaddings.all(16.0),
                        fontStyle: FontStyle.italic,
                        margin:
                            Margins(top: Margin(16.0), bottom: Margin(16.0)),
                        border: const Border(
                          left: BorderSide(
                            color: Colors.blue,
                            width: 4.0,
                          ),
                        ),
                      ),
                      'pre': Style(
                        backgroundColor: Colors.grey.shade900,
                        padding: HtmlPaddings.all(16.0),
                        margin:
                            Margins(top: Margin(16.0), bottom: Margin(16.0)),
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: FontSize(14.0),
                      ),
                      'code': Style(
                        backgroundColor: Colors.grey.shade200,
                        padding: HtmlPaddings.all(4.0),
                        fontFamily: 'monospace',
                        fontSize: FontSize(14.0),
                      ),
                      'table': Style(
                        border: const Border(
                          top: BorderSide(color: Colors.grey),
                          right: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey),
                          left: BorderSide(color: Colors.grey),
                        ),
                      ),
                      'th': Style(
                        backgroundColor: Colors.grey.shade200,
                        padding: HtmlPaddings.all(8.0),
                        border: const Border(
                          bottom: BorderSide(color: Colors.grey),
                          right: BorderSide(color: Colors.grey),
                        ),
                      ),
                      'td': Style(
                        padding: HtmlPaddings.all(8.0),
                        border: const Border(
                          bottom: BorderSide(color: Colors.grey),
                          right: BorderSide(color: Colors.grey),
                        ),
                      ),
                    },
                  ),

                  const SizedBox(height: 32),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag('Flutter'),
                      _buildTag('Mobile Development'),
                      _buildTag('TMS'),
                      _buildTag('Learning'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Comment section
                  const Text(
                    'Bình luận (${0})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildCommentBox(),

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

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  }

  Widget _buildCommentBox() {
    // Implementation of _buildCommentBox method
    return Container(); // Placeholder, actual implementation needed
  }
}
