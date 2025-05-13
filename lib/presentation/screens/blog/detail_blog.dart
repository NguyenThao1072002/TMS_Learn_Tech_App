import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/domain/usecases/blog_usecase.dart';
import 'package:tms_app/presentation/widgets/blog/blog_card.dart';
import 'package:tms_app/presentation/widgets/blog/related_blog.dart';

class DetailBlogScreen extends StatefulWidget {
  final String blogId;

  const DetailBlogScreen({Key? key, required this.blogId}) : super(key: key);

  @override
  State<DetailBlogScreen> createState() => _DetailBlogScreenState();
}

class _DetailBlogScreenState extends State<DetailBlogScreen> {
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  final BlogUsecase _blogUsecase = GetIt.instance<BlogUsecase>();
  late Future<BlogCardModel?> _blogFuture;
  bool _viewIncremented = false;
  late Future<List<BlogCardModel>> _relatedBlogsFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBlogDetails();
  }

  void _loadBlogDetails() {
    _blogFuture = _blogUsecase.getBlogById(widget.blogId);

    // Tăng lượt xem trong background mà không cần hiển thị trạng thái loading
    _blogUsecase.incrementBlogView(widget.blogId).then((success) {
      _viewIncremented = success;

      // Nếu thành công, chỉ cập nhật số lượt xem trong UI mà không tải lại dữ liệu
      if (success && mounted) {
        _blogFuture.then((blog) {
          if (blog != null) {
            _loadRelatedBlogs(blog.cat_blog_id);
          }
        });
      }
    });
  }

  void _loadRelatedBlogs(String categoryId) {
    _relatedBlogsFuture = _blogUsecase.getRelatedBlogs(categoryId,
        currentBlogId: widget.blogId, size: 5);
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

  void _shareArticle(BlogCardModel blog) {
    Share.share(
      '${blog.title} - Đọc thêm tại TMS: https://tms.edu.vn/blog/${blog.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
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
          onPressed: () {
            // Truyền lại thông tin blog ID và số lượt xem đã cập nhật
            if (_viewIncremented) {
              Navigator.pop(context, {'blogId': widget.blogId, 'viewed': true});
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleBookmark,
          ),
          FutureBuilder<BlogCardModel?>(
            future: _blogFuture,
            builder: (context, snapshot) {
              return IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black),
                onPressed: snapshot.hasData && snapshot.data != null
                    ? () => _shareArticle(snapshot.data!)
                    : null,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<BlogCardModel?>(
        future: _blogFuture,
        builder: (context, snapshot) {
          // Debug hiển thị trạng thái của Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Lỗi khi tải bài viết: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadBlogDetails();
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy bài viết',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Blog ID: ${widget.blogId}',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadBlogDetails();
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final blog = snapshot.data!;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Image.network(
                    blog.image,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          blog.catergoryName,
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
                        blog.title,
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
                              blog.authorName.isNotEmpty
                                  ? blog.authorName[0].toUpperCase()
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
                                blog.authorName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeago.format(blog.createdAt, locale: 'vi'),
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
                                  // Hiển thị số lượt xem đã tăng nếu thành công
                                  '${_viewIncremented ? blog.views + 1 : blog.views}',
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
                        data: blog.content,
                        style: {
                          'body': Style(
                            fontSize: FontSize(16.0),
                            lineHeight: LineHeight(1.8),
                          )
                        },
                      ),

                      // Bài viết liên quan
                      const SizedBox(height: 32),

                      FutureBuilder<BlogCardModel?>(
                        future: _blogFuture,
                        builder: (context, blogSnapshot) {
                          if (blogSnapshot.hasData &&
                              blogSnapshot.data != null) {
                            final future = _blogUsecase.getRelatedBlogs(
                                blogSnapshot.data!.cat_blog_id,
                                currentBlogId: widget.blogId,
                                size: 5);
                            return RelatedBlog(relatedBlogsFuture: future);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer effect for header image
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.white,
            ),
          ),

          // Shimmer effect for content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 28,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 28,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Metadata shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Content shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      10,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
