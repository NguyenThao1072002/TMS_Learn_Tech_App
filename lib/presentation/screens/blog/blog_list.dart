import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tms_app/data/models/blog/blog_card_model.dart';
import 'package:tms_app/data/models/categories/blog_category.dart';
import 'package:tms_app/domain/usecases/blog_usercase.dart';
import 'package:tms_app/domain/usecases/category_usecase.dart';
import 'package:tms_app/presentation/controller/blog_controller.dart';
import 'package:tms_app/presentation/screens/blog/detail_blog.dart';
import 'package:tms_app/presentation/widgets/blog/blog_card.dart';
import 'package:tms_app/presentation/widgets/blog/blog_filter.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late BlogController _blogController;

  // State for expand/collapse
  bool _isTopSectionExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Khởi tạo BlogController từ GetIt
    final blogUsecase = GetIt.instance<BlogUsercase>();
    final categoryUseCase = GetIt.instance<CategoryUseCase>();
    _blogController = BlogController(
      blogUsecase: blogUsecase,
      categoryUseCase: categoryUseCase,
    );

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

    // Load blog categories và blogs
    _loadData();
  }

  Future<void> _loadData() async {
    await _blogController.loadCategories();
    await _blogController.loadBlogs(refresh: true);
  }

  // Hàm refresh danh sách blog
  Future<void> _handleRefresh() async {
    return await _blogController.refresh();
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => BlogCategoryFilterDialog(
        categories: _blogController.categories.value,
        selectedCategoryIds: _blogController.selectedCategoryIds.value,
        onApplyFilter: (selectedIds) {
          _blogController.filterByCategories(selectedIds);
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
    _blogController.dispose();
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
          // Add refresh button
          ValueListenableBuilder<bool>(
            valueListenable: _blogController.isRefreshing,
            builder: (context, isRefreshing, child) {
              return isRefreshing
                  ? Container(
                      width: 48,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: _handleRefresh,
                    );
            },
          ),
          // Add search icon
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BlogSearchDelegate(
                  onSearch: (query) {
                    _blogController.setSearchQuery(query);
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
                  _buildFilterButtons(),
                ],
              ),
            ),
          ),

          // Applied filters display
          _buildAppliedFilters(),

          // Blog list
          ValueListenableBuilder<bool>(
            valueListenable: _blogController.isLoading,
            builder: (context, isLoading, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: _blogController.errorMessage,
                builder: (context, errorMessage, _) {
                  if (errorMessage != null) {
                    return Expanded(
                      child: ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red, size: 48),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Text(
                                      errorMessage,
                                      style: TextStyle(color: Colors.red[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () => _handleRefresh(),
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (isLoading &&
                      _blogController.filteredBlogs.value.isEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSkeletonCard(),
                          );
                        },
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<BlogCardModel>>(
                    valueListenable: _blogController.filteredBlogs,
                    builder: (context, blogs, _) {
                      if (blogs.isEmpty) {
                        return Expanded(
                          child: ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 3,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.article_outlined,
                                          size: 80, color: Colors.grey),
                                      const SizedBox(height: 16),
                                      Text(
                                        _blogController.searchQuery.value !=
                                                    null &&
                                                _blogController.searchQuery
                                                    .value!.isNotEmpty
                                            ? 'Không tìm thấy kết quả cho "${_blogController.searchQuery.value}"'
                                            : 'Không có bài viết nào',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: blogs.length,
                            itemBuilder: (context, index) {
                              final blog = blogs[index];

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
                                return _buildBlogCard(blog, index);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
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
      child: ValueListenableBuilder<List<BlogCategory>>(
        valueListenable: _blogController.categories,
        builder: (context, categories, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ValueListenableBuilder<List<String>>(
                        valueListenable: _blogController.selectedCategoryIds,
                        builder: (context, selectedIds, _) {
                          final isSelected =
                              selectedIds.contains(category.id.toString());
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                if (isSelected) {
                                  _blogController.filterByCategories([]);
                                } else {
                                  _blogController.filterByCategories(
                                      [category.id.toString()]);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue
                                      : _getCategoryColor(category.name)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : _getCategoryColor(category.name)
                                            .withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : _getCategoryColor(category.name),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'công nghệ':
        return Colors.blue;
      case 'lập trình':
        return Colors.purple;
      case 'trí tuệ nhân tạo':
        return Colors.green;
      case 'blockchain':
        return Colors.orange;
      case 'iot':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  void _showAuthorFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: _blogController.authors,
          builder: (context, authors, _) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn tác giả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: authors.length,
                      itemBuilder: (context, index) {
                        final author = authors[index];
                        return ListTile(
                          title: Text(author),
                          onTap: () {
                            Navigator.pop(context);
                            _blogController.filterByAuthor(
                                author == 'Tất cả' ? null : author);
                          },
                          trailing: ValueListenableBuilder<String?>(
                            valueListenable: _blogController.selectedAuthorName,
                            builder: (context, selectedAuthor, _) {
                              return selectedAuthor == author
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          suffixIcon: ValueListenableBuilder<String?>(
            valueListenable: _blogController.searchQuery,
            builder: (context, query, _) {
              return (query != null && query.isNotEmpty)
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade500),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _blogController.setSearchQuery(null);
                        });
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          _blogController.setSearchQuery(value.isNotEmpty ? value : null);
        },
      ),
    );
  }

  // Applied filters display
  Widget _buildAppliedFilters() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _blogController.selectedCategoryIds,
      builder: (context, selectedCategoryIds, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _blogController.selectedAuthorName,
          builder: (context, selectedAuthorName, _) {
            return ValueListenableBuilder<bool?>(
              valueListenable: _blogController.featuredFilter,
              builder: (context, featuredFilter, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _blogController.searchQuery,
                  builder: (context, searchQuery, _) {
                    // Check if any filter is active
                    final hasActiveFilters = selectedCategoryIds.isNotEmpty ||
                        (selectedAuthorName != null &&
                            selectedAuthorName != 'Tất cả') ||
                        featuredFilter == true ||
                        (searchQuery != null && searchQuery.isNotEmpty);

                    if (!hasActiveFilters) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      width: double.infinity,
                      color: Colors.white,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...selectedCategoryIds
                              .map((categoryId) => _buildFilterChip(
                                    label:
                                        'Danh mục: ${_blogController.getCategoryName(categoryId)}',
                                    onRemove: () {
                                      final newList =
                                          List<String>.from(selectedCategoryIds)
                                            ..remove(categoryId);
                                      _blogController
                                          .filterByCategories(newList);
                                    },
                                  )),
                          if (selectedAuthorName != null &&
                              selectedAuthorName != 'Tất cả')
                            _buildFilterChip(
                              label: 'Tác giả: $selectedAuthorName',
                              onRemove: () {
                                _blogController.filterByAuthor(null);
                              },
                            ),
                          if (featuredFilter == true)
                            _buildFilterChip(
                              label: 'Bài viết nổi bật',
                              onRemove: () {
                                _blogController.filterByFeatured(null);
                              },
                            ),
                          if (searchQuery != null && searchQuery.isNotEmpty)
                            _buildFilterChip(
                              label: 'Tìm kiếm: $searchQuery',
                              onRemove: () {
                                _searchController.clear();
                                _blogController.setSearchQuery(null);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lọc bài viết',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      // Filter by category
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danh mục',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<List<String>>(
                              valueListenable:
                                  _blogController.selectedCategoryIds,
                              builder: (context, selectedIds, _) {
                                return ValueListenableBuilder<
                                        List<BlogCategory>>(
                                    valueListenable: _blogController.categories,
                                    builder: (context, categories, _) {
                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          FilterChip(
                                            label: const Text('Tất cả'),
                                            selected: selectedIds.isEmpty,
                                            onSelected: (selected) {
                                              if (selected) {
                                                setModalState(() {
                                                  _blogController
                                                      .filterByCategories([]);
                                                });
                                              }
                                            },
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            selectedColor:
                                                const Color(0xFF3498DB),
                                            labelStyle: TextStyle(
                                              color: selectedIds.isEmpty
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: selectedIds.isEmpty
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          ...categories.map((category) {
                                            final categoryId =
                                                category.id.toString();
                                            final isSelected = selectedIds
                                                .contains(categoryId);
                                            return FilterChip(
                                              label: Text(category.name),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setModalState(() {
                                                  if (selected) {
                                                    _blogController
                                                        .filterByCategories(
                                                            [categoryId]);
                                                  } else {
                                                    _blogController
                                                        .filterByCategories([]);
                                                  }
                                                });
                                              },
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              selectedColor:
                                                  const Color(0xFF3498DB),
                                              labelStyle: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    });
                              }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Filter by author
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tác giả',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<String?>(
                              valueListenable:
                                  _blogController.selectedAuthorName,
                              builder: (context, selectedAuthor, _) {
                                return ValueListenableBuilder<List<String>>(
                                    valueListenable: _blogController.authors,
                                    builder: (context, authors, _) {
                                      return authors.isEmpty
                                          ? const Text(
                                              'Không có tác giả nào để hiển thị')
                                          : Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                FilterChip(
                                                  label: const Text('Tất cả'),
                                                  selected:
                                                      selectedAuthor == null ||
                                                          selectedAuthor ==
                                                              'Tất cả',
                                                  onSelected: (selected) {
                                                    if (selected) {
                                                      setModalState(() {
                                                        _blogController
                                                            .filterByAuthor(
                                                                null);
                                                      });
                                                    }
                                                  },
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  selectedColor:
                                                      const Color(0xFF3498DB),
                                                  labelStyle: TextStyle(
                                                    color: (selectedAuthor ==
                                                                null ||
                                                            selectedAuthor ==
                                                                'Tất cả')
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        (selectedAuthor ==
                                                                    null ||
                                                                selectedAuthor ==
                                                                    'Tất cả')
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                  ),
                                                ),
                                                ...authors
                                                    .where((author) =>
                                                        author != 'Tất cả')
                                                    .map((author) {
                                                  final isSelected =
                                                      selectedAuthor == author;
                                                  return FilterChip(
                                                    label: Text(author),
                                                    selected: isSelected,
                                                    onSelected: (selected) {
                                                      setModalState(() {
                                                        _blogController
                                                            .filterByAuthor(
                                                                selected
                                                                    ? author
                                                                    : null);
                                                      });
                                                    },
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    selectedColor:
                                                        const Color(0xFF3498DB),
                                                    labelStyle: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            );
                                    });
                              }),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Featured blogs filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bài viết nổi bật',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ValueListenableBuilder<bool?>(
                                  valueListenable:
                                      _blogController.featuredFilter,
                                  builder: (context, featuredFilter, _) {
                                    return FilterChip(
                                      label: const Text('Tất cả'),
                                      selected: featuredFilter == null,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          _blogController
                                              .filterByFeatured(null);
                                        });
                                      },
                                      backgroundColor: Colors.grey.shade200,
                                      selectedColor: const Color(0xFF3498DB),
                                      labelStyle: TextStyle(
                                        color: featuredFilter == null
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: featuredFilter == null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }),
                              const SizedBox(width: 8),
                              ValueListenableBuilder<bool?>(
                                  valueListenable:
                                      _blogController.featuredFilter,
                                  builder: (context, featuredFilter, _) {
                                    return FilterChip(
                                      label: const Text('Chỉ bài viết nổi bật'),
                                      selected: featuredFilter == true,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          _blogController.filterByFeatured(
                                              selected ? true : null);
                                        });
                                      },
                                      backgroundColor: Colors.grey.shade200,
                                      selectedColor: const Color(0xFF3498DB),
                                      labelStyle: TextStyle(
                                        color: featuredFilter == true
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: featuredFilter == true
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onRemove}) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
      backgroundColor: Colors.grey.shade200,
      deleteIconColor: Colors.black54,
      labelStyle: const TextStyle(fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildBlogCard(BlogCardModel blog, int index) {
    // Check if the blog post is new (less than 3 days old)
    final isNew = DateTime.now().difference(blog.createdAt).inDays < 3;

    return Stack(
      children: [
        BlogCard(
          blog: blog,
          onTap: (blog) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailBlogScreen(blogId: blog.id),
              ),
            ).then((result) {
              // Cập nhật lượt xem khi quay lại nếu đã xem
              if (result != null && result is Map && result['viewed'] == true) {
                final blogId = result['blogId'] as String;
                _updateBlogViewCount(blogId);
              }
            });
          },
        ),
        if (isNew)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MỚI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedBlogCard(BlogCardModel blog) {
    // Check if the blog post is new (less than 3 days old)
    final isNew = DateTime.now().difference(blog.createdAt).inDays < 3;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailBlogScreen(blogId: blog.id),
              ),
            ).then((result) {
              // Cập nhật lượt xem khi quay lại nếu đã xem
              if (result != null && result is Map && result['viewed'] == true) {
                final blogId = result['blogId'] as String;
                _updateBlogViewCount(blogId);
              }
            });
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
        ),
        if (isNew)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MỚI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức cập nhật lượt xem cho bài viết
  void _updateBlogViewCount(String blogId) {
    setState(() {
      // Cập nhật trong danh sách chính
      final blogIndex = _blogController.allBlogs.value
          .indexWhere((blog) => blog.id == blogId);
      if (blogIndex >= 0) {
        final updatedBlogs =
            List<BlogCardModel>.from(_blogController.allBlogs.value);
        // Tăng số lượt xem sử dụng copyWith
        final blog = updatedBlogs[blogIndex];
        updatedBlogs[blogIndex] = blog.copyWith(views: blog.views + 1);
        _blogController.allBlogs.value = updatedBlogs;
      }

      // Cập nhật trong danh sách lọc
      final filteredBlogIndex = _blogController.filteredBlogs.value
          .indexWhere((blog) => blog.id == blogId);
      if (filteredBlogIndex >= 0) {
        final updatedFilteredBlogs =
            List<BlogCardModel>.from(_blogController.filteredBlogs.value);
        // Tăng số lượt xem sử dụng copyWith
        final blog = updatedFilteredBlogs[filteredBlogIndex];
        updatedFilteredBlogs[filteredBlogIndex] =
            blog.copyWith(views: blog.views + 1);
        _blogController.filteredBlogs.value = updatedFilteredBlogs;
      }
    });
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
