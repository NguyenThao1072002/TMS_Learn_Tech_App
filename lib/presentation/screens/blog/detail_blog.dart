import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/domain/usecases/blog_usercase.dart';
import 'package:tms_app/presentation/widgets/blog/blog_card.dart';

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
  final BlogUsercase _blogUsecase = GetIt.instance<BlogUsercase>();
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
    print('Đang tải chi tiết blog với ID: ${widget.blogId}');
    _blogFuture = _blogUsecase.getBlogById(widget.blogId);

    // Đăng ký xem bài viết sau khi tải chi tiết
    _incrementBlogView();

    // Cập nhật danh sách bài viết liên quan khi có dữ liệu blog
    _blogFuture.then((blog) {
      if (blog != null) {
        _loadRelatedBlogs(blog.cat_blog_id);
      }
    });
  }

  void _loadRelatedBlogs(String categoryId) {
    _relatedBlogsFuture = _blogUsecase.getRelatedBlogs(categoryId,
        currentBlogId: widget.blogId, size: 5);
  }

  Future<void> _incrementBlogView() async {
    if (!_viewIncremented) {
      // Chờ một chút để người dùng thực sự xem bài viết
      await Future.delayed(const Duration(seconds: 2));
      final result = await _blogUsecase.incrementBlogView(widget.blogId);
      _viewIncremented = result;

      // Nếu đã đếm lượt xem thành công và có dữ liệu blog, cập nhật UI nếu cần
      if (result && mounted) {
        setState(() {
          // Có thể làm mới dữ liệu blog ở đây nếu cần
        });
      }
    }
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
          print('Blog Future state: ${snapshot.connectionState}');
          if (snapshot.hasError) {
            print('Blog Future error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            print('Blog data received: ${snapshot.data?.title}');
          } else {
            print('Không có dữ liệu blog: ${snapshot.data}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lỗi khi tải bài viết',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.red[700], fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                  '${blog.views}',
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

                      _buildRelatedBlogsSection(),
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

  Widget _buildRelatedBlogsSection() {
    return FutureBuilder<List<BlogCardModel>>(
      future: _blogFuture.then((blog) async {
        if (blog != null) {
          return await _blogUsecase.getRelatedBlogs(blog.cat_blog_id,
              currentBlogId: widget.blogId, size: 5);
        }
        return [];
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final relatedBlogs = snapshot.data ?? [];

        if (relatedBlogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bài viết liên quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240, // Chiều cao cố định cho danh sách cuộn ngang
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: relatedBlogs.length,
                itemBuilder: (context, index) {
                  final blog = relatedBlogs[index];
                  return Container(
                    width: 200, // Chiều rộng cố định cho mỗi mục
                    margin: const EdgeInsets.only(right: 12),
                    child: BlogCard(
                      blog: blog,
                      isHorizontal: false,
                      onTapById: () {
                        // Điều hướng đến chi tiết bài viết khi nhấp vào
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBlogScreen(
                              blogId: blog.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
