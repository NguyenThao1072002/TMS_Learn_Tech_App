import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/domain/usecases/blog_usercase.dart';
import 'package:tms_app/presentation/screens/blog/detail_blog.dart';
import 'package:tms_app/presentation/widgets/blog/blog_card.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  String _selectedCategory = 'Tất cả';
  String? _selectedAuthor;
  List<Map<String, String>> _categories = [
    {'id': 'Tất cả', 'name': 'Tất cả'}
  ];
  List<String> _authors = ['Tất cả'];
  final BlogUsercase _blogUsecase = GetIt.instance<BlogUsercase>();

  // State for expand/collapse
  bool _isTopSectionExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  // State for blog data
  late Future<List<BlogCardModel>> _blogsFuture;
  bool _isLoading = false;
  String? _searchQuery;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  final List<BlogCardModel> _blogs = [];

  // Filtering variables
  String? _categoryIdFilter;
  String? _authorNameFilter;
  bool? _featuredFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Initialize animation controller for expand/collapse
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadCategories();
    _loadAuthors();
    _loadBlogs(refresh: true);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _blogUsecase.getUniqueCategories();
      categories.insert(0, {'id': 'Tất cả', 'name': 'Tất cả'});

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Handle error
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadAuthors() async {
    try {
      final authors = await _blogUsecase.getUniqueAuthors();
      authors.insert(0, 'Tất cả');

      setState(() {
        _authors = authors;
      });
    } catch (e) {
      // Handle error
      print('Error loading authors: $e');
    }
  }

  Future<void> _loadBlogs({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _blogs.clear();
        _hasMore = true;
      }
    });

    try {
      final blogs = await _blogUsecase.getFilteredBlogs(
        searchQuery: _searchQuery,
        categoryId: _categoryIdFilter == 'Tất cả' ? null : _categoryIdFilter,
        authorName: _authorNameFilter == 'Tất cả' ? null : _authorNameFilter,
        featured: _featuredFilter,
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        if (blogs.isEmpty) {
          _hasMore = false;
        } else {
          _blogs.addAll(blogs);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải bài viết: ${e.toString()}')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _categoryIdFilter = _selectedCategory;
      _authorNameFilter = _selectedAuthor;
      _currentPage = 0;
      _blogs.clear();
      _hasMore = true;
    });

    _loadBlogs();
  }

  void _showFilterDialog() {
    String? tempCategoryFilter = _categoryIdFilter;
    String? tempAuthorFilter = _authorNameFilter;
    bool? tempFeaturedFilter = _featuredFilter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Lọc bài viết'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  const Text('Danh mục:'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempCategoryFilter ?? 'Tất cả',
                        onChanged: (value) {
                          setDialogState(() {
                            tempCategoryFilter = value;
                          });
                        },
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'],
                            child: Text(category['name'] ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Author dropdown
                  const Text('Tác giả:'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempAuthorFilter ?? 'Tất cả',
                        onChanged: (value) {
                          setDialogState(() {
                            tempAuthorFilter = value;
                          });
                        },
                        items: _authors.map((author) {
                          return DropdownMenuItem<String>(
                            value: author,
                            child: Text(author),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Featured blogs filter
                  CheckboxListTile(
                    title: const Text('Chỉ hiện bài viết nổi bật'),
                    value: tempFeaturedFilter ?? false,
                    onChanged: (value) {
                      setDialogState(() {
                        tempFeaturedFilter = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _categoryIdFilter = tempCategoryFilter;
                    _authorNameFilter = tempAuthorFilter;
                    _featuredFilter = tempFeaturedFilter;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleTopSection() {
    setState(() {
      _isTopSectionExpanded = !_isTopSectionExpanded;
      if (_isTopSectionExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Blog công nghệ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // Add search icon
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BlogSearchDelegate(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                      _currentPage = 0;
                      _blogs.clear();
                      _hasMore = true;
                    });
                    _loadBlogs();
                  },
                ),
              );
            },
          ),
          // Add filter button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterDialog,
          ),
          // Add expand/collapse button
          IconButton(
            icon: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more, color: Colors.black),
            ),
            onPressed: _toggleTopSection,
          ),
        ],
      ),
      body: Column(
        children: [
          // Expandable top section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              width: double.infinity,
              height: _isTopSectionExpanded ? null : 0.0,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryFilter(),
                ],
              ),
            ),
          ),
          _buildBlogList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài viết...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade500),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = null;
                    });
                    _loadBlogs(refresh: true);
                  },
                )
              : null,
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.isNotEmpty ? value : null;
          });
          _loadBlogs(refresh: true);
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _categoryIdFilter == category['id'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _categoryIdFilter = category['id'];
                _currentPage = 0;
                _blogs.clear();
                _hasMore = true;
              });
              _loadBlogs();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category['name'] ?? '',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlogList() {
    if (_isLoading && _blogs.isEmpty) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_blogs.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.article_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _searchQuery != null && _searchQuery!.isNotEmpty
                    ? 'Không tìm thấy kết quả cho "$_searchQuery"'
                    : 'Không có bài viết nào',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              _hasMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.8) {
            _loadBlogs();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _blogs.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom when loading more items
            if (index == _blogs.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final blog = _blogs[index];

            // Display first item as featured if it's featured blog
            if (index == 0 && blog.featured) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bài viết nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedBlogCard(blog),
                  const SizedBox(height: 24),
                  const Text(
                    'Tất cả bài viết',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            } else {
              return BlogCard(
                blog: blog,
                onTap: (blog) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailBlogScreen(blogId: blog.id),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedBlogCard(BlogCardModel blog) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBlogScreen(blogId: blog.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
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
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.sumary,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          blog.authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${blog.views}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.comment,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${blog.commentCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
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
    );
  }
}

// Search delegate for blog search
class BlogSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  BlogSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      onSearch(query);
      close(context, query);
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý tìm kiếm:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            'Flutter',
            'JavaScript',
            'React Native',
            'Artificial Intelligence',
            'Machine Learning'
          ].map((suggestion) {
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(suggestion),
              onTap: () {
                query = suggestion;
                onSearch(query);
                close(context, query);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
